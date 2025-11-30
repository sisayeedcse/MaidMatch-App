/**
 * Firebase Cloud Functions for Applink SMS API Integration
 * This file contains two callable functions:
 * 1. sendOTPviaApplink - Generates and sends OTP via Applink SMS API
 * 2. verifyOTP - Verifies the OTP entered by user
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Generate a random 6-digit OTP
 * @returns {string} 6-digit OTP as string
 */
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Cloud Function: sendOTPviaApplink
 *
 * This function:
 * 1. Generates a 6-digit OTP
 * 2. Saves it to Firestore with expiry time (5 minutes)
 * 3. Calls Applink SMS API to send OTP via SMS
 * 4. Returns success/failure response
 *
 * Input: { phoneNumber: "+8801XXXXXXXXX" }
 * Output: { success: true/false, message: "...", requestId: "..." }
 */
exports.sendOTPviaApplink = functions.https.onCall(async (data, context) => {
  try {
    // 1. Validate input
    const phoneNumber = data.phoneNumber;

    if (!phoneNumber) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Phone number is required"
      );
    }

    // Validate Bangladesh phone number format
    const bdPhoneRegex = /^(\+8801|8801|01)[3-9]\d{8}$/;
    if (!bdPhoneRegex.test(phoneNumber)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid Bangladesh phone number format. Use +8801XXXXXXXXX"
      );
    }

    // 2. Generate OTP
    const otp = generateOTP();
    const timestamp = Date.now();
    const expiryTime = timestamp + 5 * 60 * 1000; // 5 minutes from now

    // 3. Save OTP to Firestore
    const otpDoc = {
      phoneNumber: phoneNumber,
      otp: otp,
      createdAt: timestamp,
      expiresAt: expiryTime,
      verified: false,
      attempts: 0,
    };

    await admin.firestore().collection("otps").doc(phoneNumber).set(otpDoc);

    functions.logger.info(`OTP generated for ${phoneNumber}: ${otp}`);

    // 4. Get Applink credentials from environment config
    const applinkConfig = functions.config().applink;

    if (!applinkConfig || !applinkConfig.appid || !applinkConfig.secret) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        'Applink credentials not configured. Run: firebase functions:config:set applink.appid="YOUR_ID" applink.secret="YOUR_SECRET"'
      );
    }

    const applicationId = applinkConfig.appid;
    const password = applinkConfig.secret;

    // 5. Format phone number for Applink (must include tel: prefix)
    let formattedPhone = phoneNumber;
    if (!formattedPhone.startsWith("tel:")) {
      // Ensure phone starts with +880
      if (formattedPhone.startsWith("01")) {
        formattedPhone = "+880" + formattedPhone.substring(1);
      } else if (formattedPhone.startsWith("8801")) {
        formattedPhone = "+" + formattedPhone;
      }
      formattedPhone = "tel:" + formattedPhone;
    }

    // 6. Prepare Applink SMS API request payload
    const smsPayload = {
      version: "1.0",
      applicationId: applicationId,
      password: password,
      message: `Your OTP is ${otp}. Valid for 5 minutes. Do not share with anyone.`,
      destinationAddresses: [formattedPhone],
      encoding: "0", // Text encoding
    };

    functions.logger.info("Sending SMS via Applink API:", {
      phone: formattedPhone,
    });

    // 7. Call Applink SMS API
    const applinkResponse = await axios.post(
      "https://api.applink.com.bd/sms/send",
      smsPayload,
      {
        headers: {
          "Content-Type": "application/json;charset=utf-8",
        },
        timeout: 10000, // 10 seconds timeout
      }
    );

    functions.logger.info("Applink API Response:", applinkResponse.data);

    // 8. Check response status
    const responseData = applinkResponse.data;
    const statusCode = responseData.statusCode;

    // S1000 = Success
    if (statusCode === "S1000") {
      return {
        success: true,
        message: "OTP sent successfully via SMS",
        requestId: responseData.requestId || null,
        expiresIn: 300, // 5 minutes in seconds
      };
    } else {
      // API call succeeded but status indicates failure
      functions.logger.error("Applink API error:", responseData);

      return {
        success: false,
        message: `SMS delivery failed: ${
          responseData.statusDetail || "Unknown error"
        }`,
        statusCode: statusCode,
      };
    }
  } catch (error) {
    functions.logger.error("Error in sendOTPviaApplink:", error);

    // Handle Axios errors
    if (error.response) {
      // API returned error response
      return {
        success: false,
        message: `API Error: ${
          error.response.data?.statusDetail || error.message
        }`,
        statusCode: error.response.data?.statusCode,
      };
    } else if (error.request) {
      // Request made but no response
      return {
        success: false,
        message: "Network error: Could not reach Applink API",
      };
    } else if (error instanceof functions.https.HttpsError) {
      // Re-throw HttpsError for proper error handling in client
      throw error;
    } else {
      // Other errors
      throw new functions.https.HttpsError(
        "internal",
        `Internal error: ${error.message}`
      );
    }
  }
});

/**
 * Cloud Function: verifyOTP
 *
 * This function:
 * 1. Retrieves stored OTP from Firestore
 * 2. Checks if OTP is expired
 * 3. Verifies OTP matches user input
 * 4. Marks OTP as verified if successful
 * 5. Returns success/failure response
 *
 * Input: { phoneNumber: "+8801XXXXXXXXX", otp: "123456" }
 * Output: { success: true/false, message: "..." }
 */
exports.verifyOTP = functions.https.onCall(async (data, context) => {
  try {
    // 1. Validate input
    const phoneNumber = data.phoneNumber;
    const userOTP = data.otp;

    if (!phoneNumber || !userOTP) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Phone number and OTP are required"
      );
    }

    // 2. Retrieve OTP document from Firestore
    const otpDocRef = admin.firestore().collection("otps").doc(phoneNumber);

    const otpDoc = await otpDocRef.get();

    if (!otpDoc.exists) {
      return {
        success: false,
        message:
          "No OTP found for this phone number. Please request a new OTP.",
      };
    }

    const otpData = otpDoc.data();

    // 3. Check if OTP is already verified
    if (otpData.verified) {
      return {
        success: false,
        message: "OTP already used. Please request a new OTP.",
      };
    }

    // 4. Check if OTP has expired
    const currentTime = Date.now();
    if (currentTime > otpData.expiresAt) {
      // Delete expired OTP
      await otpDocRef.delete();

      return {
        success: false,
        message: "OTP has expired. Please request a new OTP.",
      };
    }

    // 5. Check attempt limit (max 3 attempts)
    if (otpData.attempts >= 3) {
      await otpDocRef.delete();

      return {
        success: false,
        message: "Too many failed attempts. Please request a new OTP.",
      };
    }

    // 6. Verify OTP
    if (otpData.otp === userOTP) {
      // OTP is correct - mark as verified
      await otpDocRef.update({
        verified: true,
        verifiedAt: currentTime,
      });

      functions.logger.info(`OTP verified successfully for ${phoneNumber}`);

      return {
        success: true,
        message: "OTP verified successfully!",
        phoneNumber: phoneNumber,
      };
    } else {
      // OTP is incorrect - increment attempts
      await otpDocRef.update({
        attempts: admin.firestore.FieldValue.increment(1),
      });

      const remainingAttempts = 3 - (otpData.attempts + 1);

      return {
        success: false,
        message: `Invalid OTP. ${remainingAttempts} attempt(s) remaining.`,
        remainingAttempts: remainingAttempts,
      };
    }
  } catch (error) {
    functions.logger.error("Error in verifyOTP:", error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      "internal",
      `Verification failed: ${error.message}`
    );
  }
});

/**
 * Optional: Cleanup function to delete expired OTPs
 * Runs daily at midnight
 */
exports.cleanupExpiredOTPs = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("Asia/Dhaka")
  .onRun(async (context) => {
    const now = Date.now();
    const expiredOTPs = await admin
      .firestore()
      .collection("otps")
      .where("expiresAt", "<", now)
      .get();

    const batch = admin.firestore().batch();
    expiredOTPs.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    functions.logger.info(`Deleted ${expiredOTPs.size} expired OTPs`);

    return null;
  });
