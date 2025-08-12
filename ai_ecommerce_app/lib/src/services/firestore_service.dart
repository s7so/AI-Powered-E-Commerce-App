import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> streamProducts() {
    return _db.collection('products').orderBy('createdAt', descending: true).snapshots().map(
      (s) => s.docs.map((d) => Product.fromJson({...d.data(), 'id': d.id})).toList(),
    );
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return Product.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<List<Product>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    final results = <Product>[];
    for (final chunk in chunks) {
      final snap = await _db.collection('products').where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(snap.docs.map((d) => Product.fromJson({...d.data(), 'id': d.id})));
    }
    return results;
  }

  Stream<List<CartItem>> streamCart(String uid) {
    return _db.collection('users').doc(uid).collection('cart').snapshots().map(
      (s) => s.docs.map((d) => CartItem.fromJson(d.data())).toList(),
    );
  }

  Future<void> addToCart(String uid, CartItem item) async {
    await _db.collection('users').doc(uid).collection('cart').doc(item.productId).set(item.toJson());
  }

  Future<void> removeFromCart(String uid, String productId) async {
    await _db.collection('users').doc(uid).collection('cart').doc(productId).delete();
  }

  Future<void> updateCartQuantity(String uid, String productId, int quantity) async {
    await _db.collection('users').doc(uid).collection('cart').doc(productId).update({'quantity': quantity});
  }

  Future<void> upsertProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toJson());
  }

  Future<String> createProduct(Product product) async {
    final ref = await _db.collection('products').add(product.toJson());
    await ref.update({'id': ref.id});
    return ref.id;
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }
}