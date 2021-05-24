import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_mart/models/http_exception.dart';
import 'package:shop_mart/providers/product.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  final productsUrl =
      Uri.https("meal-app-e2e94-default-rtdb.firebaseio.com", "/products.json");

  List<Product> _items = [];

  List<Product> get favoriteItems {
    return [..._items.where((element) => element.isFavorite)];
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final data = await http.post(productsUrl,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite
          }));

      final newProduct = Product(
          title: product.title,
          price: product.price,
          description: product.description,
          imageUrl: product.imageUrl,
          id: json.decode(data.body)['name']);
      _items.add(newProduct);
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(Product product) async {
    final prodIndex = _items.indexWhere((element) => element.id == product.id);
    if (prodIndex >= 0) {
      final updateUrl = Uri.https("meal-app-e2e94-default-rtdb.firebaseio.com",
          "/products/${product.id}.json");
      await http.patch(updateUrl,
          body: json.encode({
            'title': product.title,
            'descruprion': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price
          }));
      _items[prodIndex] = product;
      notifyListeners();
    }
  }

  Future<void> fetchAndSetProducts() async {
    var response = await http.get(productsUrl);
    final products = json.decode(response.body) as Map<String, dynamic>;
    final List<Product> loadedProducts = [];

    if (products != null) {
      products.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavorite']));
      });
    }

    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    final deleteUrl = Uri.https("meal-app-e2e94-default-rtdb.firebaseio.com",
        "/products/$productId.json");
    final response = await http.delete(deleteUrl);
    if (response.statusCode >= 400) {
      throw HttpException('Could not delete product.');
    }
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();
  }
}
