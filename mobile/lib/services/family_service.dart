import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class FamilyService {
  Future<Map<String, dynamic>> assignFamily({
    required String accessToken,
    required String countryCode,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/family_assignment');

      final response = await http.post(
        url,
        headers: {
          ...ApiConfig.getAuthHeaders(accessToken),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'country_code': countryCode}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true, 'family': jsonDecode(response.body)['family']};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Session expired. Please login again.'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'No family found for country $countryCode'};
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'error': body['error'] ?? 'Failed to assign family'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
