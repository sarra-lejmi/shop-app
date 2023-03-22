import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/consts/routes.dart';
import 'package:shop_app/providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(title),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(editProductRoute, arguments: id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .deleteProduct(id);
                    } catch (error) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Deleting Failed!"),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
