class Partner {
  final int? id;
  final String name;
  final String? type; // GAF, ambassade, ONG

  const Partner({this.id, required this.name, this.type});

  factory Partner.fromMap(Map<String, Object?> map) => Partner(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: map['type'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
      };
}
