import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/order_service.dart';

class OrdersShopOwnerScreen extends StatefulWidget {
  const OrdersShopOwnerScreen({super.key});

  @override
  State<OrdersShopOwnerScreen> createState() => _OrdersShopOwnerScreenState();
}

class _OrdersShopOwnerScreenState extends State<OrdersShopOwnerScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _orders = [];

  DateTime? _getOrderDate(Map<String, dynamic> order) {
    if (order['createdAt'] != null) {
      try {
        return DateTime.parse(order['createdAt']).toLocal();
      } catch (_) {}
    }
    if (order['_id'] != null && order['_id'].toString().length == 24) {
      try {
        final hexString = order['_id'].toString().substring(0, 8);
        final timestamp = int.parse(hexString, radix: 16);
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
      } catch (_) {}
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final hour = localDate.hour == 0
        ? 12
        : (localDate.hour > 12 ? localDate.hour - 12 : localDate.hour);
    final amPm = localDate.hour >= 12 ? 'م' : 'ص';
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '${localDate.year}/${localDate.month}/${localDate.day} $hour:$minute $amPm';
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final storeOwnerId = prefs.getString('userId') ?? '';

      final orders = await OrderService.getOrdersByStoreOwner(storeOwnerId);
      final activeOrders = orders.where((order) {
        final status = (order['status'] ?? '').toString();
        return status != 'تم الاستلام';
      }).toList();
      if (!mounted) return;

      setState(() {
        _orders = activeOrders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    try {
      await OrderService.updateOrderStatus(orderId: orderId, status: status);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث حالة الطلب إلى $status')),
      );

      await _loadOrders();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحديث الطلب: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopAppBar(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'حدث خطأ أثناء تحميل الطلبات\n$_error',
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد طلبات حالياً',
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 90,
          top: 10,
        ),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = (order['items'] ?? []) as List;
    final status = order['status'] ?? 'قيد التحضير';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8EB69B), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            'طلب رقم: ${order['_id'] ?? ''}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF163832),
            ),
          ),
          if (_getOrderDate(order) != null) ...[
            const SizedBox(height: 6),
            Text(
              'التاريخ: ${_formatDate(_getOrderDate(order)!)}',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'اسم المستخدم: ${order['buyerName'] ?? 'مستخدم'}',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
          Text(
            'نوع الحساب: ${_roleText(order['buyerRole'] ?? '')}',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const Text(
            'الأعشاب المطلوبة:',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFF163832),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),

          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDAF1DE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Icon(Icons.eco, color: Color(0xFF163832)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item['herbName'] ?? item['name'] ?? ''}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF163832),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'الكمية: ${item['quantity'] ?? 1}',
                    style: const TextStyle(color: Color(0xFF235347)),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          Text(
            'الإجمالي: ${(order['totalPrice'] ?? 0).toString()} ₪',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF163832),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),

          if (status == 'تم الاستلام')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDAF1DE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'الحالة: تم الاستلام',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: const Color(0xFFDAF1DE),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'قيد التحضير',
                  child: Text('قيد التحضير'),
                ),
                DropdownMenuItem(
                  value: 'جاهز ومع شركة التوصيل',
                  child: Text('جاهز ومع شركة التوصيل'),
                ),
              ],
              onChanged: (val) {
                if (val != null && val != status) {
                  _updateStatus(order['_id'], val);
                }
              },
            ),
        ],
      ),
    );
  }

  String _roleText(String role) {
    if (role == 'herbal_expert') return 'خبير';
    if (role == 'store_owner') return 'صاحب متجر';
    return 'زبون';
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
            'طلبات الزبائن',
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
