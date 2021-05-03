import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/cart_provider.dart' show CartProvider;
import 'package:shop_mart/providers/orders_provider.dart';
import 'package:shop_mart/widgets/cart_item.dart' as ci;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartData.totalAmount}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                      onPressed: () {
                        Provider.of<OrdersProvider>(context, listen: false)
                            .addOrder(cartData.items.values.toList(),
                                cartData.totalAmount);
                        cartData.clear();
                      },
                      child: Text('Order Now'))
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, index) => ci.CartItem(
                cartData.items.values.toList()[index].id,
                cartData.items.keys.toList()[index],
                cartData.items.values.toList()[index].price,
                cartData.items.values.toList()[index].quantity,
                cartData.items.values.toList()[index].title),
            itemCount: cartData.itemCount,
          ))
        ],
      ),
    );
  }
}
