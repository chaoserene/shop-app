import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mart/providers/product.dart';
import 'package:shop_mart/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _productForm =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _productForm = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          'title': _productForm.title,
          'description': _productForm.description,
          'price': _productForm.price.toString()
        };
        _imageUrlController.text = _productForm.imageUrl;
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
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
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      if (_productForm.id == null) {
        try {
          await Provider.of<ProductsProvider>(context, listen: false)
              .addProduct(_productForm);
        } catch (err) {
          await showDialog<Null>(
              context: context,
              builder: (ctx) => AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      )
                    ],
                    title: Text('An error ocurred'),
                    content: Text('Something went wrong!'),
                  ));
        } finally {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        }
      } else {
        Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(_productForm);
        setState(() {
          _isLoading = true;
        });
        Navigator.of(context).pop();
      }
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_productForm.id == null ? 'Edit product' : 'Add product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (val) {
                        _productForm = Product(
                            title: val,
                            price: _productForm.price,
                            description: _productForm.description,
                            imageUrl: _productForm.imageUrl,
                            id: _productForm.id,
                            isFavorite: _productForm.isFavorite);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'Please provide a title';
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (val) {
                        _productForm = Product(
                            title: _productForm.title,
                            price: double.parse(val),
                            description: _productForm.description,
                            imageUrl: _productForm.imageUrl,
                            id: _productForm.id,
                            isFavorite: _productForm.isFavorite);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'Please provide a price';
                        if (double.tryParse(val) == null)
                          return 'Please enter a valid price';
                        if (double.parse(val) <= 0)
                          return 'Please enter a price greater than zero';

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (val) {
                        _productForm = Product(
                            title: _productForm.title,
                            price: _productForm.price,
                            description: val,
                            imageUrl: _productForm.imageUrl,
                            id: _productForm.id,
                            isFavorite: _productForm.isFavorite);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'Please provide a description';
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter an URL')
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (val) {
                              _productForm = Product(
                                  title: _productForm.title,
                                  price: _productForm.price,
                                  description: _productForm.description,
                                  imageUrl: val,
                                  id: _productForm.id,
                                  isFavorite: _productForm.isFavorite);
                            },
                            validator: (val) {
                              if (val.isEmpty)
                                return 'Please provide a valid URL';
                              if (!val.startsWith('http'))
                                return 'Please enter a valid URL';
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
