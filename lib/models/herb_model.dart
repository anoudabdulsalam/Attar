class HerbModel {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String benefits;
  final String usageMethod;
  final String season;
  final String category;
  final String imageUrl;
  final double price;
  final int quantity;
  final String storeOwnerId;
  final String storeName;

  HerbModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.benefits,
    required this.usageMethod,
    required this.season,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.storeOwnerId,
    required this.storeName,
  });

  factory HerbModel.fromJson(Map<String, dynamic> json) {
    return HerbModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      description: json['description'] ?? '',
      benefits: json['benefits'] ?? '',
      usageMethod: json['usageMethod'] ?? '',
      season: json['season'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      storeOwnerId: json['storeOwnerId'] ?? '',
      storeName: json['storeName'] ?? '',
    );
  }
}