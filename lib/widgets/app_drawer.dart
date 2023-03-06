import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('User:'),
            automaticallyImplyLeading: false,
          ),
          Divider(
            color: Colors.black,
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              context.pushReplacementNamed('home');
            },
          ),
          Divider(
            color: Colors.black,
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              context.pushReplacementNamed('orders_screen');
            },
          ),
          Divider(
            color: Colors.black,
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('My Products'),
            onTap: () {
              context.pushReplacementNamed('user_products');
            },
          ),
        ],
      ),
    );
  }
}
