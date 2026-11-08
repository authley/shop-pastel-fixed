import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/pastel_theme.dart';

/// Memuat produk berdasarkan id (dari cache provider atau API) lalu
/// membangun [builder]. Dipakai bila halaman dibuka tanpa objek produk,
/// misalnya saat reload di web.
class ProductLoader extends StatefulWidget {
  final int productId;
  final Widget Function(BuildContext context, Product product) builder;

  const ProductLoader({
    super.key,
    required this.productId,
    required this.builder,
  });

  @override
  State<ProductLoader> createState() => _ProductLoaderState();
}

class _ProductLoaderState extends State<ProductLoader> {
  late final Future<Product?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ProductProvider>().loadProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final product = snapshot.data;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Pastel.lavender,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Pastel.ink,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 56, color: Pastel.accentDeep),
                    const SizedBox(height: 16),
                    const Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Pastel.ink),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Pastel.pink,
                        foregroundColor: Pastel.ink,
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text('Ke beranda'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return widget.builder(context, product);
      },
    );
  }
}
