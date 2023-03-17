import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/widgets/order_item.dart';

import './cart.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  Order(
      {required this.amount,
      required this.dateTime,
      required this.id,
      required this.products});
}

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  String? token;
  String? userId;

  OrderProvider(this.token, this.userId);

  List<Order> get orders {
    return [..._orders];
  }

  void setToken(String? newToken) {
    token = newToken;
  }

  Future<void> fetchAndSetOrders() async {
    // var url = Uri.https(
    //   'shop-app-6f36b-default-rtdb.firebaseio.com',
    //   '/orders.json',
    //   {'auth': token},
    // );

    var url = Uri.parse(
        'https://shop-app-6f36b-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final response = await http.get(url);
    print(json.decode(response.body));
    final List<Order> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        Order(
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          id: orderId,
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              price: item['price'],
              title: item['title'],
              quantity: item['quantity'],
            );
          }).toList(),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var url = Uri.https('shop-app-6f36b-default-rtdb.firebaseio.com',
        '/orders/$userId.json', {'auth': token});
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity,
                  })
              .toList()
        }));
    _orders.insert(
        0,
        Order(
            amount: total,
            dateTime: DateTime.now(),
            id: json.decode(response.body)['name'],
            products: cartProducts));

    notifyListeners();
  }
}
