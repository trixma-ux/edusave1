import 'package:flutter_test/flutter_test.dart';
import 'package:onesave/src/data/models/user.dart';
import 'package:onesave/src/data/models/user_role.dart';

void main() {
  test('User.fromMap accepte une ligne SQLite sans dates ni isActive', () {
    final u = User.fromMap({
      'id': 1,
      'name': 'admin',
      'email': 'admin@cnf.ci',
      'role': 'ADMIN',
      'passwordHash': 'x',
    });
    expect(u.role, UserRole.admin);
    expect(u.isActive, isTrue);
  });

  test('User.fromMap lit les dates et isActive quand ils existent', () {
    final u = User.fromMap({
      'name': 'b',
      'role': 'manager',
      'passwordHash': 'x',
      'createdAt': '2026-01-02T00:00:00.000',
      'updatedAt': '2026-01-03T00:00:00.000',
      'isActive': 0,
    });
    expect(u.role, UserRole.manager);
    expect(u.createdAt, DateTime(2026, 1, 2));
    expect(u.isActive, isFalse);
  });
}
