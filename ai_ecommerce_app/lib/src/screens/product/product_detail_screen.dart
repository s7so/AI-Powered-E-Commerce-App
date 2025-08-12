import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/recommendation_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج')),
      body: productsAsync.when(
        data: (products) {
          final product = products.firstWhere((p) => p.id == productId, orElse: () => products.first);
          return _ProductDetailView(product: product);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}

class _ProductDetailView extends ConsumerWidget {
  final Product product;
  const _ProductDetailView({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider(product));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.8,
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${product.price.toStringAsFixed(2)} ر.س', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 20),
          Consumer(builder: (ctx, ref, _) {
            final state = ref.watch(cartControllerProvider);
            final loading = state.isLoading;
            return FilledButton.icon(
              onPressed: loading ? null : () async {
                await ref.read(cartControllerProvider.notifier).addToCart(product);
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('تمت الإضافة إلى السلة')));
              },
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: loading ? const Text('...') : const Text('إضافة إلى السلة'),
            );
          }),
          const SizedBox(height: 24),
          Text('اقتراحات مشابهة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          recsAsync.when(
            data: (recs) {
              if (recs.isEmpty) {
                return const Text('لا توجد اقتراحات حالياً');
              }
              return Column(
                children: recs.map((p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(width: 64, child: Image.network(p.imageUrl, fit: BoxFit.cover)),
                  title: Text(p.name),
                  subtitle: Text('${p.price.toStringAsFixed(2)} ر.س'),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('خطأ: $e'),
          )
        ],
      ),
    );
  }
}