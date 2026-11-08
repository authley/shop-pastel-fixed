import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/pastel_theme.dart';
import '../widgets/product_actions.dart';

class DetailProductScreen extends StatefulWidget {
  final Product product;

  const DetailProductScreen({super.key, required this.product});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // Versi terbaru produk dari provider (berubah setelah Edit); bila belum ada
  // di cache dipakai produk yang dikirim lewat navigasi.
  Product? _live;
  Product get p => _live ?? widget.product;

  void _edit() => context.push('/edit/${p.id}', extra: p);

  Future<void> _delete() async {
    final deleted = await deleteProductWithConfirm(context, p);
    if (!deleted || !mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Widget _roundAction(IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, size: 20, color: Pastel.ink),
          onPressed: onPressed,
        ),
      ),
    );
  }

  List<String> get _images {
    final list = <String>[];
    if (p.thumbnail.isNotEmpty) list.add(p.thumbnail);
    for (final i in p.images) {
      if (!list.contains(i)) list.add(i);
    }
    return list;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _live = context.watch<ProductProvider>().byId(widget.product.id);
    final tint = Pastel.tintFor(p.id);

    return Scaffold(
      backgroundColor: tint,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 380,
            backgroundColor: tint,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: Pastel.ink),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                ),
              ),
            ),
            actions: [
              _roundAction(Icons.edit_rounded, 'Edit', _edit),
              _roundAction(Icons.delete_outline_rounded, 'Hapus', _delete),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildCarousel(tint),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Pastel.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 36),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Carousel gambar ----------
  Widget _buildCarousel(Color tint) {
    final images = _images;
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -30,
          child: _circle(170, Colors.white.withValues(alpha: 0.35)),
        ),
        Positioned(
          bottom: 50,
          left: -50,
          child: _circle(150, Colors.white.withValues(alpha: 0.25)),
        ),
        Positioned.fill(
          top: kToolbarHeight + MediaQuery.of(context).padding.top,
          bottom: 40,
          child: images.isEmpty
              ? const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 48, color: Pastel.inkSoft))
              : PageView.builder(
                  controller: _pageCtrl,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final img = CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2.6, color: Colors.white),
                      ),
                      errorWidget: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          color: Pastel.inkSoft),
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: i == 0
                          ? Hero(tag: 'product-image-${p.id}', child: img)
                          : img,
                    );
                  },
                ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? Pastel.ink
                        : Pastel.ink.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  // ---------- Isi detail ----------
  Widget _buildContent() {
    final hasDiscount = p.discountPercentage >= 1;
    final oldPrice = hasDiscount ? p.price / (1 - p.discountPercentage / 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Pill(
              text: Pastel.prettify(p.category),
              color: Pastel.tintForText(p.category),
            ),
            const SizedBox(width: 8),
            if (p.availabilityStatus.isNotEmpty)
              _Pill(
                text: p.availabilityStatus,
                color: _statusColor(p.availabilityStatus),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          p.title,
          style: const TextStyle(
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Pastel.ink,
          ),
        ),
        if (p.brand.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'by ${p.brand}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Pastel.inkSoft,
            ),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Pastel.money(p.price),
              style: const TextStyle(
                fontSize: 32,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Pastel.accentDeep,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  Pastel.money(oldPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Pastel.inkSoft,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Pill(text: '-${p.discountPercentage.round()}%', color: Pastel.pink),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Pastel.butter,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: Pastel.star),
                  const SizedBox(width: 4),
                  Text(
                    p.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Pastel.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (p.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in p.tags)
                _Pill(text: '#$t', color: Pastel.tintForText(t)),
            ],
          ),
        ],
        const SizedBox(height: 26),
        const _SectionTitle('Deskripsi'),
        const SizedBox(height: 8),
        Text(
          p.description,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.6,
            color: Pastel.inkSoft,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 26),
        const _SectionTitle('Informasi produk'),
        const SizedBox(height: 12),
        _buildInfoGrid(),
        const SizedBox(height: 26),
        _SectionTitle('Ulasan (${p.reviews.length})'),
        const SizedBox(height: 12),
        if (p.reviews.isEmpty)
          const Text('Belum ada ulasan.',
              style: TextStyle(color: Pastel.inkSoft))
        else
          for (int i = 0; i < p.reviews.length; i++)
            _ReviewCard(review: p.reviews[i], tint: Pastel.tintFor(i + 2)),
      ],
    );
  }

  Color _statusColor(String s) {
    final l = s.toLowerCase();
    if (l.contains('low')) return Pastel.butter;
    if (l.contains('out')) return Pastel.pink;
    return Pastel.mint;
  }

  Widget _buildInfoGrid() {
    final tiles = <_InfoTile>[
      _InfoTile(Icons.inventory_2_rounded, 'Stok', '${p.stock} unit', Pastel.mint),
      if (p.warrantyInformation.isNotEmpty)
        _InfoTile(Icons.verified_user_rounded, 'Garansi',
            p.warrantyInformation, Pastel.lavender),
      if (p.shippingInformation.isNotEmpty)
        _InfoTile(Icons.local_shipping_rounded, 'Pengiriman',
            p.shippingInformation, Pastel.sky),
      if (p.returnPolicy.isNotEmpty)
        _InfoTile(Icons.assignment_return_rounded, 'Pengembalian',
            p.returnPolicy, Pastel.peach),
      _InfoTile(Icons.shopping_basket_rounded, 'Min. order',
          '${p.minimumOrderQuantity} pcs', Pastel.pink),
      if (p.sku.isNotEmpty)
        _InfoTile(Icons.qr_code_2_rounded, 'SKU', p.sku, Pastel.butter),
    ];

    final rows = <Widget>[];
    for (int i = 0; i < tiles.length; i += 2) {
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: tiles[i]),
            const SizedBox(width: 12),
            Expanded(
                child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox()),
          ],
        ),
      ));
      if (i + 2 < tiles.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}

// ================= Widget kecil =================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: Pastel.ink),
      );
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Pastel.ink),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoTile(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: Pastel.accentDeep),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Pastel.inkSoft)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Pastel.ink)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  final dynamic review; // Review dari product_model.dart
  final Color tint;
  const _ReviewCard({required this.review, required this.tint});

  @override
  Widget build(BuildContext context) {
    final String name = (review.reviewerName ?? '').toString();
    final String comment = (review.comment ?? '').toString();
    final int stars = (review.rating as num).round().clamp(0, 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Pastel.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: tint,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: Pastel.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Pastel.ink)),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: Pastel.star,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(comment,
                    style: const TextStyle(
                        height: 1.4,
                        color: Pastel.inkSoft,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
