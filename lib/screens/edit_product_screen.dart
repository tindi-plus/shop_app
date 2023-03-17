import 'package:flutter/material.dart';
import 'package:shop_app/models/products.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_providers.dart';

class EditProductScreen extends StatefulWidget {
  Product? product;
  EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageInputController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  bool isEditing = true;
  bool isLoading = false;
  var editedProduct =
      Product(description: '', id: '', imageUrl: '', price: 0, title: '');

  @override
  void initState() {
    if (widget.product == null) {
      isEditing = false;
    }
    widget.product ??= editedProduct;
    _imageInputController.text = widget.product!.imageUrl;
    _imageFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      if (!_imageInputController.text.startsWith('http') &&
          !_imageInputController.text.startsWith('https')) {
        return;
      }
      if (!_imageInputController.text.endsWith('.png') &&
          !_imageInputController.text.endsWith('.jpg') &&
          !_imageInputController.text.endsWith('.jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageInputController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      isLoading = true;
    });
    try {
      if (isEditing) {
        await Provider.of<Products_Provider>(context, listen: false)
            .updateProduct(widget.product!);
      } else {
        await Provider.of<Products_Provider>(context, listen: false)
            .addProduct(widget.product!);
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('An Error has occured.'),
            content: const Text('Something went wrong.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Okay')),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        initialValue: widget.product!.title,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (newValue) {
                          widget.product = Product(
                            description: widget.product!.description,
                            id: widget.product!.id,
                            imageUrl: widget.product!.imageUrl,
                            price: widget.product!.price,
                            title: newValue ?? '',
                            isFavourite: widget.product!.isFavourite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'The title is empty! Enter Title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        initialValue: widget.product!.price.toString(),
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (newValue) {
                          widget.product = Product(
                            description: widget.product!.description,
                            id: widget.product!.id,
                            imageUrl: widget.product!.imageUrl,
                            price: double.parse(newValue ?? '0'),
                            title: widget.product!.title,
                            isFavourite: widget.product!.isFavourite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please ener a valid number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a price greater than 0.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        initialValue: widget.product!.description,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        onSaved: (newValue) {
                          widget.product = Product(
                            description: newValue ?? "",
                            id: widget.product!.id,
                            imageUrl: widget.product!.imageUrl,
                            price: widget.product!.price,
                            title: widget.product!.title,
                            isFavourite: widget.product!.isFavourite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description.';
                          }
                          if (value.length < 11) {
                            return 'Enter a description with more than 10 characters.';
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
                              right: 10,
                              top: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageInputController.text.isEmpty
                                ? Text('Enter an Image URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageInputController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageInputController,
                              focusNode: _imageFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (newValue) {
                                widget.product = Product(
                                  description: widget.product!.description,
                                  id: widget.product!.id,
                                  imageUrl: newValue ?? '',
                                  price: widget.product!.price,
                                  title: widget.product!.title,
                                  isFavourite: widget.product!.isFavourite,
                                );
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an image URL.';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid URL.';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter a valid image URL.';
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
