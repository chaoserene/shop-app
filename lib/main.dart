import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/auth_provider.dart';
import 'package:shop_mart/providers/cart_provider.dart';
import 'package:shop_mart/providers/orders_provider.dart';
import 'package:shop_mart/providers/products_provider.dart';
import 'package:shop_mart/screens/auth_screen.dart';
import 'package:shop_mart/screens/cart_screen.dart';
import 'package:shop_mart/screens/edit_product_screen.dart';
import 'package:shop_mart/screens/orders_screen.dart';
import 'package:shop_mart/screens/product_detail_screen.dart';
import 'package:shop_mart/screens/products_overview_screen.dart';
import 'package:shop_mart/screens/user_products_screen.dart';
import 'package:shop_mart/widgets/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => AuthProvider()),
          ChangeNotifierProvider(create: (ctx) => CartProvider()),
          ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
            create: (_) => null,
            update: (_, auth, previousOrders) => OrdersProvider(
                auth.token,
                previousOrders == null ? [] : previousOrders.orders,
                auth.userId),
          ),
          ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
            create: (_) => null,
            update: (_, auth, previousProducts) => ProductsProvider(
                auth.token,
                previousProducts == null ? [] : previousProducts.items,
                auth.userId),
          ),
        ],
        child: Consumer<AuthProvider>(builder: (ctx, authData, _) {
          return MaterialApp(
            title: 'Shop Mart',
            theme: ThemeData(
                primarySwatch: Colors.orange,
                accentColor: Colors.grey,
                fontFamily: 'Lato'),
            home: authData.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: authData.tryAutoLogin(),
                    builder: (ctx, snapShot) =>
                        snapShot.connectionState == ConnectionState.waiting
                            ? Center(
                                child: SplashScreen(),
                              )
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              AuthScreen.routeName: (ctx) => AuthScreen()
            },
          );
        }));
  }
}
