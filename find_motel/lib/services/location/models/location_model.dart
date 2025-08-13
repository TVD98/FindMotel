class Location {
  final String id;
  final String name;
  final String fullName;
  final String? latitude;
  final String? longitude;

  Location({
    required this.id,
    required this.name,
    required this.fullName,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );
  }
}