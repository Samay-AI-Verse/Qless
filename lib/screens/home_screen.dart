// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'scan_screen.dart';
import 'cart_screen.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'purchase_history_screen.dart';
import 'rewards_screen.dart';
import 'exit_pass_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _dimAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.75, 0)).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _dimAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Drawer (always in background)
          _buildCustomDrawer(),
          // Main Content (slides, scales, and dims)
          SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0 && !_isDrawerOpen) {
                        _toggleDrawer();
                      } else if (details.primaryVelocity! < 0 &&
                          _isDrawerOpen) {
                        _toggleDrawer();
                      }
                    },
                    onTap: () {
                      if (_isDrawerOpen) {
                        _toggleDrawer();
                      }
                    },
                    child: ClipRRect(
                      borderRadius: _isDrawerOpen
                          ? BorderRadius.circular(20)
                          : BorderRadius.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          boxShadow: _isDrawerOpen
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 30,
                                    offset: const Offset(-10, 0),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            _buildAppBar(),
                            Expanded(child: const HomeContent()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isDrawerOpen)
                    IgnorePointer(
                      ignoring: false, // Explicitly handle touches
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! < 0) {
                            _toggleDrawer();
                          }
                        },
                        onTap: _toggleDrawer,
                        child: FadeTransition(
                          opacity: _dimAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: _isDrawerOpen
                                  ? BorderRadius.circular(20)
                                  : BorderRadius.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB), // Tech Blue
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFFF8F8F8),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App Title with custom font
              Text(
                'Q-Less',
                style: GoogleFonts.pacifico(
                  color: const Color(0xFF0F172A), // Main Text
                  fontSize: 28,
                  letterSpacing: -1.5,
                ),
              ),

              // Cart Icon with Badge
              Consumer<CartProvider>(
                builder: (context, cart, child) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                          size: 28,
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDrawer() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Allow closing drawer by swiping left from drawer area
        if (details.primaryVelocity! < 0 && _isDrawerOpen) {
          _toggleDrawer();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF11998E).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guest User',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'guest@qless.com',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Menu Items
            _buildDrawerItem(Icons.home, 'Home', () {
              _toggleDrawer();
            }),
            _buildDrawerItem(Icons.qr_code_scanner, 'Scan & Pay', () {
              _toggleDrawer();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              );
            }),
            _buildDrawerItem(Icons.receipt_long, 'My Purchases', () {
              _toggleDrawer();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PurchaseHistoryScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.card_giftcard, 'My Rewards', () {
              _toggleDrawer();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardsScreen()),
              );
            }),
            const Divider(color: Colors.black12, height: 40),
            _buildDrawerItem(Icons.settings, 'Settings', () {}),
            _buildDrawerItem(Icons.help_outline, 'Help & Support', () {}),
            const Spacer(),
            // Version
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.black26, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  static const List<Map<String, dynamic>> _banners = [
    {
      'title': 'Scan & Pay',
      'subtitle': 'Skip the queue, shop faster',
      'gradient': [Color(0xFF2563EB), Color(0xFF2563EB)], // Tech Blue solid
      'icon': Icons.qr_code_scanner,
    },
    {
      'title': 'Earn Rewards',
      'subtitle': 'Get credits on every purchase',
      'gradient': [Color(0xFF1E40AF), Color(0xFF1E40AF)], // Dark Version
      'icon': Icons.card_giftcard,
    },
    {
      'title': 'Fast Checkout',
      'subtitle': 'Pay and exit in seconds',
      'gradient': [
        Color(0xFF10B981),
        Color(0xFF10B981),
      ], // Smart Mint for variety
      'icon': Icons.bolt,
    },
  ];

  static const List<Map<String, dynamic>> _recentPurchases = [
    {'store': 'DMart', 'amount': 450.0, 'items': 5, 'date': '2 days ago'},
    {'store': 'BigBazaar', 'amount': 890.0, 'items': 8, 'date': '5 days ago'},
    {'store': 'Reliance', 'amount': 320.0, 'items': 3, 'date': '1 week ago'},
  ];

  // Spending data
  static const List<Map<String, dynamic>> _spendingCategories = [
    {
      'category': 'Groceries',
      'amount': 2450.0,
      'color': Color(0xFF22C55E), // Success/Green
      'icon': Icons.shopping_basket,
    },
    {
      'category': 'Beverages',
      'amount': 890.0,
      'color': Color(0xFF2563EB), // Tech Blue
      'icon': Icons.local_cafe,
    },
    {
      'category': 'Snacks',
      'amount': 650.0,
      'color': Color(0xFFF59E0B), // Warning/Orange
      'icon': Icons.fastfood,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // Soft off-white
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Banners Slider
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: banner['gradient'] as List<Color>,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (banner['gradient'] as List<Color>)[0]
                              .withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner['subtitle']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            banner['icon'] as IconData,
                            color: Colors.white.withOpacity(0.3),
                            size: 70,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.black
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Active Session & Budget
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.itemCount > 0) {
                  return Column(
                    children: [
                      _buildActiveSessionCard(cart),
                      const SizedBox(height: 28),
                      _buildBudgetBar(cart.totalAmount),
                      const SizedBox(height: 28),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Credits/Rewards Section
            _buildCreditsSection(),
            const SizedBox(height: 28),
            // Purchase History
            _buildPurchaseHistory(),
            const SizedBox(height: 28),
            // Spending Analytics (replaced Quick Add)
            _buildSpendingAnalytics(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Soft Premium Background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.card_giftcard,
              size: 140,
              color: const Color(
                0xFF2563EB,
              ).withOpacity(0.05), // Tech Blue hint
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Rewards',
                          style: TextStyle(
                            color: Color(0xFF64748B), // Secondary Text
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1,250',
                          style: TextStyle(
                            color: Color(0xFF2563EB), // Primary Blue
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Credits',
                          style: TextStyle(
                            color: Color(0xFF0F172A), // Main Text
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Circular progress
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        children: [
                          CustomPaint(
                            painter: CircularProgressPainter(
                              percentage: 0.65,
                              color: const Color(0xFF10B981), // Smart Mint Ring
                            ),
                            size: const Size(90, 90),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '65%',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A), // Main Text
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '₹125 saved this month',
                        style: TextStyle(
                          color: Color(0xFF22C55E), // Success Green
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF2563EB), // Primary Blue
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistory() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Use real orders if available, otherwise show "No recent orders" or mock if preferred.
        // For this demo, let's prepend real orders to mock ones or just show real ones.
        // User asked to "show the real purchased data".

        final realOrders = cartProvider.orders;

        if (realOrders.isEmpty && _recentPurchases.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Purchases',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: GoogleFonts.inter().fontWeight ?? FontWeight.bold,
                  color: const Color(0xFF0F172A), // Main Text
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                // Combined length or just real orders? lets show real then mock
                itemCount: realOrders.length + _recentPurchases.length,
                itemBuilder: (context, index) {
                  // Determine if we are showing a real order or a mock one
                  final isRealOrder = index < realOrders.length;
                  final Map<String, dynamic> data;

                  if (isRealOrder) {
                    data = realOrders[index];
                  } else {
                    data = _recentPurchases[index - realOrders.length];
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isRealOrder) {
                        // Open Exit Pass / QR for Real Orders
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExitPassScreen(
                              transactionId: data['id'],
                              amount: data['total'],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: isRealOrder
                            ? Border.all(color: Colors.green, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              ),
                              if (isRealOrder)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'New',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  data['date'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['store'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${data['itemCount'] ?? data['items']} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${(data['total'] ?? data['amount']).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              if (isRealOrder)
                                const Icon(
                                  Icons.qr_code,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpendingAnalytics() {
    final totalSpent = _spendingCategories.fold(
      0.0,
      (sum, item) => sum + (item['amount'] as double),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Spending Analytics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A), // Main Text
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Spent',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    '₹${totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(_spendingCategories.length, (index) {
                final category = _spendingCategories[index];
                final percentage = (category['amount'] as double) / totalSpent;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (category['color'] as Color).withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: category['color'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category['category'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage,
                                    backgroundColor: Colors.grey[200],
                                    color: category['color'] as Color,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${(category['amount'] as double).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(percentage * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionCard(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0D10), // Charcoal Black
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B0D10).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40E0FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Color(0xFF40E0FF), // Electric Cyan
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Shopping at DMart',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB6FF3B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'In Progress',
                  style: TextStyle(
                    color: Color(0xFFB6FF3B), // Neon Lime
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSessionStat('${cart.itemCount}', 'Items'),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSessionStat(
                '₹${cart.totalAmount.toStringAsFixed(0)}',
                'Total',
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSessionStat('00:45', 'Time'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBudgetBar(double currentAmount) {
    // 2000 is dummy budget limit
    double budgetLimit = 2000.0;
    double progress = (currentAmount / budgetLimit).clamp(0.0, 1.0);
    Color barColor = progress < 0.5
        ? const Color(0xFFB6FF3B) // Green (Safe)
        : progress < 0.85
        ? const Color(0xFFF59E0B) // Orange (Warning)
        : const Color(0xFFEF4444); // Red (Danger)

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Smart Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '₹${currentAmount.toStringAsFixed(0)} / ₹${budgetLimit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress < 0.85
                ? 'You are within budget'
                : 'Warning: Approaching limit!',
            style: TextStyle(
              fontSize: 12,
              color: barColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Circular Progress Painter
class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;

  CircularProgressPainter({required this.percentage, this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    paint.color = const Color(0xFFE2E8F0); // Slate 200
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    paint.color = color;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
