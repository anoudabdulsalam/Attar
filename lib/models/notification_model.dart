class NotificationModel {
  final String id;
  final String title;
  final String body;
  final int type;
  final String? herbName;
  final String? imageUrl;
  final String? storeName;
  final String? price;
  final String? originalPrice;
  final String? offerPrice;
  final String? senderName;
  final DateTime createdAt;
  bool isRead;
  final Map<String, dynamic>? herbPayload;

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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: (json['type'] as num?)?.toInt() ?? 1,
      herbName: json['herbName']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      storeName: json['storeName']?.toString(),
      price: json['price']?.toString(),
      originalPrice: json['originalPrice']?.toString(),
      offerPrice: json['offerPrice']?.toString(),
      senderName: json['senderName']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] ?? false,
      herbPayload: json['herbPayload'] is Map
          ? Map<String, dynamic>.from(json['herbPayload'])
          : null,
    );
  }
}