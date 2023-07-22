class Product {
  int? id;
  String? name;
  String? price;
  int? quantity;

  Product({this.id, this.name, this.price, this.quantity});

  // map => product object
  static Product fromMap(Map<String, dynamic> query) {
    Product product = Product();
    product.id = query['id'];
    product.name = query['name'];
    product.price = query['price'];
    product.quantity = query['quantity'];
    return product;
  }

  //product object => map
  static Map<String, dynamic> toMap(Product product) {
    return <String, dynamic>{
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'quantity': product.quantity
    };
  }

  //get product list
  static List<Product> fromMapList(List<Map<String, dynamic>> query) {
    List<Product> productList = List.generate(
      query.length,
      (index) => Product.fromMap(query[index]),
    );

    return productList;
  }
}
