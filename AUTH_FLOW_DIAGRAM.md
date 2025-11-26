# Firebase Authentication Flow Diagram

## Complete User Journey

```
┌─────────────────────────────────────────────────────────────────────┐
│                         APP STARTS                                  │
│                            ↓                                        │
│                      main.dart                                      │
│                  Firebase.initializeApp()                           │
│                            ↓                                        │
│                     AuthWrapper                                     │
│              (Checks authentication state)                          │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┴──────────────────────┐
        │                                            │
        ▼                                            ▼
┌──────────────────┐                      ┌──────────────────┐
│ User NOT Logged In│                      │ User IS Logged In│
│                  │                      │                  │
│  LoginScreen     │                      │ Fetch User Role  │
└──────────────────┘                      └──────────────────┘
        │                                            │
        │                                            │
        ▼                                            │
┌──────────────────────────────────┐                │
│      LOGIN SCREEN                │                │
│                                  │                │
│  [Customer] [Provider] Toggle    │                │
│                                  │                │
│  Phone: +880 [__________]        │                │
│                                  │                │
│  [Login via SMS OTP]             │                │
│  [Dev Mode (Skip Auth)]          │                │
└──────────────────────────────────┘                │
        │                                            │
        │ (User enters phone)                        │
        │ (Clicks Login via SMS OTP)                 │
        ▼                                            │
┌──────────────────────────────────┐                │
│   AuthService.verifyPhoneNumber()│                │
│                                  │                │
│   → Firebase sends SMS with OTP  │                │
└──────────────────────────────────┘                │
        │                                            │
        │ (OTP sent successfully)                    │
        ▼                                            │
┌──────────────────────────────────┐                │
│   OTP VERIFICATION SCREEN        │                │
│                                  │                │
│   Code sent to +8801712345678    │                │
│                                  │                │
│   [_] [_] [_] [_] [_] [_]        │                │
│                                  │                │
│   Resend OTP in 60 seconds       │                │
│                                  │                │
│   [Verify & Continue]            │                │
└──────────────────────────────────┘                │
        │                                            │
        │ (User enters 6-digit OTP)                  │
        ▼                                            │
┌──────────────────────────────────┐                │
│   AuthService.signInWithOTP()    │                │
│                                  │                │
│   → Validates OTP with Firebase  │                │
│   → Creates UserCredential       │                │
└──────────────────────────────────┘                │
        │                                            │
        │ (OTP verified ✓)                           │
        ▼                                            │
┌──────────────────────────────────┐                │
│ createOrUpdateUserDocument()     │                │
│                                  │                │
│ Firestore: users/{uid}           │                │
│   - phoneNumber                  │                │
│   - role (customer/provider)     │                │
│   - createdAt                    │                │
│   - updatedAt                    │                │
└──────────────────────────────────┘                │
        │                                            │
        └──────────────────┬─────────────────────────┘
                           │
                           │ (User now authenticated)
                           ▼
              ┌────────────────────────┐
              │  Role-Based Navigation │
              └────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
        ▼                                     ▼
┌──────────────────┐              ┌──────────────────────┐
│  role='customer' │              │  role='provider'     │
│                  │              │                      │
│   HomeScreen     │              │ ProviderDashboard    │
│                  │              │      Screen          │
│ - Browse maids   │              │                      │
│ - Filter services│              │ - Manage jobs        │
│ - Make bookings  │              │ - Accept requests    │
│ - View history   │              │ - Track earnings     │
└──────────────────┘              └──────────────────────┘
```

## Logout Flow

```
┌─────────────────────────────────────────────┐
│      User clicks Profile Settings           │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│      User clicks Logout button              │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│    Confirmation Dialog Appears              │
│    "Are you sure you want to logout?"       │
│                                             │
│    [Cancel]  [Logout]                       │
└─────────────────────────────────────────────┘
                    │
                    │ (User confirms)
                    ▼
┌─────────────────────────────────────────────┐
│      AuthService.signOut()                  │
│                                             │
│      → Clears Firebase Auth session         │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│    AuthWrapper detects auth state change    │
│                                             │
│    authStateChanges stream emits null       │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│      Navigate to LoginScreen                │
│                                             │
│      User must re-authenticate              │
└─────────────────────────────────────────────┘
```

## Auto-Login on App Restart

```
┌─────────────────────────────────────────────┐
│           User closes app                   │
└─────────────────────────────────────────────┘
                    │
                    │ (Later...)
                    ▼
┌─────────────────────────────────────────────┐
│           User reopens app                  │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│              main.dart                      │
│        Firebase.initializeApp()             │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│            AuthWrapper                      │
│   Checks: authStateChanges stream           │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│    Firebase Auth Token Still Valid?         │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
   ┌─────────┐           ┌──────────┐
   │   NO    │           │   YES    │
   │         │           │          │
   │ Show    │           │  Fetch   │
   │ Login   │           │  Role    │
   │ Screen  │           │          │
   └─────────┘           └──────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   Navigate to    │
                    │   Dashboard      │
                    │                  │
                    │ (No login needed)│
                    └──────────────────┘
```

## Error Handling Flow

```
┌─────────────────────────────────────────────┐
│      Error During Authentication            │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┬─────────────────┬────────────────┐
        │                       │                 │                │
        ▼                       ▼                 ▼                ▼
┌──────────────┐    ┌──────────────────┐  ┌────────────┐  ┌──────────────┐
│invalid-phone │    │too-many-requests │  │quota-      │  │session-      │
│   -number    │    │                  │  │ exceeded   │  │  expired     │
└──────────────┘    └──────────────────┘  └────────────┘  └──────────────┘
        │                       │                 │                │
        ▼                       ▼                 ▼                ▼
    Show Error              Show Error       Show Error       Show Error
    SnackBar                SnackBar         SnackBar         SnackBar
        │                       │                 │                │
        ▼                       ▼                 ▼                ▼
  "Phone number         "Too many          "SMS quota        "OTP expired
   is invalid"           requests"          exceeded"        Request new"
        │                       │                 │                │
        └───────────────────────┴─────────────────┴────────────────┘
                                │
                                ▼
                    ┌──────────────────────┐
                    │   User Can Retry     │
                    │                      │
                    │ - Fix phone number   │
                    │ - Wait before retry  │
                    │ - Use test numbers   │
                    │ - Request new OTP    │
                    └──────────────────────┘
```

## Data Storage Structure

```
Firestore Database
│
└── users/ (collection)
    │
    ├── {uid-1}/ (document - Customer)
    │   ├── uid: "abc123..."
    │   ├── phoneNumber: "+8801712345678"
    │   ├── role: "customer"
    │   ├── name: "John Doe"
    │   ├── email: "john@example.com"
    │   ├── address: "123 Main St, Dhaka"
    │   ├── emergencyContacts: ["01812345678"]
    │   ├── createdAt: Timestamp
    │   └── updatedAt: Timestamp
    │
    └── {uid-2}/ (document - Provider)
        ├── uid: "xyz789..."
        ├── phoneNumber: "+8801812345678"
        ├── role: "provider"
        ├── name: "Jane Smith"
        ├── email: "jane@example.com"
        ├── skills: ["Cook", "Cleaner"]
        ├── rating: 4.8
        ├── completedJobs: 150
        ├── isAvailable: true
        ├── bio: "Experienced professional..."
        ├── verifications: ["NID", "Police"]
        ├── createdAt: Timestamp
        └── updatedAt: Timestamp
```

## Security Rules (Recommended)

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own document
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Maids collection (public read, authenticated write)
    match /maids/{maidId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Bookings (only authenticated users)
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Testing Scenarios

### Scenario 1: First Time User (Customer)

```
1. Open app → See LoginScreen
2. Toggle: [Customer] selected
3. Enter phone: 1712345678
4. Click "Login via SMS OTP"
5. Receive SMS with code: 123456
6. Enter OTP: 1-2-3-4-5-6
7. Auto-submit → Verify
8. Create user document (role='customer')
9. Navigate to HomeScreen
10. ✓ Success - User can browse services
```

### Scenario 2: First Time User (Provider)

```
1. Open app → See LoginScreen
2. Toggle: [Provider] selected
3. Enter phone: 1812345678
4. Click "Login via SMS OTP"
5. Receive SMS with code: 654321
6. Enter OTP: 6-5-4-3-2-1
7. Auto-submit → Verify
8. Create user document (role='provider')
9. Navigate to ProviderDashboardScreen
10. ✓ Success - User can manage jobs
```

### Scenario 3: Returning User

```
1. Open app → AuthWrapper checks
2. Firebase Auth token valid
3. Fetch role from Firestore
4. role='customer' → Navigate to HomeScreen
5. ✓ Success - No login required
```

### Scenario 4: Logout and Re-login

```
1. User in HomeScreen
2. Navigate to Profile Settings
3. Click Logout
4. Confirm dialog
5. signOut() → Clear session
6. AuthWrapper detects → Navigate to LoginScreen
7. User must re-authenticate
8. ✓ Success - Secure logout
```

### Scenario 5: Invalid OTP

```
1. User at OTP screen
2. Enter wrong code: 0-0-0-0-0-0
3. Click Verify
4. Firebase returns error
5. Show SnackBar: "Invalid OTP code"
6. User can retry or resend
7. ✓ Success - Error handled gracefully
```

### Scenario 6: OTP Expired

```
1. User receives OTP
2. Wait 61 seconds
3. Enter OTP
4. Firebase returns error: session-expired
5. Show SnackBar: "OTP expired. Request new one."
6. User clicks "Resend OTP"
7. New OTP sent
8. ✓ Success - User can continue
```

## Component Interaction

```
┌──────────────────────────────────────────────────────────────┐
│                         main.dart                            │
│                  (App Entry Point)                           │
│                  Initializes Firebase                        │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                      AuthWrapper                             │
│             (Widget - Smart Navigator)                       │
│          Listens to: authStateChanges stream                 │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            ├──→ Uses: AuthService
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                     AuthService                              │
│               (Singleton Service Class)                      │
│     Methods: verifyPhone, signIn, signOut, getRole           │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            ├──→ Reads/Writes: Firebase Auth
                            ├──→ Reads/Writes: Firestore (users)
                            ├──→ Uses: UserModel
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                      UserModel                               │
│                  (Data Model Class)                          │
│        Methods: fromFirestore(), toFirestore()               │
└──────────────────────────────────────────────────────────────┘
```

## Key Advantages of This Architecture

✅ **Separation of Concerns**: UI, business logic, data models are separate
✅ **Reusability**: AuthService can be used from any screen
✅ **Testability**: Services can be mocked for unit tests
✅ **Maintainability**: Changes to auth logic don't affect UI
✅ **Scalability**: Easy to add new features (email, social login)
✅ **Type Safety**: UserModel ensures data consistency
✅ **State Management**: Stream-based auth state (reactive)
✅ **Error Handling**: Centralized error messages
✅ **Security**: Firebase handles tokens, encryption
✅ **Performance**: Singleton pattern prevents multiple instances
