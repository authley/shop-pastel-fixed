// Model hasil mapping response https://dummyjson.com/products

double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int _i(dynamic v, [int def = 0]) => (v as num?)?.toInt() ?? def;

/// DummyJSON hanya mensimulasikan operasi tulis (selalu membalas id 195 untuk
/// produk baru), jadi produk yang dibuat di aplikasi diberi id lokal yang
/// unik mulai dari angka ini (id server hanya 1..194).
const int kLocalIdStart = 10000;

bool isLocalProductId(int id) => id >= kLocalIdStart;

String _availabilityFor(int stock) {
  if (stock <= 0) return 'Out of Stock';
  if (stock < 10) return 'Low Stock';
  return 'In Stock';
}

class Dimensions {
  final double width;
  final double height;
  final double depth;

  Dimensions({this.width = 0, this.height = 0, this.depth = 0});

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
        width: _d(json['width']),
        height: _d(json['height']),
        depth: _d(json['depth']),
      );
}

class Review {
  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  Review({
    this.rating = 0,
    this.comment = '',
    this.date = '',
    this.reviewerName = '',
    this.reviewerEmail = '',
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        rating: _i(json['rating']),
        comment: json['comment']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        reviewerName: json['reviewerName']?.toString() ?? '',
        reviewerEmail: json['reviewerEmail']?.toString() ?? '',
      );
}

class Meta {
  final String createdAt;
  final String updatedAt;
  final String barcode;
  final String qrCode;

  Meta({
    this.createdAt = '',
    this.updatedAt = '',
    this.barcode = '',
    this.qrCode = '',
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
        barcode: json['barcode']?.toString() ?? '',
        qrCode: json['qrCode']?.toString() ?? '',
      );
}

class Category {
  final String slug;
  final String name;
  final String url;

  Category({required this.slug, required this.name, required this.url});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final double weight;
  final Dimensions dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<Review> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final Meta meta;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    this.price = 0,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.tags = const [],
    this.brand = '',
    this.sku = '',
    this.weight = 0,
    Dimensions? dimensions,
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.availabilityStatus = '',
    this.reviews = const [],
    this.returnPolicy = '',
    this.minimumOrderQuantity = 1,
    Meta? meta,
    this.thumbnail = '',
    this.images = const [],
  })  : dimensions = dimensions ?? Dimensions(),
        meta = meta ?? Meta();

  /// Membuat produk dari data form (dipakai saat Create).
  factory Product.fromForm(int id, Map<String, dynamic> data) {
    final thumb = data['thumbnail']?.toString() ?? '';
    final stock = _i(data['stock']);
    return Product(
      id: id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      price: _d(data['price']),
      stock: stock,
      brand: data['brand']?.toString() ?? '',
      thumbnail: thumb,
      images: thumb.isEmpty ? const [] : [thumb],
      availabilityStatus: _availabilityFor(stock),
      meta: Meta(createdAt: DateTime.now().toIso8601String()),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _i(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: _d(json['price']),
      discountPercentage: _d(json['discountPercentage']),
      rating: _d(json['rating']),
      stock: _i(json['stock']),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      brand: json['brand']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      weight: _d(json['weight']),
      dimensions: Dimensions.fromJson(
          (json['dimensions'] as Map?)?.cast<String, dynamic>() ?? {}),
      warrantyInformation: json['warrantyInformation']?.toString() ?? '',
      shippingInformation: json['shippingInformation']?.toString() ?? '',
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      reviews: (json['reviews'] as List?)
              ?.map((e) => Review.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          [],
      returnPolicy: json['returnPolicy']?.toString() ?? '',
      minimumOrderQuantity: _i(json['minimumOrderQuantity'], 1),
      meta: Meta.fromJson((json['meta'] as Map?)?.cast<String, dynamic>() ?? {}),
      thumbnail: json['thumbnail']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    String? brand,
    String? availabilityStatus,
    Meta? meta,
    String? thumbnail,
    List<String>? images,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      tags: tags,
      brand: brand ?? this.brand,
      sku: sku,
      weight: weight,
      dimensions: dimensions,
      warrantyInformation: warrantyInformation,
      shippingInformation: shippingInformation,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      reviews: reviews,
      returnPolicy: returnPolicy,
      minimumOrderQuantity: minimumOrderQuantity,
      meta: meta ?? this.meta,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
    );
  }

  /// Menerapkan data form (Update) ke produk ini tanpa mengubah field lain
  /// seperti ulasan, tag, SKU, dll.
  Product applyForm(Map<String, dynamic> data) {
    final newStock =
        data.containsKey('stock') ? _i(data['stock'], stock) : stock;
    return copyWith(
      title: data['title']?.toString(),
      description: data['description']?.toString(),
      category: data['category']?.toString(),
      price: data.containsKey('price') ? _d(data['price']) : null,
      stock: newStock,
      brand: data['brand']?.toString(),
      thumbnail: data['thumbnail']?.toString(),
      availabilityStatus: _availabilityFor(newStock),
      meta: Meta(
        createdAt: meta.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
        barcode: meta.barcode,
        qrCode: meta.qrCode,
      ),
    );
  }
}

class ProductsResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List?) ?? [];
    return ProductsResponse(
      products: list
          .map((e) => Product.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: _i(json['total'], list.length),
      skip: _i(json['skip']),
      limit: _i(json['limit']),
    );
  }
}
