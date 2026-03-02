import '../../../../core/network/api_client.dart';
import '../../domain/entities/classroom.dart';
import '../models/classroom_model.dart';

class ClassroomRepository {
  final ApiClient _api;

  ClassroomRepository(this._api);

  // ─── Teacher actions ────────────────────────────────────────────────────

  Future<Classroom> createClassroom(String name) async {
    final data = await _api.post('/classrooms', data: {'name': name});
    return ClassroomModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Classroom>> getMyClassrooms() async {
    final data = await _api.get('/classrooms');
    final list = data is List ? data : (data as Map<String, dynamic>)['data'] as List? ?? [];
    return list.map((j) => ClassroomModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getClassroomDetail(
    String classroomId, {
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final data = await _api.get('/classrooms/$classroomId', queryParameters: params);
    return data as Map<String, dynamic>;
  }

  Future<Classroom> updateClassroom(String classroomId, String name) async {
    final data = await _api.patch('/classrooms/$classroomId', data: {'name': name});
    return ClassroomModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteClassroom(String classroomId) async {
    await _api.delete('/classrooms/$classroomId');
  }

  Future<String> regenerateCode(String classroomId) async {
    final data = await _api.post('/classrooms/$classroomId/regenerate-code', data: {});
    return (data as Map<String, dynamic>)['code'] as String;
  }

  Future<Map<String, dynamic>> getStudentInClassroom(
    String classroomId,
    String studentId,
  ) async {
    final data = await _api.get('/classrooms/$classroomId/students/$studentId');
    return data as Map<String, dynamic>;
  }

  Future<void> removeStudentFromClassroom(String classroomId, String studentId) async {
    await _api.delete('/classrooms/$classroomId/students/$studentId');
  }

  // ─── Student actions ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> joinClassroom(String code) async {
    final data = await _api.post('/classrooms/join', data: {'code': code});
    return data as Map<String, dynamic>;
  }

  Future<List<Classroom>> getStudentClassrooms() async {
    final data = await _api.get('/classrooms/my-classrooms');
    final list = data is List ? data : (data as Map<String, dynamic>)['data'] as List? ?? [];
    return list.map((j) => ClassroomModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> leaveClassroom(String classroomId) async {
    await _api.delete('/classrooms/my-classrooms/$classroomId');
  }
}
