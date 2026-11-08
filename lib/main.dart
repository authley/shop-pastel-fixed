import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/product_model.dart';
import 'providers/product_provider.dart';
import 'screens/add_product_screen.dart';
import 'screens/detail_product_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/list_product_screen.dart';
import 'theme/pastel_theme.dart';
import 'widgets/product_loader.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ListProductScreen(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Product) return DetailProductScreen(product: extra);
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const ListProductScreen();
        return ProductLoader(
          productId: id,
          builder: (_, product) => DetailProductScreen(product: product),
        );
      },
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Product) return EditProductScreen(product: extra);
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const ListProductScreen();
        return ProductLoader(
          productId: id,
          builder: (_, product) => EditProductScreen(product: product),
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pastel Shop',
      debugShowCheckedModeBanner: false,
      theme: Pastel.theme,
      routerConfig: _router,
    );
  }
}
