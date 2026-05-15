import 'package:flutter/material.dart';
import 'card_customer_screen.dart';

class CartExpertScreen extends StatelessWidget {
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

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('CartScreen'),
      children: [
        _buildHeader(context, 'السلة'),
        Expanded(
          child: cartItems.isEmpty
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
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItem(item, context);
                  },
                ),
        ),
        if (cartItems.isNotEmpty) _buildCheckoutBottomBar(context),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, BuildContext context) {
    String priceStr = item['price'].toString().replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
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
                      () => onUpdateQuantity(item['name'], -1),
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
                      () => onUpdateQuantity(item['name'], 1),
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
                onPressed: () => onRemove(item['name']),
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
                '${totalPrice.toStringAsFixed(1)} ₪',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CardCustomerScreen(totalPrice: totalPrice),
                ),
              );
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