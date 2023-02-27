import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyShop',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.purple,
            onPrimary: Colors.white,
            secondary: Colors.deepOrange,
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            background: Colors.lightGreenAccent,
            onBackground: Colors.black,
            surface: Colors.pinkAccent,
            onSurface: Colors.white),
            textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: ProductsOverviewScreen(),
    );
  }
}
