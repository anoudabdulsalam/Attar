import 'dart:async';
import '../models/notification_model.dart';

class MockNotificationService {
  static final MockNotificationService _instance = MockNotificationService._internal();

  factory MockNotificationService() {
    return _instance;
  }

  MockNotificationService._internal() {
    // Generate initial mock notifications for different users
    _customerAndExpertNotifications = [
      NotificationModel(
        id: '1',
        title: 'عشبة جديدة',
        body: 'تمت إضافة عشبة الزعتر البري من قبل متجر الأعشاب الصحية',
        type: 1,
        herbName: 'الزعتر البري',
        price: '15 ₪',
        storeName: 'الأعشاب الصحية',
        imageUrl: 'assets/images/finalLogo.png',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        herbPayload: {
          'herbId': 'herb_1',
          'imageUrl': 'assets/images/finalLogo.png',
          'name': 'الزعتر البري',
          'benefits': 'مفيد للجهاز التنفسي والمناعة',
          'howToUse': 'يغلى مع الماء ويشرب دافئاً',
          'price': '15 ₪',
          'storeName': 'الأعشاب الصحية',
          'onSale': false,
          'comments': [],
        },
      ),
      NotificationModel(
        id: '2',
        title: 'تحديث الطلب',
        body: 'تحول طلبك لعشبة البابونج إلى جاهز وهو الآن مع شركة التوصيل',
        type: 2,
        herbName: 'البابونج',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: '3',
        title: 'رسالة جديدة',
        body: 'وصلتك رسالة جديدة من أحمد',
        type: 3,
        senderName: 'أحمد',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '5',
        title: 'عرض خاص',
        body: 'يوجد عرض خاص على عشبة الميرمية',
        type: 5,
        herbName: 'الميرمية',
        originalPrice: '20 ₪',
        offerPrice: '12 ₪',
        imageUrl: 'assets/images/finalLogo.png',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        herbPayload: {
          'herbId': 'herb_2',
          'imageUrl': 'assets/images/finalLogo.png',
          'name': 'الميرمية',
          'benefits': 'تخفيف آلام المعدة',
          'howToUse': 'تشرب مغلية',
          'price': '20 ₪',
          'storeName': 'متجر الطبيعة',
          'onSale': true,
          'salePrice': '12 ₪',
          'comments': [],
        },
      ),
    ];

    _shopOwnerNotifications = [
      NotificationModel(
        id: '4',
        title: 'طلب جديد',
        body: 'وصلك طلب جديد لعشبة النعناع',
        type: 4,
        herbName: 'النعناع',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '3',
        title: 'رسالة جديدة',
        body: 'وصلتك رسالة جديدة من محمد',
        type: 3,
        senderName: 'محمد',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<NotificationModel> _customerAndExpertNotifications = [];
  List<NotificationModel> _shopOwnerNotifications = [];

  final _notificationController = StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get onNotificationReceived => _notificationController.stream;

  List<NotificationModel> getCustomerAndExpertNotifications() {
    return _customerAndExpertNotifications;
  }

  List<NotificationModel> getShopOwnerNotifications() {
    return _shopOwnerNotifications;
  }

  void markAsRead(String id) {
    for (var n in _customerAndExpertNotifications) {
      if (n.id == id) n.isRead = true;
    }
    for (var n in _shopOwnerNotifications) {
      if (n.id == id) n.isRead = true;
    }
  }

  // Triggered manually to show the top banner
  void simulateIncomingNotification(NotificationModel notification, String targetRole) {
    if (targetRole == 'customer' || targetRole == 'expert') {
      _customerAndExpertNotifications.insert(0, notification);
    } else {
      _shopOwnerNotifications.insert(0, notification);
    }
    _notificationController.sink.add(notification);
  }

  void dispose() {
    _notificationController.close();
  }
}
