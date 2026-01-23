import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ExitPassScreen extends StatelessWidget {
  final String transactionId;
  final double amount;

  const ExitPassScreen({
    super.key,
    this.transactionId = 'TXN-8829-XJ29',
    this.amount = 1250.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10B981), // Success Green Background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Payment Successful',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Show this QR at the exit gate',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Ticket Card
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // QR Code
                    QrImageView(
                      data: transactionId,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      transactionId,
                      style: const TextStyle(
                        color: Colors.black54,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Divider(
                      color: Colors.black12,
                      thickness: 1,
                      indent: 40,
                      endIndent: 40,
                    ),
                    const SizedBox(height: 40),

                    // Details
                    _buildDetailRow(
                      'Total Paid',
                      '₹${amount.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Date', '23 Jan 2026, 10:45 AM'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Items', '5'),

                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Go back to home and clear stack
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
