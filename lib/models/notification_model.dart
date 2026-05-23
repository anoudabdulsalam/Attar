class NotificationModel {
  final String id;
  final String title;
  final String body;
  final int type; // 1: New Herb, 2: Order Status, 3: New Message, 4: New Order (Store), 5: Discount/Offer
  final String? herbName;
  final String? imageUrl;
  final String? storeName;
  final String? price;
  final String? originalPrice;
  final String? offerPrice;
  final String? senderName;
  final DateTime createdAt;
  bool isRead;
  final Map<String, dynamic>? herbPayload; // Used to pass data to HerbPostDialog

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.herbName,
    this.imageUrl,
    this.storeName,
    this.price,
    this.originalPrice,
    this.offerPrice,
    this.senderName,
    required this.createdAt,
    this.isRead = false,
    this.herbPayload,
  });
}
