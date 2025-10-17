#!/bin/bash

# Script de build pour toutes les plateformes OneSave
# Usage: ./build_all.sh [clean] [web] [android] [ios]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${BLUE}[OneSave Build]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OneSave Build]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[OneSave Build]${NC} $1"
}

print_error() {
    echo -e "${RED}[OneSave Build]${NC} $1"
}

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    print_error "Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier la version de Flutter
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_message "Version de Flutter: $FLUTTER_VERSION"

# Nettoyer si demandé
if [[ "$1" == "clean" ]]; then
    print_message "Nettoyage des builds précédents..."
    flutter clean
    flutter pub get
    shift
fi

# Obtenir les dépendances
print_message "Récupération des dépendances..."
flutter pub get

# Vérifier les dépendances
print_message "Vérification des dépendances..."
flutter pub deps

# Build pour Web
if [[ "$1" == "web" || "$1" == "" ]]; then
    print_message "Build pour Web..."
    flutter build web --release --web-renderer html
    print_success "Build Web terminé avec succès!"
fi

# Build pour Android
if [[ "$1" == "android" || "$1" == "" ]]; then
    print_message "Build pour Android..."
    
    # Vérifier si Android SDK est configuré
    if ! flutter doctor | grep -q "Android toolchain"; then
        print_warning "Android SDK non configuré, tentative de configuration..."
        flutter doctor --android-licenses
    fi
    
    flutter build apk --release
    print_success "Build Android terminé avec succès!"
fi

# Build pour iOS (macOS uniquement)
if [[ "$1" == "ios" || "$1" == "" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_message "Build pour iOS..."
        flutter build ios --release --no-codesign
        print_success "Build iOS terminé avec succès!"
    else
        print_warning "Build iOS ignoré (macOS requis)"
    fi
fi

# Build pour toutes les plateformes
if [[ "$1" == "all" ]]; then
    print_message "Build pour toutes les plateformes..."
    
    # Web
    flutter build web --release --web-renderer html
    print_success "Build Web terminé!"
    
    # Android
    flutter build apk --release
    print_success "Build Android terminé!"
    
    # iOS (si macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        flutter build ios --release --no-codesign
        print_success "Build iOS terminé!"
    fi
fi

print_success "Tous les builds sont terminés!"
print_message "Fichiers de build disponibles dans:"
print_message "  - Web: build/web/"
print_message "  - Android: build/app/outputs/flutter-apk/"
print_message "  - iOS: build/ios/Release-iphoneos/ (macOS uniquement)"
