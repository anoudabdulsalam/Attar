import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ex;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import 'services/herb_service.dart';
import 'services/order_service.dart';

class InventoryShopOwnerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> plants;
  final VoidCallback onInventoryChanged;

  const InventoryShopOwnerScreen({
    super.key,
    required this.plants,
    required this.onInventoryChanged,
  });

  @override
  State<InventoryShopOwnerScreen> createState() =>
      _InventoryShopOwnerScreenState();
}

class _InventoryShopOwnerScreenState extends State<InventoryShopOwnerScreen> {
  bool _isDownloadingExcel = false;

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Future<void> _downloadInventoryExcel() async {
    try {
      setState(() {
        _isDownloadingExcel = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final storeOwnerId = prefs.getString('userId') ?? '';

      final orders = await OrderService.getAllOrdersByStoreOwnerForReport(
        storeOwnerId,
      );
      final excel = ex.Excel.createExcel();
      final sheet = excel['Inventory Report'];

      sheet.appendRow([
        ex.TextCellValue('اسم العشبة'),
        ex.TextCellValue('الكمية المتبقية'),
        ex.TextCellValue('الكمية المباعة'),
        ex.TextCellValue('أسماء المشترين'),
        ex.TextCellValue('نوع الحساب'),
        ex.TextCellValue('تواريخ البيع'),
        ex.TextCellValue('إجمالي المبيعات'),
      ]);

      for (final plant in widget.plants) {
        final herbId = plant['id']?.toString() ?? '';
        int soldQuantity = 0;
        double totalSales = 0;

        final buyers = <String>[];
        final roles = <String>[];
        final dates = <String>[];

        for (final order in orders) {
          final items = (order['items'] ?? []) as List;

          for (final item in items) {
            if (item['herbId']?.toString() == herbId) {
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;

              soldQuantity += quantity;
              totalSales += price * quantity;

              buyers.add(order['buyerName']?.toString() ?? 'مستخدم');

              final role = order['buyerRole']?.toString() ?? '';
              roles.add(role == 'herbal_expert' ? 'خبير' : 'زبون');

              dates.add((order['createdAt'] ?? '').toString().split('T').first);
            }
          }
        }

        sheet.appendRow([
          ex.TextCellValue(plant['name']?.toString() ?? ''),
          ex.IntCellValue((plant['quantity'] as num?)?.toInt() ?? 0),
          ex.IntCellValue(soldQuantity),
          ex.TextCellValue(buyers.join('، ')),
          ex.TextCellValue(roles.join('، ')),
          ex.TextCellValue(dates.join('، ')),
          ex.DoubleCellValue(totalSales),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) return;

      final blob = html.Blob([
        bytes,
      ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..setAttribute('download', 'inventory_report.xlsx')
        ..click();

      html.Url.revokeObjectUrl(url);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تنزيل ملف الإكسل بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تنزيل ملف الإكسل: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingExcel = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 110,
                        top: 10,
                      ),
                      itemCount: widget.plants.length,
                      itemBuilder: (context, index) {
                        final plant = widget.plants[index];
                        return _buildInventoryCard(plant, index);
                      },
                    ),
            ),
          ],
        ),

        Positioned(
          bottom: 90,
          left: 25,
          child: FloatingActionButton.extended(
            backgroundColor: const Color(0xFFDAF1DE),
            onPressed: _isDownloadingExcel ? null : _downloadInventoryExcel,
            icon: _isDownloadingExcel
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.table_chart,
                    color: Color(0xFF163832),
                    size: 30,
                  ),
            label: const Text(
              'Excel',
              style: TextStyle(
                color: Color(0xFF163832),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> plant, int index) {
    if (!plant.containsKey('quantity')) plant['quantity'] = 10;
    if (!plant.containsKey('onSale')) plant['onSale'] = false;

    final imageUrl = plant['imageUrl']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8EB69B), width: 1.5),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imageUrl.isEmpty
                ? const Icon(Icons.eco, size: 40)
                : (_isNetworkImage(imageUrl)
                      ? Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.eco, size: 40),
                        )
                      : Image.asset(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.eco, size: 40),
                        )),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        'عشبة ${plant['name']}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF163832),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF8EB69B)),
                      onPressed: () => _showEditDialog(plant, index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePlant(plant, index),
                    ),
                  ],
                ),
                Text(
                  plant['onSale'] == true && plant['salePrice'] != null
                      ? 'السعر: ${plant['price']} | سعر العرض: ${plant['salePrice']}'
                      : 'السعر: ${plant['price']}',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
                Text(
                  'الكمية المتوفرة: ${plant['quantity']}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF163832),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Text(
                      'عرض خاص:',
                      style: TextStyle(color: Color(0xFF163832)),
                    ),
                    Switch(
                      value: plant['onSale'],
                      activeThumbColor: const Color(0xFF235347),
                      onChanged: (val) async {
                        try {
                          await HerbService.updateHerb(
                            herbId: plant['id'],
                            onSale: val,
                            salePrice: val
                                ? double.tryParse(
                                    (plant['salePrice'] ?? '')
                                        .toString()
                                        .replaceAll(RegExp(r'[^0-9.]'), ''),
                                  )
                                : null,
                          );

                          setState(() {
                            plant['onSale'] = val;
                            if (!val) {
                              plant['salePrice'] = null;
                            }
                          });

                          widget.onInventoryChanged();

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تحديث حالة العرض الخاص'),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فشل تحديث العرض الخاص: $e'),
                            ),
                          );
                        }
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

  Future<void> _deletePlant(Map<String, dynamic> plant, int index) async {
    try {
      await HerbService.deleteHerb(plant['id']);

      setState(() {
        widget.plants.removeAt(index);
      });

      widget.onInventoryChanged();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف العشبة بنجاح')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل حذف العشبة: $e')));
    }
  }

  void _showEditDialog(Map<String, dynamic> plant, int index) {
    final nameCtrl = TextEditingController(text: plant['name']);
    final priceCtrl = TextEditingController(
      text: plant['price'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    final benefitsCtrl = TextEditingController(text: plant['benefits']);
    final quantityCtrl = TextEditingController(
      text: plant['quantity'].toString(),
    );
    final salePriceCtrl = TextEditingController(
      text: (plant['salePrice']?.toString() ?? '').replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFDAF1DE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تعديل المنتج',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFF163832),
              fontWeight: FontWeight.bold,
            ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF163832),
              ),
              onPressed: () async {
                try {
                  final updatedHerb = await HerbService.updateHerb(
                    herbId: plant['id'],
                    name: nameCtrl.text.trim(),
                    benefits: benefitsCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text.trim()) ?? 0,
                    quantity: int.tryParse(quantityCtrl.text.trim()) ?? 0,
                    onSale: salePriceCtrl.text.trim().isNotEmpty,
                    salePrice: salePriceCtrl.text.trim().isNotEmpty
                        ? double.tryParse(salePriceCtrl.text.trim())
                        : null,
                  );

                  setState(() {
                    plant['name'] = updatedHerb['name'] ?? nameCtrl.text.trim();
                    plant['price'] =
                        '${updatedHerb['price'] ?? priceCtrl.text.trim()} ₪';
                    plant['benefits'] =
                        updatedHerb['benefits'] ?? benefitsCtrl.text.trim();
                    plant['quantity'] =
                        updatedHerb['quantity'] ??
                        (int.tryParse(quantityCtrl.text.trim()) ?? 0);
                    plant['onSale'] =
                        updatedHerb['onSale'] ??
                        salePriceCtrl.text.trim().isNotEmpty;
                    plant['salePrice'] = updatedHerb['salePrice'] != null
                        ? '${updatedHerb['salePrice']} ₪'
                        : null;
                  });

                  widget.onInventoryChanged();

                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث بيانات العشبة بنجاح'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل تحديث العشبة: $e')),
                  );
                }
              },
              child: const Text(
                'حفظ التعديلات',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
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
                icon: const Icon(
                  Icons.menu,
                  color: Color(0xFF163832),
                  size: 30,
                ),
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
