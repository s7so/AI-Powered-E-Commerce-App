import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المسؤول'),
        actions: [
          IconButton(
            tooltip: 'Seed',
            onPressed: () async {
              try {
                final created = await ref.read(firestoreServiceProvider).seedSampleProducts();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(created == 0 ? 'البيانات موجودة مسبقاً' : 'تمت إضافة $created منتجات')),
                );
              } catch (e) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
              }
            },
            icon: const Icon(Icons.auto_awesome_mosaic_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/edit/new'),
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        data: (products) => ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final p = products[i];
            return ListTile(
              leading: SizedBox(width: 56, child: Image.network(p.imageUrl, fit: BoxFit.cover)),
              title: Text(p.name),
              subtitle: Text('${p.price.toStringAsFixed(2)} ر.س - ${p.category}'),
              trailing: IconButton(onPressed: () => context.go('/admin/edit/${p.id}'), icon: const Icon(Icons.edit_outlined)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}