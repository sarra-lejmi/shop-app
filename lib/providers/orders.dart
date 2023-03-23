import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem>? theOrders;
  String? authToken;
  final String? userId;

  Orders({
    this.authToken,
    this.theOrders,
    this.userId,
  });

  List<OrderItem> get orders {
    return theOrders == null ? [] : [...theOrders!];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-app-flutter-project-sl-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode(
        {
          "amount": total,
          "dateTime": timestamp.toIso8601String(),
          "products": cartProducts
              .map(
                (cp) => {
                  "id": cp.id,
                  "title": cp.title,
                  "quantity": cp.quantity,
                  "price": cp.price,
                },
              )
              .toList(),
        },
      ),
    );
    theOrders!.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shop-app-flutter-project-sl-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // ignore: unnecessary_null_comparison
    if (extractedData == null) {
      return;
    }
    extractedData.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData["amount"],
            products: (orderData["products"] as List<dynamic>)
                .map((item) => CartItem(
                    id: item["id"],
                    title: item["title"],
                    quantity: item["quantity"],
                    price: item["price"]))
                .toList(),
            dateTime: DateTime.parse(orderData["dateTime"]),
          ),
        );
      },
    );
    theOrders = loadedOrders;
    notifyListeners();
  }
}
