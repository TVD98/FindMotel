class Province {
  final String id;
  final String name;
  final List<Unit> units;

  Province({required this.id, required this.name, required this.units});

  Province copyWith(List<Unit>? units) => Province(id: id, name: name, units: units ?? this.units);

  Province copyWithChildren(String districtId, List<Unit> wards) {
    return Province(
      id: id,
      name: name,
      units: units.map((e) => e.id == districtId ? e.copyWith(wards) : e).toList(),
    );
  }
}

class Unit {
  final String id;
  final String name;
  final List<Unit> units;

  Unit({required this.id, required this.name, required this.units});

  Unit copyWith(List<Unit>? units) => Unit(id: id, name: name, units: units ?? this.units);
}
