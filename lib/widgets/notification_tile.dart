import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../herb_post_dialog.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIconForType() {
    switch (notification.type) {
      case 1:
        return Icons.energy_savings_leaf_outlined;
      case 2:
        return Icons.local_shipping_outlined;
      case 3:
        return Icons.chat_bubble_outline;
      case 4:
        return Icons.shopping_bag_outlined;
      case 5:
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  void _handleTap(BuildContext context) {
    if (notification.type == 1 || notification.type == 5) {
      if (notification.herbPayload != null) {
        showDialog(
          context: context,
          builder: (context) => HerbPostDialog(
            herbId: notification.herbPayload!['herbId'] ?? '',
            imageUrl: notification.herbPayload!['imageUrl'] ?? 'assets/images/finalLogo.png',
            name: notification.herbPayload!['name'] ?? '',
            benefits: notification.herbPayload!['benefits'] ?? '',
            howToUse: notification.herbPayload!['howToUse'] ?? '',
            price: notification.herbPayload!['price'] ?? '',
            storeName: notification.herbPayload!['storeName'] ?? '',
            onSale: notification.herbPayload!['onSale'] ?? false,
            salePrice: notification.herbPayload!['salePrice'],
            comments: notification.herbPayload!['comments'] ?? [],
            isFavorite: false,
            onFavoriteToggle: () {},
            onAddToCart: () {},
          ),
        );
      }
    }
    onTap(); // call the provided onTap (e.g. to mark as read)
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Right icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(),
                  color: const Color(0xFF163832),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Center Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF163832),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildContent(),
                  ],
                ),
              ),
              // Left Time & Dot
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.circle, color: Colors.green, size: 8),
                      ]
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (notification.type) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اسم العشبة: ${notification.herbName ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Text('السعر: ${notification.price ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Text('المتجر: ${notification.storeName ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        );
      case 2:
        return Text(
          'طلب رقم #${notification.id.hashCode.toString().substring(0, 4).replaceAll('-', '1')} لعشبة ${notification.herbName ?? ''} جاهز وهو الآن مع شركة التوصيل',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        );
      case 3:
        return const Text(
          'بشأن استفسار عن المنتج',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        );
      case 4:
        return const Text(
          'من زبون جديد',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red),
              ),
              child: const Text('عرض خاص', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  notification.originalPrice ?? '',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  notification.offerPrice ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return Text(
          notification.body,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}
