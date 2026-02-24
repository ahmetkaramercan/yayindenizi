import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/city_model.dart';
import '../../data/models/district_model.dart';
import '../../data/repositories/cities_repository.dart';

final citiesRepositoryProvider = Provider<CitiesRepository>((ref) {
  return sl<CitiesRepository>();
});

final citiesProvider = FutureProvider.family<List<CityModel>, String?>((ref, search) async {
  final repo = ref.watch(citiesRepositoryProvider);
  return repo.getCities(search: search?.isEmpty == true ? null : search);
});

final districtsProvider = FutureProvider.family<List<DistrictModel>, ({String cityId, String? search})>((ref, params) async {
  final repo = ref.watch(citiesRepositoryProvider);
  return repo.getDistricts(
    cityId: params.cityId,
    search: params.search?.isEmpty == true ? null : params.search,
  );
});
