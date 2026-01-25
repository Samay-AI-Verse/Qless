import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Support Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.headset_mic, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Need Help?',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our support team is available 24/7 to assist you with any issues.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Contact Us'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          _buildFAQItem(
            'How do I scan items?',
            'Tap the floating action button with the scanner icon on the home screen. Point your camera at the product barcode to add it to your cart.',
          ),
          _buildFAQItem(
            'How do I pay?',
            'After adding items, go to your cart and proceed to checkout. Depending on the store, you can pay via UPI, Card, or Wallet.',
          ),
          _buildFAQItem(
            'Where is my exit pass?',
            'After successful payment, an exit pass with a QR code is generated. Access it from "Recent Purchases" or verify at the exit gate.',
          ),
          _buildFAQItem(
            'Can I return items?',
            'Returns are subject to store policy. Please visit the help desk at the store entrance for returns.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: GoogleFonts.outfit(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
