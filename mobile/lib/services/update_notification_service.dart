import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';

class UpdateNotificationService {
  static const _notificationId = 42;
  static const _prefKey = 'last_update_notified_version';
  static const _sessionCountKey = 'app_session_count';

  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    // Handle tap from killed state — app relaunched by a notification tap.
    final launchDetails = await _notifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final url = launchDetails?.notificationResponse?.payload;
      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Skip permission dialog on first session — let the user explore first.
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getInt(_sessionCountKey) ?? 0;
    await prefs.setInt(_sessionCountKey, sessions + 1);
    if (sessions < 1) return;

    if (Platform.isAndroid) {
      final plugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (plugin == null) return;
      final granted = await plugin.areNotificationsEnabled() ?? false;
      if (granted) return;
      if (!context.mounted) return;
      final proceed = await _showRationale(context);
      if (proceed) await plugin.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final plugin = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (plugin == null) return;
      if (!context.mounted) return;
      final proceed = await _showRationale(context);
      if (proceed) {
        await plugin.requestPermissions(alert: true, badge: true, sound: true);
      }
    }
  }

  Future<void> checkAndNotify() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final result = Platform.isIOS
        ? await _fetchAppStoreVersion(packageInfo.packageName)
        : await _fetchPlayStoreVersion(packageInfo.packageName);
    if (result == null) return;

    final storeVersion = result['version']!;
    final storeUrl = result['store_url']!;
    if (!_isNewer(storeVersion, packageInfo.version)) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_prefKey) == storeVersion) return;

    if (Platform.isAndroid) {
      final plugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = plugin == null || (await plugin.areNotificationsEnabled() ?? false);
      if (!granted) return;
    }

    await _fire(storeVersion, storeUrl);
    await prefs.setString(_prefKey, storeVersion);
  }

  // Calls the Rails backend which proxies the Google Play Developer API.
  // Falls back silently if the backend is unreachable or returns an error.
  Future<Map<String, String>?> _fetchPlayStoreVersion(String packageName) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/app_version');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final version = data['version'] as String?;
      final storeUrl = data['store_url'] as String?;
      if (version == null || storeUrl == null) return null;
      return {'version': version, 'store_url': storeUrl};
    } catch (_) {
      return null;
    }
  }

  // iTunes Lookup API — documented, stable, no authentication required.
  Future<Map<String, String>?> _fetchAppStoreVersion(String bundleId) async {
    try {
      final url = Uri.parse(
        'https://itunes.apple.com/lookup?bundleId=$bundleId&country=us',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return null;
      final app = results.first as Map<String, dynamic>;
      final version = app['version'] as String?;
      final storeUrl = app['trackViewUrl'] as String?;
      if (version == null || storeUrl == null) return null;
      return {'version': version, 'store_url': storeUrl};
    } catch (_) {
      return null;
    }
  }

  bool _isNewer(String store, String installed) {
    final s = store.split('.').map(int.tryParse).toList();
    final i = installed.split('.').map(int.tryParse).toList();
    for (var idx = 0; idx < 3; idx++) {
      final sv = idx < s.length ? (s[idx] ?? 0) : 0;
      final iv = idx < i.length ? (i[idx] ?? 0) : 0;
      if (sv > iv) return true;
      if (sv < iv) return false;
    }
    return false;
  }

  Future<void> _fire(String version, String storeUrl) async {
    final platform = Platform.isIOS ? 'App Store' : 'Play Store';
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'app_updates',
        'App Updates',
        channelDescription: 'Notifications for new app versions',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _notifications.show(
      _notificationId,
      'New version available',
      'Version $version is available on the $platform.',
      details,
      payload: storeUrl,
    );
  }

  static void _onTap(NotificationResponse response) {
    final url = response.payload;
    if (url != null) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<bool> _showRationale(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stay up to date'),
        content: const Text(
          'Allow this app to send you notifications so you know '
          'when a new version is available.\n\n'
          "If you deny, you won't be notified about updates and may miss "
          'important improvements or bug fixes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
