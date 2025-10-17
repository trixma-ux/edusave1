class User {
  final int? id;
  final String name;
  final String? email;
  final String role; // ADMIN, MEMBRE
  final String passwordHash;

  const User({this.id, required this.name, this.email, required this.role, required this.passwordHash});

  User copyWith({int? id, String? name, String? email, String? role, String? passwordHash}) => User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        passwordHash: passwordHash ?? this.passwordHash,
      );

  factory User.fromMap(Map<String, Object?> map) => User(
        id: map['id'] as int?,
        name: map['name'] as String,
        email: map['email'] as String?,
        role: map['role'] as String,
        passwordHash: map['passwordHash'] as String,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'passwordHash': passwordHash,
      };
}
