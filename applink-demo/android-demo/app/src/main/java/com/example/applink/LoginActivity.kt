package com.example.applink

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.ProgressBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.functions.ktx.functions
import com.google.firebase.ktx.Firebase

/**
 * LoginActivity - Phone Number Input Screen
 * 
 * This activity allows users to:
 * 1. Enter their Bangladesh phone number
 * 2. Request OTP via Applink SMS API
 * 3. Navigate to OTP verification screen
 */
class LoginActivity : AppCompatActivity() {

    // Firebase Cloud Functions instance
    private lateinit var functions: FirebaseFunctions

    // UI Components
    private lateinit var phoneInput: EditText
    private lateinit var sendOtpButton: Button
    private lateinit var progressBar: ProgressBar

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        // Initialize Firebase Functions
        functions = Firebase.functions

        // Initialize UI components
        phoneInput = findViewById(R.id.phoneInput)
        sendOtpButton = findViewById(R.id.sendOtpButton)
        progressBar = findViewById(R.id.progressBar)

        // Set click listener for Send OTP button
        sendOtpButton.setOnClickListener {
            val phoneNumber = phoneInput.text.toString().trim()
            
            if (validatePhoneNumber(phoneNumber)) {
                sendOTP(phoneNumber)
            }
        }
    }

    /**
     * Validate Bangladesh phone number format
     * Accepts: 01XXXXXXXXX, 8801XXXXXXXXX, +8801XXXXXXXXX
     */
    private fun validatePhoneNumber(phone: String): Boolean {
        if (phone.isEmpty()) {
            phoneInput.error = "Phone number is required"
            return false
        }

        // Bangladesh phone number regex
        val bdPhoneRegex = Regex("^(\\+8801|8801|01)[3-9]\\d{8}$")
        
        if (!bdPhoneRegex.matches(phone)) {
            phoneInput.error = "Invalid phone number. Use format: 01XXXXXXXXX"
            return false
        }

        return true
    }

    /**
     * Format phone number to +880 format for Applink API
     */
    private fun formatPhoneNumber(phone: String): String {
        return when {
            phone.startsWith("+880") -> phone
            phone.startsWith("880") -> "+$phone"
            phone.startsWith("01") -> "+880${phone.substring(1)}"
            else -> phone
        }
    }

    /**
     * Call Firebase Cloud Function to send OTP via Applink SMS API
     */
    private fun sendOTP(phoneNumber: String) {
        // Show loading state
        setLoadingState(true)

        // Format phone number
        val formattedPhone = formatPhoneNumber(phoneNumber)

        // Prepare data for Cloud Function
        val data = hashMapOf(
            "phoneNumber" to formattedPhone
        )

        // Call the sendOTPviaApplink Cloud Function
        functions
            .getHttpsCallable("sendOTPviaApplink")
            .call(data)
            .addOnSuccessListener { result ->
                setLoadingState(false)
                
                // Parse response from Cloud Function
                val response = result.data as? Map<*, *>
                val success = response?.get("success") as? Boolean ?: false
                val message = response?.get("message") as? String ?: "Unknown response"

                if (success) {
                    // OTP sent successfully
                    Toast.makeText(
                        this,
                        "OTP sent to $formattedPhone",
                        Toast.LENGTH_LONG
                    ).show()

                    // Navigate to OTP verification screen
                    val intent = Intent(this, OtpActivity::class.java)
                    intent.putExtra("phoneNumber", formattedPhone)
                    startActivity(intent)
                } else {
                    // Failed to send OTP
                    Toast.makeText(
                        this,
                        "Failed: $message",
                        Toast.LENGTH_LONG
                    ).show()
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
     * Toggle loading state (disable button, show progress)
     */
    private fun setLoadingState(isLoading: Boolean) {
        sendOtpButton.isEnabled = !isLoading
        phoneInput.isEnabled = !isLoading
        progressBar.visibility = if (isLoading) ProgressBar.VISIBLE else ProgressBar.GONE
        
        sendOtpButton.text = if (isLoading) "Sending..." else "Send OTP"
    }
}
