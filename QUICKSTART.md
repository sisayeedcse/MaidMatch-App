# Quick Start: Firebase Auth Setup

## Step 1: Generate SHA Keys (Windows PowerShell)

```powershell
cd d:\App\maidmatch\android
.\gradlew signingReport
```

**Copy these from the output:**

- `SHA1: XX:XX:XX:XX:...`
- `SHA256: XX:XX:XX:XX:...`

## Step 2: Add to Firebase Console

1. Open Firebase Console: https://console.firebase.google.com
2. Select your project (maidmatch)
3. Go to: **Project Settings** (⚙️ icon)
4. Scroll to **Your apps** section
5. Click on your Android app
6. Click **Add fingerprint**
7. Paste SHA-1, click Save
8. Click **Add fingerprint** again
9. Paste SHA-256, click Save

## Step 3: Enable Phone Authentication

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click **Sign-in method** tab
3. Click **Phone**
4. Toggle **Enable**
5. Click **Save**

## Step 4: Add Test Phone Numbers (Optional)

1. Still in **Sign-in method** tab
2. Scroll down to **Phone numbers for testing**
3. Click **Add phone number**
4. Enter: `+8801712345678`
5. Enter code: `123456`
6. Click **Add**

Now you can test with +8801712345678 and always receive 123456 as OTP (no SMS sent)

## Step 5: Download Updated google-services.json

1. Firebase Console → **Project Settings**
2. Scroll to **Your apps**
3. Click on Android app
4. Click **Download google-services.json**
5. Replace file at: `d:\App\maidmatch\android\app\google-services.json`

## Step 6: Test the App

### Option A: With Real SMS

```powershell
cd d:\App\maidmatch
flutter run
```

- Enter real phone number (format: 1712345678)
- Receive SMS with OTP
- Enter OTP to login

### Option B: With Test Number

- Enter test phone: 1712345678
- Always use OTP: 123456
- No SMS sent, free testing

### Option C: Dev Mode (Skip Auth)

- Click "Dev Mode (Skip Auth)" button
- Bypasses authentication
- For UI testing only

## Troubleshooting

### "OTP not received"

→ Check SHA keys are added to Firebase Console

### "Invalid phone number"

→ Format must be 10 digits (e.g., 1712345678)

### "Too many requests"

→ Use test phone numbers instead

### "App crashes"

→ Ensure google-services.json is updated after adding SHA keys

## Quick Commands Reference

```powershell
# Install dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk

# Clean and rebuild
flutter clean; flutter pub get; flutter run

# Generate SHA keys
cd android; .\gradlew signingReport
```

## Phone Number Format

**Bangladesh Format**: `+880` + 10 digits

Examples:

- Input: `1712345678` → System adds `+880` → `+8801712345678`
- Input: `1812345678` → System adds `+880` → `+8801812345678`

## User Roles

After login, users are routed based on role:

- `customer` → HomeScreen (browse services)
- `provider` → ProviderDashboardScreen (manage jobs)

Role is set during first login (based on toggle on login screen)

## Files to Review

Key implementation files:

1. `lib/services/auth_service.dart` - Auth logic
2. `lib/screens/login_screen.dart` - Login UI
3. `lib/screens/otp_verification_screen.dart` - OTP UI
4. `lib/widgets/auth_wrapper.dart` - Auto-login

Documentation:

- `FIREBASE_AUTH_GUIDE.md` - Complete guide
- `IMPLEMENTATION_SUMMARY.md` - What was done

## That's It! 🎉

With SHA keys added and Phone Auth enabled in Firebase Console, your app is ready to authenticate users via SMS OTP.

**Need help?** Check FIREBASE_AUTH_GUIDE.md for detailed instructions.
