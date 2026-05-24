import 'dart:ui';
import 'package:flutter/material.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  String selectedFilter = 'هذا الشهر';

  final List<Map<String, dynamic>> sales = [
    {
      'invoice': 'INV-001',
      'date': '22/5/2026',
      'customer': 'أحمد',
      'product': 'بابونج',
      'qty': 2,
      'unitPrice': 60,
      'discount': 0,
      'total': 120,
      'expenses': 25,
      'paymentStatus': 'مدفوع',
      'paymentMethod': 'كاش',
    },
    {
      'invoice': 'INV-002',
      'date': '22/5/2026',
      'customer': 'سارة',
      'product': 'نعناع',
      'qty': 1,
      'unitPrice': 80,
      'discount': 5,
      'total': 75,
      'expenses': 15,
      'paymentStatus': 'مدفوع',
      'paymentMethod': 'محفظة',
    },
    {
      'invoice': 'INV-003',
      'date': '21/5/2026',
      'customer': 'علي',
      'product': 'يانسون',
      'qty': 3,
      'unitPrice': 50,
      'discount': 0,
      'total': 150,
      'expenses': 40,
      'paymentStatus': 'قيد الانتظار',
      'paymentMethod': 'غير مدفوع',
    },
  ];

  int get totalSales =>
      sales.fold(0, (sum, item) => sum + item['total'] as int);

  int get totalExpenses =>
      sales.fold(0, (sum, item) => sum + item['expenses'] as int);

  int get netProfit => totalSales - totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF163832),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF051F20),
                    Color(0xFF163832),
                    Color(0xFF235347),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -80,
              child: _blurCircle(const Color(0xFF8EB69B), 220),
            ),
            Positioned(
              bottom: -100,
              left: -90,
              child: _blurCircle(const Color(0xFFDAF1DE), 240),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(context),
                    const SizedBox(height: 20),

                    const Text(
                      'لوحة المحاسبة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'إدارة المبيعات، الأرباح، المصاريف وسجلات الدفع',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        _summaryCard(
                          title: 'إجمالي المبيعات',
                          value: '₪$totalSales',
                          icon: Icons.payments_outlined,
                          dark: true,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: 'صافي الربح',
                          value: '₪$netProfit',
                          icon: Icons.trending_up,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _summaryCard(
                          title: 'عدد الطلبات',
                          value: '${sales.length}',
                          icon: Icons.shopping_bag_outlined,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: 'المصاريف',
                          value: '₪$totalExpenses',
                          icon: Icons.receipt_long_outlined,
                          dark: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _filters(),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'سجل المبيعات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showFullTable(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDAF1DE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.grid_on,
                                  size: 17,
                                  color: Color(0xFF163832),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'عرض الجدول الكامل',
                                  style: TextStyle(
                                    color: Color(0xFF163832),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: ListView.separated(
                              itemCount: sales.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = sales[index];
                                final profit =
                                    item['total'] - item['expenses'];

                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDAF1DE),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF163832),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['product'],
                                              style: const TextStyle(
                                                color: Color(0xFF051F20),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item['customer']} • ${item['date']} • الكمية ${item['qty']}',
                                              style: const TextStyle(
                                                color: Color(0xFF235347),
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'صافي الربح: ₪$profit',
                                              style: const TextStyle(
                                                color: Color(0xFF163832),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₪${item['total']}',
                                            style: const TextStyle(
                                              color: Color(0xFF163832),
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          _statusBadge(item['paymentStatus']),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    final filters = ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'من تاريخ إلى تاريخ'];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFDAF1DE)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  color:
                      isSelected ? const Color(0xFF163832) : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullTable(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFDAF1DE),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.82,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8EB69B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'الجدول المحاسبي الكامل',
                    style: TextStyle(
                      color: Color(0xFF163832),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFF8EB69B),
                          ),
                          columns: const [
                            DataColumn(label: Text('رقم الفاتورة')),
                            DataColumn(label: Text('التاريخ')),
                            DataColumn(label: Text('الزبون')),
                            DataColumn(label: Text('المنتج')),
                            DataColumn(label: Text('الكمية')),
                            DataColumn(label: Text('سعر الوحدة')),
                            DataColumn(label: Text('الخصم')),
                            DataColumn(label: Text('المجموع')),
                            DataColumn(label: Text('المصاريف')),
                            DataColumn(label: Text('صافي الربح')),
                            DataColumn(label: Text('حالة الدفع')),
                            DataColumn(label: Text('طريقة الدفع')),
                          ],
                          rows: sales.map((item) {
                            final profit =
                                item['total'] - item['expenses'];

                            return DataRow(
                              cells: [
                                DataCell(Text(item['invoice'])),
                                DataCell(Text(item['date'])),
                                DataCell(Text(item['customer'])),
                                DataCell(Text(item['product'])),
                                DataCell(Text('${item['qty']}')),
                                DataCell(Text('₪${item['unitPrice']}')),
                                DataCell(Text('₪${item['discount']}')),
                                DataCell(Text('₪${item['total']}')),
                                DataCell(Text('₪${item['expenses']}')),
                                DataCell(Text('₪$profit')),
                                DataCell(Text(item['paymentStatus'])),
                                DataCell(Text(item['paymentMethod'])),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
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

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 19,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    bool dark = false,
  }) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              dark ? const Color(0xFFDAF1DE) : Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: dark ? Colors.white.withOpacity(0.4) : Colors.white24,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: dark ? const Color(0xFF163832) : Colors.white,
              size: 28,
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: dark ? const Color(0xFF235347) : Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: dark ? const Color(0xFF051F20) : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isPaid = status == 'مدفوع';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFF8EB69B) : Colors.orange.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Color(0xFF051F20),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _blurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}