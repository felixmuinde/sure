import 'package:flutter/foundation.dart';
import '../models/insights_data.dart';
import '../services/insights_service.dart';

enum InsightsLoadState { initial, loading, loaded, notFound, error }

class InsightsProvider with ChangeNotifier {
  final _service = InsightsService();

  InsightsData?     _data;
  InsightsLoadState _state = InsightsLoadState.initial;
  String?           _errorMessage;

  InsightsData?     get data         => _data;
  InsightsLoadState get state        => _state;
  String?           get errorMessage => _errorMessage;

  Future<void> fetchInsights({required String accessToken}) async {
    _state = InsightsLoadState.loading;
    notifyListeners();

    final result = await _service.getInsights(accessToken: accessToken);

    if (result['success'] == true) {
      _data         = result['data'] as InsightsData;
      _state        = InsightsLoadState.loaded;
      _errorMessage = null;
    } else if (result['error'] == 'not_found') {
      _state        = InsightsLoadState.notFound;
      _errorMessage = result['message'] as String?;
    } else {
      _state        = InsightsLoadState.error;
      _errorMessage = result['message'] as String?;
    }

    notifyListeners();
  }
}
