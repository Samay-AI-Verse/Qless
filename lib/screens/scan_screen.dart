// lib/screens/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  String? lastScannedCode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code != lastScannedCode) {
        setState(() {
          lastScannedCode = code;
          isScanning = false;
        });

        _addScannedProductToCart(code);

        // Reset scanning after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              isScanning = true;
            });
          }
        });
        break;
      }
    }
  }

  void _addScannedProductToCart(String code) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Mock product data based on scanned code
    final product = {
      'id': code,
      'name': 'Product ${code.substring(0, code.length > 6 ? 6 : code.length)}',
      'price': (50 + (code.hashCode % 200)).toDouble(),
      'image': '',
    };

    cartProvider.addItem(product);

    // Show success overlay
    _showSuccessOverlay(product);
  }

  void _showSuccessOverlay(Map<String, dynamic> product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Added to Cart!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                product['name'],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '₹${product['price'].toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Continue Scanning',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'View Cart',
                        style: TextStyle(color: Colors.white),
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

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White Background as Primary
      body: Stack(
        children: [
          // Camera View (Full Screen)
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Top Header (White Background)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white, // White background for the header
              padding: const EdgeInsets.only(
                top: 50, // Safe area approximation
                bottom: 20,
                left: 24,
                right: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Q-Less',
                    style: GoogleFonts.pacifico(
                      color: Colors.black, // Black Text
                      fontSize: 28,
                      letterSpacing: -1.5,
                    ),
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.black, // Black Icon
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black, // Black badge background
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanning Frame (Black Accents)
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                // Slight transparent white border to separate camera from dark background if any,
                // but user wants White theme. Let's use Black borders for the frame.
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner decorations (Black)
                  ...List.generate(4, (index) {
                    return Positioned(
                      top: index < 2 ? -2.5 : null,
                      bottom: index >= 2 ? -2.5 : null,
                      left: index % 2 == 0 ? -2.5 : null,
                      right: index % 2 == 1 ? -2.5 : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: index == 0
                                ? const Radius.circular(20)
                                : Radius.zero,
                            topRight: index == 1
                                ? const Radius.circular(20)
                                : Radius.zero,
                            bottomLeft: index == 2
                                ? const Radius.circular(20)
                                : Radius.zero,
                            bottomRight: index == 3
                                ? const Radius.circular(20)
                                : Radius.zero,
                          ),
                          border: Border(
                            top: index < 2
                                ? BorderSide(
                                    color: Colors.black, // Black corners
                                    width: 5,
                                  )
                                : BorderSide.none,
                            bottom: index >= 2
                                ? BorderSide(
                                    color: Colors.black, // Black corners
                                    width: 5,
                                  )
                                : BorderSide.none,
                            left: index % 2 == 0
                                ? BorderSide(
                                    color: Colors.black, // Black corners
                                    width: 5,
                                  )
                                : BorderSide.none,
                            right: index % 2 == 1
                                ? BorderSide(
                                    color: Colors.black, // Black corners
                                    width: 5,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                      ),
                    );
                  }),
                  // Scanning line animation
                  if (isScanning)
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(seconds: 2),
                      builder: (context, double value, child) {
                        return Positioned(
                          top: 280 * value - 2,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.black, // Black scanning line
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted && isScanning) {
                          setState(() {});
                        }
                      },
                    ),
                ],
              ),
            ),
          ),

          // Bottom Control Area (White Background)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white, // White background
              child: SafeArea(
                child: Column(
                  children: [
                    Text(
                      isScanning
                          ? 'Point camera at product barcode'
                          : 'Product scanned!',
                      style: const TextStyle(
                        color: Colors.black, // Black text
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Torch
                    GestureDetector(
                      onTap: () {
                        cameraController.toggleTorch();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black, // Black background for button
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          cameraController.torchEnabled
                              ? Icons.flash_on
                              : Icons.flash_off,
                          color: Colors.white, // White icon for contrast
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
