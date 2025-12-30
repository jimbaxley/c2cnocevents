# 🎉 Team Up NC Events App

A modern Flutter application for managing and viewing events with beautiful card designs and notification capabilities. Built for the Team Up NC community with secure Firebase Remote Config integration and dynamic Coda data source.

[![Flutter](https://img.shields.io/badge/Flutter-3.32.7-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Remote%20Config-orange.svg)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)](https://flutter.dev)

## ✨ Features

- **🎯 Event Discovery**: Browse events with beautiful card-based UI
- **🔔 Smart Notifications**: Get notified before events start
- **�� Categories & Search**: Filter events by category and search
- **🔄 Live Preview**: Hot reload for rapid development
- **📊 Coda Integration**: Connect to Coda documents for dynamic event data
- **🌐 Cross-platform**: Runs on iOS, Android, and Web
- **🔐 Secure Configuration**: Firebase Remote Config for credential management
- **📱 Auto-fallback**: Seamlessly switches between live and sample data

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.32.7 or later)
- VS Code with Flutter extension
- Chrome browser (for web preview)
- Firebase project with Remote Config enabled

### Setup

1. **Clone and Navigate**
   ```bash
   git clone https://github.com/YOUR_USERNAME/TeamUpNC.git
   cd TeamUpNC
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Already configured in this repo)
   - Firebase Remote Config is pre-configured
   - Coda credentials are managed through Firebase Remote Config
   - No manual API key setup required

4. **Run the App**
   ```bash
   # iOS Simulator
   flutter run

   # Web (Chrome)
   flutter run -d chrome

   # Android
   flutter run -d android
   ```

## 🏗️ Architecture

- **Frontend**: Flutter with Material Design 3
- **State Management**: StatefulWidget with Provider pattern
- **Remote Config**: Firebase Remote Config for secure credential distribution
- **Data Source**: Coda API integration with automatic fallback
- **Typography**: Montserrat font family for improved readability
- **Image Handling**: Cached network images with Coda authentication

## 🔧 Configuration

### Firebase Remote Config Keys

The app automatically loads these configuration values:

- `coda_api_token`: Coda API authentication token
- `coda_doc_id`: Coda document ID for events
- `coda_table_id`: Coda table ID containing event data

### Environment Setup

1. Firebase project is pre-configured
2. Remote Config values are distributed automatically
3. No manual credential management required

## 📱 Build & Deploy

### iOS (TestFlight)

```bash
flutter build ipa
# Upload resulting .ipa file to App Store Connect
```

### Android (Play Store)

```bash
flutter build appbundle
# Upload resulting .aab file to Google Play Console
```

### Web

```bash
flutter build web
# Deploy to Firebase Hosting or your preferred web host
```

## 🔒 Security

- ✅ No hardcoded API keys or tokens
- ✅ Secure credential distribution via Firebase Remote Config
- ✅ Safe for public GitHub repositories
- ✅ Production-ready with clean logging

## 📚 Documentation

- [Coda Integration Guide](CODA_INTEGRATION.md)
- [Development Guide](DEVELOPMENT_GUIDE.md)
- [Architecture Overview](architecture.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Team Up NC community for requirements and feedback
- Firebase team for Remote Config capabilities
- Coda team for flexible API integration
- Flutter team for the amazing cross-platform framework

---

**Version**: 1.0.1 (Build 4)  
**Last Updated**: July 2025  
**Maintainer**: Team Up NC Development Team
