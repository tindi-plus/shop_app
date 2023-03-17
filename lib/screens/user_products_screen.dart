import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/providers/products_providers.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products_Provider>(context, listen: false)
        .fetchAndSetProducts(filter: true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products_Provider>(context);
    print('rebuilding....');
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Products'),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed('edit_products');
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Consumer<Products_Provider>(
                  builder: (context, productsData, child) => RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: productsData.items.length,
                        itemBuilder: (context, index) {
                          return Card(
                              elevation: 5.0,
                              child: UserProductItem(
                                  product: productsData.items[index]));
                        },
                      ),
                    ),
                  ),
                ),
        ));
  }
}
