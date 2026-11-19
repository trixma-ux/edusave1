import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user.dart';
import '../data/models/user_role.dart';
import '../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier(ref.read(userRepositoryProvider));
});

final usersProvider = FutureProvider<List<User>>((ref) async {
  final userRepository = ref.read(userRepositoryProvider);
  return await userRepository.getAllUsers();
});

final userManagementProvider = StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  return UserManagementNotifier(ref.read(userRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<User?> {
  final UserRepository _userRepository;

  CurrentUserNotifier(this._userRepository) : super(null);

  Future<bool> login(String email, String password) async {
    final user = await _userRepository.authenticateUser(email, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  /// Définit l'utilisateur connecté (après authentification réussie).
  void setUser(User user) => state = user;

  void logout() {
    state = null;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (state != null) {
      final success = await _userRepository.changePassword(
        state!.id!,
        oldPassword,
        newPassword,
      );
      if (success) {
        // Refresh current user data
        final updatedUser = await _userRepository.getUserById(state!.id!);
        if (updatedUser != null) {
          state = updatedUser;
        }
      }
      return success;
    }
    return false;
  }

  bool hasPermission(String permission) {
    return state?.hasPermission(permission) ?? false;
  }

  bool isAdmin() {
    return state?.role == UserRole.admin;
  }

  bool isManager() {
    return state?.role == UserRole.manager;
  }

  bool isUser() {
    return state?.role == UserRole.user;
  }
}

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final UserRepository _userRepository;

  UserManagementNotifier(this._userRepository) : super(UserManagementState.initial()) {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final users = await _userRepository.getAllUsers();
      state = state.copyWith(
        users: users,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final user = User(
        name: name,
        email: email,
        role: role,
        passwordHash: '', // Will be set by repository
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
      
      await _userRepository.createUser(user);
      await _loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateUser(
    int userId, {
    required String name,
    required String email,
    required UserRole role,
  }) async {
    try {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          name: name,
          email: email,
          role: role,
          updatedAt: DateTime.now(),
        );
        await _userRepository.updateUser(updatedUser);
        await _loadUsers();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _userRepository.deleteUser(userId);
      await _loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleUserStatus(int userId) async {
    try {
      await _userRepository.toggleUserStatus(userId);
      await _loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> changeUserRole(int userId, UserRole newRole) async {
    try {
      await _userRepository.updateUserRole(userId, newRole);
      await _loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetPassword(int userId, String newPassword) async {
    try {
      await _userRepository.resetPassword(userId, newPassword);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await _loadUsers();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final users = await _userRepository.searchUsers(query);
      state = state.copyWith(
        users: users,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class UserManagementState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  UserManagementState({
    required this.users,
    required this.isLoading,
    this.error,
  });

  factory UserManagementState.initial() => UserManagementState(
    users: [],
    isLoading: false,
  );

  UserManagementState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get hasError => error != null;
}
