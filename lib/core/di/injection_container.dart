import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/token_storage.dart';
import '../network/api_client.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/cities/data/repositories/cities_repository.dart';
import '../../features/student/data/repositories/book_repository.dart';
import '../../features/student/data/repositories/test_repository.dart';
import '../../features/student/data/repositories/analytics_repository.dart';
import '../../features/student/data/repositories/user_repository.dart';
import '../../features/teacher/data/repositories/relation_repository.dart';
import '../../features/teacher/data/repositories/classroom_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();

  // Core
  sl.registerSingleton<TokenStorage>(TokenStorage(prefs));
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<ApiClient>(), sl<TokenStorage>()),
  );
  sl.registerLazySingleton<CitiesRepository>(
    () => CitiesRepository(sl<ApiClient>()),
  );
  sl.registerLazySingleton<BookRepository>(
    () => BookRepository(sl<ApiClient>()),
  );
  sl.registerLazySingleton<TestRepository>(
    () => TestRepository(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepository(sl<ApiClient>()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(sl<ApiClient>()),
  );
  sl.registerLazySingleton<RelationRepository>(
    () => RelationRepository(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ClassroomRepository>(
    () => ClassroomRepository(sl<ApiClient>()),
  );
}
