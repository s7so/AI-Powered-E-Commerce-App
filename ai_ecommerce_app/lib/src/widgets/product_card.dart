import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.6,
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${product.price.toStringAsFixed(2)} ر.س', style: Theme.of(context).textTheme.bodyMedium),
                  if (product.specialOffer)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Chip(label: const Text('عرض خاص'), color: WidgetStatePropertyAll(Colors.amber.shade200)),
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