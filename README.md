# MaidMatch - Domestic Services Marketplace 🏠✨

A modern, elegant Flutter application connecting urban households with verified domestic workers. Built with Firebase Authentication, Cloud Firestore, and Material 3 design.

![Flutter](https://img.shields.io/badge/Flutter-3.10.1-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)
![Material 3](https://img.shields.io/badge/Material%203-Enabled-6366F1)

## 🌟 Features

### For Customers
- 📱 **Phone Authentication** - Secure SMS OTP login
- 🔍 **Smart Search** - Find service providers by skill and category
- ⭐ **Verified Profiles** - NID, Police clearance, NGO verification
- 💬 **Real-time Booking** - Instant booking with price calculator
- 📊 **Booking History** - Track all past and upcoming services
- 🔔 **Notifications** - Stay updated on booking status
- 🆘 **Safety Features** - Panic button, emergency contacts

### For Service Providers
- 📋 **Job Dashboard** - Manage all job requests in one place
- ✅ **Accept/Decline** - Control your work schedule
- 💰 **Earnings Tracker** - Monitor completed jobs and income
- 🔔 **Real-time Alerts** - Get notified of new job requests
- ⚡ **Availability Toggle** - Turn on/off when not available
- ⭐ **Rating System** - Build reputation through customer reviews

## 🎨 Design Highlights

- **Modern Gradient Theme** - Indigo, Purple, Pink color scheme
- **Glassmorphism Effects** - Frosted glass UI components
- **Smooth Animations** - Fade transitions, hero animations
- **Material 3** - Latest design system with custom theming
- **Responsive Layout** - Works on all screen sizes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart 3.0+
- Android Studio / VS Code
- Firebase account
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sisayeedcse/MaidMatch-App.git
   cd MaidMatch-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Phone Authentication
   - Download `google-services.json` and place in `android/app/`
   - Add SHA-1 and SHA-256 fingerprints to Firebase Console

4. **Generate SHA keys** (Windows)
   ```powershell
   cd android
   .\gradlew signingReport
   ```
   Copy SHA-1 and SHA-256 to Firebase Console → Project Settings → Add fingerprint

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

*Coming soon - Screenshots showcasing the modern UI and key features*

## 🏗️ Project Structure

```
lib/
├── data/
│   └── dummy_data.dart           # Sample data for testing
├── models/
│   └── user_model.dart           # User data model
├── screens/
│   ├── login_screen.dart         # Phone authentication
│   ├── otp_verification_screen.dart  # OTP verification
│   ├── home_screen.dart          # Customer dashboard
│   ├── provider_dashboard_screen.dart  # Provider dashboard
│   ├── maid_profile_screen.dart  # Service provider profile
│   ├── booking_checkout_screen.dart   # Booking flow
│   ├── bookings_history_screen.dart   # Booking history
│   ├── notifications_screen.dart      # Notifications
│   ├── profile_settings_screen.dart   # User settings
│   └── safety_features_screen.dart    # Safety tools
├── services/
│   └── auth_service.dart         # Firebase Authentication service
├── widgets/
│   ├── auth_wrapper.dart         # Auth state management
│   └── maid_card.dart           # Service provider card
└── main.dart                     # App entry point
```

## 🔐 Authentication Flow

1. User enters phone number (+880 format)
2. Firebase sends SMS with OTP
3. User verifies 6-digit OTP
4. User document created in Firestore
5. Role-based navigation (Customer/Provider)
6. Persistent login across app restarts

See [FIREBASE_AUTH_GUIDE.md](FIREBASE_AUTH_GUIDE.md) for detailed setup.

## 📚 Documentation

- **[FIREBASE_AUTH_GUIDE.md](FIREBASE_AUTH_GUIDE.md)** - Complete Firebase setup instructions
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation details
- **[QUICKSTART.md](QUICKSTART.md)** - Quick reference guide
- **[AUTH_FLOW_DIAGRAM.md](AUTH_FLOW_DIAGRAM.md)** - Visual authentication flows

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10.1
- **Language**: Dart 3.0+
- **Authentication**: Firebase Auth (Phone)
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage (planned)
- **State Management**: StatefulWidget with setState
- **Design**: Material 3
- **Icons**: Material Icons, Cupertino Icons

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  url_launcher: ^6.3.2
```

## 🧪 Testing

### Test with Real SMS
- Ensure SHA keys are configured
- Use real phone numbers
- Actual SMS delivery

### Test with Firebase Test Numbers
- Add test numbers in Firebase Console
- No SMS sent, predefined OTP
- Free, no quota usage

### Dev Mode
- Click "Dev Mode (Skip Auth)" on login
- Bypasses authentication
- For UI testing only

## 🔮 Roadmap

### Phase 1 (Completed) ✅
- Firebase Authentication
- User roles (Customer/Provider)
- Service provider listings
- Basic booking flow
- Safety features UI

### Phase 2 (In Progress) 🚧
- Applink SMS/USSD integration
- Real payment processing
- Google Maps integration
- In-app chat system
- Push notifications (FCM)

### Phase 3 (Planned) 📋
- AI/ML matching engine
- Background verification API
- Call masking with Applink
- Advanced analytics
- Multi-language support

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Sisayeed**
- GitHub: [@sisayeedcse](https://github.com/sisayeedcse)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication and database services
- Material Design for UI/UX guidelines
- Community contributors

## 📞 Support

For support, issues, or feature requests:
- Create an issue on GitHub
- Check documentation files in the repository
- Review [FIREBASE_AUTH_GUIDE.md](FIREBASE_AUTH_GUIDE.md) for setup help

## 🔒 Security

Please report security vulnerabilities to the repository maintainer privately before public disclosure.

---

**Built with ❤️ using Flutter & Firebase**
