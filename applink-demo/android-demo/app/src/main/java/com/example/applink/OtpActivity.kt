package com.example.applink

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.functions.ktx.functions
import com.google.firebase.ktx.Firebase

/**
 * OtpActivity - OTP Verification Screen
 * 
 * This activity allows users to:
 * 1. Enter the OTP received via SMS
 * 2. Verify OTP through Firebase Cloud Function
 * 3. Handle success/failure responses
 */
class OtpActivity : AppCompatActivity() {

    // Firebase Cloud Functions instance
    private lateinit var functions: FirebaseFunctions

    // UI Components
    private lateinit var phoneDisplay: TextView
    private lateinit var otpInput: EditText
    private lateinit var verifyButton: Button
    private lateinit var resendButton: Button
    private lateinit var progressBar: ProgressBar

    // Phone number passed from LoginActivity
    private var phoneNumber: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_otp)

        // Initialize Firebase Functions
        functions = Firebase.functions

        // Get phone number from intent
        phoneNumber = intent.getStringExtra("phoneNumber") ?: ""

        // Initialize UI components
        phoneDisplay = findViewById(R.id.phoneDisplay)
        otpInput = findViewById(R.id.otpInput)
        verifyButton = findViewById(R.id.verifyButton)
        resendButton = findViewById(R.id.resendButton)
        progressBar = findViewById(R.id.progressBar)

        // Display phone number
        phoneDisplay.text = "OTP sent to $phoneNumber"

        // Set click listener for Verify button
        verifyButton.setOnClickListener {
            val otp = otpInput.text.toString().trim()
            
            if (validateOTP(otp)) {
                verifyOTP(otp)
            }
        }

        // Set click listener for Resend button
        resendButton.setOnClickListener {
            resendOTP()
        }
    }

    /**
     * Validate OTP input (must be 6 digits)
     */
    private fun validateOTP(otp: String): Boolean {
        if (otp.isEmpty()) {
            otpInput.error = "OTP is required"
            return false
        }

        if (otp.length != 6) {
            otpInput.error = "OTP must be 6 digits"
            return false
        }

        if (!otp.all { it.isDigit() }) {
            otpInput.error = "OTP must contain only numbers"
            return false
        }

        return true
    }

    /**
     * Call Firebase Cloud Function to verify OTP
     */
    private fun verifyOTP(otp: String) {
        // Show loading state
        setLoadingState(true)

        // Prepare data for Cloud Function
        val data = hashMapOf(
            "phoneNumber" to phoneNumber,
            "otp" to otp
        )

        // Call the verifyOTP Cloud Function
        functions
            .getHttpsCallable("verifyOTP")
            .call(data)
            .addOnSuccessListener { result ->
                setLoadingState(false)
                
                // Parse response from Cloud Function
                val response = result.data as? Map<*, *>
                val success = response?.get("success") as? Boolean ?: false
                val message = response?.get("message") as? String ?: "Unknown response"

                if (success) {
                    // OTP verified successfully
                    Toast.makeText(
                        this,
                        "✓ Verification successful!",
                        Toast.LENGTH_LONG
                    ).show()

                    // Navigate to main app or finish login
                    // For demo, just show success and finish
                    finish()
                } else {
                    // OTP verification failed
                    Toast.makeText(
                        this,
                        message,
                        Toast.LENGTH_LONG
                    ).show()

                    // Clear OTP input for retry
                    otpInput.text.clear()
                    otpInput.requestFocus()
                }
            }
            .addOnFailureListener { exception ->
                setLoadingState(false)
                
                // Handle errors
                Toast.makeText(
                    this,
                    "Error: ${exception.message}",
                    Toast.LENGTH_LONG
                ).show()
                
                exception.printStackTrace()
            }
    }

    /**
     * Resend OTP by calling sendOTPviaApplink again
     */
    private fun resendOTP() {
        // Show loading state
        setLoadingState(true)

        // Prepare data for Cloud Function
        val data = hashMapOf(
            "phoneNumber" to phoneNumber
        )

        // Call the sendOTPviaApplink Cloud Function
        functions
            .getHttpsCallable("sendOTPviaApplink")
            .call(data)
            .addOnSuccessListener { result ->
                setLoadingState(false)
                
                // Parse response
                val response = result.data as? Map<*, *>
                val success = response?.get("success") as? Boolean ?: false

                if (success) {
                    Toast.makeText(
                        this,
                        "New OTP sent!",
                        Toast.LENGTH_SHORT
                    ).show()
                    
                    // Clear previous OTP input
                    otpInput.text.clear()
                } else {
                    val message = response?.get("message") as? String ?: "Failed to resend OTP"
                    Toast.makeText(this, message, Toast.LENGTH_LONG).show()
                }
            }
            .addOnFailureListener { exception ->
                setLoadingState(false)
                Toast.makeText(
                    this,
                    "Error: ${exception.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
    }

    /**
     * Toggle loading state (disable buttons, show progress)
     */
    private fun setLoadingState(isLoading: Boolean) {
        verifyButton.isEnabled = !isLoading
        resendButton.isEnabled = !isLoading
        otpInput.isEnabled = !isLoading
        progressBar.visibility = if (isLoading) ProgressBar.VISIBLE else ProgressBar.GONE
        
        verifyButton.text = if (isLoading) "Verifying..." else "Verify OTP"
    }
}
