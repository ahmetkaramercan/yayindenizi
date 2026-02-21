import '../../../../core/network/api_client.dart';
import '../../domain/entities/student.dart';
import '../../../teacher/domain/entities/teacher.dart';

class UserRepository {
  final ApiClient _api;

  UserRepository(this._api);

  Future<Student> getStudentProfile() async {
    final data = await _api.get('/users/student/me');
    final map = data as Map<String, dynamic>;
    return Student(
      id: map['id'],
      adSoyad: map['adSoyad'] ?? '',
      email: map['email'] ?? '',
      il: map['il'],
      ilce: map['ilce'],
    );
  }

  Future<Teacher> getTeacherProfile() async {
    final data = await _api.get('/users/teacher/me');
    final map = data as Map<String, dynamic>;
    return Teacher(
      id: map['id'],
      adSoyad: map['adSoyad'] ?? '',
      email: map['email'] ?? '',
      ogretmenKodu: map['ogretmenKodu'] ?? '',
      okul: map['okul'],
      il: map['il'],
      ilce: map['ilce'],
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.patch('/users/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
