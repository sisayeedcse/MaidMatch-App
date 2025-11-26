# Firebase Authentication Setup Guide

## Overview

MaidMatch now uses Firebase Authentication with phone number verification (OTP/SMS). This provides secure, production-ready authentication for both customers and service providers.

## Features Implemented

### 1. **Phone Authentication (SMS OTP)**

- **Login Flow**: User enters phone number → Receives OTP via SMS → Verifies OTP → Auto-navigates to appropriate dashboard
- **OTP Screen**: 6-digit verification with countdown timer, resend functionality
- **Auto-verification**: On Android devices, OTP can be auto-detected
- **Role-based Navigation**: Customers → HomeScreen, Providers → ProviderDashboardScreen

### 2. **Authentication Service** (`lib/services/auth_service.dart`)

Centralized singleton service managing all authentication operations:

- `verifyPhoneNumber()` - Initiates SMS OTP flow
- `signInWithOTP()` - Verifies OTP code and signs in user
- `signInWithCredential()` - Auto sign-in with credential
- `createOrUpdateUserDocument()` - Creates/updates user in Firestore
- `getUserRole()` - Fetches user role from Firestore
- `signOut()` - Logs out current user
- `authStateChanges` - Stream for listening to auth state

### 3. **User Model** (`lib/models/user_model.dart`)

Type-safe data model for user profiles:

- Common fields: uid, phoneNumber, role, name, email
- Provider fields: skills, rating, completedJobs, isAvailable, bio, verifications
- Customer fields: address, emergencyContacts
- Methods: `fromFirestore()`, `toFirestore()`, `copyWith()`

### 4. **Auth Wrapper** (`lib/widgets/auth_wrapper.dart`)

Smart navigation component that:

- Listens to authentication state changes
- Shows LoginScreen when not authenticated
- Redirects to appropriate dashboard based on user role
- Handles loading states during auth checks

### 5. **Updated Screens**

- **LoginScreen** (`lib/screens/login_screen.dart`)

  - Form validation for phone numbers
  - Real Firebase OTP initiation
  - Dev mode button for testing (skips auth)
  - Error handling with user-friendly messages

- **OTPVerificationScreen** (`lib/screens/otp_verification_screen.dart`)

  - 6 animated OTP input boxes
  - 60-second countdown timer
  - Resend OTP functionality
  - Auto-submit when 6 digits entered
  - Auto-verification support (Android)

- **ProfileSettingsScreen** (`lib/screens/profile_settings_screen.dart`)
  - Real logout functionality
  - Confirmation dialog before logout
  - Error handling for logout failures

## Firebase Console Setup Required

### 1. **Enable Phone Authentication**

```
Firebase Console → Authentication → Sign-in method → Phone → Enable
```

### 2. **Android Setup (SHA-1/SHA-256 Required)**

Phone authentication requires SHA keys for Android:

```powershell
# Navigate to your project
cd android

# Generate SHA keys (requires Java keytool)
.\gradlew signingReport

# Copy SHA-1 and SHA-256 from output
# Example output:
# SHA1: A1:B2:C3:D4:...
# SHA256: E1:F2:G3:H4:...
```

Add SHA keys to Firebase:

```
Firebase Console → Project Settings → Your apps → android → Add fingerprint
```

### 3. **Download Updated google-services.json**

After adding SHA keys, download the updated `google-services.json`:

```
Firebase Console → Project Settings → Your apps → android → Download google-services.json
```

Replace the file at: `android/app/google-services.json`

### 4. **iOS Setup (Optional, for iOS testing)**

```
Firebase Console → Project Settings → Your apps → iOS → Download GoogleService-Info.plist
```

Place at: `ios/Runner/GoogleService-Info.plist`

### 5. **Test Phone Numbers (For Development)**

Add test phone numbers to bypass SMS sending:

```
Firebase Console → Authentication → Sign-in method → Phone → Add test number
Example: +8801234567890 → Code: 123456
```

## Code Structure

```
lib/
├── services/
│   └── auth_service.dart         # Authentication logic
├── models/
│   └── user_model.dart           # User data model
├── widgets/
│   └── auth_wrapper.dart         # Auth state management
├── screens/
│   ├── login_screen.dart         # Login with phone
│   ├── otp_verification_screen.dart  # OTP verification
│   ├── home_screen.dart          # Customer dashboard
│   ├── provider_dashboard_screen.dart  # Provider dashboard
│   └── profile_settings_screen.dart   # Settings with logout
└── main.dart                     # Entry point with AuthWrapper
```

## Phone Number Format

**Bangladesh**: `+880` + 10 digits

- Example: `+8801712345678`
- Input: User enters `1712345678`, app prepends `+880`

**To change country code**:
Edit `login_screen.dart`:

```dart
final phoneNumber = '+880${_phoneController.text}';  // Change +880
```

## User Roles

Two roles stored in Firestore `users` collection:

1. **customer** - Regular users booking services
2. **provider** - Service providers offering services

Role-based navigation in `auth_wrapper.dart`:

```dart
if (role == 'customer') {
  return HomeScreen();
} else {
  return ProviderDashboardScreen();
}
```

## Testing

### Test with Real SMS (Production Mode)

1. Ensure SHA keys are added to Firebase Console
2. Use real phone number
3. Receive actual SMS with OTP
4. Enter OTP to verify

### Test without SMS (Dev Mode)

Click "Dev Mode (Skip Auth)" button on login screen to:

- Upload dummy data to Firestore
- Skip authentication
- Navigate directly to dashboard

### Test with Firebase Test Numbers

1. Add test number in Firebase Console
2. Use test number to login
3. Automatically receive predefined OTP
4. No actual SMS sent (saves costs)

## Security Features

1. **Phone Verification**: Only verified phone numbers can access the app
2. **Auto-Expiry**: OTP codes expire after 60 seconds
3. **Rate Limiting**: Firebase prevents spam requests
4. **Secure Credentials**: Firebase handles token management
5. **Role Validation**: User role checked from Firestore before dashboard access

## Error Handling

Common errors and solutions:

### "invalid-phone-number"

- Solution: Ensure correct format (+880 + 10 digits)

### "too-many-requests"

- Solution: Wait before retrying, or use test phone numbers

### "quota-exceeded"

- Solution: Upgrade Firebase plan or use test numbers

### "invalid-verification-code"

- Solution: Check OTP is correct and not expired

### "session-expired"

- Solution: Request new OTP via resend button

## Data Flow

1. **Login**:

   ```
   User enters phone → AuthService.verifyPhoneNumber()
   → Firebase sends SMS → Navigate to OTPScreen
   ```

2. **OTP Verification**:

   ```
   User enters OTP → AuthService.signInWithOTP()
   → User credential created → createOrUpdateUserDocument()
   → Navigate to appropriate dashboard
   ```

3. **Auto Sign-In**:

   ```
   App starts → AuthWrapper checks authStateChanges
   → User signed in → Fetch role from Firestore
   → Navigate to dashboard
   ```

4. **Logout**:
   ```
   User clicks logout → Confirmation dialog
   → AuthService.signOut() → AuthWrapper detects change
   → Navigate to LoginScreen
   ```

## Next Steps

### Recommended Enhancements:

1. **Profile Completion**: Add screen for users to complete profile after first login
2. **Email/Name**: Collect additional info after phone verification
3. **Profile Photos**: Integrate Firebase Storage for profile pictures
4. **Background Checks**: Store verification documents in Firestore
5. **Multi-factor Auth**: Add email verification as second factor
6. **Social Login**: Add Google/Facebook auth (for customers)

### Integration with Existing Features:

1. **Booking System**: Link bookings to authenticated user UIDs
2. **Reviews**: Associate reviews with verified user accounts
3. **Notifications**: Use FCM with authenticated user tokens
4. **Chat**: Connect in-app chat to user UIDs
5. **Payment**: Link payment methods to user accounts

## Dependencies Added

```yaml
dependencies:
  firebase_auth: ^4.16.0 # Phone authentication
  firebase_core: ^2.24.2 # Already present
  cloud_firestore: ^4.14.0 # Already present
```

## Troubleshooting

### OTP not received?

1. Check phone number format
2. Verify SHA keys in Firebase Console
3. Ensure Phone Authentication is enabled
4. Check Firebase Console logs for errors
5. Try test phone numbers first

### Login successful but navigates to wrong screen?

1. Check user role in Firestore `users` collection
2. Verify role is exactly 'customer' or 'provider'
3. Clear app data and re-login

### App crashes on login?

1. Ensure Firebase is initialized in `main.dart`
2. Check `google-services.json` is up to date
3. Verify all dependencies are installed (`flutter pub get`)
4. Check console logs for detailed error

## Production Checklist

Before deploying to production:

- [ ] Remove "Dev Mode" button from LoginScreen
- [ ] Add SHA-1/SHA-256 for release keystore
- [ ] Set up Cloud Functions for SMS template customization
- [ ] Configure Firebase billing limits
- [ ] Add phone number validation regex for your region
- [ ] Implement rate limiting on client side
- [ ] Add analytics tracking for auth events
- [ ] Test with multiple phone numbers
- [ ] Set up monitoring alerts for auth failures

## Cost Considerations

Firebase Phone Auth pricing:

- **Free tier**: 10,000 verifications/month
- **Paid tier**: $0.01 per verification after free tier

Recommendations:

- Use test numbers during development
- Monitor usage in Firebase Console
- Implement client-side validation to reduce invalid attempts
- Consider SMS provider integration for lower costs at scale

---

**Implementation Status**: ✅ Complete (Core authentication flow)
**Testing Status**: ⚠️ Requires Firebase Console configuration
**Production Ready**: ⚠️ Requires SHA key setup and testing

For questions or issues, check Firebase documentation: https://firebase.google.com/docs/auth/flutter/phone-auth
