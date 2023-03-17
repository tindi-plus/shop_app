import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.description,
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.title,
    this.isFavourite = false,
  });

  Future<void> toggleFavouriteStatus(String token, String userId) async {
   var url = Uri.https(
      'shop-app-6f36b-default-rtdb.firebaseio.com',
      '/userFavourites/$userId/$id.json',
      {'auth': token},
    );
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try{
      final response = await http.put(url, body: json.encode(
          isFavourite
      ),);

      if (response.statusCode >= 400){
        isFavourite = oldStatus;
      notifyListeners();
      }
    }catch (error){
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}
