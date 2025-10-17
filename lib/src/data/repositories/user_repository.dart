import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../local/db_helper.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class UserRepository {
  final DbHelper _dbHelper = DbHelper.instance;

  // Create a new user
  Future<int> createUser(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', orderBy: 'name ASC');
    
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Get active users
  Future<List<User>> getActiveUsers() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Get users by role
  Future<List<User>> getUsersByRole(UserRole role) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'role = ? AND isActive = ?',
      whereArgs: [role.name, 1],
      orderBy: 'name ASC',
    );
    
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user (soft delete)
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Permanently delete user
  Future<int> permanentlyDeleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Authenticate user
  Future<User?> authenticateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null && user.isActive) {
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash == hashedPassword) {
        return user;
      }
    }
    return null;
  }

  // Change password
  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    final user = await getUserById(userId);
    if (user != null) {
      final hashedOldPassword = _hashPassword(oldPassword);
      if (user.passwordHash == hashedOldPassword) {
        final hashedNewPassword = _hashPassword(newPassword);
        final updatedUser = user.copyWith(
          passwordHash: hashedNewPassword,
          updatedAt: DateTime.now(),
        );
        await updateUser(updatedUser);
        return true;
      }
    }
    return false;
  }

  // Reset password (admin only)
  Future<bool> resetPassword(int userId, String newPassword) async {
    final user = await getUserById(userId);
    if (user != null) {
      final hashedPassword = _hashPassword(newPassword);
      final updatedUser = user.copyWith(
        passwordHash: hashedPassword,
        updatedAt: DateTime.now(),
      );
      await updateUser(updatedUser);
      return true;
    }
    return false;
  }

  // Update user role
  Future<bool> updateUserRole(int userId, UserRole newRole) async {
    final user = await getUserById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(
        role: newRole,
        updatedAt: DateTime.now(),
      );
      await updateUser(updatedUser);
      return true;
    }
    return false;
  }

  // Toggle user active status
  Future<bool> toggleUserStatus(int userId) async {
    final user = await getUserById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(
        isActive: !user.isActive,
        updatedAt: DateTime.now(),
      );
      await updateUser(updatedUser);
      return true;
    }
    return false;
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // Get user count by role
  Future<Map<UserRole, int>> getUserCountByRole() async {
    final users = await getAllUsers();
    final counts = <UserRole, int>{};
    
    for (final role in UserRole.values) {
      counts[role] = users.where((user) => user.role == role).length;
    }
    
    return counts;
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create default admin user
  Future<void> createDefaultAdmin() async {
    final existingAdmin = await getUserByEmail('admin@onesave.ci');
    if (existingAdmin == null) {
      final admin = User(
        name: 'Administrateur',
        email: 'admin@onesave.ci',
        role: UserRole.admin,
        passwordHash: _hashPassword('admin123'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
      await createUser(admin);
    }
  }
}
