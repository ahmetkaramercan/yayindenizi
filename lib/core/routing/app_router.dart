import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../storage/token_storage.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/student_register_page.dart';
import '../../features/auth/presentation/pages/teacher_register_page.dart';
import '../../features/student/presentation/pages/student_home_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/student/presentation/pages/paragraf_kocu/level_selection_page.dart';
import '../../features/student/presentation/pages/paragraf_kocu/section_test_list_page.dart';
import '../../features/student/presentation/pages/paragraf_kocu/test_page.dart';
import '../../features/student/presentation/pages/paragraf_kocu/analysis_page.dart';
import '../../features/student/domain/entities/book.dart';
import '../../features/student/presentation/pages/deneme_kitaplari/mock_test_list_page.dart';
import '../../features/student/presentation/pages/deneme_kitaplari/mock_test_page.dart';
import '../../features/student/presentation/pages/deneme_kitaplari/mock_test_result_page.dart';
import '../../features/student/presentation/pages/deneme_kitaplari/mock_test_analysis_page.dart';
import '../../features/student/presentation/pages/konu_kitaplari/topic_list_page.dart';
import '../../features/student/presentation/pages/konu_kitaplari/topic_test_list_page.dart';
import '../../features/student/presentation/pages/konu_kitaplari/topic_test_page.dart';
import '../../features/student/presentation/pages/konu_kitaplari/topic_test_result_page.dart';
import '../../features/student/presentation/pages/konu_kitaplari/topic_analysis_page.dart';
import '../../features/student/presentation/pages/analysis/student_analysis_page.dart';
import '../../features/teacher/presentation/pages/teacher_dashboard_page.dart';
import '../../features/teacher/presentation/pages/student_analysis_page.dart';
import '../../features/teacher/presentation/pages/student_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final storage = sl<TokenStorage>();
    final isLoggedIn = storage.isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation.startsWith('/register');

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) {
      final role = storage.userRole;
      return role == 'TEACHER' ? '/teacher/dashboard' : '/student/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register/student',
      name: 'student-register',
      builder: (context, state) => const StudentRegisterPage(),
    ),
    GoRoute(
      path: '/register/teacher',
      name: 'teacher-register',
      builder: (context, state) => const TeacherRegisterPage(),
    ),
    GoRoute(
      path: '/student/home',
      name: 'student-home',
      builder: (context, state) => const StudentHomePage(),
    ),
    GoRoute(
      path: '/student/dashboard',
      name: 'student-dashboard',
      builder: (context, state) => const StudentDashboardPage(),
    ),
    GoRoute(
      path: '/teacher/dashboard',
      name: 'teacher-dashboard',
      builder: (context, state) => const TeacherDashboardPage(),
    ),
    GoRoute(
      path: '/student/book-sections',
      name: 'book-sections',
      builder: (context, state) {
        final book = state.extra as Book;
        return LevelSelectionPage(book: book);
      },
    ),
    GoRoute(
      path: '/student/section-tests',
      name: 'section-tests',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SectionTestListPage(
          sectionId: extra['sectionId'] as String,
          sectionTitle: extra['sectionTitle'] as String,
          bookTitle: extra['bookTitle'] as String,
        );
      },
    ),
    GoRoute(
      path: '/student/paragraf-kocu/test',
      name: 'paragraf-kocu-test',
      builder: (context, state) {
        final testId = state.extra as String? ?? '';
        return TestPage(testId: testId);
      },
    ),
    GoRoute(
      path: '/student/paragraf-kocu/analysis',
      name: 'paragraf-kocu-analysis',
      builder: (context, state) => const AnalysisPage(),
    ),
    GoRoute(
      path: '/student/deneme-kitaplari',
      name: 'deneme-kitaplari-list',
      builder: (context, state) => const MockTestListPage(),
    ),
    GoRoute(
      path: '/student/deneme-kitaplari/test',
      name: 'deneme-kitaplari-test',
      builder: (context, state) {
        final testId = state.extra as String? ?? '';
        return MockTestPage(testId: testId);
      },
    ),
    GoRoute(
      path: '/student/deneme-kitaplari/result',
      name: 'deneme-kitaplari-result',
      builder: (context, state) => const MockTestResultPage(),
    ),
    GoRoute(
      path: '/student/deneme-kitaplari/analysis',
      name: 'deneme-kitaplari-analysis',
      builder: (context, state) => const MockTestAnalysisPage(),
    ),
    GoRoute(
      path: '/student/konu-kitaplari',
      name: 'konu-kitaplari-list',
      builder: (context, state) => const TopicListPage(),
    ),
    GoRoute(
      path: '/student/konu-kitaplari/topic',
      name: 'konu-kitaplari-topic',
      builder: (context, state) {
        final topicId = state.extra as String? ?? '';
        return TopicTestListPage(topicId: topicId);
      },
    ),
    GoRoute(
      path: '/student/konu-kitaplari/test',
      name: 'konu-kitaplari-test',
      builder: (context, state) {
        final testId = state.extra as String? ?? '';
        return TopicTestPage(testId: testId);
      },
    ),
    GoRoute(
      path: '/student/konu-kitaplari/test-result',
      name: 'konu-kitaplari-test-result',
      builder: (context, state) => const TopicTestResultPage(),
    ),
    GoRoute(
      path: '/student/konu-kitaplari/topic-analysis',
      name: 'konu-kitaplari-topic-analysis',
      builder: (context, state) {
        final topicId = state.extra as String? ?? '';
        return TopicAnalysisPage(topicId: topicId);
      },
    ),
    GoRoute(
      path: '/student/analysis',
      name: 'student-analysis',
      builder: (context, state) => const StudentAnalysisPage(),
    ),
    GoRoute(
      path: '/teacher/student-analysis',
      name: 'teacher-student-analysis',
      builder: (context, state) => const TeacherStudentAnalysisPage(),
    ),
    GoRoute(
      path: '/teacher/student-detail',
      name: 'teacher-student-detail',
      builder: (context, state) {
        final studentId = state.extra as String? ?? '';
        return StudentDetailPage(studentId: studentId);
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const StudentHomePage(),
    ),
  ],
);

