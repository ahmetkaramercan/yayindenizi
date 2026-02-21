import '../../../../core/network/api_client.dart';
import '../../../student/domain/entities/student.dart';
import '../../domain/entities/teacher.dart';

class RelationRepository {
  final ApiClient _api;

  RelationRepository(this._api);

  // ─── Student actions ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> addTeacher(String ogretmenKodu) async {
    final data = await _api.post('/relations/teachers', data: {
      'ogretmenKodu': ogretmenKodu,
    });
    return data as Map<String, dynamic>;
  }

  Future<List<Teacher>> getMyTeachers() async {
    final data = await _api.get('/relations/my-teachers');
    final List list = data is List ? data : [];

    return list.map((json) {
      final j = json as Map<String, dynamic>;
      return Teacher(
        id: j['id'],
        adSoyad: j['adSoyad'] ?? '',
        email: j['email'] ?? '',
        ogretmenKodu: j['ogretmenKodu'] ?? '',
        okul: j['okul'],
        il: j['il'],
        ilce: j['ilce'],
      );
    }).toList();
  }

  Future<void> removeTeacher(String teacherId) async {
    await _api.delete('/relations/teachers/$teacherId');
  }

  // ─── Teacher actions ───────────────────────────────────────────────────

  Future<List<Student>> getMyStudents({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final data = await _api.get('/relations/my-students', queryParameters: params);

    // Backend returns paginated: { data: [...], total, page, limit }
    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'];
    } else {
      list = [];
    }

    return list.map((json) {
      final j = json as Map<String, dynamic>;
      return Student(
        id: j['id'],
        adSoyad: j['adSoyad'] ?? '',
        email: j['email'] ?? '',
        il: j['il'],
        ilce: j['ilce'],
      );
    }).toList();
  }

  Future<Map<String, dynamic>> getStudentDetail(String studentId) async {
    final data = await _api.get('/relations/students/$studentId');
    return data as Map<String, dynamic>;
  }

  Future<void> removeStudent(String studentId) async {
    await _api.delete('/relations/students/$studentId');
  }
}
