import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/consts/routes.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your products"),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(editProductRoute),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (context, index) => UserProductItem(
              id: productsData.items[index].id!,
              title: productsData.items[index].title,
              imageUrl: productsData.items[index].imageUrl,
            ),
          ),
        ),
      ),
    );
  }
}
