import 'package:flutter/material.dart';
import 'card_customer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';
import 'widgets/order_rating_dialog.dart';
import 'services/herb_service.dart';

class CartCustomerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(String) onRemove;
  final Function(String, int) onUpdateQuantity;
  final double totalPrice;
  final Future<void> Function()? onRatingSubmitted;

  const CartCustomerScreen({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onUpdateQuantity,
    required this.totalPrice,
    this.onRatingSubmitted,
  });

  @override
  State<CartCustomerScreen> createState() => _CartCustomerScreenState();
}

class _CartCustomerScreenState extends State<CartCustomerScreen> {
  List<dynamic> _orders = [];
  bool _loadingOrders = false;

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

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

  DateTime? _getReceivedDate(Map<String, dynamic> order) {
    final value =
        order['receivedAt'] ??
        order['deliveredAt'] ??
        (order['status'] == 'تم الاستلام' ? order['updatedAt'] : null);

    if (value != null) {
      try {
        return DateTime.parse(value.toString()).toLocal();
      } catch (_) {}
    }
    return null;
  }

  Color _statusColor(String status) {
    if (status == 'تم الاستلام') {
      return Colors.green;
    }
    return Colors.orange;
  }

  IconData _statusIcon(String status) {
    if (status == 'تم الاستلام') {
      return Icons.check_circle;
    }
    if (status == 'جاهز ومع شركة التوصيل') {
      return Icons.local_shipping;
    }
    return Icons.hourglass_top;
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

  Future<void> _showRatingDialog(Map<String, dynamic> order) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) return;

    final List items = order['items'] ?? [];
    if (items.isEmpty) return;

    final Map<String, int> selectedRatings = {};

    for (final item in items) {
      final herbId = item['herbId']?.toString() ?? '';
      if (herbId.isNotEmpty) {
        selectedRatings[herbId] = 5;
      }
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFDDF3E3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'تقييم الأعشاب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF163832),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'يرجى تقييم الأعشاب التي قمت باستلامها',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF163832), fontSize: 13),
                    ),
                    const SizedBox(height: 14),

                    ...items.map((item) {
                      final herbId = item['herbId']?.toString() ?? '';
                      final herbName =
                          item['herbName']?.toString() ?? 'عشبة غير معروفة';
                      final rating = selectedRatings[herbId] ?? 5;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              herbName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF163832),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starValue = index + 1;

                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      selectedRatings[herbId] = starValue;
                                    });
                                  },
                                  icon: Icon(
                                    starValue <= rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFFFB400),
                                    size: 24,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'تخطي',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF163832),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      for (final item in items) {
                        final herbId = item['herbId']?.toString() ?? '';
                        final rating = selectedRatings[herbId];

                        if (herbId.isNotEmpty && rating != null) {
                          await HerbService.rateHerb(
                            herbId: herbId,
                            userId: userId,
                            rating: rating,
                          );
                        }
                      }

                      if (!mounted) return;

                      Navigator.pop(dialogContext);
                      await widget.onRatingSubmitted?.call();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حفظ التقييم بنجاح'),
                          backgroundColor: Color(0xFF235347),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'تأكيد التقييم',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
          final priceStr = item['price'].toString().replaceAll(
            RegExp(r'[^0-9.]'),
            '',
          );

          return {
            'herbId': item['id'],
            'herbName': item['name'],
            'imageUrl': item['imageUrl'],
            'quantity': item['quantity'],
            'price': double.tryParse(priceStr) ?? 0,
            'storeName': firstItem['storeName'] ?? 'متجر غير معروف',
          };
        }).toList();

        double storeTotal = 0.0;

        for (final item in storeItems) {
          final priceStr = item['price'].toString().replaceAll(
            RegExp(r'[^0-9.]'),
            '',
          );
          final price = double.tryParse(priceStr) ?? 0.0;
          final quantity = item['quantity'] as int;
          storeTotal += price * quantity;
        }

        await OrderService.createOrder(
          buyerId: buyerId,
          buyerName: buyerName,
          buyerRole: 'customer',
          storeOwnerId: storeOwnerId,
          storeName: firstItem['storeName'] ?? 'متجر غير معروف',
          items: items,
          totalPrice: storeTotal,
        );
      }

      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء الطلب بنجاح')));

      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إنشاء الطلب: $e')));

      return false;
    }
  }

  Future<void> _loadOrders({required bool previousOrders}) async {
    try {
      setState(() {
        _loadingOrders = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final buyerId = prefs.getString('userId') ?? '';

      final allOrders = await OrderService.getOrdersByBuyer(buyerId);

      final filteredOrders = allOrders.where((order) {
        final status = (order['status'] ?? '').toString();
        if (previousOrders) {
          return status == 'تم الاستلام';
        }
        return status != 'تم الاستلام';
      }).toList();

      if (!mounted) return;

      setState(() {
        _orders = filteredOrders;
        _loadingOrders = false;
      });

      _showTrackingDialog(previousOrders: previousOrders);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingOrders = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحميل الطلبات: $e')));
    }
  }

  void _showTrackingDialog({required bool previousOrders}) {
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
                        Expanded(
                          child: Text(
                            previousOrders ? 'الطلبات السابقة' : 'تتبع طلباتك',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                        ? Center(
                            child: Text(
                              previousOrders
                                  ? 'لا توجد طلبات سابقة'
                                  : 'لا توجد طلبات حالياً',
                              style: const TextStyle(
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
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  CrossAxisAlignment.start,
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
                                                if (_getOrderDate(order) !=
                                                    null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'تاريخ الطلب: ${_formatDate(_getOrderDate(order)!)}',
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                                if (_getReceivedDate(order) !=
                                                    null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'تاريخ الاستلام: ${_formatDate(_getReceivedDate(order)!)}',
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                                            _statusIcon(status),
                                            color: _statusColor(status),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'الحالة: $status',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: _statusColor(status),
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
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.eco,
                                                color: Color(0xFF235347),
                                                size: 22,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${item['herbName']} - ${item['price']} ₪',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF163832,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      'الكمية: ${item['quantity'] ?? 1}',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF163832,
                                                        ),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      'المتجر: ${order['storeName'] ?? item['storeName'] ?? 'متجر غير معروف'}',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF235347,
                                                        ),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
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
                                            final updatedOrder =
                                                await OrderService.updateOrderStatus(
                                                  orderId: order['_id'],
                                                  status: 'تم الاستلام',
                                                );

                                            if (!mounted) return;

                                            Navigator.pop(context);

                                            await _loadOrders(
                                              previousOrders: false,
                                            );

                                            await _showRatingDialog(
                                              updatedOrder,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF8EB69B,
                                            ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _loadingOrders
                ? null
                : () => _loadOrders(previousOrders: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF163832),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.history, color: Colors.white, size: 27),
            label: const Text(
              'الطلبات السابقة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _loadingOrders
                ? null
                : () => _loadOrders(previousOrders: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDAF1DE),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 4,
            ),
            icon: const Icon(
              Icons.local_shipping,
              color: Color(0xFF163832),
              size: 28,
            ),
            label: const Text(
              'تتبع طلبك',
              style: TextStyle(
                color: Color(0xFF163832),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, BuildContext context) {
    String priceStr = item['price'].toString().replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
    double price = double.tryParse(priceStr) ?? 0.0;
    final int quantity = (item['quantity'] as int?) ?? 1;
    final double itemTotal = price * quantity;

    final imagePath = item['imageUrl']?.toString() ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDAF1DE),
          borderRadius: BorderRadius.circular(15),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: imagePath.isNotEmpty
                      ? (_isNetworkImage(imagePath)
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.eco,
                                  color: Color(0xFF8EB69B),
                                  size: 30,
                                ),
                              )
                            : Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.eco,
                                  color: Color(0xFF8EB69B),
                                  size: 30,
                                ),
                              ))
                      : const Icon(Icons.eco, color: Color(0xFF8EB69B), size: 30),
                ),
              ),
              const SizedBox(width: 12),
              
              // Middle section (Name, Price, Quantity)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['name']?.toString() ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '₪ ${price.toStringAsFixed(price % 1 == 0 ? 0 : 1)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Quantity Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => widget.onUpdateQuantity(
                                item['id'].toString(),
                                quantity + 1,
                              ),
                              child: const CircleAvatar(
                                radius: 11,
                                backgroundColor: Color(0xFF8EB69B),
                                child: Icon(Icons.add, size: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                if (quantity > 1) {
                                  widget.onUpdateQuantity(
                                    item['id'].toString(),
                                    quantity - 1,
                                  );
                                }
                              },
                              child: const CircleAvatar(
                                radius: 11,
                                backgroundColor: Color(0xFF8EB69B),
                                child: Icon(Icons.remove, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Left section (Trash, Total)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => widget.onRemove(item['id'].toString()),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                  Text(
                    'مجموع: ${itemTotal.toStringAsFixed(1)} ₪',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
