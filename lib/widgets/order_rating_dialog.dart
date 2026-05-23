import 'package:flutter/material.dart';
import '../services/herb_service.dart';

class OrderRatingDialog extends StatefulWidget {
  final List<dynamic> items;
  final String currentUserId;

  const OrderRatingDialog({
    super.key,
    required this.items,
    required this.currentUserId,
  });

  @override
  State<OrderRatingDialog> createState() => _OrderRatingDialogState();
}

class _OrderRatingDialogState extends State<OrderRatingDialog> {
  final Map<String, int> _ratings = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      final herbId = item['herbId']?.toString() ?? '';
      if (herbId.isNotEmpty) {
        _ratings[herbId] = 1; // Default rating
      }
    }
  }

  Future<void> _submitRatings() async {
    setState(() => _isSubmitting = true);

    try {
      for (var entry in _ratings.entries) {
        if (widget.currentUserId.isNotEmpty && entry.key.isNotEmpty) {
          await HerbService.rateHerb(
            herbId: entry.key,
            userId: widget.currentUserId,
            rating: entry.value,
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تقييم الأعشاب بنجاح!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التقييم: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFDAF1DE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تقييم الأعشاب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163832),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'يرجى تقييم الأعشاب التي قمت باستلامها',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.items.map((item) {
                      final herbName = item['herbName']?.toString() ?? item['name']?.toString() ?? 'عشبة';
                      final herbId = item['herbId']?.toString() ?? '';
                      if (herbId.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                herbName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF163832),
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _ratings[herbId] = index + 1;
                                    });
                                  },
                                  child: Icon(
                                    index < (_ratings[herbId] ?? 1)
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
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                    child: const Text('تخطي', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF163832),
                    ),
                    onPressed: _isSubmitting ? null : _submitRatings,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('تأكيد التقييم', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
