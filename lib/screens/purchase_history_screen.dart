import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  static const List<Map<String, dynamic>> _history = [
    {
      'id': 'ORD-2024-001',
      'store': 'DMart, Andheri West',
      'date': '21 Jan 2026',
      'items': 12,
      'total': 2450.0,
      'status': 'Completed',
      'points_earned': 24,
    },
    {
      'id': 'ORD-2024-002',
      'store': 'Zudio, Inorbit Mall',
      'date': '18 Jan 2026',
      'items': 4,
      'total': 1890.0,
      'status': 'Completed',
      'points_earned': 18,
    },
    {
      'id': 'ORD-2024-003',
      'store': 'Reliance Fresh',
      'date': '15 Jan 2026',
      'items': 8,
      'total': 850.0,
      'status': 'Completed',
      'points_earned': 8,
    },
    {
      'id': 'ORD-2024-004',
      'store': 'Star Bazaar',
      'date': '10 Jan 2026',
      'items': 22,
      'total': 5600.0,
      'status': 'Completed',
      'points_earned': 56,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Orders History',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final order = _history[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['store'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['date'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order['status'],
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 24,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${order['items']} Items',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${order['total'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.stars,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'You earned ${order['points_earned']} points',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
