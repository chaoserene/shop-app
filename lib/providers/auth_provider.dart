import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_mart/models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expirationDate;
  String _userId;
  Timer _timer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expirationDate != null &&
        _expirationDate.isAfter(DateTime.now())) return _token;

    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signUp(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCkCIGPi4b7EY_0tPudDLZ6eFuI8k1sj5c");
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final data = json.decode(response.body);

      if (data['error'] != null) throw HttpException(data['error']['message']);

      _token = data['idToken'];
      _userId = data['localId'];
      _expirationDate =
          DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));

      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'auth',
          json.encode({
            'token': _token,
            'userId': _userId,
            'expirationDate': _expirationDate.toIso8601String()
          }));
    } catch (er) {
      throw er;
    }
  }

  Future<void> logIn(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCkCIGPi4b7EY_0tPudDLZ6eFuI8k1sj5c");
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final data = json.decode(response.body);

      if (data['error'] != null) throw HttpException(data['error']['message']);

      _token = data['idToken'];
      _userId = data['localId'];
      _expirationDate =
          DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'auth',
          json.encode({
            'token': _token,
            'userId': _userId,
            'expirationDate': _expirationDate.toIso8601String()
          }));
    } catch (er) {
      throw er;
    }
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expirationDate = null;

    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    prefs.clear();
  }

  void _autoLogout() {
    if (_timer != null) _timer.cancel();
    var timeToExpiry = _expirationDate.difference(DateTime.now()).inSeconds;
    _timer = Timer(Duration(seconds: timeToExpiry), () {
      logOut();
    });
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('auth')) return false;

    final userData =
        json.decode(prefs.getString('auth')) as Map<String, dynamic>;
    final expirationDate = DateTime.parse(userData['expirationDate']);

    if (expirationDate.isBefore(DateTime.now())) return false;

    _token = userData['token'];
    _userId = userData['userId'];
    _expirationDate = DateTime.parse(userData['expirationDate']);

    notifyListeners();
    _autoLogout();
    return true;
  }
}
