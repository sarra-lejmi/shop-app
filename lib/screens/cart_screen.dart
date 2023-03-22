import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      cart.totalAmount().toStringAsFixed(2),
                      style: Theme.of(context).primaryTextTheme.titleSmall,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OdrerTextButton(cart: cart),
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) => CartItemWidget(
              id: cart.items.values.toList()[index].id,
              productId: cart.items.keys.toList()[index],
              title: cart.items.values.toList()[index].title,
              price: cart.items.values.toList()[index].price,
              quantity: cart.items.values.toList()[index].quantity,
            ),
          )),
        ],
      ),
    );
  }
}

class OdrerTextButton extends StatefulWidget {
  const OdrerTextButton({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  State<OdrerTextButton> createState() => _OdrerTextButtonState();
}

class _OdrerTextButtonState extends State<OdrerTextButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.purpleAccent,
        textStyle: Theme.of(context).textTheme.labelSmall,
      ),
      onPressed: (widget.cart.totalAmount() <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount(),
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text(
              "ORDER NOW",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }
}
