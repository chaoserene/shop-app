import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/orders_provider.dart' show OrdersProvider;
import 'package:shop_mart/widgets/app_drawer.dart';
import 'package:shop_mart/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<OrdersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, index) => OrderItem(ordersData.orders[index]),
        itemCount: ordersData.orders.length,
      ),
      drawer: AppDrawer(),
    );
  }
}
