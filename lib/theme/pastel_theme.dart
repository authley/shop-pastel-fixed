import 'package:flutter/material.dart';

/// Palet warna pastel + ThemeData untuk seluruh aplikasi.
class Pastel {
  static const Color background = Color(0xFFFFF8F3);
  static const Color pink = Color(0xFFFFD6E0);
  static const Color peach = Color(0xFFFFDAC1);
  static const Color mint = Color(0xFFC9F2DD);
  static const Color lavender = Color(0xFFE6D9F7);
  static const Color sky = Color(0xFFCFE8FF);
  static const Color butter = Color(0xFFFFF3BF);

  static const Color ink = Color(0xFF4A4458);
  static const Color inkSoft = Color(0xFF8D869B);
  static const Color accent = Color(0xFFE5769F);
  static const Color accentDeep = Color(0xFFC95A85);
  static const Color star = Color(0xFFF5B945);

  static const List<Color> tints = [pink, peach, mint, lavender, sky, butter];

  static Color tintFor(int i) => tints[i.abs() % tints.length];

  static Color tintForText(String s) {
    final sum = s.codeUnits.fold<int>(0, (a, b) => a + b);
    return tints[sum % tints.length];
  }

  static String prettify(String slug) {
    if (slug.isEmpty) return slug;
    return slug
        .split('-')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static String money(num v) => '\$${v.toStringAsFixed(2)}';

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: ink.withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      secondary: lavender,
      surface: Colors.white,
      onSurface: ink,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: ink,
            displayColor: ink,
          ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: pink,
      ),
    );
  }
}
