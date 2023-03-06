import 'package:flutter/cupertino.dart';

import '../models/products.dart';

class CartItem {
  String id;
  String title;
  int quantity;
  double price;

  CartItem(
      {required this.id,
      required this.price,
      required this.title,
      this.quantity = 1});
}

class Cart with ChangeNotifier {
  // A map that contains the product ID as key, and a cartItem as a value
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get numItems {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });

    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toIso8601String(),
          price: product.price,
          title: product.title,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((key, value) => value.id == productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }

    notifyListeners();
  }
}
