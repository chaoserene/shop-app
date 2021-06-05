import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_mart/models/http_exception.dart';
import 'package:shop_mart/providers/product.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  String authToken;
  List<Product> _items;
  String userId;

  ProductsProvider(this.authToken, this._items, this.userId);

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
      final data = await http.post(
          Uri.https("meal-app-e2e94-default-rtdb.firebaseio.com",
              "/products.json", {'auth': authToken}),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': this.userId
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
          "/products/${product.id}.json", {'auth': authToken});
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

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    var mapFilter = {'auth': authToken};

    if (filterByUser) {
      mapFilter['orderBy'] = json.encode('creatorId');
      mapFilter['equalTo'] = json.encode(this.userId);
    }

    var response = await http.get(Uri.https(
        "meal-app-e2e94-default-rtdb.firebaseio.com",
        "/products.json",
        mapFilter));
    final products = json.decode(response.body) as Map<String, dynamic>;
    final List<Product> loadedProducts = [];

    if (products != null) {
      final favResponse = await http.get(Uri.https(
          "meal-app-e2e94-default-rtdb.firebaseio.com",
          "/userFavorites/${this.userId}.json",
          {'auth': authToken}));
      final favoriteData = json.decode(favResponse.body);

      products.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: double.parse(prodData['price'].toString()),
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
    }

    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    final deleteUrl = Uri.https("meal-app-e2e94-default-rtdb.firebaseio.com",
        "/products/$productId.json", {'auth': authToken});
    final response = await http.delete(deleteUrl);
    if (response.statusCode >= 400) {
      throw HttpException('Could not delete product.');
    }
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();
  }
}
