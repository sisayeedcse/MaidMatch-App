import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () {}, child: const Text("Mark all as read")),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationCard(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            title: "Booking Confirmed",
            message:
                "Your booking with Rahima Begum has been confirmed for tomorrow.",
            time: "5 minutes ago",
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFBBF24),
            title: "New Review",
            message: "You received a 5-star review from Ayesha Rahman!",
            time: "2 hours ago",
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.sms_rounded,
            iconColor: const Color(0xFF6366F1),
            title: "SMS Sent",
            message:
                "Booking confirmation sent via Applink API to service provider.",
            time: "1 day ago",
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.local_offer_rounded,
            iconColor: const Color(0xFFEC4899),
            title: "Special Offer",
            message: "Get 20% off on your next booking! Limited time offer.",
            time: "2 days ago",
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.update_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: "Service Update",
            message:
                "New features added: Call masking and panic button for your safety.",
            time: "3 days ago",
            isRead: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : iconColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isRead
                              ? FontWeight.w600
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
