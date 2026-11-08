import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/pastel_theme.dart';

/// Dialog konfirmasi lalu menghapus produk lewat backend.
/// Mengembalikan true bila produk berhasil dihapus.
Future<bool> deleteProductWithConfirm(
  BuildContext context,
  Product product,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Hapus produk?',
        style: TextStyle(fontWeight: FontWeight.w800, color: Pastel.ink),
      ),
      content: Text(
        '"${product.title}" akan dihapus dari daftar produk.',
        style: const TextStyle(color: Pastel.inkSoft, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Batal',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: Pastel.inkSoft)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Pastel.accent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Hapus',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );

  if (confirmed != true) return false;
  if (!context.mounted) return false;

  final provider = context.read<ProductProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final ok = await provider.deleteProduct(product.id);

  messenger.showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: ok ? Pastel.mint : Pastel.pink,
    content: Text(
      ok
          ? '"${product.title}" dihapus'
          : (provider.actionError ?? 'Gagal menghapus produk.'),
      style: const TextStyle(color: Pastel.ink),
    ),
  ));
  return ok;
}
