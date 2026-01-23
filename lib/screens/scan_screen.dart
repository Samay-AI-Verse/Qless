// lib/screens/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/product_database.dart';
import 'payment_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Optimized Camera Controller
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    // Limit formats to common retail codes for faster detection
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.qrCode,
    ],
    returnImage: false,
  );
  bool isScanning = true;
  String? lastScannedCode;

  // State for the overlay
  Map<String, dynamic>? _lastAddedProduct;
  Timer? _overlayTimer;

  @override
  void dispose() {
    cameraController.dispose();
    _overlayTimer?.cancel();
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

        // Use Real Data Lookup
        _processScannedCode(code);

        // Reset scanning after 1.5 seconds (scanner cooldown)
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              isScanning = true;
              // Don't clear lastScannedCode immediately to prevent double scan of same item instantly
              // But allow rescan after 3 seconds maybe? For now simple logic.
            });
          }
        });
        break;
      }
    }
  }

  void _processScannedCode(String code) {
    // 1. Get Product Data from "Database"
    final product = ProductDatabase.lookupProduct(code);

    // 2. Add to Cart Provider
    Provider.of<CartProvider>(context, listen: false).addItem(product);

    // 3. Show "Recent Item" Overlay instead of blocking Dialog
    setState(() {
      _lastAddedProduct = product;
    });

    // 4. Auto-hide overlay after 3 seconds
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _lastAddedProduct = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View (Full Screen)
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // 2. Dark Overlay with Cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Scanner Frame (White Curvy Borders)
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // White Corner Decorations
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
                                ? const BorderSide(
                                    color: Colors.white,
                                    width: 4,
                                  )
                                : BorderSide.none,
                            bottom: index >= 2
                                ? const BorderSide(
                                    color: Colors.white,
                                    width: 4,
                                  )
                                : BorderSide.none,
                            left: index % 2 == 0
                                ? const BorderSide(
                                    color: Colors.white,
                                    width: 4,
                                  )
                                : BorderSide.none,
                            right: index % 2 == 1
                                ? const BorderSide(
                                    color: Colors.white,
                                    width: 4,
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
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
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

          // 4. Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Scan Item',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        cameraController.torchEnabled
                            ? Icons.flash_on
                            : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        cameraController.toggleTorch();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Recent Item Overlay (Dynamic)
          if (_lastAddedProduct != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: _buildRecentItemCard(),
            ),

          // 6. Bottom Cart Summary & Pay Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCartSummary(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Added to Cart',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _lastAddedProduct!['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₹${_lastAddedProduct!['price'].toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCartSummary() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.itemCount == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total (${cart.itemCount} items)',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Premium Black
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
