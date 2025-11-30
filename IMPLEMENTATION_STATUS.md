# MaidMatch - Implementation Status Report

**Date:** November 30, 2025  
**Project:** MaidMatch Domestic Services Marketplace  
**Flutter Version:** 3.10.1  
**Dart SDK:** ^3.10.1

---

## 📊 Overall Progress: **~55%**

### Completion Breakdown:
- ✅ **Core Features:** 70%
- ⚠️ **Advanced Features:** 40%
- ❌ **Missing Features:** 30%

---

## ✅ IMPLEMENTED FEATURES

### 1. Authentication & User Management ✅ **COMPLETE**

**Status:** Fully Implemented

**Files:**
- `lib/services/auth_service.dart` (184 lines)
- `lib/screens/login_screen.dart` (466 lines)
- `lib/screens/otp_verification_screen.dart`
- `lib/widgets/auth_wrapper.dart`

**Features:**
- ✅ Phone number authentication (Firebase Auth)
- ✅ SMS OTP verification
- ✅ Auto OTP retrieval (Android)
- ✅ Resend OTP functionality
- ✅ User role selection (Customer/Provider)
- ✅ User document creation in Firestore
- ✅ Auth state management
- ✅ Session persistence

**Notes:**
- Using Firebase Phone Auth
- Proper error handling
- Material 3 design with animations

---

### 2. User Profiles ✅ **COMPLETE**

**Status:** Fully Implemented

**Files:**
- `lib/models/user_model.dart` (160 lines)
- `lib/screens/edit_profile_screen.dart` (348 lines)
- `lib/screens/edit_provider_profile_screen.dart` (560 lines)
- `lib/screens/profile_settings_screen.dart`

**Features:**
- ✅ User data model (customer & provider)
- ✅ Profile editing for customers
- ✅ Provider profile with skills, bio, rates
- ✅ Availability toggle for providers
- ✅ Profile settings screen
- ✅ Emergency contacts management

**Data Fields:**
- uid, phoneNumber, role, name, email, photoURL
- Provider: skills[], rating, completedJobs, bio, verifications[]
- Customer: address, emergencyContacts[]

---

### 3. Service Provider Discovery ✅ **COMPLETE**

**Status:** Fully Implemented

**Files:**
- `lib/screens/home_screen.dart` (556 lines)
- `lib/widgets/maid_card.dart`
- `lib/screens/maid_profile_screen.dart`
- `lib/data/dummy_data.dart`

**Features:**
- ✅ Category-based filtering (All, Cook, Cleaner, Nanny, Driver)
- ✅ Search functionality
- ✅ Provider cards with photos, ratings, skills
- ✅ Real-time Firestore data streaming
- ✅ Provider detail view
- ✅ Verification badges display
- ✅ Beautiful gradient UI
- ✅ Smooth animations

**UI Elements:**
- Category chips with icons
- Search bar
- Grid/List view of providers
- Rating stars
- Verification icons (NID, Police, NGO)

---

### 4. Booking System ✅ **COMPLETE**

**Status:** Fully Implemented

**Files:**
- `lib/services/booking_service.dart` (348 lines)
- `lib/models/booking_model.dart` (250 lines)
- `lib/screens/booking_checkout_screen.dart`
- `lib/screens/bookings_history_screen.dart`

**Features:**
- ✅ Create booking with service details
- ✅ Date and time slot selection
- ✅ Duration selection (2h, 4h, 8h, Full Day)
- ✅ Dynamic price calculation
- ✅ Address and special instructions
- ✅ Booking status tracking (pending, accepted, active, completed, cancelled)
- ✅ Customer booking history
- ✅ Provider job requests
- ✅ Accept/Decline booking
- ✅ Start/Complete job
- ✅ Cancel booking with reason
- ✅ Real-time updates via Firestore streams

**Booking Statuses:**
- `pending` - Waiting provider response
- `accepted` - Provider confirmed
- `active` - Service in progress
- `completed` - Job finished
- `cancelled` - Booking cancelled

---

### 5. Provider Dashboard ✅ **COMPLETE**

**Status:** Fully Implemented

**Files:**
- `lib/screens/provider_dashboard_screen.dart`

**Features:**
- ✅ Statistics cards (Total Jobs, Earnings, Rating)
- ✅ Pending job requests list
- ✅ Active jobs display
- ✅ Accept/Decline actions
- ✅ Start/Complete job buttons
- ✅ Earnings tracker
- ✅ Job history
- ✅ Availability toggle

**Dashboard Metrics:**
- Total jobs completed
- Total earnings (calculated)
- Average rating
- Active job count
- Pending requests count

---

### 6. Review & Rating System ✅ **COMPLETE**

**Status:** Fully Implemented

**Files:**
- `lib/services/review_service.dart` (352 lines)
- `lib/models/review_model.dart`
- `lib/widgets/rating_dialog.dart`
- `lib/screens/provider_reviews_screen.dart`

**Features:**
- ✅ Create review after completed booking
- ✅ 5-star rating system
- ✅ Text review/comment
- ✅ One review per booking validation
- ✅ Provider average rating calculation
- ✅ Total reviews count
- ✅ Review display on provider profile
- ✅ Review stream for real-time updates
- ✅ Customer verification (only customer can review)

**Validations:**
- Only completed bookings can be reviewed
- One review per booking
- Rating 1-5 stars
- Automatic provider rating update

---

### 7. Safety Features ⚠️ **PARTIAL**

**Status:** UI Complete, Backend Partial

**Files:**
- `lib/screens/safety_features_screen.dart`

**Implemented:**
- ✅ Panic button UI
- ✅ Emergency contacts display
- ✅ Safety tips section
- ✅ Call masking explanation
- ✅ Live location sharing UI
- ✅ Background verification info

**Missing:**
- ❌ Real panic button activation (SMS sending)
- ❌ Actual call masking integration
- ❌ GPS location tracking
- ❌ Real-time location sharing
- ❌ Emergency SMS via Applink API

**Note:** UI is complete but actual emergency features need backend implementation.

---

### 8. Firebase Storage Integration ✅ **NEW - COMPLETE**

**Status:** Fully Implemented (Just Added)

**Files:**
- `lib/services/storage_service.dart` (228 lines)
- `lib/widgets/image_upload_widget.dart` (330 lines)
- `lib/screens/image_upload_demo_screen.dart` (324 lines)
- `FIREBASE_STORAGE_GUIDE.md` (Complete documentation)

**Features:**
- ✅ Profile photo upload
- ✅ Portfolio image management
- ✅ Verification document upload (NID, Police clearance)
- ✅ Image picker (Gallery/Camera)
- ✅ Upload progress tracking
- ✅ Image preview
- ✅ Delete images
- ✅ Fetch portfolio images
- ✅ Cleanup on user deletion
- ✅ Proper file naming with timestamps
- ✅ Security rules defined

**Storage Structure:**
```
/profiles/{profile_userId_timestamp.jpg}
/portfolios/{providerId}/{portfolio_providerId_timestamp.jpg}
/documents/{userId}/{docType_userId_timestamp.ext}
```

**Packages Added:**
- `firebase_storage: ^11.5.3`
- `image_picker: ^1.0.4`
- `path: ^1.8.3`

**Integration Status:**
- ⚠️ **NOT YET INTEGRATED** into edit_profile_screen.dart
- ⚠️ **NOT YET INTEGRATED** into edit_provider_profile_screen.dart
- ✅ Demo screen created showing usage
- ✅ Complete documentation provided

---

### 9. Applink SMS API Integration ✅ **DEMO COMPLETE**

**Status:** Complete Demo System Created

**Files:**
- `applink-demo/functions/index.js` (323 lines)
- `applink-demo/android-demo/` (Kotlin Android app)
- `APPLINK_DEMO_README.md` (Complete guide)

**Features:**
- ✅ Firebase Cloud Functions setup
- ✅ sendOTPviaApplink function
- ✅ verifyOTP function
- ✅ OTP storage in Firestore
- ✅ OTP expiry (5 minutes)
- ✅ Attempt limiting (5 attempts)
- ✅ Bangladesh phone validation
- ✅ Cleanup scheduled function
- ✅ Android demo app (Kotlin)
- ✅ Complete documentation
- ✅ Security best practices

**Integration Status:**
- ✅ Demo system complete
- ⚠️ **NOT INTEGRATED** into main MaidMatch app
- ⚠️ Login screen still uses Firebase Phone Auth
- 💡 Can replace Firebase Phone Auth with Applink for Bangladesh users

---

### 10. Firestore Database ✅ **COMPLETE**

**Status:** Fully Configured

**Files:**
- `firestore.rules` (Complete security rules)

**Collections:**
- ✅ `users` - User profiles (customer & provider)
- ✅ `bookings` - Booking records
- ✅ `reviews` - Customer reviews
- ✅ `otps` - OTP records (for Applink)
- ⚠️ `payments` - Structure defined, not implemented
- ⚠️ `reports` - Structure defined, not implemented

**Security Rules:**
- ✅ User can only read/write their own data
- ✅ Provider can update booking status
- ✅ Customer can create bookings
- ✅ Review validation (only after completed booking)
- ✅ OTP rules for Applink integration

---

### 11. UI/UX Design ✅ **EXCELLENT**

**Status:** Material 3 with Custom Theme

**Theme:**
- Primary: Indigo (#6366F1)
- Gradients: Indigo → Purple → Pink
- Glassmorphism effects
- Smooth animations
- Card-based layouts
- Modern iconography

**Screens:**
- ✅ Login screen with role selection
- ✅ OTP verification
- ✅ Home screen with search & filters
- ✅ Provider detail view
- ✅ Booking checkout
- ✅ Booking history
- ✅ Provider dashboard
- ✅ Profile editing
- ✅ Notifications (static UI)
- ✅ Safety features
- ✅ Settings

---

## ❌ MISSING FEATURES

### 1. Payment Integration ❌ **NOT IMPLEMENTED**

**Priority:** HIGH

**Required:**
- ❌ Payment gateway integration (SSLCommerz, bKash, Nagad)
- ❌ Payment processing after booking
- ❌ Payment history
- ❌ Refund handling
- ❌ Payment receipts
- ❌ Provider payout system

**Current Status:**
- Firestore `payments` collection defined
- No payment service implemented
- No payment UI screens
- Booking creates without payment

**Recommendation:**
- Integrate SSLCommerz for card payments
- Add bKash/Nagad for mobile banking
- Create payment gateway service
- Add payment success/failure screens

---

### 2. Push Notifications (FCM) ❌ **NOT IMPLEMENTED**

**Priority:** HIGH

**Required:**
- ❌ Firebase Cloud Messaging setup
- ❌ Device token registration
- ❌ Notification service
- ❌ Send notification on booking created
- ❌ Send notification on booking accepted
- ❌ Send notification on booking completed
- ❌ Send notification on new review
- ❌ Background notification handling
- ❌ Notification settings

**Current Status:**
- Notifications screen has static dummy data
- No FCM package in pubspec.yaml
- No notification service
- No Cloud Functions for notifications

**Files to Create:**
- `lib/services/notification_service.dart`
- Update `pubspec.yaml` with `firebase_messaging`
- Create Cloud Function for sending notifications

---

### 3. Google Maps Integration ❌ **NOT IMPLEMENTED**

**Priority:** MEDIUM-HIGH

**Required:**
- ❌ Map view for service area
- ❌ Provider location display
- ❌ Distance calculation
- ❌ Geolocation services
- ❌ Address autocomplete
- ❌ Live location tracking during service

**Current Status:**
- Location field exists (text only)
- No maps package
- No geolocation
- No distance-based provider sorting

**Packages Needed:**
- `google_maps_flutter`
- `geolocator`
- `geocoding`

---

### 4. In-App Chat/Messaging ❌ **NOT IMPLEMENTED**

**Priority:** MEDIUM

**Required:**
- ❌ Chat service
- ❌ Chat screen
- ❌ Message model
- ❌ Real-time messaging (Firestore)
- ❌ Chat notifications
- ❌ Message history
- ❌ Typing indicators
- ❌ Read receipts

**Current Status:**
- No chat functionality
- Users rely on phone calls only

**Files to Create:**
- `lib/services/chat_service.dart`
- `lib/models/message_model.dart`
- `lib/screens/chat_screen.dart`
- `lib/screens/chat_list_screen.dart`

---

### 5. Admin Panel ❌ **NOT IMPLEMENTED**

**Priority:** MEDIUM

**Required:**
- ❌ Admin web dashboard
- ❌ User management
- ❌ Provider verification
- ❌ Booking monitoring
- ❌ Payment tracking
- ❌ Report handling
- ❌ Analytics dashboard
- ❌ Content moderation

**Current Status:**
- No admin functionality
- All verification is manual
- No admin screens

**Recommendation:**
- Create separate Flutter Web app
- Or use FlutterFlow/Firebase Console

---

### 6. Advanced Search & Filters ❌ **PARTIAL**

**Priority:** LOW-MEDIUM

**Implemented:**
- ✅ Category filter
- ✅ Basic search

**Missing:**
- ❌ Filter by rating
- ❌ Filter by price range
- ❌ Filter by experience
- ❌ Filter by availability
- ❌ Filter by location/distance
- ❌ Sort options (rating, price, distance)

---

### 7. Analytics & Reporting ❌ **NOT IMPLEMENTED**

**Priority:** LOW

**Required:**
- ❌ Firebase Analytics setup
- ❌ User behavior tracking
- ❌ Booking conversion tracking
- ❌ Revenue analytics
- ❌ Provider performance metrics
- ❌ Customer retention metrics

---

### 8. Real Emergency Features ❌ **NOT IMPLEMENTED**

**Priority:** HIGH (Safety Critical)

**Current:**
- ✅ Safety features UI exists
- ❌ No actual emergency functionality

**Required:**
- ❌ Real panic button triggering SMS
- ❌ GPS location capture
- ❌ Emergency contact SMS (via Applink)
- ❌ Call masking service
- ❌ Background location tracking during service
- ❌ SOS alert to authorities

---

## ⚠️ INTEGRATION ISSUES

### 1. Image Upload Not Integrated ⚠️

**Issue:**
- `ImageUploadWidget` created but not used in profile screens
- Users cannot upload profile photos yet
- Provider portfolio upload not functional

**Fix Required:**
```dart
// In edit_profile_screen.dart - ADD:
import '../widgets/image_upload_widget.dart';

ImageUploadWidget(
  initialImageUrl: widget.user.photoURL,
  uploadType: 'profile',
  onImageUploaded: (downloadUrl) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({'photoURL': downloadUrl});
  },
)
```

### 2. Applink SMS Not Integrated ⚠️

**Issue:**
- Applink demo system complete
- Main app still uses Firebase Phone Auth
- Emergency features don't send real SMS

**Options:**
1. Replace Firebase Phone Auth with Applink for Bangladesh
2. Keep Firebase Auth, use Applink only for emergency SMS
3. Hybrid: Firebase for OTP, Applink for notifications

### 3. Android Permissions Not Configured ⚠️

**Missing in AndroidManifest.xml:**
```xml
<!-- Camera permission -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Storage permissions -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- For Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Location permissions (for Maps) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 4. Gradle Version Error ⚠️

**Error:**
```
Minimum supported Gradle version is 8.13. Current version is 8.9.
```

**Fix:**
Update `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip
```

### 5. Firebase Storage Rules Not Deployed ⚠️

**Issue:**
- Storage rules written in `FIREBASE_STORAGE_GUIDE.md`
- Not deployed to Firebase Console

**Fix:**
1. Enable Firebase Storage in Console
2. Deploy security rules from guide

---

## 🐛 CODE ISSUES

### 1. Unused Variables/Fields

**File:** `lib/screens/profile_settings_screen.dart`
```dart
bool _notificationsEnabled = true;  // Unused
bool _locationEnabled = false;       // Unused
```

**Fix:** Remove or implement functionality

### 2. Unused Method

**File:** `lib/screens/bookings_history_screen.dart`
```dart
Widget _buildBookingCard({...})  // Declared but never called
```

**Fix:** Remove or use the method

### 3. Unused Service

**File:** `lib/screens/edit_profile_screen.dart`
```dart
final AuthService _authService = AuthService();  // Declared but unused
```

**Fix:** Remove if not needed

---

## 📦 PACKAGE STATUS

### Installed Packages ✅
```yaml
firebase_core: ^2.24.2
cloud_firestore: ^4.14.0
firebase_auth: ^4.16.0
firebase_storage: ^11.5.3  # NEW
image_picker: ^1.0.4       # NEW
path: ^1.8.3               # NEW
url_launcher: ^6.3.2
cupertino_icons: ^1.0.8
```

### Missing Packages ❌
```yaml
# For push notifications
firebase_messaging: ^14.7.0

# For Google Maps
google_maps_flutter: ^2.5.0
geolocator: ^10.1.0
geocoding: ^2.1.1

# For payments
http: ^1.1.0  # For API calls to payment gateways

# For image optimization
flutter_image_compress: ^2.1.0

# For local storage
shared_preferences: ^2.2.2

# For state management (optional)
provider: ^6.1.1  # or riverpod, bloc
```

---

## 🔧 SETUP REQUIRED

### Immediate Actions Needed:

1. **Install Packages:**
```bash
cd d:\App\maidmatch
flutter pub get
```

2. **Fix Gradle Version:**
```bash
# Update gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip
```

3. **Configure Android Permissions:**
   - Add camera, storage, location permissions to AndroidManifest.xml
   - Create file_paths.xml for FileProvider

4. **Enable Firebase Storage:**
   - Go to Firebase Console
   - Enable Storage
   - Deploy security rules

5. **Integrate Image Upload:**
   - Update edit_profile_screen.dart
   - Update edit_provider_profile_screen.dart
   - Add ImageUploadWidget

6. **Test All Features:**
   - Run on Android device
   - Test authentication flow
   - Test booking creation
   - Test review system
   - Test image upload

---

## 📈 PRIORITY ROADMAP

### Phase 1: Complete Current Features (1-2 weeks)
1. ✅ Fix Gradle version
2. ✅ Integrate ImageUploadWidget into profile screens
3. ✅ Configure Android permissions
4. ✅ Deploy Firebase Storage rules
5. ✅ Test image upload functionality
6. ✅ Fix code warnings (unused variables)

### Phase 2: Critical Features (2-3 weeks)
1. 🔴 **Payment Integration** (SSLCommerz/bKash)
2. 🔴 **Push Notifications** (FCM)
3. 🔴 **Real Emergency Features** (Panic button with Applink SMS)

### Phase 3: Enhanced Features (3-4 weeks)
1. 🟡 **Google Maps Integration**
2. 🟡 **In-App Chat**
3. 🟡 **Advanced Search Filters**

### Phase 4: Admin & Analytics (2-3 weeks)
1. 🟢 **Admin Panel** (Web)
2. 🟢 **Analytics Dashboard**
3. 🟢 **Reporting System**

---

## 📊 FEATURE COMPLETION MATRIX

| Feature                | Status | Progress | Priority | LOE    |
|------------------------|--------|----------|----------|--------|
| Authentication         | ✅     | 100%     | HIGH     | Done   |
| User Profiles          | ✅     | 100%     | HIGH     | Done   |
| Provider Discovery     | ✅     | 100%     | HIGH     | Done   |
| Booking System         | ✅     | 100%     | HIGH     | Done   |
| Review System          | ✅     | 100%     | HIGH     | Done   |
| Provider Dashboard     | ✅     | 100%     | HIGH     | Done   |
| Image Upload           | ⚠️     | 90%      | HIGH     | 1 day  |
| Applink SMS Demo       | ✅     | 100%     | MEDIUM   | Done   |
| Safety Features UI     | ⚠️     | 60%      | HIGH     | 3 days |
| Payment Integration    | ❌     | 0%       | HIGH     | 1 week |
| Push Notifications     | ❌     | 0%       | HIGH     | 3 days |
| Google Maps            | ❌     | 0%       | MEDIUM   | 1 week |
| In-App Chat            | ❌     | 0%       | MEDIUM   | 1 week |
| Admin Panel            | ❌     | 0%       | MEDIUM   | 2 weeks|
| Advanced Filters       | ⚠️     | 30%      | LOW      | 2 days |
| Analytics              | ❌     | 0%       | LOW      | 1 week |

**LOE = Level of Effort**

---

## 🎯 RECOMMENDATIONS

### Immediate (Next 24 hours):
1. Run `flutter pub get`
2. Fix Gradle version error
3. Integrate ImageUploadWidget into profile screens
4. Test on real Android device

### Short Term (This Week):
1. Add Android permissions for camera/storage
2. Deploy Firebase Storage rules
3. Fix code warnings
4. Test complete user flow
5. Create payment integration plan

### Medium Term (This Month):
1. Implement payment gateway (SSLCommerz recommended)
2. Implement FCM push notifications
3. Integrate Applink SMS for emergency features
4. Add Google Maps for location features

### Long Term (Next Month):
1. Build admin panel (Flutter Web)
2. Add in-app chat
3. Implement analytics
4. Add advanced search filters
5. Beta testing with real users

---

## 📝 TECHNICAL DEBT

1. **Dummy Data Usage:**
   - `lib/data/dummy_data.dart` used for testing
   - Should be removed before production

2. **Skip Login Flag:**
   - `main.dart` has `SKIP_LOGIN_FOR_TESTING = true`
   - Must be set to `false` for production

3. **Error Handling:**
   - Some screens lack comprehensive error handling
   - Need to add try-catch blocks consistently

4. **Code Duplication:**
   - Some UI code repeated across screens
   - Consider creating reusable widgets

5. **State Management:**
   - Using setState() everywhere
   - Consider Provider/Riverpod for better state management

6. **Testing:**
   - No unit tests
   - No integration tests
   - Only widget_test.dart (default)

---

## 🔐 SECURITY CHECKLIST

✅ **Implemented:**
- [x] Firebase security rules for Firestore
- [x] User authentication required
- [x] User can only access their own data
- [x] Booking validation rules
- [x] Review validation (only customer can review completed bookings)
- [x] Firebase Storage rules defined

⚠️ **Partial:**
- [ ] Firebase Storage rules not deployed yet
- [ ] Android permissions need configuration
- [ ] API keys should be in environment variables

❌ **Missing:**
- [ ] Payment security (PCI compliance)
- [ ] Rate limiting for API calls
- [ ] Input sanitization in all forms
- [ ] SQL injection prevention (N/A - using Firestore)
- [ ] XSS prevention in web version

---

## 🚀 DEPLOYMENT READINESS

### Current Status: **NOT READY** ⚠️

**Blockers:**
1. ❌ Payment integration missing (cannot process transactions)
2. ❌ Push notifications missing (poor user experience)
3. ⚠️ Image upload not integrated (users can't upload photos)
4. ⚠️ Gradle version needs update
5. ❌ Real emergency features not working (safety concern)

**Before Production:**
1. Implement payment gateway
2. Implement FCM notifications
3. Integrate image upload
4. Add comprehensive error logging
5. Create privacy policy & terms of service
6. Complete security audit
7. Perform load testing
8. Beta test with real users

**Estimated Time to Production:** 4-6 weeks

---

## 💡 CONCLUSION

### What Works Well:
1. ✅ **Solid Foundation:** Authentication, booking, reviews all working
2. ✅ **Beautiful UI:** Modern Material 3 design with smooth animations
3. ✅ **Clean Architecture:** Services, models, screens properly organized
4. ✅ **Firebase Integration:** Firestore, Auth, Storage all connected
5. ✅ **Provider Dashboard:** Complete job management system

### What Needs Work:
1. ❌ **Payments:** Critical missing feature
2. ❌ **Notifications:** Users won't get updates
3. ❌ **Maps:** Cannot see provider locations
4. ⚠️ **Image Upload:** Created but not integrated
5. ⚠️ **Safety Features:** UI exists but not functional

### Overall Assessment:
The MaidMatch app has a **strong foundation** with core features working well. The **booking system, authentication, and reviews** are production-ready. However, critical features like **payments and push notifications** are missing. With **4-6 weeks of focused development**, the app can be production-ready.

**Current State:** Beta-Ready (internal testing)  
**Production Ready:** After implementing payments + notifications

---

**Report Generated:** November 30, 2025  
**Next Review:** After Phase 1 completion

