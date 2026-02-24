class DistrictModel {
  final String id;
  final String name;

  const DistrictModel({required this.id, required this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}
