import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service_products.dart';

typedef _Matcher = bool Function(Product product);

/// State produk + operasi CRUD.
///
/// Backend: https://dummyjson.com. Server ini hanya *mensimulasikan* operasi
/// tulis (POST/PATCH/DELETE membalas sukses tetapi data server tidak berubah).
/// Supaya aplikasi tetap terasa CRUD penuh, setiap perubahan yang sukses di
/// server disimpan juga di "overlay" lokal (produk baru, produk yang diedit,
/// produk yang dihapus) dan diterapkan lagi setiap kali data dimuat ulang
/// (refresh, cari, filter kategori, urutkan).
class ProductProvider extends ChangeNotifier {
  ProductProvider({ApiServiceProducts? api})
      : _api = api ?? ApiServiceProducts();

  final ApiServiceProducts _api;

  List<Product> _products = [];
  List<String> _categoryList = [];
  bool _loading = false;
  String? _error;
  String? _actionError;
  String _selectedCategory = '';

  // Penanda request terbaru agar respons lama tidak menimpa hasil baru.
  int _requestId = 0;

  // ---- Overlay perubahan lokal ----
  final List<Product> _created = [];
  final Map<int, Product> _edited = {};
  final Set<int> _deleted = {};
  final Map<int, Product> _cache = {};
  int _nextLocalId = kLocalIdStart;

  // Filter tampilan aktif (dipakai untuk menentukan apakah produk baru cocok).
  _Matcher _matcher = (_) => true;

  List<Product> get products => _products;
  List<String> get categoryList => _categoryList;
  bool get loading => _loading;
  String? get error => _error;

  /// Pesan error dari operasi tambah / ubah / hapus terakhir.
  String? get actionError => _actionError;
  int get total => _products.length;
  String get selectedCategory => _selectedCategory;

  /// Produk terbaru berdasarkan id (null jika tidak dikenal / sudah dihapus).
  Product? byId(int id) => _cache[id];

  // ------------------------------------------------------------------
  // READ
  // ------------------------------------------------------------------

  Future<void> _load(
    Future<ProductsResponse> Function() call, {
    _Matcher? matcher,
    String? sortBy,
    String order = 'asc',
  }) async {
    final id = ++_requestId;
    _matcher = matcher ?? (_) => true;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await call();
      if (id != _requestId) return;
      final merged = _applyOverlay(res.products, sortBy, order);
      for (final item in merged) {
        _cache[item.id] = item;
      }
      _products = merged;
    } catch (e) {
      if (id != _requestId) return;
      _error = _friendly(e);
      _products = [];
    } finally {
      if (id == _requestId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  List<Product> _applyOverlay(
    List<Product> fetched,
    String? sortBy,
    String order,
  ) {
    final result = <Product>[];
    for (final item in fetched) {
      if (_deleted.contains(item.id)) continue;
      result.add(_edited[item.id] ?? item);
    }
    // Produk yang dibuat di aplikasi tampil paling atas bila cocok dengan
    // filter yang sedang aktif.
    result.insertAll(0, _created.where(_matcher));

    if (sortBy != null) {
      int compare(Product a, Product b) {
        if (sortBy == 'price') return a.price.compareTo(b.price);
        if (sortBy == 'rating') return a.rating.compareTo(b.rating);
        if (sortBy == 'stock') return a.stock.compareTo(b.stock);
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }

      result.sort((a, b) => order == 'desc' ? compare(b, a) : compare(a, b));
    }
    return result;
  }

  Future<void> fetchProducts({int limit = 30, int skip = 0}) {
    _selectedCategory = '';
    return _load(() => _api.getAllProducts(limit: limit, skip: skip));
  }

  Future<void> fetchCategories() async {
    try {
      _categoryList = await _api.getCategoryList();
      notifyListeners();
    } catch (_) {
      // Kategori pelengkap; kegagalannya tidak perlu menghentikan UI.
    }
  }

  Future<void> searchProducts(String query) {
    final q = query.trim();
    if (q.isEmpty) return fetchProducts(limit: 0);
    _selectedCategory = '';
    final lower = q.toLowerCase();
    return _load(
      () => _api.searchProducts(q),
      matcher: (p) =>
          p.title.toLowerCase().contains(lower) ||
          p.description.toLowerCase().contains(lower) ||
          p.brand.toLowerCase().contains(lower) ||
          p.category.toLowerCase().contains(lower),
    );
  }

  Future<void> filterByCategory(String category) {
    if (category.isEmpty) return fetchProducts(limit: 0);
    _selectedCategory = category;
    return _load(
      () => _api.getProductsByCategory(category),
      matcher: (p) => p.category == category,
    );
  }

  Future<void> sortProducts(String sortBy, String order) {
    _selectedCategory = '';
    return _load(
      () => _api.sortProducts(sortBy, order),
      sortBy: sortBy,
      order: order,
    );
  }

  /// Mengambil satu produk (dipakai saat membuka detail / edit lewat URL
  /// tanpa objek produk, mis. reload di web).
  Future<Product?> loadProduct(int id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    if (_deleted.contains(id) || isLocalProductId(id)) return null;
    try {
      final fetched = await _api.getProduct(id);
      final product = _edited[id] ?? fetched;
      _cache[id] = product;
      return product;
    } catch (e) {
      _actionError = _friendly(e);
      return null;
    }
  }

  // ------------------------------------------------------------------
  // CREATE
  // ------------------------------------------------------------------

  Future<Product?> addProduct(Map<String, dynamic> data) async {
    _actionError = null;
    try {
      // POST /products/add (server hanya mensimulasikan; id balikannya selalu
      // sama, jadi id unik dibuat sendiri di sisi aplikasi).
      await _api.addProduct(data);
      final product = Product.fromForm(_nextLocalId++, data);
      _created.insert(0, product);
      _cache[product.id] = product;
      if (_matcher(product)) {
        _products = [product, ..._products];
      }
      notifyListeners();
      return product;
    } catch (e) {
      _actionError = _friendly(e);
      notifyListeners();
      return null;
    }
  }

  // ------------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------------

  Future<Product?> updateProduct(int id, Map<String, dynamic> data) async {
    _actionError = null;
    final current = _cache[id];
    if (current == null) {
      _actionError = 'Produk tidak ditemukan.';
      notifyListeners();
      return null;
    }
    try {
      final local = isLocalProductId(id);
      // Produk lokal tidak dikenal server (PATCH-nya pasti 404), jadi hanya
      // produk asli server yang dikirim ke PATCH /products/{id}.
      if (!local) await _api.updateProduct(id, data);

      final updated = current.applyForm(data);
      _cache[id] = updated;
      if (local) {
        final i = _created.indexWhere((e) => e.id == id);
        if (i != -1) _created[i] = updated;
      } else {
        _edited[id] = updated;
      }

      final index = _products.indexWhere((e) => e.id == id);
      if (index != -1) {
        final next = List<Product>.of(_products);
        next[index] = updated;
        _products = next;
      }
      notifyListeners();
      return updated;
    } catch (e) {
      _actionError = _friendly(e);
      notifyListeners();
      return null;
    }
  }

  // ------------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------------

  Future<bool> deleteProduct(int id) async {
    _actionError = null;
    try {
      final local = isLocalProductId(id);
      if (!local) await _api.deleteProduct(id); // DELETE /products/{id}

      _created.removeWhere((e) => e.id == id);
      _edited.remove(id);
      if (!local) _deleted.add(id);
      _cache.remove(id);
      _products = _products.where((e) => e.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = _friendly(e);
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------------------------------------

  String _friendly(Object e) {
    if (e is DioException) {
      final type = e.type;
      if (type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.sendTimeout ||
          type == DioExceptionType.receiveTimeout) {
        return 'Koneksi timeout. Coba lagi.';
      }
      if (type == DioExceptionType.connectionError) {
        return 'Tidak ada koneksi internet.';
      }
      if (type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode;
        if (code == 404) return 'Data tidak ditemukan di server (404).';
        return 'Server menolak permintaan ($code).';
      }
      return 'Terjadi kesalahan jaringan.';
    }
    return 'Terjadi kesalahan: $e';
  }
}
