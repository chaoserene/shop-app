import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/orders_provider.dart' show OrdersProvider;
import 'package:shop_mart/widgets/app_drawer.dart';
import 'package:shop_mart/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: FutureBuilder(
          future: Provider.of<OrdersProvider>(context, listen: false)
              .fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Consumer<OrdersProvider>(
                  builder: (ctx, orderData, child) => orderData.orders.length ==
                          0
                      ? Center(
                          child: Text("You haven't purchased anything yet!"),
                        )
                      : ListView.builder(
                          itemBuilder: (ctx, index) =>
                              OrderItem(orderData.orders[index]),
                          itemCount: orderData.orders.length,
                        ));
            }
          }),
      drawer: AppDrawer(),
    );
  }
}
