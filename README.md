# OneSave - Multi-Platform Educational Project Management App

OneSave is a comprehensive Flutter application designed for managing educational projects, events, beneficiaries, and partners. Built with modern Flutter architecture and Material 3 design principles, supporting Web, iOS, and Android platforms with real-time data synchronization.

## 🚀 Features

### Core Features
- **Project Management**: Create, track, and manage educational projects
- **Event Management**: Schedule and manage events and meetings
- **Beneficiary Management**: Track project beneficiaries and participants
- **Partner Management**: Manage project partners and collaborators
- **Analytics Dashboard**: Comprehensive analytics with charts and insights

### Advanced Features
- **🌐 Multi-Platform Support**: Web, iOS, and Android compatibility
- **🔄 Real-time Data Sync**: Automatic data synchronization across all platforms
- **🌙 Dark Theme Support**: Complete dark/light theme with system preference
- **☁️ Cloud Synchronization**: Real-time sync with conflict resolution
- **🔔 Push Notifications**: Firebase Cloud Messaging integration
- **📱 Offline Mode**: Advanced offline capabilities with operation queuing
- **🌍 Internationalization**: English/French language support
- **📊 Enhanced Analytics**: Advanced charts and data visualization
- **🔌 API Integration**: External system integration capabilities
- **👥 Multi-User Support**: Role-based access control

## 🏗️ Architecture

### State Management
- **Riverpod**: Modern state management solution
- **Provider Pattern**: Clean separation of concerns
- **Repository Pattern**: Data access abstraction

### Data Layer
- **SQLite with SQLCipher**: Encrypted local database
- **Flutter Secure Storage**: Secure key storage
- **JSON Serialization**: Model serialization/deserialization

### UI/UX
- **Material 3 Design**: Modern Material Design implementation
- **Glassmorphism Effects**: Beautiful UI components
- **Smooth Animations**: Flutter Animate integration
- **Responsive Design**: Adaptive layouts for all screen sizes

## 📱 Screenshots

*Screenshots will be added here*

## 🛠️ Installation

### Prerequisites
- Flutter SDK (3.3.0 or higher)
- Dart SDK (3.3.0 or higher)
- Android Studio / VS Code
- Git
- For iOS: Xcode (macOS only)
- For Web: Chrome or any modern browser

### Setup
1. Clone the repository:
```bash
git clone https://github.com/yourusername/onesave.git
cd onesave
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Run the app:
```bash
# For Web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS (macOS only)
flutter run -d ios
```

## 🚀 Building for Production

### Quick Build (All Platforms)
```bash
# Windows PowerShell
.\build_all.ps1 -All

# Linux/macOS
./build_all.sh all
```

### Individual Platform Builds
```bash
# Web only
.\build_all.ps1 -Web

# Android only
.\build_all.ps1 -Android

# iOS only (macOS)
./build_all.sh ios
```

### Manual Build Commands
```bash
# Web
flutter build web --release --web-renderer html

# Android
flutter build apk --release

# iOS (macOS only)
flutter build ios --release --no-codesign
```

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Enable Cloud Messaging in Firebase Console

### API Configuration
1. Go to Settings > API Configuration
2. Enter your API base URL
3. Add your authentication token

### Database
The app uses SQLite with SQLCipher for encrypted local storage. The database is automatically created and migrated on first launch.

## 📁 Project Structure

```
lib/
├── src/
│   ├── app.dart                 # Main app widget
│   ├── main.dart               # App entry point
│   ├── data/
│   │   ├── models/             # Data models
│   │   ├── repositories/       # Data repositories
│   │   └── local/              # Local database
│   ├── providers/              # Riverpod providers
│   ├── services/               # Business logic services
│   ├── theme/                  # App theming
│   ├── ui/
│   │   ├── screens/            # App screens
│   │   └── widgets/            # Reusable widgets
│   └── routing/                # Navigation routing
├── l10n/                       # Localization files
└── assets/                     # App assets
```

## 🎨 Theming

The app supports both light and dark themes with Material 3 design:

- **Light Theme**: Clean, modern interface with bright colors
- **Dark Theme**: Eye-friendly dark interface
- **System Theme**: Automatically follows system preference
- **Custom Colors**: OneSave brand colors throughout

## 🌍 Internationalization

Currently supports:
- **French** (Default)
- **English**

To add new languages:
1. Create new ARB files in `l10n/`
2. Add locale to `LocalizationService.supportedLocales`
3. Update `localeResolutionCallback`

## 🔐 Security

- **Encrypted Storage**: All sensitive data encrypted with SQLCipher
- **Secure Keys**: Authentication tokens stored securely
- **Role-Based Access**: Multi-user support with permissions
- **Data Validation**: Input validation and sanitization

## 📊 Analytics

The app includes comprehensive analytics:
- Project statistics by program and status
- Beneficiary demographics
- Event participation metrics
- Monthly trends and insights
- Export capabilities

## 🔄 Synchronization

- **Real-time Sync**: Automatic synchronization when online
- **Conflict Resolution**: Last-write-wins strategy
- **Offline Queue**: Operations queued when offline
- **Background Sync**: Syncs in background when possible

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📦 Dependencies

### Core Dependencies
- `flutter_riverpod`: State management
- `sqflite_sqlcipher`: Encrypted database
- `flutter_secure_storage`: Secure storage
- `dio`: HTTP client
- `connectivity_plus`: Network connectivity

### UI Dependencies
- `flutter_animate`: Animations
- `glassmorphism`: Glass effects
- `fl_chart`: Charts and graphs
- `shimmer`: Loading effects

### Firebase
- `firebase_core`: Firebase initialization
- `firebase_messaging`: Push notifications

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **CNF Côte d'Ivoire**: Project sponsor
- **Development Team**: Flutter development

## 📞 Support

For support, email support@onesave.ci or create an issue in this repository.

## 🗺️ Roadmap

### Version 0.2.0 ✅
- [x] Dark theme support
- [x] Cloud synchronization
- [x] Push notifications
- [x] Advanced offline mode

### Version 0.3.0 ✅
- [x] Internationalization
- [x] Enhanced analytics
- [x] API integration
- [x] Multi-user support

### Version 0.4.0 (Planned)
- [ ] Advanced reporting
- [ ] Data export/import
- [ ] Advanced user management
- [ ] Performance optimizations

---

**OneSave** - Empowering Education Through Technology 🎓