import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/models/products.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import 'package:shop_app/widgets/splash_screen.dart';
import './providers/products_providers.dart';
import './screens/products_overview_screen.dart';

import 'screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products_Provider>(
            create: (context) {
              var token = Provider.of<Auth>(context, listen: false).token;
              var userId = Provider.of<Auth>(context, listen: false).userId;
              return Products_Provider(token, userId);
            },
            update: (context, auth, previous) {
              previous?.setToken(auth.token);
              return previous ?? Products_Provider(auth.token, auth.userId);
            },
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, OrderProvider>(
            create: (context) {
              var token = Provider.of<Auth>(context, listen: false).token;
              var userId = Provider.of<Auth>(context, listen: false).userId;
              return OrderProvider(token, userId);
            },
            update: (context, auth, previous) {
              previous?.setToken(auth.token);
              return previous ?? OrderProvider(auth.token, auth.userId);
            },
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, auth, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'MyShop',
              theme: ThemeData(
                primarySwatch: Colors.purple,
                colorScheme: const ColorScheme(
                    brightness: Brightness.light,
                    primary: Colors.purple,
                    onPrimary: Colors.white,
                    secondary: Color.fromARGB(255, 235, 83, 37),
                    onSecondary: Colors.white,
                    error: Colors.red,
                    onError: Colors.white,
                    background: Colors.lightGreenAccent,
                    onBackground: Colors.black,
                    surface: Color.fromARGB(255, 122, 6, 45),
                    onSurface: Colors.black),
                textTheme: GoogleFonts.latoTextTheme(),
              ),
              routerConfig: _router,
            );
          },
        ));
  }
}

final GoRouter _router = GoRouter(routes: [
  GoRoute(
    name: 'home',
    path: '/',
    builder: (context, state) => Consumer<Auth>(
      builder: (context, auth, child) {
        if (auth.isAuth) {
          return ProductsOverviewScreen();
        } else {
          //try to auto login the user
          return FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (context, authResultSnapshot) {
              if (authResultSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return SplashScreen();
              }else {
                return AuthScreen();
              }
            },
          );
          
        }
      },
    ),
    routes: [
      GoRoute(
        name: 'product_detail',
        path: 'product_detail',
        builder: (context, state) => ProductDetailScreen(
          product: state.extra as Product,
        ),
      ),
      GoRoute(
        name: 'cart_screen',
        path: 'cart_screen',
        builder: (context, state) => CartScreen(),
      ),
      GoRoute(
        name: 'orders_screen',
        path: 'orders_screen',
        builder: (context, state) => OrdersScreen(),
      ),
      GoRoute(
        name: 'user_products',
        path: 'user_products',
        builder: (context, state) => UserProductsScreen(),
        routes: [
          GoRoute(
            name: 'edit_products',
            path: 'edit_products',
            builder: (context, state) =>
                EditProductScreen(product: state.extra as Product?),
          ),
        ],
      ),
    ],
  ),
]);
