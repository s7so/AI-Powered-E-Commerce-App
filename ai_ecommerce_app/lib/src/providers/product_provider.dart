import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.streamProducts();
});

final cartStreamProvider = StreamProvider<List<CartItem>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  final service = ref.watch(firestoreServiceProvider);
  return service.streamCart(uid);
});

class CartController extends StateNotifier<AsyncValue<void>> {
  CartController(this._ref) : super(const AsyncData(null));
  final Ref _ref;

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    state = const AsyncLoading();
    try {
      final uid = _ref.read(currentUserProvider)?.uid;
      if (uid == null) throw Exception('Not authenticated');
      final item = CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );
      await _ref.read(firestoreServiceProvider).addToCart(uid, item);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeFromCart(String productId) async {
    state = const AsyncLoading();
    try {
      final uid = _ref.read(currentUserProvider)?.uid;
      if (uid == null) throw Exception('Not authenticated');
      await _ref.read(firestoreServiceProvider).removeFromCart(uid, productId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    state = const AsyncLoading();
    try {
      final uid = _ref.read(currentUserProvider)?.uid;
      if (uid == null) throw Exception('Not authenticated');
      await _ref.read(firestoreServiceProvider).updateCartQuantity(uid, productId, quantity);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, AsyncValue<void>>((ref) => CartController(ref));