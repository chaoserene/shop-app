import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/auth_provider.dart';
import 'package:shop_mart/providers/cart_provider.dart';
import 'package:shop_mart/providers/product.dart';
import 'package:shop_mart/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
        ),
        header: Container(
          color: Colors.black87,
          padding: EdgeInsets.all(5),
          child: Text(
            product.title,
            style: TextStyle(color: Colors.white),
          ),
        ),
        footer: GridTileBar(
          leading: Row(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined,
                    color: Theme.of(context).primaryColor),
                onPressed: () {
                  cart.addItem(product.id, product.price, product.title);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Product's been added to cart!"),
                    action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ));
                },
              ),
              Consumer<Product>(
                builder: (ctx, product, child) => IconButton(
                  icon: Icon(
                    product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    product.toggleFavoriteStatus(auth.token, auth.userId);
                  },
                ),
              )
            ],
          ),
          backgroundColor: Colors.black87,
          title: Text(
            '\$${product.price.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }
}
