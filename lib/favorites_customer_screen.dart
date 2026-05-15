import 'package:flutter/material.dart';
import 'home_customer_screen.dart'; // To reuse HerbCard

class FavoritesCustomerScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoritePlants;
  final Function(String) onFavoriteToggle;
  final Function(Map<String, dynamic>) onAddToCart;
  final Function(String, int) onRatingChanged;
  final Function(String) onShareTap;

  const FavoritesCustomerScreen({
    super.key,
    required this.favoritePlants,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onRatingChanged,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('FavoritesScreen'),
      children: [
        _buildTopAppBar(context),
        Expanded(
          child: favoritePlants.isEmpty
              ? const Center(
                  child: Text(
                    'لا يوجد أعشاب في المفضلة حالياً',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 90,
                    top: 20,
                  ),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: favoritePlants.map<Widget>((plant) {
                      return HerbCard(
                        imageUrl: plant['imageUrl'],
                        name: plant['name'],
                        benefits: plant['benefits'],
                        howToUse: plant['howToUse'],
                        price: plant['price'],
                        isFavorite: plant['isFavorite'] ?? false,
                        rating: plant['rating'] ?? 5,
                        onFavoriteToggle: () => onFavoriteToggle(plant['name']),
                        onAddToCart: () => onAddToCart(plant),
                        onRatingChanged: (newRating) =>
                            onRatingChanged(plant['name'], newRating),
                        onShareTap: () => onShareTap(plant['name']),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDAF1DE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
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
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.eco, color: Color(0xFF163832), size: 40),
              ),
            ],
          ),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'المفضلة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163832),
                ),
              ),
            ],
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
