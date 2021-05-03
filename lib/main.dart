import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/cart_provider.dart';
import 'package:shop_mart/providers/orders_provider.dart';
import 'package:shop_mart/providers/products_provider.dart';
import 'package:shop_mart/screens/cart_screen.dart';
import 'package:shop_mart/screens/orders_screen.dart';
import 'package:shop_mart/screens/product_detail_screen.dart';
import 'package:shop_mart/screens/products_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ProductsProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => OrdersProvider()),
      ],
      child: MaterialApp(
        title: 'Shop Mart',
        theme: ThemeData(
            primarySwatch: Colors.orange,
            accentColor: Colors.grey,
            fontFamily: 'Lato'),
        home: ProductOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen()
        },
      ),
    );
  }
}
