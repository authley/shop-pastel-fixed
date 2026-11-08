import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../theme/pastel_theme.dart';

/// Kartu produk untuk grid di halaman depan.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  /// Membuka menu aksi (lihat / edit / hapus). Dipicu tombol "⋯" atau tekan lama.
  final VoidCallback? onMenu;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final tint = Pastel.tintFor(product.id);
    final subtitle = product.brand.isNotEmpty
        ? product.brand
        : Pastel.prettify(product.category);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onMenu,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: Pastel.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'product-image-${product.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            color: tint,
                            child: product.thumbnail.isEmpty
                                ? const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Pastel.inkSoft,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: product.thumbnail,
                                    fit: BoxFit.contain,
                                    placeholder: (_, _) => const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, _, _) => const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Pastel.inkSoft,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (onMenu != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: onMenu,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.more_horiz_rounded,
                                size: 18, color: Pastel.ink),
                          ),
                        ),
                      ),
                    if (product.discountPercentage >= 1)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '-${product.discountPercentage.round()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Pastel.accentDeep,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: Pastel.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Pastel.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Pastel.money(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Pastel.accentDeep,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded,
                          size: 16, color: Pastel.star),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Pastel.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
