import 'package:flutter/foundation.dart';
import '../models/student_account.dart';
import '../services/my_account_service.dart';
import '../services/log_service.dart';

class MyAccountProvider extends ChangeNotifier {
  StudentAccount? account;
  bool isLoading = false;
  String? error;

  final MyAccountService _service = MyAccountService();

  Future<void> load(String apiKey) async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      account = await _service.fetchMyAccount(apiKey);
    } catch (e) {
      error = e.toString();
      LogService.instance.error('MyAccountProvider', 'Failed to load: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
