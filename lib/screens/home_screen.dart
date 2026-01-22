// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'scan_screen.dart';
import 'cart_screen.dart';
import 'dart:async';

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
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.6, 0)).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
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
      backgroundColor: const Color(0xFF0066CC),
      body: Stack(
        children: [
          // Drawer (always in background)
          _buildCustomDrawer(),
          // Main Content (slides over drawer)
          SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0 && !_isDrawerOpen) {
                  _toggleDrawer();
                } else if (details.primaryVelocity! < 0 && _isDrawerOpen) {
                  _toggleDrawer();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: _isDrawerOpen
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(-5, 0),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        ),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text(
          'Scan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0066CC), Color(0xFF004999)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  // Menu Button
                  IconButton(
                    icon: Icon(
                      _isDrawerOpen ? Icons.close : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: _toggleDrawer,
                  ),
                  const SizedBox(width: 8),
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00509E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: Colors.white70),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Voice Search
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  // Scan
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notifications
                  Consumer<CartProvider>(
                    builder: (context, cart, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
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
                  const SizedBox(width: 8),
                  // Profile
                  GestureDetector(
                    onTap: _toggleDrawer,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'SS',
                          style: TextStyle(
                            color: Color(0xFF0066CC),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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
  }

  Widget _buildCustomDrawer() {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0066CC), width: 3),
                ),
                child: const Icon(
                  Icons.person,
                  size: 35,
                  color: Color(0xFF0066CC),
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
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'guest@qless.com',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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
          _buildDrawerItem(Icons.qr_code_scanner, 'Scan Products', () {
            _toggleDrawer();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanScreen()),
            );
          }),
          _buildDrawerItem(Icons.shopping_cart, 'My Cart', () {
            _toggleDrawer();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          }),
          _buildDrawerItem(Icons.history, 'Order History', () {}),
          _buildDrawerItem(Icons.favorite, 'Favorites', () {}),
          const Divider(color: Colors.white24, height: 40),
          _buildDrawerItem(Icons.settings, 'Settings', () {}),
          _buildDrawerItem(Icons.help_outline, 'Help & Support', () {}),
          _buildDrawerItem(Icons.info_outline, 'About', () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
      if (_currentPage < _offers.length - 1) {
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

  static const List<Map<String, dynamic>> _offers = [
    {
      'title': 'Mega Sale!',
      'subtitle': 'Up to 50% off on groceries',
      'gradient': [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    },
    {
      'title': 'Fresh Arrivals',
      'subtitle': 'New products in store',
      'gradient': [Color(0xFF065F46), Color(0xFF10B981)],
    },
    {
      'title': 'Member Special',
      'subtitle': 'Extra 10% off for members',
      'gradient': [Color(0xFF7C2D12), Color(0xFFF97316)],
    },
  ];

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Groceries',
      'icon': Icons.shopping_basket,
      'color': Color(0xFFFFEBEE),
    },
    {'name': 'Fresh', 'icon': Icons.eco, 'color': Color(0xFFE8F5E9)},
    {'name': 'Snacks', 'icon': Icons.cookie, 'color': Color(0xFFFFF3E0)},
    {'name': 'Beverages', 'icon': Icons.local_cafe, 'color': Color(0xFFE3F2FD)},
    {'name': 'Personal Care', 'icon': Icons.face, 'color': Color(0xFFFCE4EC)},
    {'name': 'Home Care', 'icon': Icons.home, 'color': Color(0xFFF3E5F5)},
  ];

  static const List<Map<String, dynamic>> _products = [
    {
      'id': 'P001',
      'name': 'Organic Milk',
      'price': 62.0,
      'category': 'Fresh',
      'discount': '10% OFF',
    },
    {
      'id': 'P002',
      'name': 'Whole Wheat Bread',
      'price': 45.0,
      'category': 'Groceries',
      'discount': null,
    },
    {
      'id': 'P003',
      'name': 'Fresh Eggs (12 pcs)',
      'price': 84.0,
      'category': 'Fresh',
      'discount': '5% OFF',
    },
    {
      'id': 'P004',
      'name': 'Basmati Rice 1kg',
      'price': 120.0,
      'category': 'Groceries',
      'discount': '15% OFF',
    },
    {
      'id': 'P005',
      'name': 'Chips Pack',
      'price': 20.0,
      'category': 'Snacks',
      'discount': null,
    },
    {
      'id': 'P006',
      'name': 'Cold Drink 2L',
      'price': 90.0,
      'category': 'Beverages',
      'discount': '20% OFF',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offers Slider
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _offers.length,
                itemBuilder: (context, index) {
                  final offer = _offers[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: offer['gradient'] as List<Color>,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            offer['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _offers.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF0066CC)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick links',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: category['color'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 40,
                          color: const Color(0xFF0066CC),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['name'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Products Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Products',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCard(context, product);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Discount Badge
          Stack(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              if (product['discount'] != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product['discount'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Product Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'] as String,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${(product['price'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addItem({
                            'id': product['id'],
                            'name': product['name'],
                            'price': product['price'],
                            'image': '',
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product['name']} added to cart!',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
