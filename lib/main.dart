import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/consts/routes.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_details_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Products(),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (context) => Orders(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          fontFamily: "Lato",
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.deepOrange,
                secondary: Colors.deepOrange,
              ),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.purple),
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            labelStyle: TextStyle(color: Colors.purple),
          ),
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: Colors.purple),
        ),
        home: const ProductOverviewScreen(),
        routes: {
          productDetailsRoute: (context) => const ProductDetailsScreen(),
          cartRoute: (context) => const CartScreen(),
          ordersRoute: (context) => const OrdersScreen(),
          productsRoute: (context) => const UserProductsScreen(),
          editProductRoute: (context) => const EditProductScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
