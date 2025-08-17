# 🎁 Hedieaty - Gift Management & Event Planning App

[![Flutter](https://img.shields.io/badge/Flutter-3.5.3+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.5.3+-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Hedieaty** is a comprehensive Flutter-based mobile application designed to revolutionize gift-giving and event planning. The app enables users to create events, manage gift lists, coordinate with friends, and ensure every celebration becomes memorable through organized gift management.

## 🚀 Features

### 🔐 Authentication & User Management
- **User Registration & Login**: Secure authentication using Firebase Auth
- **Profile Management**: Complete user profile customization with avatar support
- **Social Integration**: Friend system for collaborative gift planning

### 📅 Event Management
- **Event Creation**: Create detailed events with name, date, location, and description
- **Event Organization**: Manage multiple events with intuitive categorization
- **Event Sharing**: Share events with friends for collaborative planning

### 🎁 Gift Management System
- **Gift Creation**: Add gifts with detailed information (name, description, category, price)
- **Image Support**: Upload and store gift images using Firebase Storage
- **Gift Status Tracking**: Monitor gift status (available, pledged, purchased)
- **Pledging System**: Friends can pledge to buy specific gifts
- **Gift Categories**: Organize gifts by type and preferences

### 🔔 Smart Notifications
- **Push Notifications**: Real-time updates using Firebase Cloud Messaging
- **Event Reminders**: Automated reminders for upcoming events
- **Gift Updates**: Notifications for gift pledges and status changes

### 💾 Data Management
- **Local Database**: SQLite integration for offline functionality
- **Cloud Sync**: Firebase Firestore for real-time data synchronization
- **Image Compression**: Optimized image storage and retrieval

### 🎨 User Experience
- **Animated Splash Screen**: Engaging Lottie animations
- **Modern UI/UX**: Material Design with Google Fonts
- **Responsive Design**: Optimized for various screen sizes
- **Search Functionality**: Find users and gifts quickly

## 🛠️ Technology Stack

### Frontend Framework
- **Flutter 3.5.3+**: Cross-platform mobile development framework
- **Dart 3.5.3+**: Programming language for Flutter

### Backend & Cloud Services
- **Firebase Core**: Core Firebase functionality
- **Firebase Authentication**: User authentication and management
- **Firebase Firestore**: NoSQL cloud database
- **Firebase Storage**: File and image storage
- **Firebase Cloud Messaging**: Push notifications
- **Firebase Realtime Database**: Real-time data synchronization

### Local Database
- **SQLite**: Local database for offline functionality
- **SQFlite**: Flutter plugin for SQLite database operations

### UI/UX Libraries
- **Material Design**: Google's design system
- **Google Fonts**: Typography enhancement
- **Lottie**: High-quality animations
- **Animated Splash Screen**: Engaging app launch experience

### Image & Media
- **Image Picker**: Camera and gallery integration
- **Flutter Image Compress**: Image optimization
- **Image Package**: Advanced image processing

### Utilities & Dependencies
- **Path Provider**: File system access
- **Intl**: Internationalization support
- **Crypto**: Cryptographic functions
- **HTTP**: Network requests
- **Google APIs**: Google services integration
- **Flutter Local Notifications**: Local notification handling

## 🏗️ Architecture & Project Structure

```
hedieaty/
├── lib/                          # Main application source code
│   ├── main.dart                 # Application entry point
│   ├── firebase_options.dart     # Firebase configuration
│   ├── notifications.dart        # Notification handling
│   ├── screens/                  # UI screens
│   │   ├── splash_screen.dart   # Animated splash screen
│   │   ├── auth/                # Authentication screens
│   │   │   ├── start_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── home_screen.dart     # Main home screen
│   │   ├── tabs.dart           # Navigation tabs
│   │   ├── profile_screen.dart # User profile management
│   │   ├── events/             # Event management
│   │   │   ├── event_creation.dart
│   │   │   └── event_list_screen.dart
│   │   └── gifts/              # Gift management
│   │       ├── gift_creation.dart
│   │       ├── gift_list_screen.dart
│   │       ├── gift_details_edit.dart
│   │       └── pledged_gifts_screen.dart
│   ├── widgets/                 # Reusable UI components
│   └── database/                # Data layer
│       ├── database_helper.dart # SQLite database helper
│       ├── models/              # Data models
│       │   ├── user.dart
│       │   ├── event.dart
│       │   ├── gift.dart
│       │   └── friend.dart
│       └── DAO/                 # Data Access Objects
├── assets/                      # Application assets
│   ├── Lottie/                 # Animation files
│   ├── images/                 # Image assets
│   └── fonts/                  # Custom fonts
├── android/                     # Android-specific configuration
├── test/                       # Unit tests
├── integration_test/           # Integration tests
├── pubspec.yaml                # Dependencies and configuration
└── firebase.json               # Firebase configuration
```

## 🔄 Application Workflow

### 1. User Onboarding
```
Splash Screen → Authentication → Profile Setup → Home Screen
```

### 2. Event Creation Flow
```
Home Screen → Create Event → Fill Event Details → Save Event → Event List
```

### 3. Gift Management Flow
```
Event Details → Add Gift → Gift Information → Image Upload → Save Gift
```

### 4. Friend Interaction Flow
```
Search Users → Send Friend Request → Accept Request → Collaborative Planning
```

### 5. Gift Pledging Flow
```
Browse Gifts → Pledge Gift → Update Status → Notify Event Organizer
```

## 📱 Key Screens & Functionality

### **Splash Screen**
- Lottie animation for engaging user experience
- App branding and loading states

### **Authentication Screens**
- **Start Screen**: App introduction and authentication options
- **Login Screen**: User login with email/password
- **Signup Screen**: New user registration

### **Home Screen**
- Friend list display
- User search functionality
- Quick access to events and gifts
- Navigation to main features

### **Event Management**
- **Event Creation**: Form-based event setup
- **Event List**: Organized view of all events
- Event editing and deletion capabilities

### **Gift Management**
- **Gift Creation**: Comprehensive gift information input
- **Gift List**: Organized gift display with status
- **Gift Details**: Full gift information and editing
- **Pledged Gifts**: Track gift commitments

### **Profile Management**
- User information editing
- Avatar management
- Account settings
- Friend management

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: Version 3.5.3 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio / VS Code**: Recommended IDEs
- **Firebase Account**: For backend services
- **Git**: Version control system

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/AbdelrahmanKhaled18/Hedieaty.git
   cd Hedieaty
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, Storage, and Cloud Messaging
   - Download `google-services.json` and place it in `android/app/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Run the Application**
   ```bash
   flutter run
   ```

### Environment Configuration
- Ensure Flutter is properly configured for your target platforms
- Configure Firebase project settings
- Set up notification permissions for push notifications

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test
```

### Test Coverage
```bash
flutter test --coverage
```

## 📱 Platform Support

- **Android**: Full support with Firebase integration
- **iOS**: Compatible (requires iOS-specific Firebase setup)
- **Web**: Not currently supported
- **Desktop**: Not currently supported

## 🔧 Configuration

### Firebase Configuration
- Update `firebase.json` with your project settings
- Configure authentication providers in Firebase Console
- Set up Firestore security rules
- Configure Storage rules for image uploads

### Local Database
- SQLite database is automatically created
- Database schema is managed through models
- Local data syncs with Firebase when online

## 📊 Performance & Optimization

- **Image Compression**: Automatic image optimization for storage
- **Offline Support**: Local database for offline functionality
- **Lazy Loading**: Efficient data loading and caching
- **Memory Management**: Optimized image handling and storage

## 🔒 Security Features

- **Firebase Security Rules**: Database access control
- **User Authentication**: Secure login and registration
- **Data Validation**: Input sanitization and validation
- **Secure Storage**: Encrypted local data storage

## 🚀 Deployment

### Android Build
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### Firebase Deployment
- Configure Firebase hosting if needed
- Update Firebase project settings
- Deploy security rules and configurations

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Guidelines
- Follow Flutter coding standards
- Write comprehensive tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting



## 🙏 Acknowledgments

- **Flutter Team**: For the amazing cross-platform framework
- **Firebase Team**: For robust backend services
- **Lottie**: For beautiful animations
- **Google Fonts**: For typography resources
- **Open Source Community**: For various packages and libraries

## 📞 Support & Contact

- **Project Link**: [https://github.com/AbdelrahmanKhaled18/Hedieaty](https://github.com/AbdelrahmanKhaled18/Hedieaty)
- **Issues**: [GitHub Issues](https://github.com/AbdelrahmanKhaled18/Hedieaty/issues)
- **Documentation**: [Flutter Docs](https://docs.flutter.dev/)

## 🔮 Future Roadmap

- [ ] **Multi-language Support**: Internationalization
- [ ] **Advanced Analytics**: User behavior tracking
- [ ] **Social Features**: Enhanced friend interactions
- [ ] **Payment Integration**: Gift purchasing capabilities
- [ ] **Calendar Integration**: Event synchronization
- [ ] **Web Platform**: Browser-based access
- [ ] **AI Recommendations**: Smart gift suggestions

---



*Transform every celebration into a memorable experience with Hedieaty!*