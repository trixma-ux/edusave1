# EduSave (CNF Côte d’Ivoire)

[![Flutter CI](https://github.com/trixma-ux/edusave1/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/trixma-ux/edusave1/actions/workflows/flutter-ci.yml)

Application mobile Flutter hors-ligne avec SQLite chiffré (SQLCipher).

## Lancer
```bash
flutter pub get
flutter run
```
Identifiants: `admin` / `admin123`

## Intégration continue (CI)
- Lint/analyse: `flutter analyze`
- Tests: `flutter test`
- Build APK debug: `flutter build apk --debug`
La CI s’exécute sur chaque `push`/`PR` vers `main`.

## Modules
- Programmes: CLAC, IFADEM, ELAN (liste des projets par programme)
- Projets: création, statut, associations bénéficiaires/partenaires, export PDF/Excel
- Rencontres: événements avec rappels locaux
- Statistiques: filtres par période, agrégations programme/genre, graphiques
- Paramètres: infos et sécurité

## Statistiques avancées
- Agrégations SQL côté local via `StatsService`
- Filtres date (De/À) appliqués sur projets et participations
- Graphiques: camembert (répartition par programme), barres (participation par genre)

## Export
- PDF (`pdf`) et Excel (`excel`), fichiers dans le dossier Documents de l’app

## Sécurité
- Base chiffrée (clé dans `flutter_secure_storage`)
- MDP hashés (SHA-256)

## Arborescence
```
lib/
  src/
    data/
      local/db_helper.dart
      models/*
      repositories/*
    services/
      auth_service.dart
      notification_service.dart
      report_export_service.dart
      stats_service.dart
    providers/app_providers.dart
    routing/app_router.dart
    theme/app_theme.dart
    ui/screens/
      login, home, programs, projects, project_details,
      events, beneficiaries, partners, stats, settings
```

## Roadmap suggérée
- Formulaires complets projets (dates, description, indicateurs)
- Rapports PDF stylés avec logos CNF/OIF
- Sauvegarde/restauration (fichier chiffré)
- Internationalisation future
```
