import 'user_role.dart';

class User {
  final int? id;
  final String name;
  final String? email;
  final UserRole role;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const User({
    this.id, 
    required this.name, 
    this.email, 
    required this.role, 
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  User copyWith({
    int? id, 
    String? name, 
    String? email, 
    UserRole? role, 
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        passwordHash: passwordHash ?? this.passwordHash,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  /// Lecture tolérante : le schéma SQLite local (`users`) ne contient pas
  /// forcément `createdAt`, `updatedAt` ni `isActive`, et le rôle peut être
  /// stocké en majuscules (ex. « ADMIN »).
  factory User.fromMap(Map<String, Object?> map) {
    DateTime parseDate(Object? v) =>
        (v is String ? DateTime.tryParse(v) : null) ?? DateTime.now();
    final roleName = (map['role'] as String?)?.toLowerCase();
    final active = map['isActive'];
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == roleName,
        orElse: () => UserRole.user,
      ),
      passwordHash: map['passwordHash'] as String,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      isActive: active == null || active == 1 || active == true,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int?,
        name: json['name'] as String,
        email: json['email'] as String?,
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.user,
        ),
        passwordHash: json['passwordHash'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isActive': isActive ? 1 : 0,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isActive': isActive,
      };

  bool hasPermission(String permission) {
    return role.hasPermission(permission);
  }
}
