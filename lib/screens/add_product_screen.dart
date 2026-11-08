import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../theme/pastel_theme.dart';
import '../widgets/product_form.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pastel.pink,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Pastel.ink,
        title: const Text('Tambah Produk',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ProductForm(
        submitLabel: 'Simpan produk',
        onSubmit: (data) async {
          final messenger = ScaffoldMessenger.of(context);
          final router = GoRouter.of(context);
          final provider = context.read<ProductProvider>();
          final result = await provider.addProduct(data);
          if (result != null) {
            messenger.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Pastel.mint,
              content: Text('"${result.title}" berhasil ditambahkan',
                  style: const TextStyle(color: Pastel.ink)),
            ));
            router.pop();
          } else {
            messenger.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Pastel.pink,
              content: Text(
                  provider.actionError ?? 'Gagal menambah produk. Coba lagi.',
                  style: const TextStyle(color: Pastel.ink)),
            ));
          }
        },
      ),
    );
  }
}
