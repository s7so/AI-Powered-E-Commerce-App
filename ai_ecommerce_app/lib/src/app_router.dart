import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/edit_product_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = FirebaseAuth.instance.authStateChanges();

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoggingIn = state.matchedLocation.startsWith('/login') || state.matchedLocation.startsWith('/register');
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && (isLoggingIn)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (ctx, st) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, st) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (ctx, st) => const HomeScreen()),
      GoRoute(path: '/product/:id', builder: (ctx, st) {
        final id = st.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      }),
      GoRoute(path: '/cart', builder: (ctx, st) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (ctx, st) => const CheckoutScreen()),
      GoRoute(path: '/admin', builder: (ctx, st) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/edit/:id', builder: (ctx, st) {
        final id = st.pathParameters['id'];
        return EditProductScreen(productId: id);
      }),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}