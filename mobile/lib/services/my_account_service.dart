import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_account.dart';
import 'api_config.dart';
import 'log_service.dart';

class MyAccountService {
  Future<StudentAccount?> fetchMyAccount(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/my_account');

    final response = await http.get(
      url,
      headers: {
        ...ApiConfig.getAuthHeaders(token),
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    LogService.instance.debug('MyAccountService', 'Response ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return StudentAccount.fromJson(data);
    }

    if (response.statusCode == 404 || response.statusCode == 503) {
      return null;
    }

    throw Exception('Unexpected response ${response.statusCode}: ${response.body}');
  }
}
