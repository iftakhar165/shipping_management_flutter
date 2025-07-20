# Shipping Management Flutter App

A comprehensive shipping management Flutter application with GetX state management and Firebase backend integration.

## Features

### Core Functionality
- ✅ **User Authentication** (Email/Password + Google Sign-in)
- ✅ **Parcel Management** (Create, Track, Update)
- ✅ **Real-time Tracking** with Maps Integration
- ✅ **Dashboard Analytics** with Charts and Metrics
- ✅ **Multi-role Support** (Customer, Delivery Man, Admin)
- ✅ **Advanced UI/UX** with Material 3 Design

### Advanced Features
- 🔥 **Firebase Integration** (Auth, Firestore, Storage)
- 📊 **Analytics Dashboard** with Real-time Data
- 🚚 **Delivery Management** for Delivery Personnel
- 💳 **Payment Integration** (Stripe, Razorpay)
- 📧 **Notification System** (Push, Email, SMS)
- 🗺️ **Maps & Location Services**
- 📄 **PDF Generation** for Shipping Labels
- 🎨 **Animations & Transitions**

## Architecture

### State Management
- **GetX** for state management and dependency injection
- **Controllers** for business logic
- **Services** for API and Firebase operations

### Project Structure
```
lib/
├── controllers/          # GetX Controllers
├── models/              # Data Models
├── services/            # API & Firebase Services
├── views/               # UI Components
│   ├── screens/         # App Screens
│   └── widgets/         # Reusable Widgets
├── routes/              # App Navigation
├── utils/               # Utilities & Theme
└── main.dart           # App Entry Point
```

### Key Models
- **UserModel** - User authentication and profile
- **ParcelModel** - Comprehensive parcel data
- **DeliveryManModel** - Delivery personnel information
- **AnalyticsModel** - Business analytics and metrics
- **BusinessModel** - Business configuration

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/iftakhar165/shipping_management_flutter.git
   cd shipping_management_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password + Google)
   - Enable Firestore Database
   - Enable Storage
   - Download and replace `firebase_options.dart` with your configuration

4. **Google Sign-in Setup**
   - Configure OAuth 2.0 in Google Cloud Console
   - Add SHA-1 fingerprint for Android
   - Update `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`

5. **Run the application**
   ```bash
   flutter run
   ```

### Platform-specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Update `android/app/build.gradle` with proper configuration

#### iOS
- iOS 11.0 or higher
- Update `ios/Runner/Info.plist` with required permissions

## Key Dependencies

### Core
- `get: ^4.6.6` - State management
- `firebase_core: ^2.24.2` - Firebase core
- `firebase_auth: ^4.15.3` - Authentication
- `cloud_firestore: ^4.13.6` - Database
- `google_sign_in: ^6.2.1` - Google authentication

### UI/UX
- `google_fonts: ^6.1.0` - Typography
- `flutter_animate: ^4.5.0` - Animations
- `lottie: ^3.0.0` - Lottie animations
- `shimmer: ^3.0.0` - Loading states

### Charts & Analytics
- `fl_chart: ^0.68.0` - Charts
- `syncfusion_flutter_charts: ^24.2.9` - Advanced charts

### Maps & Location
- `google_maps_flutter: ^2.5.3` - Maps
- `geolocator: ^10.1.0` - Location services

## Usage

### Authentication
- Email/Password registration and login
- Google Sign-in integration
- Role-based access (Customer, Delivery Man, Admin)

### Parcel Management
- Create parcels with detailed information
- Track parcels in real-time
- Update parcel status
- Generate shipping labels

### Dashboard
- View key metrics and analytics
- Quick actions for common tasks
- Real-time data updates

## Development

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Comment complex logic
- Maintain consistent folder structure

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Building

#### Debug Build
```bash
flutter build apk --debug
flutter build ios --debug
```

#### Release Build
```bash
flutter build apk --release
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Contact: [support@shippingmanagement.com]

## Screenshots

[Add screenshots of the app here]

## Changelog

### v1.0.0
- Initial release with core features
- Authentication system
- Parcel management
- Dashboard analytics
- Maps integration

---

Built with ❤️ using Flutter and Firebase
