import '../../../../core/network/api_client.dart';

class AnalyticsRepository {
  final ApiClient _api;

  AnalyticsRepository(this._api);

  Future<Map<String, dynamic>> getMyOverview() async {
    final data = await _api.get('/analytics/my/overview');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyFull() async {
    final data = await _api.get('/analytics/my/full');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentOverview(String studentId) async {
    final data = await _api.get('/analytics/student/$studentId/overview');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentFull(String studentId) async {
    final data = await _api.get('/analytics/student/$studentId/full');
    return data as Map<String, dynamic>;
  }
}
