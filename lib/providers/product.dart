import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  void toggleFavoriteStatus() {
    this.isFavorite = !this.isFavorite;
    final updateUrl = Uri.https("meal-app-e2e94-default-rtdb.firebaseio.com",
        "/products/${this.id}.json");
    http.patch(updateUrl, body: json.encode({'isFavorite': this.isFavorite}));
    notifyListeners();
  }
}
