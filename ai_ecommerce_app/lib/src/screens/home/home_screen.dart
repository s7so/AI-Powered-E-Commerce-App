import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتجر الذكي'),
        actions: [
          IconButton(onPressed: () => context.go('/cart'), icon: const Icon(Icons.shopping_cart_outlined)),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') {
                await ref.read(authServiceProvider).signOut();
                if (mounted) context.go('/login');
              } else if (v == 'admin') {
                context.go('/admin');
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'admin', child: Text('لوحة المسؤول')),
              const PopupMenuItem(value: 'logout', child: Text('تسجيل الخروج')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث عن منتج...'),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = products.where((p) => p.name.toLowerCase().contains(_query) || p.category.toLowerCase().contains(_query)).toList();
                if (filtered.isEmpty) return const Center(child: Text('لا توجد منتجات'));
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.78),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final p = filtered[i];
                    return ProductCard(
                      product: p,
                      onTap: () => context.go('/product/${p.id}')
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          )
        ],
      ),
    );
  }
}