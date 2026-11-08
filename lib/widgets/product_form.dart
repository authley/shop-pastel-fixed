import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/pastel_theme.dart';

class ProductForm extends StatefulWidget {
  final Product? initial;
  final String submitLabel;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const ProductForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _brandController;
  late final TextEditingController _stockController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _descriptionController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final product = widget.initial;
    _titleController = TextEditingController(text: product?.title ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
    _stockController = TextEditingController(
      text: product == null ? '' : product.stock.toString(),
    );
    _thumbnailController = TextEditingController(
      text: product?.thumbnail ?? '',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _stockController.dispose();
    _thumbnailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double? _parsePrice(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit({
        'title': _titleController.text.trim(),
        'price': _parsePrice(_priceController.text) ?? 0.0,
        'category': _categoryController.text.trim(),
        'brand': _brandController.text.trim(),
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        'thumbnail': _thumbnailController.text.trim(),
        'description': _descriptionController.text.trim(),
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  String? _validPrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    final price = _parsePrice(value);
    if (price == null || price < 0) return 'Masukkan harga yang valid';
    return null;
  }

  String? _validStock(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // opsional, dianggap 0
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Masukkan bilangan bulat ≥ 0';
    return null;
  }

  String? _validUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // opsional
    final uri = Uri.tryParse(v);
    final ok = uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
    return ok ? null : 'URL harus diawali http:// atau https://';
  }

  Future<void> _pickCategory(List<String> categories) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Pastel.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.6,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final slug = categories[i];
              final isCurrent = slug == _categoryController.text;
              return ListTile(
                title: Text(
                  Pastel.prettify(slug),
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: Pastel.ink,
                  ),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.check_rounded, color: Pastel.accent)
                    : null,
                onTap: () => Navigator.of(ctx).pop(slug),
              );
            },
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _categoryController.text = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categoryList;
    final hasCategories = categories.isNotEmpty;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_titleController, 'Nama produk', validator: _required),
          const SizedBox(height: 14),
          _field(
            _priceController,
            'Harga',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validPrice,
          ),
          const SizedBox(height: 14),
          _field(
            _categoryController,
            'Kategori',
            validator: _required,
            // Bila daftar kategori dari server tersedia, pilih lewat sheet;
            // bila tidak, tetap bisa diketik manual.
            readOnly: hasCategories,
            onTap: hasCategories ? () => _pickCategory(categories) : null,
            suffixIcon: hasCategories
                ? const Icon(Icons.expand_more_rounded, color: Pastel.inkSoft)
                : null,
          ),
          const SizedBox(height: 14),
          _field(_brandController, 'Merek'),
          const SizedBox(height: 14),
          _field(
            _stockController,
            'Stok',
            keyboardType: TextInputType.number,
            validator: _validStock,
          ),
          const SizedBox(height: 14),
          _field(
            _thumbnailController,
            'URL gambar',
            keyboardType: TextInputType.url,
            validator: _validUrl,
          ),
          const SizedBox(height: 14),
          _field(_descriptionController, 'Deskripsi', maxLines: 4),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(widget.submitLabel),
            style: FilledButton.styleFrom(
              backgroundColor: Pastel.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Pastel.lavender),
        ),
      ),
    );
  }
}
