class Beneficiary {
  final int? id;
  final String fullName;
  final String? gender;
  final int? age;
  final String? segment; // jeune/femme/cinéaste

  const Beneficiary({this.id, required this.fullName, this.gender, this.age, this.segment});

  factory Beneficiary.fromMap(Map<String, Object?> map) => Beneficiary(
        id: map['id'] as int?,
        fullName: map['fullName'] as String,
        gender: map['gender'] as String?,
        age: map['age'] as int?,
        segment: map['segment'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'gender': gender,
        'age': age,
        'segment': segment,
      };
}
