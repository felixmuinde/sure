import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/insights_data.dart';
import 'api_config.dart';

class InsightsService {
  Future<Map<String, dynamic>> getInsights({required String accessToken}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/insights');
      final response = await http.get(
        url,
        headers: ApiConfig.getAuthHeaders(accessToken),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'data': InsightsData.fromJson(jsonDecode(response.body))};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'not_found',
          'message': 'No ISA data found for your account. Contact support.',
        };
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'error': body['error'] ?? 'unknown',
          'message': body['message'] ?? 'Unable to load ISA data.',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'network_error', 'message': e.toString()};
    }
  }
}
