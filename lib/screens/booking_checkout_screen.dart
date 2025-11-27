import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final String name;
  final String skill;
  final String location;
  final String phone;
  final String rating;

  const BookingCheckoutScreen({
    super.key,
    required this.name,
    required this.skill,
    required this.location,
    required this.phone,
    required this.rating,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  String selectedDate = "Tomorrow";
  String selectedTime = "Morning (9 AM - 12 PM)";
  String selectedDuration = "4 hours";
  int selectedServiceIndex = 0;

  final List<Map<String, dynamic>> timeSlots = [
    {"label": "Morning (9 AM - 12 PM)", "available": true},
    {"label": "Afternoon (1 PM - 5 PM)", "available": true},
    {"label": "Evening (6 PM - 9 PM)", "available": false},
  ];

  final List<Map<String, dynamic>> durations = [
    {"label": "2 hours", "price": 400},
    {"label": "4 hours", "price": 700},
    {"label": "Full Day", "price": 1200},
  ];

  Color _getSkillColor() {
    switch (widget.skill.toLowerCase()) {
      case 'cook':
      case 'cooking':
        return const Color(0xFFEF4444);
      case 'cleaner':
      case 'cleaning':
        return const Color(0xFF3B82F6);
      case 'nanny':
      case 'babysitting':
        return const Color(0xFFEC4899);
      case 'driver':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6366F1);
    }
  }

  int _getSelectedPrice() {
    final selectedDurationData = durations.firstWhere(
      (d) => d['label'] == selectedDuration,
      orElse: () => durations[1],
    );
    return selectedDurationData['price'];
  }

  Future<void> _confirmBooking() async {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getSkillColor(),
                      _getSkillColor().withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Creating booking...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final authService = AuthService();
      final bookingService = BookingService();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        Navigator.pop(context);
        _showErrorDialog('Please login to continue');
        return;
      }

      // Get current user data
      final userDoc = await authService.getUserDocument(currentUser.uid);
      final userData = UserModel.fromFirestore(userDoc);

      // Parse date
      DateTime bookingDate;
      if (selectedDate == 'Today') {
        bookingDate = DateTime.now();
      } else if (selectedDate == 'Tomorrow') {
        bookingDate = DateTime.now().add(const Duration(days: 1));
      } else {
        // For custom date, use tomorrow as default for now
        bookingDate = DateTime.now().add(const Duration(days: 1));
      }

      // Create booking (Note: providerId should come from selected provider)
      // For demo, we'll use a placeholder - in production, pass actual provider data
      await bookingService.createBooking(
        customerId: currentUser.uid,
        providerId: 'provider_${widget.phone}', // Placeholder
        serviceType: widget.skill,
        date: bookingDate,
        timeSlot: selectedTime,
        duration: selectedDuration,
        totalPrice: _getSelectedPrice(),
        address: userData.address ?? 'Address not set',
        specialInstructions: '', // You can add a text field for this
        customerName: userData.name,
        customerPhone: userData.phoneNumber,
        providerName: widget.name,
        providerPhone: widget.phone,
        providerSkill: widget.skill,
      );

      Navigator.pop(context);
      _showSuccessDialog();
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Failed to create booking: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFF6366F1).withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Booking Confirmed!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Your booking with ${widget.name} has been confirmed",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sms_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "SMS Sent via Applink API",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Confirmation sent to ${widget.phone}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Back to Home"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getSkillColor(),
                            _getSkillColor().withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "View Booking",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skillColor = _getSkillColor();
    final price = _getSelectedPrice();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Book Service"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Provider Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [skillColor, skillColor.withOpacity(0.6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: skillColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person_rounded,
                          color: skillColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.skill,
                          style: TextStyle(
                            fontSize: 13,
                            color: skillColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFBBF24),
                        size: 20,
                      ),
                      Text(
                        widget.rating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            const Text(
              "Select Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDateChip("Today"),
                const SizedBox(width: 8),
                _buildDateChip("Tomorrow"),
                const SizedBox(width: 8),
                _buildDateChip("Custom"),
              ],
            ),
            const SizedBox(height: 24),

            // Time Slot Selection
            const Text(
              "Select Time Slot",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...timeSlots.map((slot) => _buildTimeSlot(slot)),
            const SizedBox(height: 24),

            // Duration Selection
            const Text(
              "Select Duration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...durations.map(
              (duration) => _buildDurationCard(duration, skillColor),
            ),
            const SizedBox(height: 24),

            // Special Instructions
            const Text(
              "Special Instructions (Optional)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Any specific requirements or instructions...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    "৳$price",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: skillColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [skillColor, skillColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: skillColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Pay via Mobile Balance",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String label) {
    final isSelected = selectedDate == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedDate = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _getSkillColor() : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _getSkillColor() : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlot(Map<String, dynamic> slot) {
    final isSelected = selectedTime == slot['label'];
    final isAvailable = slot['available'];

    return GestureDetector(
      onTap: isAvailable
          ? () => setState(() => selectedTime = slot['label'])
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _getSkillColor()
                : isAvailable
                ? Colors.grey.shade300
                : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? _getSkillColor() : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                slot['label'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isAvailable ? Colors.black : Colors.grey,
                ),
              ),
            ),
            if (!isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Booked",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(Map<String, dynamic> duration, Color color) {
    final isSelected = selectedDuration == duration['label'];

    return GestureDetector(
      onTap: () => setState(() => selectedDuration = duration['label']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                duration['label'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Text(
              "৳${duration['price']}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
