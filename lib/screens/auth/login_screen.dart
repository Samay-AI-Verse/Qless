import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_config.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;

  Future<void> _sendOtp() async {
    if (_mobileController.text.isEmpty) {
      _showMessage('Please enter your mobile number', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      var response = await http.post(
        Uri.parse(
          '${AuthConfig.sendOtp}?mobile_number=${_mobileController.text.trim()}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() => _otpSent = true);
        _showMessage('🔐 Verification code sent to your device');
      } else {
        try {
          // Try to decode backend error if meaningful
          var data = json.decode(response.body);
          _showMessage(data['message'] ?? 'Failed to send OTP', isError: true);
        } catch (_) {
          _showMessage('Failed to send OTP', isError: true);
        }
      }
    } catch (e) {
      _showMessage('⚠️ Unable to send code: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndLogin() async {
    if (_otpController.text.isEmpty) {
      _showMessage('Please enter OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Verify OTP
      var otpResponse = await http.post(
        Uri.parse(AuthConfig.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mobile_number': _mobileController.text.trim(),
          'otp': _otpController.text.trim(),
        }),
      );

      if (otpResponse.statusCode == 200 || otpResponse.statusCode == 201) {
        // We ignore the backend 'registered' flag because we want to enforce
        // a local profile setup flow for this specific app (Q-Less).
        // The user wants to "ask for the name and last name and then ok and then move to the home page"

        if (mounted) {
          _showMessage('✅ Verified! Setting up profile...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RegisterScreen(mobileNumber: _mobileController.text.trim()),
            ),
          );
        }
      } else {
        try {
          var data = json.decode(otpResponse.body);
          throw Exception(data['detail'] ?? 'Invalid OTP');
        } catch (_) {
          throw Exception('Invalid OTP');
        }
      }
    } catch (e) {
      _showMessage('❌ Login failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.black),
            const SizedBox(height: 24),
            Text(
              'Welcome',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your mobile number to continue',
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),

            // Mobile Number Input
            TextField(
              controller: _mobileController,
              enabled: !_otpSent,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.phone, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),

            if (!_otpSent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Send Code',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

            // OTP Input
            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Enter 6-Digit Code',
                  labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                  hintText: '● ● ● ● ● ●',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 24,
                    letterSpacing: 8,
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Verify & Login',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: Text(
                    'Change Number',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            // Replaced the registration link with a label since we auto-redirect now
            if (!_otpSent)
              Center(
                child: Text(
                  'New users will be redirected to registration',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
