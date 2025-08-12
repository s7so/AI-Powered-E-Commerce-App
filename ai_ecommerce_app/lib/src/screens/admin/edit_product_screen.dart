import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/storage_service.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final String? productId;
  const EditProductScreen({super.key, this.productId});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _specialOffer = false;
  File? _imageFile;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final products = ref.read(productsStreamProvider).maybeWhen(data: (d) => d, orElse: () => null);
    if (products != null && widget.productId != null && widget.productId != 'new') {
      final p = products.firstWhere((e) => e.id == widget.productId, orElse: () => products.first);
      _nameController.text = p.name;
      _descController.text = p.description;
      _priceController.text = p.price.toStringAsFixed(2);
      _categoryController.text = p.category;
      _imageUrlController.text = p.imageUrl;
      _specialOffer = p.specialOffer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productId == null || widget.productId == 'new' ? 'إضافة منتج' : 'تعديل منتج')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم'), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 3),
              const SizedBox(height: 12),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: 'الفئة')), 
              const SizedBox(height: 12),
              TextFormField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'رابط الصورة (اختياري إذا رفعت ملف)')),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _specialOffer,
                onChanged: (v) => setState(() => _specialOffer = v),
                title: const Text('عرض خاص'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () async {
                        // Placeholder: in real app, use image_picker.
                        // Here we keep it simple: allow entering a local file path (dev environment)
                        final path = await _promptForPath(context);
                        if (path != null) setState(() => _imageFile = File(path));
                      },
                      label: const Text('رفع صورة من ملف'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_imageFile != null) Text(_imageFile!.path.split('/').last),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _loading = true);
                  try {
                    final now = DateTime.now();
                    String imageUrl = _imageUrlController.text.trim();
                    if (_imageFile != null) {
                      final productId = widget.productId == null || widget.productId == 'new' ? now.millisecondsSinceEpoch.toString() : widget.productId!;
                      imageUrl = await StorageService().uploadProductImage(file: _imageFile!, productId: productId);
                    }
                    final product = Product(
                      id: widget.productId == null || widget.productId == 'new' ? '' : widget.productId!,
                      name: _nameController.text.trim(),
                      description: _descController.text.trim(),
                      price: double.tryParse(_priceController.text.trim()) ?? 0,
                      imageUrl: imageUrl,
                      category: _categoryController.text.trim(),
                      specialOffer: _specialOffer,
                      createdAt: now,
                    );
                    if (widget.productId == null || widget.productId == 'new') {
                      await ref.read(firestoreServiceProvider).createProduct(product);
                    } else {
                      await ref.read(firestoreServiceProvider).upsertProduct(product);
                    }
                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
                child: Text(_loading ? '...' : 'حفظ'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _promptForPath(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('أدخل مسار الملف (dev)'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: '/path/to/image.jpg')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('حسناً')),
        ],
      ),
    );
  }
}