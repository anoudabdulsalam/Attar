import 'package:flutter/material.dart';
import 'card_customer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';

class CartExpertScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(String) onRemove;
  final Function(String, int) onUpdateQuantity;
  final double totalPrice;

  const CartExpertScreen({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onUpdateQuantity,
    required this.totalPrice,
  });

  @override
  State<CartExpertScreen> createState() => _CartExpertScreenState();
}

class _CartExpertScreenState extends State<CartExpertScreen> {
  List<dynamic> _orders = [];
  bool _loadingOrders = false;

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Future<bool> _createOrder() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final buyerId = prefs.getString('userId') ?? '';

    if (buyerId.isEmpty || widget.cartItems.isEmpty) {
      return false;
    }

    final user = await UserService.getUserById(buyerId);
    final buyerName = user['fullName'] ?? user['email'] ?? 'مستخدم';

    final Map<String, List<Map<String, dynamic>>> groupedItems = {};

    for (final item in widget.cartItems) {
      final storeOwnerId = item['storeOwnerId']?.toString() ?? '';

      if (storeOwnerId.isEmpty) {
        throw Exception('في عشبة بالسلة بدون صاحب متجر');
      }

      groupedItems.putIfAbsent(storeOwnerId, () => []);
      groupedItems[storeOwnerId]!.add(item);
    }

    for (final entry in groupedItems.entries) {
      final storeOwnerId = entry.key;
      final storeItems = entry.value;
      final firstItem = storeItems.first;

      final items = storeItems.map((item) {
        final priceStr =
            item['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');

        return {
          'herbId': item['id'],
          'herbName': item['name'],
          'imageUrl': item['imageUrl'],
          'quantity': item['quantity'],
          'price': double.tryParse(priceStr) ?? 0,
        };
      }).toList();

      double storeTotal = 0.0;

      for (final item in storeItems) {
        final priceStr =
            item['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        final price = double.tryParse(priceStr) ?? 0.0;
        final quantity = item['quantity'] as int;
        storeTotal += price * quantity;
      }

      await OrderService.createOrder(
        buyerId: buyerId,
        buyerName: buyerName,
        buyerRole: 'herbal_expert',
        storeOwnerId: storeOwnerId,
        storeName: firstItem['storeName'] ?? 'متجر غير معروف',
        items: items,
        totalPrice: storeTotal,
      );
    }

    if (!mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الطلب بنجاح')),
    );

    return true;
  } catch (e) {
    if (!mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل إنشاء الطلب: $e')),
    );

    return false;
  }
}
  Future<void> _loadOrders() async {
    try {
      setState(() {
        _loadingOrders = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final buyerId = prefs.getString('userId') ?? '';

      final orders = await OrderService.getOrdersByBuyer(buyerId);

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _loadingOrders = false;
      });

      _showTrackingDialog();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingOrders = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل الطلبات: $e')),
      );
    }
  }

void _showTrackingDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: 760,
            height: 560,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  color: const Color(0xFFDAF1DE),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF163832),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'تتبع طلباتك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF163832),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: _orders.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد طلبات حالياً',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF163832),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(18),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            final items = (order['items'] ?? []) as List;
                            final status = order['status'] ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4FBF5),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF8EB69B),
                                  width: 1.3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Color(0xFF8EB69B),
                                        child: Icon(
                                          Icons.store,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'المتجر: ${order['storeName'] ?? 'متجر غير معروف'}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Color(0xFF163832),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'رقم الطلب: ${order['_id'] ?? ''}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDAF1DE),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Icon(
                                          status == 'جاهز ومع شركة التوصيل'
                                              ? Icons.local_shipping
                                              : Icons.hourglass_top,
                                          color: status ==
                                                  'جاهز ومع شركة التوصيل'
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'الحالة: $status',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: status ==
                                                      'جاهز ومع شركة التوصيل'
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'الأعشاب المطلوبة:',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Color(0xFF163832),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...items.map((item) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          const Icon(
                                            Icons.eco,
                                            color: Color(0xFF235347),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${item['herbName']}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Color(0xFF163832),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'الكمية: ${item['quantity']}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              color: Color(0xFF235347),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'الإجمالي: ${order['totalPrice'] ?? 0} ₪',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Color(0xFF163832),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (status == 'جاهز ومع شركة التوصيل') ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await OrderService.updateOrderStatus(
                                            orderId: order['_id'],
                                            status: 'تم الاستلام',
                                          );

                                          if (!mounted) return;

                                          Navigator.pop(context);
                                          _loadOrders();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF8EB69B),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'تم الاستلام',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('CartScreen'),
      children: [
        _buildHeader(context, 'السلة'),
        Expanded(
          child: widget.cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'السلة فارغة، قم بإضافة بعض الأعشاب!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    return _buildCartItem(item, context);
                  },
                ),
        ),
        _buildActionButtons(context),
        if (widget.cartItems.isNotEmpty) _buildCheckoutBottomBar(context),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: _loadingOrders ? null : _loadOrders,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDAF1DE),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
        ),
        icon: const Icon(
          Icons.local_shipping,
          color: Color(0xFF163832),
          size: 30,
        ),
        label: const Text(
          'تتبع طلبك',
          style: TextStyle(
            color: Color(0xFF163832),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    ),
  );
}
  Widget _buildCartItem(Map<String, dynamic> item, BuildContext context) {
    String priceStr =
        item['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
    double price = double.tryParse(priceStr) ?? 0.0;
    double itemTotal = price * (item['quantity'] as int);

    final imagePath = item['imageUrl']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDAF1DE),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(5),
            child: imagePath.isNotEmpty
                ? (_isNetworkImage(imagePath)
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.eco,
                          color: Color(0xFF8EB69B),
                          size: 40,
                        ),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.eco,
                          color: Color(0xFF8EB69B),
                          size: 40,
                        ),
                      ))
                : const Icon(
                    Icons.eco,
                    color: Color(0xFF8EB69B),
                    size: 40,
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF051F20),
                  ),
                ),
                Text(
                  '${item['price']}',
                  style: const TextStyle(
                    color: Color(0xFF235347),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _quantityButton(
                      Icons.remove,
                      () => widget.onUpdateQuantity(item['name'], -1),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${item['quantity']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF163832),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _quantityButton(
                      Icons.add,
                      () => widget.onUpdateQuantity(item['name'], 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 28,
                ),
                onPressed: () => widget.onRemove(item['name']),
              ),
              Text(
                'مجموع: ${itemTotal.toStringAsFixed(1)} ₪',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163832),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Color(0xFF8EB69B),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildCheckoutBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF163832).withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${widget.totalPrice.toStringAsFixed(1)} ₪',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
          onPressed: () async {
                  final created = await _createOrder();

                  if (!mounted) return;

                  if (created) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CardCustomerScreen(totalPrice: widget.totalPrice),
                      ),
                    );
                  }
                },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8EB69B),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'متابعة الدفع',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF051F20),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF051F20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
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
          Row(
            children: [
              Image.asset(
                'assets/images/finalLogo.png',
                height: 50,
                width: 70,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.eco, color: Color(0xFF163832), size: 40),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
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