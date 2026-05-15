import 'package:flutter/material.dart';

class OrdersShopOwnerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

  const OrdersShopOwnerScreen({super.key, required this.orders});

  @override
  State<OrdersShopOwnerScreen> createState() => _OrdersShopOwnerScreenState();
}

class _OrdersShopOwnerScreenState extends State<OrdersShopOwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopAppBar(),
        Expanded(
          child: widget.orders.isEmpty
              ? const Center(
                  child: Text(
                    'لا يوجد طلبات حالياً',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90, top: 10),
                  itemCount: widget.orders.length,
                  itemBuilder: (context, index) {
                    final order = widget.orders[index];
                    return _buildOrderCard(order);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
            child: Image.asset(
              order['imageUrl'] ?? 'assets/images/plant_placeholder.png',
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
                Text(
                  'طلب: ${order['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF163832),
                  ),
                ),
                Text(
                  'اسم الزبون: ${order['customerName']}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
                Text(
                  'العشبة: ${order['herbName']}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
                Text(
                  'الكمية: ${order['quantity']}',
                  style: const TextStyle(
                    color: Color(0xFF163832),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: order['status'],
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFDAF1DE),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'قيد التحضير', child: Text('قيد التحضير')),
                    DropdownMenuItem(value: 'جاهز ومع شركة التوصيل', child: Text('جاهز ومع شركة التوصيل')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        order['status'] = val;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم تحديث حالة الطلب إلى $val')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
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
