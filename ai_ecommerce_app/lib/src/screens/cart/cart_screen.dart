import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات')),
      body: cartAsync.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('السلة فارغة'));
          final total = items.fold<double>(0, (acc, i) => acc + i.price * i.quantity);
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return ListTile(
                      leading: SizedBox(width: 56, child: Image.network(item.imageUrl, fit: BoxFit.cover)),
                      title: Text(item.name),
                      subtitle: Text('${item.price.toStringAsFixed(2)} ر.س'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () => ref.read(cartControllerProvider.notifier).updateQuantity(item.productId, item.quantity - 1), icon: const Icon(Icons.remove_circle_outline)),
                          Text('${item.quantity}'),
                          IconButton(onPressed: () => ref.read(cartControllerProvider.notifier).updateQuantity(item.productId, item.quantity + 1), icon: const Icon(Icons.add_circle_outline)),
                          IconButton(onPressed: () => ref.read(cartControllerProvider.notifier).removeFromCart(item.productId), icon: const Icon(Icons.delete_outline)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الإجمالي: ${total.toStringAsFixed(2)} ر.س', style: Theme.of(context).textTheme.titleLarge),
                    FilledButton(
                      onPressed: () => context.go('/checkout'),
                      child: const Text('إتمام الشراء'),
                    ),
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}