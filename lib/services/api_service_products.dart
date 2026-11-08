import 'package:dio/dio.dart';

import '../models/product_model.dart';

/// Endpoint https://dummyjson.com/docs/products
class ApiServiceProducts {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// GET /products?limit=&skip= (limit=0 -> semua produk)
  Future<ProductsResponse> getAllProducts({
    int limit = 30,
    int skip = 0,
  }) async {
    final res = await _dio.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductsResponse.fromJson(res.data);
  }

  Future<Product> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data);
  }

  Future<Product> addProduct(Map<String, dynamic> data) async {
    final res = await _dio.post('/products/add', data: data);
    return Product.fromJson(res.data);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/products/$id', data: data);
    return Product.fromJson(res.data);
  }

  /// DELETE /products/{id}
  Future<void> deleteProduct(int id) async {
    await _dio.delete('/products/$id');
  }

  Future<ProductsResponse> searchProducts(String query) async {
    final res = await _dio.get(
      '/products/search',
      queryParameters: {'q': query, 'limit': 0},
    );
    return ProductsResponse.fromJson(res.data);
  }

  Future<ProductsResponse> getProductsPaginated({
    int limit = 10,
    int skip = 0,
    String? select,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'skip': skip};
    if (select != null) params['select'] = select;
    final res = await _dio.get('/products', queryParameters: params);
    return ProductsResponse.fromJson(res.data);
  }

  Future<ProductsResponse> sortProducts(String sortBy, String order) async {
    final res = await _dio.get(
      '/products',
      queryParameters: {'sortBy': sortBy, 'order': order, 'limit': 0},
    );
    return ProductsResponse.fromJson(res.data);
  }

  Future<List<Category>> getCategories() async {
    final res = await _dio.get('/products/categories');
    return (res.data as List)
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<String>> getCategoryList() async {
    final res = await _dio.get('/products/category-list');
    return (res.data as List).map((e) => e.toString()).toList();
  }

  Future<ProductsResponse> getProductsByCategory(String category) async {
    final res = await _dio.get(
      '/products/category/$category',
      queryParameters: {'limit': 0},
    );
    return ProductsResponse.fromJson(res.data);
  }
}
