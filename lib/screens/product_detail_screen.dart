import 'package:flutter/material.dart';
import 'package:shop_app/models/products.dart';


class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: Text(product.title),
    ),);
  }
}