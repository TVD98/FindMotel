class Province {
  final int code;
  final String name;
  final List<District> districts;

  Province({required this.code, required this.name, required this.districts});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'],
      name: json['name'] ?? '',
      districts:
          (json['districts'] as List<dynamic>?)
              ?.map((e) => District.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class District {
  final int code;
  final String name;
  final List<Ward> wards;

  District({required this.code, required this.name, required this.wards});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      code: json['code'],
      name: json['name'] ?? '',
      wards:
          (json['wards'] as List<dynamic>?)
              ?.map((e) => Ward.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Ward {
  final int code;
  final String name;

  Ward({required this.code, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(code: json['code'], name: json['name'] ?? '');
  }
}
