class Catalog {
  List<String> types;
  List<String> texturies;
  List<String> amenities;

  Catalog({
    required this.types,
    required this.texturies,
    required this.amenities,
  });

  factory Catalog.fromMap(Map<String, dynamic> map) {
    return Catalog(
      types: List<String>.from(map['types'] as List),
      texturies: List<String>.from(map['texturies'] as List),
      amenities: List<String>.from(map['amenities'] as List),
    );
  }
}
