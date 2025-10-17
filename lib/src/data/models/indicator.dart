class Indicator {
  final int? id;
  final int projectId;
  final String name;
  final double value;
  final String? unit;

  const Indicator({this.id, required this.projectId, required this.name, required this.value, this.unit});

  factory Indicator.fromMap(Map<String, Object?> map) => Indicator(
        id: map['id'] as int?,
        projectId: map['projectId'] as int,
        name: map['name'] as String,
        value: (map['value'] as num).toDouble(),
        unit: map['unit'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'projectId': projectId,
        'name': name,
        'value': value,
        'unit': unit,
      };
}
