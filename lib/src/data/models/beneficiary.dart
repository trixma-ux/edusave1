class Beneficiary {
  final int? id;
  final String fullName;
  final String? gender;
  final int? age;
  final String? segment; // jeune/femme/cinéaste
  final DateTime createdAt;
  final DateTime updatedAt;

  const Beneficiary({
    this.id, 
    required this.fullName, 
    this.gender, 
    this.age, 
    this.segment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Beneficiary.fromMap(Map<String, Object?> map) => Beneficiary(
        id: map['id'] as int?,
        fullName: map['fullName'] as String,
        gender: map['gender'] as String?,
        age: map['age'] as int?,
        segment: map['segment'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  factory Beneficiary.fromJson(Map<String, dynamic> json) => Beneficiary(
        id: json['id'] as int?,
        fullName: json['fullName'] as String,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        segment: json['segment'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'gender': gender,
        'age': age,
        'segment': segment,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'gender': gender,
        'age': age,
        'segment': segment,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
