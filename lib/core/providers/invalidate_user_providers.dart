import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/student/presentation/providers/student_home_provider.dart';
import '../../features/student/presentation/providers/student_dashboard_provider.dart';
import '../../features/student/presentation/providers/paragraf_kocu_provider.dart';
import '../../features/student/presentation/providers/test_provider.dart';
import '../../features/student/presentation/providers/topic_provider.dart';
import '../../features/student/presentation/providers/mock_test_provider.dart';
import '../../features/student/presentation/providers/mock_test_analysis_provider.dart';
import '../../features/student/presentation/providers/student_analysis_provider.dart';
import '../../features/student/presentation/providers/book_analysis_provider.dart';
import '../../features/student/presentation/providers/section_analysis_provider.dart';
import '../../features/student/presentation/providers/add_teacher_provider.dart';
import '../../features/teacher/presentation/providers/teacher_dashboard_provider.dart';
import '../../features/teacher/presentation/providers/teacher_student_detail_provider.dart';
import '../../features/teacher/presentation/providers/teacher_student_analysis_provider.dart';

/// Provider that returns a function to invalidate all user-specific providers.
/// Call the returned function on login success and logout to prevent showing previous user's data.
final invalidateUserProvidersProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(studentHomeProvider);
    ref.invalidate(studentDashboardProvider);
    ref.invalidate(paragrafKocuProvider);
    ref.invalidate(testProvider);
    ref.invalidate(topicProvider);
    ref.invalidate(mockTestProvider);
    ref.invalidate(mockTestAnalysisProvider);
    ref.invalidate(studentAnalysisProvider);
    ref.invalidate(bookAnalysisProvider);
    ref.invalidate(sectionAnalysisProvider);
    ref.invalidate(addTeacherProvider);
    ref.invalidate(teacherDashboardProvider);
    ref.invalidate(teacherStudentDetailProvider);
    ref.invalidate(teacherStudentAnalysisProvider);
  };
});
