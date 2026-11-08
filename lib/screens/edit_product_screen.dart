import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/pastel_theme.dart';
import '../widgets/product_form.dart';

class EditProductScreen extends StatelessWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pastel.lavender,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Pastel.ink,
        title: const Text('Edit Produk',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ProductForm(
        initial: product,
        submitLabel: 'Simpan perubahan',
        onSubmit: (data) async {
          final messenger = ScaffoldMessenger.of(context);
          final router = GoRouter.of(context);
          final provider = context.read<ProductProvider>();
          final result = await provider.updateProduct(product.id, data);
          if (result != null) {
            messenger.showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Pastel.mint,
              content: Text('Produk berhasil diperbarui',
                  style: TextStyle(color: Pastel.ink)),
            ));
            router.pop();
          } else {
            messenger.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Pastel.pink,
              content: Text(provider.actionError ?? 'Gagal memperbarui produk.',
                  style: const TextStyle(color: Pastel.ink)),
            ));
          }
        },
      ),
    );
  }
}
