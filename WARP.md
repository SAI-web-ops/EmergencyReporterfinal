# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Emergency Reporter is a comprehensive citizen-focused emergency reporting platform with a Flutter mobile app and Node.js/TypeScript backend server. The app enables real-time incident reporting with video/photo capture, location services, emergency contacts, and a citizen rewards system.

## Architecture

### Flutter Mobile App (`lib/`)

The Flutter app follows a provider-based architecture with clear separation of concerns:

- **Providers** (`providers/`): State management using Provider pattern
  - `AppStateProvider`: Global app state (theme, locale)
  - `IncidentProvider`: Incident reporting and management
  - `LocationProvider`: GPS location services and permissions
  - `PointsProvider`: Citizen rewards and points system

- **Repositories** (`repositories/`): Data layer abstraction for API communication
  - All repositories use `ApiClient` for consistent HTTP requests
  - Handles authentication, incident reporting, points, uploads, alerts, chat, and notifications

- **Screens** (`screens/`): Main UI screens including home, incident reporting, panic button, citizen points, and settings

- **Widgets** (`widgets/`): Reusable UI components for consistent design
  - Emergency buttons, location cards, media capture, progress indicators

- **Utils** (`utils/`): Core utilities including themes, config, i18n, and offline queue management

### Backend Server (`server/`)

Node.js/TypeScript server with Express.js and Socket.IO:

- **Routes** (`src/routes/`): REST API endpoints for incidents, points, uploads, alerts, auth, notifications, and chat
- **Database** (`src/database/`): SQLite database with better-sqlite3
- **Services** (`src/services/`): Encryption service for secure file handling
- **Middleware** (`src/middleware/`): Authentication middleware

## Development Commands

### Flutter App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS
flutter build ios

# Run tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build cache
flutter clean
```

### Backend Server

```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Start development server with hot reload
npm run dev

# Build TypeScript
npm run build

# Start production server
npm start

# Run with specific port
PORT=3000 npm run dev
```

## Key Dependencies

### Flutter
- **provider**: State management pattern
- **geolocator/geocoding**: Location services
- **camera/video_player**: Media capture and playback
- **google_maps_flutter**: Map integration
- **shared_preferences/sqflite**: Local storage
- **http/dio**: Network requests
- **permission_handler**: Runtime permissions

### Backend
- **express**: Web framework
- **socket.io**: Real-time communication for chat
- **better-sqlite3**: SQLite database
- **bcryptjs/jsonwebtoken**: Authentication
- **multer**: File upload handling
- **zod**: Input validation

## Development Setup

### Prerequisites
- Flutter SDK (3.8.0+)
- Node.js (16+)
- Android Studio/Xcode for mobile development
- Android/iOS device or emulator

### Environment Configuration

1. **Flutter App**: Update `lib/utils/config.dart` with appropriate API endpoints
2. **Backend**: Create `.env` file in `server/` directory with required environment variables
3. **Google Maps**: Add API keys to Android (`android/app/src/main/AndroidManifest.xml`) and iOS (`ios/Runner/Info.plist`)

### Database

The backend uses SQLite with automatic initialization. Database file is created in `server/data/` directory.

## File Upload System

The server handles encrypted file uploads in the `uploads/enc/` directory with backup capabilities. Files are processed through the crypto service for security.

## Real-time Features

Socket.IO enables real-time chat communication between citizens and emergency services. The chat system supports both REST API and WebSocket connections.

## Multi-platform Support

Flutter app supports:
- Android/iOS mobile platforms  
- Web deployment capability
- Windows/macOS/Linux desktop (configured but may need additional setup)

## Internationalization

The app supports 5 languages (English, Hindi, Spanish, French, German) with locale-specific emergency contact numbers and cultural adaptations.