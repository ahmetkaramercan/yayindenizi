import '../../../../core/network/api_client.dart';

class AnalyticsRepository {
  final ApiClient _api;

  AnalyticsRepository(this._api);

  Future<Map<String, dynamic>> getMyOverview() async {
    final data = await _api.get('/analytics/my/overview');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyFull({String? bookId}) async {
    final params = <String, dynamic>{};
    if (bookId != null) params['bookId'] = bookId;
    final data = await _api.get('/analytics/my/full', queryParameters: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMySectionAnalysis(String sectionId) async {
    final data = await _api.get('/analytics/my/section/$sectionId');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentOverview(String studentId) async {
    final data = await _api.get('/analytics/student/$studentId/overview');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentFull(String studentId, {String? bookId}) async {
    final params = <String, dynamic>{};
    if (bookId != null) params['bookId'] = bookId;
    final data = await _api.get(
      '/analytics/student/$studentId/full',
      queryParameters: params,
    );
    return data as Map<String, dynamic>;
  }
}
