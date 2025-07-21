class FilterOption {
  final String id;
  final String name;

  FilterOption({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  FilterOption copyWith({String? id, String? name}) {
    return FilterOption(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}