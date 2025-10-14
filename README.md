# Emergency Reporter

A comprehensive citizen-focused emergency reporting and response platform built with Flutter. This mobile app enables users to instantly report accidents, crimes, and emergencies through video and location sharing, while connecting directly with emergency services.

## 🚨 Features

### Real-Time Incident Reporting
- **Video & Photo Capture**: Record incidents with GPS-tagged location data
- **Live Streaming**: Stream incidents in real-time to emergency services
- **Anonymous Reporting**: Protect user identity while sharing critical information
- **AI-Powered Detection**: Automatic detection of accidents, violence, and suspicious activity

### Emergency Response
- **One-Tap Emergency Calls**: Quick dial buttons for police (100), ambulance (108/102), fire services (101)
- **Panic Button**: Shake-to-activate emergency alert system
- **Women's Helpline**: Dedicated support for women in distress (1091)
- **Child Helpline**: Emergency assistance for children (1098)

### Citizen Engagement
- **Points & Rewards System**: Earn points for valuable contributions
- **Achievement Badges**: Unlock badges for community service
- **Rewards Redemption**: Exchange points for local store discounts, medical priority, workshops
- **Community Impact**: Track your contribution to public safety

### Smart Features
- **Location-Based Alerts**: Auto-route incidents to nearest emergency units
- **Offline Mode**: Record and save reports offline with automatic upload
- **Multilingual Support**: Available in English, Hindi, Spanish, French, and German
- **Dark/Light Theme**: Customizable app appearance

## 🏗️ Architecture

### State Management
- **Provider Pattern**: Centralized state management for app-wide data
- **AppStateProvider**: Manages theme, locale, and global settings
- **IncidentProvider**: Handles incident reporting and management
- **LocationProvider**: Manages GPS location and permissions
- **PointsProvider**: Tracks citizen points and rewards

### Navigation
- **GoRouter**: Declarative routing with type-safe navigation
- **Nested Routes**: Organized screen hierarchy for better UX

### UI Components
- **Material Design 3**: Modern, accessible interface design
- **Custom Widgets**: Reusable components for consistent UI
- **Animations**: Smooth transitions and micro-interactions
- **Responsive Design**: Optimized for various screen sizes

## 📱 Screens

### Home Screen
- Emergency quick-dial buttons
- Location status indicator
- Citizen points summary
- Recent incidents overview
- Quick action cards

### Incident Reporting
- Incident type selection
- Priority level assignment
- Media capture (photo/video)
- Location verification
- Anonymous reporting option

### Emergency Contacts
- Official emergency numbers
- Personal quick-dial contacts
- Safety tips and guidance
- Contact information management

### Panic Button
- Large, accessible panic button
- Shake detection for activation
- Emergency countdown timer
- Quick emergency contact access

### Citizen Points
- Points overview and progress
- Available rewards and redemption
- Transaction history
- Achievement tracking

### Settings & Profile
- Theme and language preferences
- Notification settings
- Privacy and security options
- Profile management

## 🛠️ Technical Stack

### Core Dependencies
- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **GoRouter**: Navigation and routing

### Location & Maps
- **Geolocator**: GPS location services
- **Geocoding**: Address resolution
- **Google Maps**: Map integration

### Media & Camera
- **Camera**: Photo and video capture
- **Video Player**: Media playback
- **Image Picker**: Gallery selection

### UI & Animations
- **Flutter Staggered Animations**: List and grid animations
- **Lottie**: Advanced animations
- **Shimmer**: Loading placeholders

### Utilities
- **Shared Preferences**: Local storage
- **HTTP/Dio**: Network requests
- **Permission Handler**: Runtime permissions
- **URL Launcher**: External app integration

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd emergencyreporter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **Android Setup**
   - Add location permissions in `android/app/src/main/AndroidManifest.xml`
   - Configure camera permissions
   - Set up Google Maps API key

2. **iOS Setup**
   - Add location permissions in `ios/Runner/Info.plist`
   - Configure camera permissions
   - Set up Google Maps API key

## 📋 Permissions

### Required Permissions
- **Location**: GPS access for incident location tagging
- **Camera**: Photo and video capture for evidence
- **Microphone**: Audio recording for video evidence
- **Storage**: Save media files locally
- **Phone**: Emergency number dialing

### Optional Permissions
- **Notifications**: Push notifications for updates
- **Vibration**: Haptic feedback for panic button

## 🎨 Design System

### Color Palette
- **Primary Red**: #D32F2F (Emergency actions)
- **Primary Blue**: #1976D2 (Police services)
- **Primary Green**: #388E3C (Medical services)
- **Primary Orange**: #F57C00 (Fire services)
- **Accent Yellow**: #FFC107 (Citizen points)

### Typography
- **Headlines**: Bold, large text for important information
- **Body**: Regular text for descriptions and content
- **Captions**: Small text for secondary information

### Components
- **Cards**: Elevated surfaces for content grouping
- **Buttons**: Clear call-to-action elements
- **Input Fields**: Form controls with validation
- **Icons**: Consistent iconography throughout

## 🔒 Privacy & Security

### Data Protection
- **Encryption**: All data encrypted in transit and at rest
- **Anonymous Reporting**: Option to report without identity disclosure
- **Local Storage**: Sensitive data stored securely on device
- **Minimal Data Collection**: Only necessary information collected

### User Control
- **Data Export**: Users can export their data
- **Account Deletion**: Complete data removal option
- **Privacy Settings**: Granular control over data sharing

## 🌍 Accessibility

### Features
- **Screen Reader Support**: Full VoiceOver/TalkBack compatibility
- **High Contrast**: Enhanced visibility options
- **Large Text**: Scalable font sizes
- **Voice Commands**: Hands-free operation support
- **Haptic Feedback**: Tactile response for interactions

### Internationalization
- **Multi-language Support**: 5 languages supported
- **RTL Support**: Right-to-left language compatibility
- **Cultural Adaptation**: Region-specific emergency numbers

## 🚀 Future Enhancements

### Planned Features
- **Real-time Chat**: Direct communication with emergency dispatchers
- **Smart City Integration**: Connect with urban infrastructure
- **AI Analysis**: Advanced incident detection and classification
- **Community Features**: Neighborhood safety groups
- **Advanced Analytics**: Detailed safety insights and trends

### Technical Improvements
- **Offline Sync**: Better offline functionality
- **Performance Optimization**: Faster app loading and response
- **Advanced Security**: Biometric authentication
- **Cloud Integration**: Seamless data synchronization

## 🤝 Contributing

We welcome contributions to improve the Emergency Reporter app. Please read our contributing guidelines and submit pull requests for any enhancements.

### Development Guidelines
- Follow Flutter best practices
- Write comprehensive tests
- Update documentation
- Ensure accessibility compliance

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support, questions, or feedback:
- **Email**: support@emergencyreporter.app
- **Documentation**: [Link to docs]
- **Issues**: [GitHub Issues]

## 🙏 Acknowledgments

- Emergency services personnel for their guidance
- Community safety advocates
- Open source contributors
- Beta testers and feedback providers

---

**Emergency Reporter** - Making communities safer, one report at a time. 🚨🛡️
