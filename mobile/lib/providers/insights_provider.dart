import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/insights_data.dart';
import '../services/insights_service.dart';

enum InsightsLoadState { initial, loading, loaded, notFound, error }

class InsightsProvider with ChangeNotifier {
  static const _cacheKey = 'insights_data_v1';

  final _service = InsightsService();

  InsightsData?     _data;
  InsightsLoadState _state = InsightsLoadState.initial;
  String?           _errorMessage;

  InsightsData?     get data         => _data;
  InsightsLoadState get state        => _state;
  String?           get errorMessage => _errorMessage;

  InsightsProvider() {
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final prefs  = await SharedPreferences.getInstance();
    final stored = prefs.getString(_cacheKey);
    if (stored != null) {
      _data  = InsightsData.fromJson(jsonDecode(stored) as Map<String, dynamic>);
      _state = InsightsLoadState.loaded;
      notifyListeners();
    }
  }

  Future<void> fetchInsights({required String accessToken}) async {
    if (_data == null) {
      _state = InsightsLoadState.loading;
      notifyListeners();
    }

    final result = await _service.getInsights(accessToken: accessToken);

    if (result['success'] == true) {
      _data         = result['data'] as InsightsData;
      _state        = InsightsLoadState.loaded;
      _errorMessage = null;
      _saveToCache(_data!);
    } else if (result['error'] == 'not_found') {
      if (_data == null) {
        _state        = InsightsLoadState.notFound;
        _errorMessage = result['message'] as String?;
      }
    } else {
      if (_data == null) {
        _state        = InsightsLoadState.error;
        _errorMessage = result['message'] as String?;
      }
    }

    notifyListeners();
  }

  Future<void> _saveToCache(InsightsData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
  }
}
