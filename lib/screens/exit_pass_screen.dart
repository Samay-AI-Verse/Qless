import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ExitPassScreen extends StatefulWidget {
  final String transactionId;
  final double amount;
  final List<Map<String, dynamic>> items;

  const ExitPassScreen({
    super.key,
    this.transactionId = 'TXN-8829-XJ29',
    this.amount = 1250.0,
    this.items = const [],
  });

  @override
  State<ExitPassScreen> createState() => _ExitPassScreenState();
}

class _ExitPassScreenState extends State<ExitPassScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // ValueNotifier to track sheet position for animations
  // 0.0 = collapsed (minSize), 1.0 = expanded (maxSize) logic will be handled in listener
  final ValueNotifier<double> _sheetPosition = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _sheetPosition.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    // Normalizing the position between min (0.25) and max (0.85)
    // Result: 0.0 when at min, 1.0 when at max
    final size = _sheetController.size;
    final min = 0.25;
    final max = 0.85;

    double normalized = (size - min) / (max - min);
    if (normalized < 0) normalized = 0;
    if (normalized > 1) normalized = 1;

    _sheetPosition.value = normalized;
  }

  void _toggleSheet() {
    if (_sheetController.size < 0.3) {
      _sheetController.animateTo(
        0.6,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _sheetController.animateTo(
        0.25,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToHome() {
    // Clear navigation stack and go to first route (Home)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Total height of the screen
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF10B981), // Success Green
        body: Stack(
          children: [
            // 1. MAIN CONTENT (QR & Status) - Animated
            Positioned.fill(
              child: SafeArea(
                child: ValueListenableBuilder<double>(
                  valueListenable: _sheetPosition,
                  builder: (context, position, child) {
                    // Parallax & Scale Effect
                    // As position goes 0 -> 1 (Sheet goes UP):
                    // - Slide content UP (negative Y translation)
                    // - Scale content DOWN slightly

                    double slideY = -150 * position;
                    double scale =
                        1.0 - (0.15 * position); // Scales down to 0.85
                    double opacity = 1.0 - (0.5 * position); // Fades slightly

                    return Transform.translate(
                      offset: Offset(0, slideY),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Success Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Payment Successful',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              // QR Code Card (Larger as requested)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    QrImageView(
                                      data: widget.transactionId,
                                      version: QrVersions.auto,
                                      size: 260.0, // Big Size
                                      backgroundColor: Colors.white,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Scan at Exit Gate',
                                      style: GoogleFonts.outfit(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Total Amount (Smaller as requested)
                              Column(
                                children: [
                                  Text(
                                    'Total Paid',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.amount.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              // Spacer that approximates the initial sheet height area
                              // so content sits nicely above it initially.
                              SizedBox(height: size.height * 0.28),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. BOTTOM DRAGGABLE SHEET (Receipt List)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize:
                  0.25, // Increased from 0.12 to 0.25 to show items
              minChildSize: 0.25,
              maxChildSize: 0.85,
              snap: true,
              snapSizes: const [0.25, 0.6, 0.85],
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 30,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    // Count = Header + Items (No footer button)
                    itemCount: widget.items.length + 1,
                    itemBuilder: (context, index) {
                      // --- HEADER SECTION (Index 0) ---
                      if (index == 0) {
                        return GestureDetector(
                          onTap: _toggleSheet,
                          behavior: HitTestBehavior.translucent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Handle
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Header Text
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.receipt_long,
                                          color: Colors.blueGrey,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Order Details',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${widget.items.length} items',
                                        style: GoogleFonts.outfit(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              if (widget.items.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Center(
                                    child: Text(
                                      'No items',
                                      style: GoogleFonts.outfit(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      // --- LIST ITEMS (Index 1 to N) ---
                      if (widget.items.isEmpty) return const SizedBox.shrink();

                      final item = widget.items[index - 1]; // offset by 1
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: const Icon(
                                Icons.local_mall_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? 'Unknown Item',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Qty: ${item['quantity']}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${((item['price'] as double) * (item['quantity'] as int)).toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
