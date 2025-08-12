import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                    validator: (v) => v != null && v.contains('@') ? null : 'أدخل بريد صحيح',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true,
                    validator: (v) => (v != null && v.length >= 6) ? null : '6 أحرف على الأقل',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _loading = true);
                            try {
                              await ref.read(authServiceProvider).signInWithEmail(_emailController.text.trim(), _passwordController.text);
                              if (context.mounted) context.go('/home');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الدخول: $e')));
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                    child: _loading ? const CircularProgressIndicator() : const Text('دخول'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    onPressed: () async {
                      try {
                        await ref.read(authServiceProvider).signInWithGoogle();
                        if (mounted) context.go('/home');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل Google: $e')));
                      }
                    },
                    label: const Text('الدخول عبر Google'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('إنشاء حساب جديد'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}