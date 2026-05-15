import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'services/herb_service.dart';
import 'models/herb_model.dart';

// Import the new screens
import 'store_names_shop_owner_screen.dart';
import 'chat_shop_owner_screen.dart';
import 'chat_detail_shop_owner_screen.dart';
import 'notifications_shop_owner_screen.dart';
import 'orders_shop_owner_screen.dart';
import 'inventory_shop_owner_screen.dart';
import 'add_herb_dialog.dart';
import 'about_us_home_screen.dart';
import 'contact_us_shop_owner_screen.dart';
import 'profile_shop_owner_screen.dart';
import 'favorites_shop_owner_screen.dart';
import 'login_screen.dart';
import 'herb_post_dialog.dart';

class HomeShopOwnerScreen extends StatefulWidget {
  const HomeShopOwnerScreen({super.key});

  @override
  State<HomeShopOwnerScreen> createState() => _HomeShopOwnerScreenState();
}

class _HomeShopOwnerScreenState extends State<HomeShopOwnerScreen> {
  int _selectedIndex = 2;
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  List<HerbModel> _herbs = [];
  bool _isLoadingHerbs = true;
  String? _herbsError;

  final Map<String, bool> _favoriteStatus = {};
  final Map<String, int> _ratings = {};

  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'ORD-101',
      'customerName': 'سليم يوسف',
      'herbName': 'اليانسون',
      'quantity': 2,
      'status': 'قيد التحضير',
      'imageUrl': 'assets/images/Anise.png',
    },
    {
      'id': 'ORD-102',
      'customerName': 'عمر حسن',
      'herbName': 'البابونج',
      'quantity': 1,
      'status': 'قيد التحضير',
      'imageUrl': 'assets/images/Chamomile.png',
    },
  ];

  final List<String> _categories = [
    'الكل',
    'أعشاب طبية',
    'أعشاب عطرية',
    'أعشاب للطهي',
  ];

  @override
  void initState() {
    super.initState();
    fetchHerbs();
  }

  Future<void> fetchHerbs() async {
    try {
      setState(() {
        _isLoadingHerbs = true;
        _herbsError = null;
      });

      final data = await HerbService.getAllHerbs();
      final herbs = data.map((item) => HerbModel.fromJson(item)).toList();

      if (!mounted) return;

      setState(() {
        _herbs = herbs;
        _isLoadingHerbs = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _herbsError = e.toString();
        _isLoadingHerbs = false;
      });
    }
  }

  List<Map<String, dynamic>> get _apiPlants {
    return _herbs.map((herb) {
      return {
        'id': herb.id,
        'imageUrl': herb.imageUrl.isNotEmpty
            ? herb.imageUrl
            : 'assets/images/finalLogo.png',
        'name': herb.name,
        'benefits': herb.benefits.isNotEmpty
            ? herb.benefits
            : herb.description,
        'howToUse': herb.usageMethod.isNotEmpty
            ? herb.usageMethod
            : 'غير محدد',
        'price': '${herb.price.toStringAsFixed(0)} ₪',
        'category': _mapCategoryToArabic(herb.category),
        'isFavorite': _favoriteStatus[herb.id] ?? false,
        'rating': _ratings[herb.id] ?? 5,
        'description': herb.description,
        'scientificName': herb.scientificName,
        'season': herb.season,
        'quantity': herb.quantity,
        'storeName': herb.storeName,
      };
    }).toList();
  }

  String _mapCategoryToArabic(String category) {
    final cat = category.toLowerCase().trim();

    if (cat.contains('medicinal')) return 'أعشاب طبية';
    if (cat.contains('aromatic')) return 'أعشاب عطرية';
    if (cat.contains('spice')) return 'أعشاب للطهي';
    if (cat.contains('digestive')) return 'أعشاب طبية';
    if (cat.contains('relaxing')) return 'أعشاب طبية';
    if (cat.contains('respiratory')) return 'أعشاب طبية';

    return category.isEmpty ? 'أعشاب طبية' : category;
  }

  List<Map<String, dynamic>> get _filteredPlants {
    List<Map<String, dynamic>> plants = _apiPlants;

    if (_selectedCategoryIndex != 0) {
      String selectedCat = _categories[_selectedCategoryIndex];
      plants = plants
          .where((plant) => plant['category'] == selectedCat)
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      plants = plants.where((plant) {
        String name = plant['name'].toString().toLowerCase();
        return name.contains(_searchQuery.trim().toLowerCase());
      }).toList();
    }

    return plants;
  }

  void _toggleFavorite(String herbId) {
    setState(() {
      _favoriteStatus[herbId] = !(_favoriteStatus[herbId] ?? false);
    });
  }

  void _showShareDialog(BuildContext context, Map<String, dynamic> plant) {
    String plantName = plant['name'];
    final List<String> experts = [
      'د. أحمد قاسم - خبير أعشاب',
      'صيدلية الطبيعة - متجر',
      'أ. فؤاد محمود - متخصص أدوية طبيعية',
      'مزرعة الريحان - مزرعة خاصة',
      'د. منى علي - خبيرة تغذية',
    ];

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = experts
                .where((e) => e.contains(searchQuery))
                .toList();
            return AlertDialog(
              backgroundColor: const Color(0xFFDAF1DE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'إرسال $plantName إلى:',
                style: const TextStyle(
                  color: Color(0xFF163832),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 320,
                height: 350,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث عن اسم الخبير أو المتجر...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF163832),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF8EB69B),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              filtered[index],
                              style: const TextStyle(
                                color: Color(0xFF163832),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                CupertinoIcons.paperplane,
                                color: Color(0xFF235347),
                                size: 24,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                String expertName = filtered[index];
                                String chatName = expertName.contains('-')
                                    ? expertName.split('-')[0].trim()
                                    : expertName;
                                ChatDetailShopOwnerScreen.addSharedPost(
                                  chatName,
                                  plant,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم إرسال $plantName إلى $chatName بنجاح. ألق نظرة على المحادثات!',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF163832),
      endDrawer: _buildDrawer(context),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginBachground1.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      const Color(0xFF163832).withOpacity(0.5),
                      const Color(0xFF163832).withOpacity(0.6),
                      Colors.white.withOpacity(0.15),
                    ],
                    stops: const [0.0, 0.3, 0.8, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: _buildCurrentBody(),
                ),
                if (_selectedIndex == 2)
                  Positioned(
                    bottom: 80,
                    right: 20,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF8EB69B),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddHerbDialog(
                            onAdd: (newHerb) async {
                              await fetchHerbs();
                            },
                          ),
                        );
                      },
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                _buildBottomNavigationBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBody() {
    switch (_selectedIndex) {
      case 0:
        return const StoreNamesShopOwnerScreen();
      case 1:
        return const ChatShopOwnerScreen();
      case 2:
        return _buildHomeContent();
      case 3:
        return const NotificationsShopOwnerScreen();
      case 4:
        return OrdersShopOwnerScreen(orders: _mockOrders);
      case 5:
        return const AboutUsHomeScreen();
      case 6:
        return FavoritesShopOwnerScreen(
          favoritePlants:
              _filteredPlants.where((p) => p['isFavorite'] == true).toList(),
          onFavoriteToggle: (name) {
            final plant = _filteredPlants.firstWhere(
              (p) => p['name'] == name,
              orElse: () => {},
            );
            if (plant.isNotEmpty) {
              _toggleFavorite(plant['id']);
            }
          },
          onAddToCart: (plant) {},
          onRatingChanged: (name, rating) {
            final plant = _filteredPlants.firstWhere(
              (p) => p['name'] == name,
              orElse: () => {},
            );
            if (plant.isNotEmpty) {
              setState(() {
                _ratings[plant['id']] = rating;
              });
            }
          },
          onShareTap: (name) {
            final plantIndex =
                _filteredPlants.indexWhere((p) => p['name'] == name);
            if (plantIndex != -1) {
              _showShareDialog(context, _filteredPlants[plantIndex]);
            }
          },
        );
      case 7:
        return const ProfileShopOwnerScreen();
      case 8:
        return const ContactUsShopOwnerScreen();
      case 9:
        return InventoryShopOwnerScreen(
          plants: _filteredPlants,
          onInventoryChanged: () {
            setState(() {});
          },
        );
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Column(
      key: const ValueKey('HomeContent'),
      children: [
        _buildTopAppBar(context),
        _buildSearchBar(),
        _buildCategories(),
        Expanded(child: _buildPlantHorizontalList()),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF8EB69B),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Color(0xFF8EB69B)),
          ),
          const SizedBox(height: 10),
          const Text(
            'مرحباً بك!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white54, height: 40),
          _drawerItem(
            icon: Icons.person,
            title: 'الملف الشخصي',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 7);
            },
          ),
          _drawerItem(
            icon: Icons.home,
            title: 'الرئيسية',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            },
          ),
          _drawerItem(
            icon: Icons.receipt_long,
            title: 'الطلبات',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 4);
            },
          ),
          _drawerItem(
            icon: Icons.inventory_2,
            title: 'المخزون',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 9);
            },
          ),
          _drawerItem(
            icon: Icons.favorite,
            title: 'المفضلة',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 6);
            },
          ),
          _drawerItem(
            icon: Icons.notifications,
            title: 'الإشعارات',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
            },
          ),
          _drawerItem(
            icon: Icons.info,
            title: 'من نحن',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 5);
            },
          ),
          _drawerItem(
            icon: Icons.contact_support,
            title: 'تواصل معنا',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 8);
            },
          ),
          const Spacer(),
          _drawerItem(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
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
                'اكتشف أعشابك',
                style: TextStyle(
                  fontSize: 20,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'ابحث عن عشبتك المفضلة...',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF235347)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم التقاط الصورة: ${image.name}'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            bool isSelected = index == _selectedCategoryIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8EB69B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF235347),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlantHorizontalList() {
    if (_isLoadingHerbs) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_herbsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'حدث خطأ أثناء تحميل الأعشاب',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _herbsError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchHerbs,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_filteredPlants.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أعشاب متاحة حالياً',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90, top: 10),
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: _filteredPlants.map((plant) {
            return HerbCard(
              imageUrl: plant['imageUrl'],
              name: plant['name'],
              benefits: plant['benefits'],
              howToUse: plant['howToUse'],
              price: plant['price'],
              isFavorite: plant['isFavorite'],
              rating: plant['rating'] ?? 5,
              onSale: plant['onSale'] ?? false,
              salePrice: plant['salePrice'],
              onFavoriteToggle: () => _toggleFavorite(plant['id']),
              onAddToCart: () {},
              onRatingChanged: (newRating) {
                setState(() {
                  _ratings[plant['id']] = newRating;
                });
              },
              onShareTap: () => _showShareDialog(context, plant),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Positioned(
      bottom: 5,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFDAF1DE),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navIcon(
              icon: Icons.storefront,
              index: 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
              },
            ),
            _navIcon(
              icon: Icons.chat_bubble_outline,
              index: 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
              },
            ),
            _navIcon(
              icon: Icons.home,
              index: 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
              },
            ),
            _navIcon(
              icon: Icons.receipt_long,
              index: 4,
              onTap: () {
                setState(() => _selectedIndex = 4);
              },
            ),
            _navIcon(
              icon: Icons.inventory_2,
              index: 9,
              onTap: () {
                setState(() => _selectedIndex = 9);
              },
            ),
            _navIcon(
              icon: Icons.notifications_none,
              index: 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required int index,
    required VoidCallback onTap,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF235347),
          size: 32,
        ),
      ),
    );
  }
}

class HerbCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String benefits;
  final String howToUse;
  final String price;
  final bool isFavorite;
  final int rating;
  final bool onSale;
  final String? salePrice;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onShareTap;

  const HerbCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.benefits,
    required this.howToUse,
    required this.price,
    required this.isFavorite,
    required this.rating,
    this.onSale = false,
    this.salePrice,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onRatingChanged,
    required this.onShareTap,
  });

  @override
  State<HerbCard> createState() => _HerbCardState();
}

class _HerbCardState extends State<HerbCard> {
  bool _isHovering = false;

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: _isHovering ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.black54,
              builder: (context) => HerbPostDialog(
                imageUrl: widget.imageUrl,
                name: widget.name,
                benefits: widget.benefits,
                howToUse: widget.howToUse,
                price: widget.price,
                isFavorite: widget.isFavorite,
                onFavoriteToggle: widget.onFavoriteToggle,
                onAddToCart: widget.onAddToCart,
                onShareTap: widget.onShareTap,
              ),
            );
          },
          child: Container(
            width: 220,
            height: 380,
            decoration: BoxDecoration(
              color: const Color(0xFFDAF1DE),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: _isHovering ? 5 : 2,
                  blurRadius: _isHovering ? 15 : 10,
                  offset: Offset(0, _isHovering ? 8 : 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipPath(
                        clipper: WavyTopClipper(),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDAF1DE),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _isNetworkImage(widget.imageUrl)
                              ? Image.network(
                                  widget.imageUrl,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.eco,
                                    size: 80,
                                    color: Color(0xFF8EB69B),
                                  ),
                                )
                              : Image.asset(
                                  widget.imageUrl,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.eco,
                                    size: 80,
                                    color: Color(0xFF8EB69B),
                                  ),
                                ),
                        ),
                      ),
                      if (widget.onSale)
                        Positioned(
                          top: 15,
                          right: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'عرض خاص',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 15,
                        left: 15,
                        child: GestureDetector(
                          onTap: widget.onFavoriteToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: widget.isFavorite
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.isFavorite
                                  ? const Color(0xFF163832)
                                  : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF051F20),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onShareTap,
                              child: const Icon(
                                CupertinoIcons.paperplane,
                                color: Color(0xFF235347),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.benefits,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF051F20),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.howToUse,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF051F20),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.onSale && widget.salePrice != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.price,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    widget.salePrice!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                widget.price,
                                style: const TextStyle(
                                  color: Color(0xFF235347),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            Row(
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () =>
                                      widget.onRatingChanged(index + 1),
                                  child: Icon(
                                    index < widget.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFFFB400),
                                    size: 16,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onAddToCart,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8EB69B),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إضافة للسلة',
                          style: TextStyle(
                            color: Color(0xFF051F20),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.add_shopping_cart,
                          color: Color(0xFF051F20),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WavyTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 4),
      size.height - 60,
    );
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}