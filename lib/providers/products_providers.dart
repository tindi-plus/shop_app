import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/models/products.dart';
import 'package:http/http.dart' as http;

class Products_Provider with ChangeNotifier {
  String? token;
  String? userId;
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  Products_Provider(this.token, this.userId);

  // var _showFavouritesOnly = false;

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((element) => element.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get favouritesOnly {
    //return only the favourite products
    return _items.where((element) => element.isFavourite).toList();
  }

  void setToken(String? newToken) {
    token = newToken;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts({bool filter = false}) async {
    // var url = Uri.https(
    //   'shop-app-6f36b-default-rtdb.firebaseio.com',
    //   '/products.json',
    //   {
    //     'auth': token,
    //     'orderBy': 'creatorId',
    //     'equalTo': userId,
    //   },
    // );
    var filterString = filter ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop-app-6f36b-default-rtdb.firebaseio.com/products.json?auth=$token$filterString');

    var urlFav = Uri.https(
      'shop-app-6f36b-default-rtdb.firebaseio.com',
      '/userFavourites/$userId.json',
      {'auth': token},
    );

    try {
      final response = await http.get(url);
      final favouriteResponse = await http.get(urlFav);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      //If the returned map of favourite products is null, set [favouriteData]
      // to empty map
      favouriteData ?? {};

      extractedData.forEach((key, prodData) {
        var prod = Product(
          description: prodData['description'],
          id: key,
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          title: prodData['title'],
          //If the favouriteData does not contain the prod id, set isFavourtie to false
          isFavourite: favouriteData[key] ?? false,
        );

        loadedProducts.add(prod);
      });
      _items = loadedProducts;
      notifyListeners();
      print('loading items complete');
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.https(
      'shop-app-6f36b-default-rtdb.firebaseio.com',
      '/products.json',
      {'auth': token},
    );
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));

      final newProduct = Product(
        description: product.description,
        id: json.decode(response.body)['name'],
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
        isFavourite: product.isFavourite,
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error.toString());
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    var url = Uri.https(
      'shop-app-6f36b-default-rtdb.firebaseio.com',
      '/products/${product.id}.json',
      {'auth': token},
    );

    try {
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
    } catch (error) {
      rethrow;
    }

    final productIndex =
        _items.indexWhere((element) => element.id == product.id);
    _items[productIndex] = product;
    notifyListeners();
  }

  Future<void> deleteProduct(Product product) async {
    var url = Uri.https(
      'shop-app-6f36b-default-rtdb.firebaseio.com',
      '/products/${product.id}',
      {'auth': token},
    );
    var tempIndex = _items.indexWhere((element) => element.id == product.id);
    var temDeletedProd = _items[tempIndex];
    _items.removeAt(tempIndex);
    notifyListeners();
    var response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(tempIndex, temDeletedProd);
      notifyListeners();
      throw HttpException('Could not delete message');
    }
    temDeletedProd = null as Product;
  }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }
}
