import '../../../../core/network/api_client.dart';
import '../models/city_model.dart';
import '../models/district_model.dart';

class CitiesRepository {
  final ApiClient _api;

  CitiesRepository(this._api);

  Future<List<CityModel>> getCities({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final data = await _api.get('/cities', queryParameters: params);
    final list = data is List ? data : [];
    return list
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DistrictModel>> getDistricts({
    required String cityId,
    String? search,
  }) async {
    final params = <String, dynamic>{'cityId': cityId};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final data = await _api.get('/cities/districts', queryParameters: params);
    final list = data is List ? data : [];
    return list
        .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
