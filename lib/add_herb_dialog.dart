import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/herb_service.dart';
import 'services/cloudinary_service.dart';

class AddHerbDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddHerbDialog({super.key, required this.onAdd});

  @override
  State<AddHerbDialog> createState() => _AddHerbDialogState();
}

class _AddHerbDialogState extends State<AddHerbDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _usesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedCategory = 'أعشاب طبية';
  final List<String> _categories = ['أعشاب طبية', 'أعشاب عطرية', 'أعشاب للطهي'];

  XFile? _pickedImage;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  String _mapCategoryToEnglish(String category) {
    switch (category) {
      case 'أعشاب طبية':
        return 'Medicinal Herbs';
      case 'أعشاب عطرية':
        return 'Aromatic Herbs';
      case 'أعشاب للطهي':
        return 'Spice Herbs';
      default:
        return 'Medicinal Herbs';
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة الاسم والسعر على الأقل')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      String uploadedImageUrl = '';

      if (_pickedImage != null) {
        uploadedImageUrl =
            await CloudinaryService.uploadImage(_pickedImage!) ?? '';
      }

      final herb = await HerbService.addHerb(
        name: _nameController.text.trim(),
        benefits: _benefitsController.text.trim(),
        usageMethod: _usesController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        category: _mapCategoryToEnglish(_selectedCategory),
        imageUrl: uploadedImageUrl,
        storeOwnerId: '6a01a9db8d5e7e2493634ff',
        storeName: 'Attar Store',
      );

      widget.onAdd({
        'id': herb['_id'],
        'imageUrl': uploadedImageUrl.isNotEmpty
            ? uploadedImageUrl
            : 'assets/images/plant_placeholder.png',
        'name': herb['name'] ?? '',
        'benefits': herb['benefits'] ?? '',
        'howToUse': herb['usageMethod'] ?? '',
        'price': '${(herb['price'] ?? 0).toString()} ₪',
        'category': _selectedCategory,
        'isFavorite': false,
        'rating': 5,
        'quantity': herb['quantity'] ?? 1,
      });

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة العشبة مع الصورة بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشلت الإضافة: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _benefitsController.dispose();
    _usesController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFDAF1DE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      title: const Text(
        'إضافة عشبة جديدة',
        style: TextStyle(
          color: Color(0xFF163832),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF8EB69B)),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: kIsWeb
                              ? Image.network(
                                  _pickedImage!.path,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  _pickedImage!.path,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Color(0xFF163832),
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Color(0xFF163832),
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'إضافة صورة',
                              style: TextStyle(color: Color(0xFF163832)),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('اسم العشبة', _nameController),
              const SizedBox(height: 10),
              _buildTextField('الفوائد', _benefitsController),
              const SizedBox(height: 10),
              _buildTextField('طريقة الاستخدام', _usesController),
              const SizedBox(height: 10),
              _buildTextField('السعر (₪)', _priceController, isNumber: true),
              const SizedBox(height: 10),
              _buildTextField(
                'الكمية الأولية',
                _quantityController,
                isNumber: true,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      cat,
                      style: const TextStyle(color: Color(0xFF163832)),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            'إلغاء',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF163832),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'إضافة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8EB69B)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}