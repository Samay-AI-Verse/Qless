// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get items => _items;
  List<Map<String, dynamic>> get orders => _orders;

  int get itemCount =>
      _items.fold(0, (sum, item) => sum + (item['quantity'] as int));

  double get totalAmount => _items.fold(
    0.0,
    (sum, item) =>
        sum + ((item['price'] as double) * (item['quantity'] as int)),
  );

  void addItem(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item['id'] == product['id']);

    if (index >= 0) {
      // Item already exists, increase quantity
      _items[index]['quantity'] = (_items[index]['quantity'] as int) + 1;
    } else {
      // Add new item with quantity 1
      _items.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void updateQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index]['quantity'] = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Create a completed order from current cart
  String completeOrder() {
    if (_items.isEmpty) return '';

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final total = totalAmount;
    final date = DateTime.now();

    final order = {
      'id': orderId,
      'items': List<Map<String, dynamic>>.from(_items),
      'total': total,
      'date': date,
      'store': 'DMart, Andheri West', // Mock location
      'itemCount': itemCount,
    };

    _orders.insert(0, order); // Add to top of list
    clearCart();
    return orderId;
  }
}
