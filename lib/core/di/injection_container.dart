import 'package:get_it/get_it.dart';

/// Dependency Injection container
/// Features eklendikçe buraya servisler eklenecek
final sl = GetIt.instance;

Future<void> init() async {
  // Core dependencies
  // Örnek: sl.registerLazySingleton(() => NetworkInfoImpl());

  // Features
  // Student feature dependencies
  // Teacher feature dependencies
}

