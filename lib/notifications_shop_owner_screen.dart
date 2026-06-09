import 'package:flutter/material.dart';
import 'widgets/notification_tile.dart';
import 'services/notification_service.dart';

class NotificationsShopOwnerScreen extends StatefulWidget {
  const NotificationsShopOwnerScreen({super.key});

  @override
  State<NotificationsShopOwnerScreen> createState() =>
      _NotificationsShopOwnerScreenState();
}

class _NotificationsShopOwnerScreenState
    extends State<NotificationsShopOwnerScreen> {
  late Future<List<dynamic>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture =
        NotificationService.getNotifications('shop_owner');
  }

  void refreshNotifications() {
    setState(() {
      notificationsFuture =
          NotificationService.getNotifications('shop_owner');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('NotificationsScreen'),
      children: [
        _buildHeader(context, 'الإشعارات'),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFDAF1DE),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'حدث خطأ أثناء تحميل الإشعارات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                );
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد إشعارات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return NotificationTile(
                    notification: notification,
                    onTap: () async {
                      await NotificationService.markAsRead(
                        notification.id,
                      );

                      refreshNotifications();
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 3.0,
      ),
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
                errorBuilder: (_, _, _) => const Icon(
                  Icons.eco,
                  color: Color(0xFF163832),
                  size: 40,
                ),
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