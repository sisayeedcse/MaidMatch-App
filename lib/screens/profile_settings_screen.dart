import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'edit_profile_screen.dart';
import 'edit_provider_profile_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = false;
  final AuthService _authService = AuthService();

  Future<void> _navigateToEditProfile() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final user = UserModel.fromFirestore(userDoc);

      // Navigate to appropriate edit screen based on role
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => user.isProvider
              ? EditProviderProfileScreen(user: user)
              : EditProfileScreen(user: user),
        ),
      );

      // Refresh screen if profile was updated
      if (result == true && mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _authService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF6366F1).withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Profile Settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Profile Picture
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Customer Account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "+880 1700000000",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Settings Sections
                _buildSection("Account Information", [
                  _buildSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                    onTap: _navigateToEditProfile,
                  ),
                  _buildSettingTile(
                    icon: Icons.phone_rounded,
                    title: "Phone Number",
                    subtitle: "+880 1700000000",
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.location_on_outlined,
                    title: "Address",
                    subtitle: "Manage your saved addresses",
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection("Safety & Security", [
                  _buildSettingTile(
                    icon: Icons.shield_outlined,
                    title: "Emergency Contacts",
                    subtitle: "Add or edit emergency contacts",
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.lock_outline_rounded,
                    title: "Privacy Settings",
                    subtitle: "Control your privacy preferences",
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.security_rounded,
                    title: "Safety Center",
                    subtitle: "Learn about safety features",
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection("Preferences", [
                  _buildSettingTile(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    subtitle: "Manage notification preferences",
                    trailing: Switch(value: true, onChanged: (value) {}),
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.language_rounded,
                    title: "Language",
                    subtitle: "English",
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark Mode",
                    subtitle: "Switch to dark theme",
                    trailing: Switch(value: false, onChanged: (value) {}),
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection("Support", [
                  _buildSettingTile(
                    icon: Icons.help_outline_rounded,
                    title: "Help Center",
                    subtitle: "FAQs and support",
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.info_outline_rounded,
                    title: "About",
                    subtitle: "App version 1.0.0",
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                    subtitle: "Read our terms",
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing:
          trailing ??
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
    );
  }
}
