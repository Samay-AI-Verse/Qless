import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import 'scan_screen.dart';
import 'cart_screen.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'purchase_history_screen.dart';
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return GestureDetector(
          onHorizontalDragEnd: (details) {
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
                      child: ClipOval(
                        child: _getProfileWidget(userProvider.profileImagePath),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.firstName.isNotEmpty
                                ? userProvider.fullName
                                : 'Guest User',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProvider.mobileNumber ?? 'No Info',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
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
      },
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

  Widget _getProfileWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.person, size: 40, color: Colors.white);
    }

    // Assume Short string = Emoji
    if (imagePath.length <= 8) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Text(imagePath, style: const TextStyle(fontSize: 35)),
      );
    }

    // Else assume file path
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.person, size: 40, color: Colors.white),
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
      'title': 'Mega Sale',
      'subtitle': 'Flat 50% OFF on Snacks',
      'gradient': [Color(0xFFFF416C), Color(0xFFFF4B2B)], // Red-Orange
      'icon': Icons.local_offer_rounded,
    },
    {
      'title': 'Fresh & Organic',
      'subtitle': 'Get 20% Cashback on Veggies',
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)], // Green
      'icon': Icons.eco_rounded,
    },
    {
      'title': 'Express Checkout',
      'subtitle': 'Scan to Pay & Skip the Line',
      'gradient': [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple
      'icon': Icons.qr_code_scanner_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Pending Cart / Active Checkout Banner
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                if (cart.itemCount == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B), // Dark Blue-Black
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pending Checkout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${cart.itemCount} Items • ₹${cart.totalAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Pay Now'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Banners Slider
            SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
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
                              .withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative Circles
                        Positioned(
                          right: -30,
                          top: -30,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'LIMITED OFFER',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      banner['title']!,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      banner['subtitle']!,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                banner['icon'] as IconData,
                                color: Colors.white.withOpacity(0.2),
                                size: 80,
                              ),
                            ],
                          ),
                        ),
                      ],
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

            // Quick Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Analytics',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Spent',
                          '₹0',
                          Icons.account_balance_wallet_rounded,
                          const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Saved',
                          '₹0',
                          Icons.savings_rounded,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Transactions',
                          '0',
                          Icons.receipt_long_rounded,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Avg. Bill',
                          '₹0',
                          Icons.trending_up_rounded,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Rewards Points Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.stars_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Reward Points',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '0',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start shopping to earn points!',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFEC4899),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '1 Point = ₹1 Discount',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFEC4899),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Circular Progress
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: 0.0, // 0% progress
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '0%',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'to next',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                'reward',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Monthly Spending Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                        Text(
                          'Monthly Spending',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'January',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF3B82F6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Simple Bar Chart Representation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarChart('W1', 0, 100),
                        _buildBarChart('W2', 0, 100),
                        _buildBarChart('W3', 0, 100),
                        _buildBarChart('W4', 0, 100),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Start shopping to see your spending trends',
                        style: GoogleFonts.outfit(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            // Purchase History
            _buildPurchaseHistory(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(String label, double value, double maxValue) {
    final height = value == 0 ? 20.0 : (value / maxValue) * 100;

    return Column(
      children: [
        Container(
          width: 40,
          height: 100,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 40,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.6),
                  const Color(0xFF3B82F6),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseHistory() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final realOrders = cartProvider.orders;

        if (realOrders.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_toggle_off_rounded,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent purchases',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Purchases',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PurchaseHistoryScreen(),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: realOrders.length,
                itemBuilder: (context, index) {
                  final order = realOrders[index];
                  final items = order['items'] as List;
                  final total = order['total'] as double;
                  final date = order['date'] as DateTime;

                  return Container(
                    width: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(16),
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
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Logo
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B0FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Color(0xFF0091EA),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "D-Mart, Andheri West", // Hardcoded "Real" Location
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${items.length} Items',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₹${total.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
