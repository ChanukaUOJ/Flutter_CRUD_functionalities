import 'package:flutter/material.dart';
import 'package:working_with_local_backend/Product_DB_Helper.dart';

import 'Product.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<Product> productsList = [];

  Product? _selectedProduct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ProductDBHelper.instance.getProductsList().then((value) {
      setState(() {
        productsList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Screen"),
        backgroundColor: Colors.green[400],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: productsList.length,
                  itemBuilder: (BuildContext context, index) {
                    if (productsList.isNotEmpty) {
                      return InkWell(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 3,
                                    spreadRadius: 3,
                                    color: Colors.grey.withOpacity(0.2))
                              ]),
                          child: ListTile(
                              leading: const Icon(Icons.all_inbox),
                              title: Text(
                                productsList[index].name!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "LKR ${productsList[index].price!}",
                                style: const TextStyle(fontSize: 15),
                              ),
                              trailing: Container(
                                width: 100,
                                child:
                                    Wrap(direction: Axis.horizontal, children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedProduct = productsList[index];
                                        showProductDialog(
                                            context, InputType.updateProduct);
                                      });
                                    },
                                    icon: const Icon(Icons.edit),
                                    color: Colors.grey[500],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedProduct = productsList[index];
                                      });

                                      ProductDBHelper.instance
                                          .deleteProduct(_selectedProduct!)
                                          .then((value) {
                                        ProductDBHelper.instance
                                            .getProductsList()
                                            .then((value) {
                                          setState(() {
                                            productsList = value;
                                          });
                                        });
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red[500],
                                  ),
                                ]),
                              )),
                        ),
                      );
                    } else {
                      return const SizedBox(
                        child: Center(child: Text("List is empty!")),
                      );
                    }
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showProductDialog(context, InputType.addProduct);
        },
        backgroundColor: Colors.green[400],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  showProductDialog(BuildContext context, InputType type) {
    bool isUpdateProduct = (type == InputType.updateProduct) ? true : false;

    if (isUpdateProduct && _selectedProduct != null) {
      // Use null-aware operators to handle possible null values
      _nameController.text = _selectedProduct?.name ?? '';
      _priceController.text = _selectedProduct?.price ?? '';
      _quantityController.text = _selectedProduct?.quantity?.toString() ?? '';
    }

    var saveButton = TextButton(
      onPressed: () {
        if (_nameController.text.isNotEmpty &&
            _priceController.text.isNotEmpty &&
            _quantityController.text.isNotEmpty) {
          if (!isUpdateProduct) {
            setState(() {
              Product product = Product();
              product.name = _nameController.text;
              product.price = _priceController.text;
              product.quantity = int.parse(_quantityController.text);

              ProductDBHelper.instance.insertProduct(product).then((value) {
                ProductDBHelper.instance.getProductsList().then((value) {
                  setState(() {
                    productsList = value;
                  });
                });

                Navigator.pop(context);
                _emptyListText();
              });
            });
          } else {
            setState(() {
              _selectedProduct?.name = _nameController.text;
              _selectedProduct?.price = _priceController.text;
              _selectedProduct?.quantity = int.parse(_quantityController.text);

              ProductDBHelper.instance
                  .updateProduct(_selectedProduct!)
                  .then((value) {
                ProductDBHelper.instance.getProductsList().then((value) {
                  setState(() {
                    productsList = value;
                  });
                });

                Navigator.pop(context);
                _emptyListText();
              });
            });
          }
        }
      },
      child: const Text("Save"),
    );
    var cancelButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );

    AlertDialog ProductDetails = AlertDialog(
      title: const Text("Add Products"),
      content: SizedBox(
        child: Wrap(
          children: [
            SizedBox(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
              ),
            ),
            SizedBox(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                ),
              ),
            ),
            SizedBox(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                ),
              ),
            )
          ],
        ),
      ),
      actions: [saveButton, cancelButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProductDetails;
        });
  }

  void _emptyListText() {
    _nameController.text = "";
    _priceController.text = "";
    _quantityController.text = "";
  }
}

enum InputType { addProduct, updateProduct }
