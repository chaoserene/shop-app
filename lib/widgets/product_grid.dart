import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/products_provider.dart';
import 'package:shop_mart/widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;
  ProductGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return products.length == 0
        ? Center(
            child: Text('No products available'),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: products[index], child: ProductItem()),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
          );
  }
}
