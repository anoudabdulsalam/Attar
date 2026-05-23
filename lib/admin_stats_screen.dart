import 'dart:ui';
import 'package:flutter/material.dart';
import 'services/admin_service.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  bool isLoading = true;
  List<dynamic> stats = [];
  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      setState(() {
        isLoading = true;
      });
      final data = await AdminService.getStoreStats();
      setState(() {
        stats = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في جلب الإحصائيات: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (stats.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد إحصائيات متاحة للمتاجر',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    final maxSales = stats
        .map((e) => _toDouble(e['totalSalesThisMonth']))
        .fold<double>(0, (prev, element) => element > prev ? element : prev);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  Card(
                    color: Colors.white.withOpacity(0.2),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'رسم بياني لمبيعات المحلات',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 24,
                              runSpacing: 24,
                              children: stats.map((stat) {
                                final storeName =
                                    stat['storeName'] ?? 'متجر غير معروف';
                                final sales = _toDouble(
                                  stat['totalSalesThisMonth'],
                                );
                                final percent = maxSales == 0
                                    ? 0.0
                                    : sales / maxSales;

                                return Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 85,
                                          height: 85,
                                          child: CircularProgressIndicator(
                                            value: percent,
                                            strokeWidth: 8,
                                            backgroundColor: Colors.white24,
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                        Text(
                                          '${(percent * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      storeName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${sales.toStringAsFixed(0)} ₪',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  ...stats.map((stat) {
                    final herbs = stat['herbs'] as List<dynamic>;

                    return Card(
                      color: Colors.white.withOpacity(0.2),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ExpansionTile(
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white70,
                        title: Text(
                          stat['storeName'] ?? 'متجر غير معروف',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'المالك: ${stat['ownerName'] ?? '-'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المبيعات هذا الشهر: ${stat['totalSalesThisMonth']} شيقل',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'إجمالي الأعشاب المضافة: ${stat['totalHerbsAdded']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.white30,
                                  height: 24,
                                ),
                                const Text(
                                  'تفاصيل الأعشاب:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                herbs.isEmpty
                                    ? const Text(
                                        'لا توجد أعشاب مضافة لهذا المتجر.',
                                        style: TextStyle(color: Colors.white70),
                                      )
                                    : Column(
                                        children: herbs.map((herb) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '- ${herb['name']}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'الكمية: ${herb['quantity']}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
