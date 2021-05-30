import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/products_provider.dart';
import 'package:shop_mart/screens/edit_product_screen.dart';
import 'package:shop_mart/widgets/app_drawer.dart';
import 'package:shop_mart/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-product';

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<ProductsProvider>(ctx, listen: false)
        .fetchAndSetProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      child: Consumer<ProductsProvider>(
                        builder: (context, productsData, _) => Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            itemBuilder: (_, index) => Column(
                              children: [
                                UserProductItem(
                                    productsData.items[index].title,
                                    productsData.items[index].imageUrl,
                                    productsData.items[index].id),
                                Divider()
                              ],
                            ),
                            itemCount: productsData.items.length,
                          ),
                        ),
                      ),
                      onRefresh: () => _refreshProducts(context),
                    )),
    );
  }
}
