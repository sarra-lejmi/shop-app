import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: "",
    description: "",
    price: 0.0,
    imageUrl: "",
  );
  var _isInit = true;
  var _initValue = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      // ignore: unnecessary_null_comparison
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValue = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final validateField = _formKey.currentState!.validate();
    if (!validateField) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id!, _editedProduct);
      setState(() {
        _isLoading = false;
      Navigator.of(context).pop();
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
        setState(() {
          _isLoading = false;
          Navigator.of(context).pop();
        });
      } catch (e) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("An error occured!"),
            content: const Text("Something went wrong!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.of(ctx).pop();
                },
                child: const Text("OKAY"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValue["title"],
                        decoration: const InputDecoration(
                          label: Text("Title"),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (newValue) => _editedProduct = Product(
                          id: _editedProduct.id,
                          title: newValue!,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a title!";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue["price"],
                        decoration: const InputDecoration(
                          label: Text("Price"),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (newValue) => _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(newValue!),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a price!";
                          } else if (double.tryParse(value) == null) {
                            return "Please enter a valid number!";
                          } else if (double.parse(value) <= 0.0) {
                            return "Please enter a valide price!";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue["description"],
                        decoration: const InputDecoration(
                          label: Text("Description"),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        onSaved: (newValue) => _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: newValue!,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a description!";
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(
                              top: 8.0,
                              right: 10.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Text("Enter the image URL")
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Image URL"),
                              ),
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onEditingComplete: () {
                                setState(
                                  () {},
                                );
                              },
                              onFieldSubmitted: (_) => _saveForm(),
                              onSaved: (newValue) => _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: newValue!,
                                isFavorite: _editedProduct.isFavorite,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter an image URL!";
                                }

                                if (!value.startsWith("http") &&
                                    !value.startsWith("https")) {
                                  return "Please enter a valid URL!";
                                }

                                if (!value.endsWith(".png") &&
                                    !value.endsWith(".jpeg") &&
                                    !value.endsWith(".jpg")) {
                                  return "Please enter a valid image URL!";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
