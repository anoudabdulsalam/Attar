import 'package:flutter/material.dart';

class InventoryShopOwnerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> plants;
  final VoidCallback onInventoryChanged;

  const InventoryShopOwnerScreen({
    super.key,
    required this.plants,
    required this.onInventoryChanged,
  });

  @override
  State<InventoryShopOwnerScreen> createState() => _InventoryShopOwnerScreenState();
}

class _InventoryShopOwnerScreenState extends State<InventoryShopOwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopAppBar(),
        Expanded(
          child: widget.plants.isEmpty
              ? const Center(
                  child: Text(
                    'لا يوجد أعشاب في المخزون',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90, top: 10),
                  itemCount: widget.plants.length,
                  itemBuilder: (context, index) {
                    final plant = widget.plants[index];
                    return _buildInventoryCard(plant, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> plant, int index) {
    // Add default mock properties if not exist
    if (!plant.containsKey('quantity')) plant['quantity'] = 10;
    if (!plant.containsKey('onSale')) plant['onSale'] = false;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8EB69B), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: plant['imageUrl'].toString().startsWith('assets') 
                ? Image.asset(
                    plant['imageUrl'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.eco, size: 40),
                  )
                : Image.network(
                    plant['imageUrl'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.eco, size: 40),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'عشبة ${plant['name']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF163832),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF8EB69B)),
                          onPressed: () => _showEditDialog(plant, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.plants.removeAt(index);
                            });
                            widget.onInventoryChanged();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم حذف العشبة بنجاح')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'السعر: ${plant['price']}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
                Text(
                  'الكمية المتوفرة: ${plant['quantity']}',
                  style: const TextStyle(
                    color: Color(0xFF163832),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text('عرض خاص:', style: TextStyle(color: Color(0xFF163832))),
                    Switch(
                      value: plant['onSale'],
                      activeThumbColor: const Color(0xFF235347),
                      onChanged: (val) {
                        setState(() {
                          plant['onSale'] = val;
                        });
                        widget.onInventoryChanged();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> plant, int index) {
    final nameCtrl = TextEditingController(text: plant['name']);
    final priceCtrl = TextEditingController(text: plant['price'].toString().replaceAll(RegExp(r'[^0-9.]'), ''));
    final benefitsCtrl = TextEditingController(text: plant['benefits']);
    final quantityCtrl = TextEditingController(text: plant['quantity'].toString());
    final salePriceCtrl = TextEditingController(text: (plant['salePrice']?.toString() ?? '').replaceAll(RegExp(r'[^0-9.]'), ''));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFDAF1DE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'تعديل المنتج',
            style: TextStyle(color: Color(0xFF163832), fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('الاسم', nameCtrl),
                const SizedBox(height: 10),
                _buildTextField('السعر الأساسي (₪)', priceCtrl, isNumber: true),
                const SizedBox(height: 10),
                _buildTextField('سعر العرض (₪)', salePriceCtrl, isNumber: true),
                const SizedBox(height: 10),
                _buildTextField('الفوائد', benefitsCtrl),
                const SizedBox(height: 10),
                _buildTextField('الكمية', quantityCtrl, isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF163832)),
              onPressed: () {
                setState(() {
                  plant['name'] = nameCtrl.text;
                  plant['price'] = '${priceCtrl.text} ₪';
                  if (salePriceCtrl.text.isNotEmpty) {
                    plant['salePrice'] = '${salePriceCtrl.text} ₪';
                  } else {
                    plant['salePrice'] = null;
                  }
                  plant['benefits'] = benefitsCtrl.text;
                  plant['quantity'] = int.tryParse(quantityCtrl.text) ?? 0;
                });
                widget.onInventoryChanged();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث بيانات العشبة بنجاح')),
                );
              },
              child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDAF1DE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          const Text(
            'المخزون',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF163832),
            ),
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFF163832), size: 30),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
