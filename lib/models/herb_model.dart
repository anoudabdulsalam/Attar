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
  final bool onSale;
  final double? salePrice;
  final List<dynamic> comments;
  final List<dynamic> ratings;
  final int salesCount;
  final double averageRating;
  final String createdAt;
  final String? saleUpdatedAt;

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
    required this.onSale,
    required this.salePrice,
    required this.comments,
    required this.ratings,
    required this.salesCount,
    required this.averageRating,
    required this.createdAt,
    this.saleUpdatedAt,
  });

  factory HerbModel.fromJson(Map<String, dynamic> json) {
    return HerbModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      scientificName: json['scientificName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      benefits: json['benefits']?.toString() ?? '',
      usageMethod: json['usageMethod']?.toString() ?? '',
      season: json['season']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      storeOwnerId: json['storeOwnerId']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      onSale: json['onSale'] ?? false,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      comments: json['comments'] ?? [],
      ratings: json['ratings'] ?? [],
      salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 1.0,
      createdAt: json['createdAt']?.toString() ?? '',
      saleUpdatedAt: json['saleUpdatedAt']?.toString(),
    );
  }
}