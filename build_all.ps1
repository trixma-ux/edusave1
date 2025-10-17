# Script de build PowerShell pour toutes les plateformes OneSave
# Usage: .\build_all.ps1 [clean] [web] [android] [ios]

param(
    [switch]$Clean,
    [switch]$Web,
    [switch]$Android,
    [switch]$IOS,
    [switch]$All
)

# Fonction pour afficher les messages
function Write-Message {
    param([string]$Message, [string]$Color = "White")
    Write-Host "[OneSave Build] $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OneSave Build] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[OneSave Build] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[OneSave Build] $Message" -ForegroundColor Red
}

# Vérifier si Flutter est installé
try {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Message "Version de Flutter: $flutterVersion" "Cyan"
} catch {
    Write-Error "Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
}

# Nettoyer si demandé
if ($Clean) {
    Write-Message "Nettoyage des builds précédents..." "Yellow"
    flutter clean
    flutter pub get
}

# Obtenir les dépendances
Write-Message "Récupération des dépendances..." "Cyan"
flutter pub get

# Vérifier les dépendances
Write-Message "Vérification des dépendances..." "Cyan"
flutter pub deps

# Build pour Web
if ($Web -or (-not $Android -and -not $IOS -and -not $All)) {
    Write-Message "Build pour Web..." "Cyan"
    flutter build web --release --web-renderer html
    Write-Success "Build Web terminé avec succès!"
}

# Build pour Android
if ($Android -or $All) {
    Write-Message "Build pour Android..." "Cyan"
    
    # Vérifier si Android SDK est configuré
    $androidStatus = flutter doctor | Select-String "Android toolchain"
    if (-not $androidStatus) {
        Write-Warning "Android SDK non configuré, tentative de configuration..."
        flutter doctor --android-licenses
    }
    
    flutter build apk --release
    Write-Success "Build Android terminé avec succès!"
}

# Build pour iOS (Windows ne supporte pas iOS)
if ($IOS -or $All) {
    Write-Warning "Build iOS ignoré (macOS requis pour iOS)"
}

# Si aucun paramètre spécifique, build Web par défaut
if (-not $Web -and -not $Android -and -not $IOS -and -not $All) {
    Write-Message "Build pour Web..." "Cyan"
    flutter build web --release --web-renderer html
    Write-Success "Build Web terminé avec succès!"
}

Write-Success "Tous les builds sont terminés!"
Write-Message "Fichiers de build disponibles dans:" "Cyan"
Write-Message "  - Web: build\web\" "White"
Write-Message "  - Android: build\app\outputs\flutter-apk\" "White"
