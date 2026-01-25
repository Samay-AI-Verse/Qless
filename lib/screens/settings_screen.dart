import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Push Notifications',
                      style: GoogleFonts.outfit(),
                    ),
                    subtitle: Text(
                      'Receive updates on offers & orders',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                    activeColor: Colors.black,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text('Dark Mode', style: GoogleFonts.outfit()),
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                    activeColor: Colors.black,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Language', style: GoogleFonts.outfit()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'English',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Security'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Biometric Login', style: GoogleFonts.outfit()),
                    subtitle: Text(
                      'Use FaceID or Fingerprint',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    value: _biometricEnabled,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                    activeColor: Colors.black,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Change PIN', style: GoogleFonts.outfit()),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('About'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Privacy Policy', style: GoogleFonts.outfit()),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Terms of Service',
                      style: GoogleFonts.outfit(),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('App Version', style: GoogleFonts.outfit()),
                    trailing: Text(
                      '1.0.0',
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'Made with ❤️ by Team QLess',
                style: GoogleFonts.outfit(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
