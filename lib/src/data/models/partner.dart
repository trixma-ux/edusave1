class Partner {
  final int? id;
  final String name;
  final String? type; // GAF, ambassade, ONG
  final DateTime createdAt;
  final DateTime updatedAt;

  const Partner({
    this.id, 
    required this.name, 
    this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Partner.fromMap(Map<String, Object?> map) => Partner(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: map['type'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
        id: json['id'] as int?,
        name: json['name'] as String,
        type: json['type'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
