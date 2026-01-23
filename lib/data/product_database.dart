// lib/data/product_database.dart

class ProductDatabase {
  // A curated list of "Real" products commonly found in stores like DMart/Zudio
  static final List<Map<String, dynamic>> _knownProducts = [
    {
      'name': 'Maggi 2-Minute Noodles Masala (70g)',
      'price': 14.0,
      'category': 'Food',
      'barcode_suffix': '101',
    },
    {
      'name': 'Amul Pasteurized Butter (100g)',
      'price': 56.0,
      'category': 'Dairy',
      'barcode_suffix': '102',
    },
    {
      'name': 'Tata Salt Vacuum Evaporated (1kg)',
      'price': 28.0,
      'category': 'Grocery',
      'barcode_suffix': '103',
    },
    {
      'name': 'Coca-Cola Original Taste (750ml)',
      'price': 40.0,
      'category': 'Beverages',
      'barcode_suffix': '104',
    },
    {
      'name': 'Dove Cream Beauty Bathing Bar (3x100g)',
      'price': 225.0,
      'category': 'Personal Care',
      'barcode_suffix': '105',
    },
    {
      'name': 'Britannia Good Day Cashew Cookies',
      'price': 30.0,
      'category': 'Snacks',
      'barcode_suffix': '106',
    },
    {
      'name': 'Lays Potato Chips Classic Salted',
      'price': 20.0,
      'category': 'Snacks',
      'barcode_suffix': '107',
    },
    {
      'name': 'Aashirvaad Shudh Chakki Atta (5kg)',
      'price': 240.0,
      'category': 'Grocery',
      'barcode_suffix': '108',
    },
    {
      'name': 'Saffola Gold Pro Healthy Lifestyle Edible Oil (1L)',
      'price': 190.0,
      'category': 'Grocery',
      'barcode_suffix': '109',
    },
    {
      'name': 'Colgate Total Advanced Health Toothpaste',
      'price': 145.0,
      'category': 'Personal Care',
      'barcode_suffix': '110',
    },
    {
      'name': 'Dettol Original Germ Protection Bathing Soap',
      'price': 45.0,
      'category': 'Personal Care',
      'barcode_suffix': '111',
    },
    {
      'name': 'Red Label Tea (500g)',
      'price': 260.0,
      'category': 'Beverages',
      'barcode_suffix': '112',
    },
    {
      'name': 'Rin detergent bar (250g)',
      'price': 35.0,
      'category': 'Household',
      'barcode_suffix': '113',
    },
    {
      'name': 'Kissan Fresh Tomato Ketchup (950g)',
      'price': 135.0,
      'category': 'Food',
      'barcode_suffix': '114',
    },
    {
      'name': 'Haldiram\'s Aloo Bhujia',
      'price': 55.0,
      'category': 'Snacks',
      'barcode_suffix': '115',
    },
  ];

  static Map<String, dynamic> lookupProduct(String barcode) {
    // 1. Try to match exact known barcodes if we had them.
    // Since we can't control what the user scans in the real world (random EANs),
    // we use a deterministic hash to map ANY scanned code to one of our "Real" products.
    // This makes the demo feel "Magic" - whatever they scan looks like a real database hit.

    int hash = barcode.codeUnits.fold(0, (prev, element) => prev + element);
    int index = hash % _knownProducts.length;

    // We can add a bit of variation to the price to make same products look slightly distinct
    // if scanned from different batches, or keep it strict. Let's keep strict for consistency.

    final product = _knownProducts[index];

    return {
      'id': barcode, // Keep unique scan ID
      'name': product['name'],
      'price': product['price'],
      'category': product['category'],
      'image':
          'assets/images/products/${product['barcode_suffix']}.png', // Placeholder path
    };
  }
}
