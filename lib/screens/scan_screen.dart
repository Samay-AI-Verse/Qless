// lib/screens/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          // Top Overlay with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Scan Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) => Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
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
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
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
            ),
          ),
          // Scanning Frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isScanning ? const Color(0xFF10B981) : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  ...List.generate(4, (index) {
                    return Positioned(
                      top: index < 2 ? 0 : null,
                      bottom: index >= 2 ? 0 : null,
                      left: index % 2 == 0 ? 0 : null,
                      right: index % 2 == 1 ? 0 : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: index < 2
                                ? BorderSide(
                                    color: isScanning
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                    width: 5,
                                  )
                                : BorderSide.none,
                            bottom: index >= 2
                                ? BorderSide(
                                    color: isScanning
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                    width: 5,
                                  )
                                : BorderSide.none,
                            left: index % 2 == 0
                                ? BorderSide(
                                    color: isScanning
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                    width: 5,
                                  )
                                : BorderSide.none,
                            right: index % 2 == 1
                                ? BorderSide(
                                    color: isScanning
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
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
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.5),
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
          // Bottom Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isScanning
                            ? 'Point camera at product barcode'
                            : 'Product scanned!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan barcodes to add items to your cart',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              cameraController.torchEnabled
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              cameraController.toggleTorch();
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 40),
                          IconButton(
                            icon: const Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              cameraController.switchCamera();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
