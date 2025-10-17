enum UserRole {
  admin,
  manager,
  user,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.manager:
        return 'Gestionnaire';
      case UserRole.user:
        return 'Utilisateur';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Accès complet à toutes les fonctionnalités';
      case UserRole.manager:
        return 'Gestion des projets et des utilisateurs';
      case UserRole.user:
        return 'Accès en lecture seule';
    }
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.admin:
        return [
          'create_project',
          'edit_project',
          'delete_project',
          'view_project',
          'create_event',
          'edit_event',
          'delete_event',
          'view_event',
          'create_beneficiary',
          'edit_beneficiary',
          'delete_beneficiary',
          'view_beneficiary',
          'create_partner',
          'edit_partner',
          'delete_partner',
          'view_partner',
          'view_analytics',
          'export_data',
          'manage_users',
          'configure_api',
          'configure_sync',
        ];
      case UserRole.manager:
        return [
          'create_project',
          'edit_project',
          'view_project',
          'create_event',
          'edit_event',
          'view_event',
          'create_beneficiary',
          'edit_beneficiary',
          'view_beneficiary',
          'create_partner',
          'edit_partner',
          'view_partner',
          'view_analytics',
          'export_data',
        ];
      case UserRole.user:
        return [
          'view_project',
          'view_event',
          'view_beneficiary',
          'view_partner',
          'view_analytics',
        ];
    }
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
}
