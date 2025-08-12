import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/recommendation.dart';
import '../services/functions_service.dart';
import 'product_provider.dart';

final functionsServiceProvider = Provider<FunctionsService>((ref) => FunctionsService());

final recommendationsProvider = FutureProvider.family<List<Product>, Product>((ref, product) async {
  final request = RecommendationRequest(productId: product.id, name: product.name, category: product.category);
  try {
    final ids = await ref.read(functionsServiceProvider).getRecommendations(request);
    if (ids.isEmpty) return [];
    final products = await ref.read(firestoreServiceProvider).getProductsByIds(ids);
    return products.where((p) => p.id != product.id).toList();
  } catch (_) {
    return [];
  }
});