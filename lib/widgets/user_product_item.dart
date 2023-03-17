import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_providers.dart';

import '../models/products.dart';

class UserProductItem extends StatelessWidget {
  final Product product;
  UserProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          product.imageUrl,
        ),
      ),
      trailing: Container(
        width: 100,
        child: Row(children: [
          IconButton(
            onPressed: () {
              context.pushNamed('edit_products', extra: product);
            },
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              try {
                await Provider.of<Products_Provider>(context, listen: false)
                    .deleteProduct(product);
              }catch (error) {
                print('Error Activated');
                scaffold.showSnackBar(
                  SnackBar(
                    content: Text('Deleting failed', textAlign: TextAlign.center),
                  ),
                );
              }
            },
            color: Theme.of(context).errorColor,
            icon: Icon(Icons.delete),
          ),
        ]),
      ),
    );
  }
}
