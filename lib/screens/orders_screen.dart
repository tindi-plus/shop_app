import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/order_item.dart';

import '../providers/orders.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future setOrders;

  @override
  void initState() {
    setOrders =
        Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Built Orders');
    // final ordersData = Provider.of<OrderProiver>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: setOrders,
          builder: ((ctxt, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.error != null) {
              return Center(
                child: Text('An Error occured'),
              );
            } else {
              return Consumer<OrderProvider>(
                builder: (context, ordersData, child) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return OrderItem(myOrder: ordersData.orders[index]);
                    },
                    itemCount: ordersData.orders.length,
                  );
                },
              );
            }
          }),
        ));
  }
}
