import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/pastel_theme.dart';
import '../theme/product_card.dart';
import '../widgets/product_actions.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.fetchProducts(limit: 0); // limit=0 -> semua produk (194)
      p.fetchCategories();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // update ikon clear
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _runSearch(value);
    });
  }

  void _runSearch(String value) {
    final p = context.read<ProductProvider>();
    final q = value.trim();
    setState(() => _selectedCategory = '');
    if (q.isEmpty) {
      p.fetchProducts(limit: 0);
    } else {
      p.searchProducts(q);
    }
  }

  void _selectCategory(String slug) {
    final p = context.read<ProductProvider>();
    _debounce?.cancel();
    _searchCtrl.clear();
    FocusScope.of(context).unfocus();
    setState(() => _selectedCategory = slug);
    if (slug.isEmpty) {
      p.fetchProducts(limit: 0);
    } else {
      p.filterByCategory(slug);
    }
  }

  Future<void> _reload() {
    final p = context.read<ProductProvider>();
    final q = _searchCtrl.text.trim();
    if (q.isNotEmpty) return p.searchProducts(q);
    if (_selectedCategory.isNotEmpty) return p.filterByCategory(_selectedCategory);
    return p.fetchProducts(limit: 0);
  }

  // ---------- Menu aksi produk (lihat / edit / hapus) ----------
  void _showActions(Product product) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Pastel.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Pastel.ink,
                  ),
                ),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.visibility_rounded, color: Pastel.accent),
              title: const Text('Lihat detail',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push('/detail/${product.id}', extra: product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Pastel.accent),
              title: const Text('Edit produk',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push('/edit/${product.id}', extra: product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Pastel.accentDeep),
              title: const Text('Hapus produk',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Pastel.accentDeep)),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                deleteProductWithConfirm(context, product);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Pastel.pink,
        foregroundColor: Pastel.ink,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah',
            style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => context.push('/add'),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          _buildCategoryChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ---------- Header + search ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Pastel.pink, Pastel.peach, Pastel.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Halo! 👋',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Pastel.inkSoft,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Temukan produk\nfavoritmu',
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Pastel.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_rounded,
                    color: Pastel.accent),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: Pastel.softShadow,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                _runSearch(v);
              },
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Pastel.ink),
              decoration: InputDecoration(
                hintText: 'Cari produk, mis. phone, mascara…',
                hintStyle: const TextStyle(
                    color: Pastel.inkSoft, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Pastel.accent),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Pastel.inkSoft),
                        onPressed: () {
                          _searchCtrl.clear();
                          _debounce?.cancel();
                          _runSearch('');
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Chip kategori ----------
  Widget _buildCategoryChips() {
    final categories = context.watch<ProductProvider>().categoryList;
    final items = ['', ...categories];
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final slug = items[i];
          final selected = slug == _selectedCategory;
          final tint = slug.isEmpty ? Pastel.pink : Pastel.tintForText(slug);
          return GestureDetector(
            onTap: () => _selectCategory(slug),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? tint : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Pastel.accent : tint,
                  width: 1.5,
                ),
              ),
              child: Text(
                slug.isEmpty ? 'Semua' : Pastel.prettify(slug),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Pastel.ink : Pastel.inkSoft,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- Isi: grid / loading / error / kosong ----------
  Widget _buildBody() {
    final p = context.watch<ProductProvider>();

    if (p.loading && p.products.isEmpty) {
      return const _SkeletonGrid();
    }
    if (p.error != null && p.products.isEmpty) {
      return _MessageState(
        icon: Icons.wifi_off_rounded,
        title: 'Gagal memuat produk',
        subtitle: 'Periksa koneksi internet lalu coba lagi.',
        actionLabel: 'Coba lagi',
        onAction: _reload,
      );
    }
    if (p.products.isEmpty) {
      return const _MessageState(
        icon: Icons.search_off_rounded,
        title: 'Produk tidak ditemukan',
        subtitle: 'Coba kata kunci atau kategori lain.',
      );
    }

    final query = _searchCtrl.text.trim();
    final label = query.isNotEmpty
        ? 'Hasil untuk "$query"'
        : _selectedCategory.isNotEmpty
            ? Pastel.prettify(_selectedCategory)
            : 'Semua produk';

    return Stack(
      children: [
        RefreshIndicator(
          color: Pastel.accent,
          backgroundColor: Colors.white,
          onRefresh: _reload,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Pastel.ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Pastel.mint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${p.products.length} produk',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Pastel.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.64,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final product = p.products[i];
                      return ProductCard(
                        product: product,
                        onMenu: () => _showActions(product),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          context.push('/detail/${product.id}',
                              extra: product);
                        },
                      );
                    },
                    childCount: p.products.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (p.loading)
          const Positioned(
            top: 0,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: LinearProgressIndicator(minHeight: 4),
            ),
          ),
      ],
    );
  }
}

/// Placeholder pastel saat data pertama kali dimuat.
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.64,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: Pastel.tintFor(i).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

/// Tampilan untuk state error / hasil kosong.
class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Pastel.lavender,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: Pastel.accentDeep),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: Pastel.ink),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Pastel.inkSoft, height: 1.4),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Pastel.pink,
                  foregroundColor: Pastel.ink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: onAction,
                child: Text(actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
