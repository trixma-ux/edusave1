# Configuration GitHub pour OneSave

Ce document décrit la configuration complète du repository GitHub pour OneSave, incluant les protections de branche, les workflows CI/CD, et la gestion des environnements.

## 🔒 Protection de la branche main

### Configuration requise

1. **Aller dans Settings > Branches**
2. **Cliquer sur "Add rule" pour la branche `main`**
3. **Configurer les règles suivantes :**

#### Règles de protection
- ✅ **Require a pull request before merging**
  - Require approvals: `1`
  - Dismiss stale PR approvals when new commits are pushed: `✅`
  - Require review from code owners: `✅` (si vous avez un fichier CODEOWNERS)

- ✅ **Require status checks to pass before merging**
  - Require branches to be up to date before merging: `✅`
  - Status checks: `test` (nom du job CI)

- ✅ **Require conversation resolution before merging**
  - Require all conversations on code to be resolved: `✅`

- ✅ **Restrict pushes that create files**
  - Restrict pushes that create files: `✅`

- ✅ **Require linear history**
  - Require linear history: `✅`

- ✅ **Include administrators**
  - Include administrators: `✅`

- ✅ **Allow force pushes**
  - Allow force pushes: `❌`

- ✅ **Allow deletions**
  - Allow deletions: `❌`

## 🚀 Workflows CI/CD

### 1. Workflow CI (`.github/workflows/ci.yml`)

**Déclencheurs :**
- Push sur `main` et `develop`
- Pull requests vers `main` et `develop`

**Actions :**
- Vérification du formatage du code
- Analyse statique (`flutter analyze`)
- Exécution des tests avec couverture
- Build APK debug
- Upload des rapports de couverture

### 2. Workflow Release APK (`.github/workflows/release-apk.yml`)

**Déclencheurs :**
- Création de tags (format `v*`)

**Actions :**
- Build APK release
- Upload de l'APK comme artefact
- Création automatique d'une release GitHub
- Génération des notes de version

## 🌍 Environnements

### Configuration de l'environnement "production"

1. **Aller dans Settings > Environments**
2. **Créer un nouvel environnement : "production"**
3. **Configurer les règles d'approbation :**

#### Règles d'approbation
- ✅ **Required reviewers**
  - Ajouter les reviewers requis (ex: maintainers, tech leads)
  - Nombre minimum d'approbations : `1`

- ✅ **Wait timer**
  - Délai d'attente : `0 minutes` (ou configurer selon vos besoins)

- ✅ **Deployment branches**
  - Branches autorisées : `main` uniquement

### Variables d'environnement (si nécessaire)

Si vous avez besoin de variables d'environnement spécifiques :

1. **Dans l'environnement "production"**
2. **Ajouter des secrets :**
   - `KEYSTORE_PASSWORD` : Mot de passe du keystore Android
   - `KEY_ALIAS` : Alias de la clé de signature
   - `KEY_PASSWORD` : Mot de passe de la clé

## 📋 Checklist de configuration

### Repository Settings
- [ ] Protection de branche `main` configurée
- [ ] Environnement `production` créé
- [ ] Reviewers assignés à l'environnement `production`
- [ ] Secrets configurés (si nécessaire)

### Workflows
- [ ] Workflow CI fonctionnel
- [ ] Workflow Release APK fonctionnel
- [ ] Badges de statut ajoutés au README

### Première release
- [ ] Tag `v0.1.0` créé
- [ ] Release GitHub générée automatiquement
- [ ] APK téléchargeable depuis la release

## 🔧 Commandes utiles

### Créer un tag et déclencher une release
```bash
# Créer et pousser un tag
git tag v0.1.0
git push origin v0.1.0

# Le workflow release-apk.yml se déclenchera automatiquement
```

### Vérifier le statut des workflows
```bash
# Voir les workflows en cours
gh run list

# Voir les détails d'un workflow
gh run view <run-id>
```

## 🚨 Dépannage

### Problèmes courants

1. **Workflow CI échoue**
   - Vérifier que tous les tests passent localement
   - Vérifier le formatage du code : `flutter format .`
   - Vérifier l'analyse : `flutter analyze`

2. **Release APK échoue**
   - Vérifier que le tag est bien poussé
   - Vérifier les permissions du token GitHub
   - Vérifier la configuration du keystore (si signé)

3. **Protection de branche bloque les PRs**
   - Vérifier que le workflow CI passe
   - Vérifier que tous les reviewers ont approuvé
   - Vérifier que les conversations sont résolues

## 📚 Ressources

- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [GitHub Actions Workflows](https://docs.github.com/en/actions/using-workflows)
