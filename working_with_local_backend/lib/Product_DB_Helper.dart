import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import 'Product.dart';

class ProductDBHelper {
  static const _databaseName = "mydb.db";
  static const _databaseVersion = 1;

  static const _tableName = "products";
  static String path = "";

  ProductDBHelper._privateConstructor();
  static final ProductDBHelper instance = ProductDBHelper._privateConstructor();

  static Database? _database;

  //check whether the database created or not
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  //initialize database with local file path, db name
  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    // Localstorage path/databasename.db
    String path = join(documentDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  //oncreate for create the database
  Future _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY autoincrement, name TEXT, price TEXT, quantity INTEGER)');
  }

  //set the path to access the local database
  static Future getFieldData() async {
    return getDatabasesPath().then((value) {
      return path = value;
    });
  }

  //insert data
  Future insertProduct(Product product) async {
    Database? db = await instance.database;

    return await db.insert(_tableName, Product.toMap(product),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  //update data
  Future<Product> updateProduct(Product product) async {
    Database db = await instance.database;

    await db.update(_tableName, Product.toMap(product),
        where: 'id = ?', whereArgs: [product.id]);

    return product;
  }

  //delete data
  Future deleteProduct(Product product) async {
    Database db = await instance.database;

    var deletedProduct =
        await db.delete(_tableName, where: 'id = ?', whereArgs: [product.id]);

    return deletedProduct;
  }

  Future<List<Product>> getProductsList() async {
    Database? db = await instance.database;

    List<Map<String, dynamic>> maps = await db.query(_tableName);
    print(maps);
    return Product.fromMapList(maps);
  }
}
