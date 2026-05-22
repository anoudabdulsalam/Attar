import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'smart_chat_screen.dart';
import '../services/herb_service.dart';
import '../models/herb_model.dart';
import '../services/user_service.dart';

// Import the new screens
import 'store_names_customer_screen.dart';
import 'chat_customer_screen.dart';
import 'chat_detail_customer_screen.dart';
import 'notifications_customer_screen.dart';
import 'cart_customer_screen.dart';
import 'about_us_home_screen.dart';
import 'contact_us_customer_screen.dart';
import 'profile_customer_screen.dart';
import 'favorites_customer_screen.dart';
import 'login_screen.dart';
import 'herb_post_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart'; 
class HomeCustomerScreen extends StatefulWidget {
  const HomeCustomerScreen({super.key});

  @override
  State<HomeCustomerScreen> createState() => _HomeCustomerScreenState();
}

class _HomeCustomerScreenState extends State<HomeCustomerScreen> {
  int _selectedIndex = 2;
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  int _chatUnreadCount = 0;

  List<HerbModel> _herbs = [];
  bool _isLoadingHerbs = true;
  String? _herbsError;

  final List<Map<String, dynamic>> _cartItems = [];
  final Map<String, bool> _favoriteStatus = {};
  final Map<String, int> _ratings = {};

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
  _loadChatUnreadCount();
}

Future<void> _loadChatUnreadCount() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId') ?? '';

  if (userId.isEmpty) return;

  final conversations = await ChatService.getConversations(userId);

  int total = 0;

  for (final conv in conversations) {
    total += (conv['unreadCount'] as num?)?.toInt() ?? 0;
  }

  if (!mounted) return;

  setState(() {
    _chatUnreadCount = total;
  });
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
        'storeOwnerId': herb.storeOwnerId,
        'quantity': herb.quantity,
        'storeName': herb.storeName,
        'comments': herb.comments,
        'onSale': herb.onSale,
        'salePrice': herb.salePrice != null
            ? '${herb.salePrice!.toStringAsFixed(0)} ₪'
            : null,
        
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

  void _addToCart(Map<String, dynamic> plant) {
  setState(() {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['name'] == plant['name'],
    );

    final effectivePrice =
        (plant['onSale'] == true && plant['salePrice'] != null)
            ? plant['salePrice']
            : plant['price'];

    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] += 1;
      _cartItems[existingIndex]['price'] = effectivePrice;
      _cartItems[existingIndex]['onSale'] = plant['onSale'] ?? false;
      _cartItems[existingIndex]['salePrice'] = plant['salePrice'];
    } else {
      _cartItems.add({
        'id': plant['id'],
        'name': plant['name'],
        'price': effectivePrice,
        'imageUrl': plant['imageUrl'],
        'quantity': 1,
        'storeOwnerId': plant['storeOwnerId'],
        'storeName': plant['storeName'],
        'onSale': plant['onSale'] ?? false,
        'salePrice': plant['salePrice'],
        'originalPrice': plant['price'],
      });
    }

    _selectedIndex = 4;
  });
}

  void _removeFromCart(String name) {
    setState(() {
      _cartItems.removeWhere((item) => item['name'] == name);
    });
  }

  void _updateQuantity(String name, int change) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['name'] == name);
      if (index != -1) {
        _cartItems[index]['quantity'] += change;
        if (_cartItems[index]['quantity'] <= 0) {
          _cartItems.removeAt(index);
        }
      }
    });
  }

  double get _cartTotal {
  double total = 0.0;
  for (var item in _cartItems) {
    final priceSource =
        (item['onSale'] == true && item['salePrice'] != null)
            ? item['salePrice']
            : item['price'];

    String priceStr = priceSource.toString().replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );

    double price = double.tryParse(priceStr) ?? 0.0;
    total += price * (item['quantity'] as int);
  }
  return total;
}

  Future<void> _showShareDialog(BuildContext context, Map<String, dynamic> plant) async {
  try {
    final users = await UserService.getAllUsers();
    String searchQuery = '';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = users.where((user) {
              final name = (user['fullName'] ??
                      user['ownerName'] ??
                      user['storeName'] ??
                      user['email'] ??
                      '')
                  .toString();
              return name.contains(searchQuery);
            }).toList();

            return AlertDialog(
              backgroundColor: const Color(0xFFDAF1DE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'إرسال ${plant['name']} إلى:',
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
                        hintText: 'ابحث عن اسم المستخدم...',
                        prefixIcon: const Icon(Icons.search),
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
                          final user = filtered[index];

                          final name = user['fullName'] ??
                              user['ownerName'] ??
                              user['storeName'] ??
                              user['email'] ??
                              'مستخدم';

                          final role = user['role'] == 'store_owner'
                              ? 'صاحب متجر'
                              : user['role'] == 'herbal_expert'
                                  ? 'خبير'
                                  : 'زبون';

                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF8EB69B),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              '$name - $role',
                              style: const TextStyle(
                                color: Color(0xFF163832),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                CupertinoIcons.paperplane,
                                color: Color(0xFF235347),
                              ),
                             onPressed: () async {
  try {
    Navigator.pop(ctx);

    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId') ?? '';

    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم الحالي')),
      );
      return;
    }

    final receiverId = user['_id'].toString();
    final receiverName = name.toString();
    final receiverRole = user['role'].toString();

    final conversation = await ChatService.createConversation(
      user1Id: currentUserId,
      user1Role: 'customer',
      user2Id: receiverId,
      user2Role: receiverRole,
      chatName: receiverName,
    );

    await ChatService.sendMessage(
      conversationId: conversation['_id'].toString(),
      senderId: currentUserId,
      senderRole: 'customer',
      receiverId: receiverId,
      receiverRole: receiverRole,
      text: 'تم إرسال عشبة ${plant['name']}',
      type: 'post',
      herb: plant,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال ${plant['name']} إلى $receiverName')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل إرسال العشبة: $e')),
    );
  }
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
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل تحميل المستخدمين: $e')),
    );
  }
}

void _toggleFavorite(String herbId) {
  setState(() {
    _favoriteStatus[herbId] = !(_favoriteStatus[herbId] ?? false);
  });
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
                if (_selectedIndex == 2) _buildSmartChatButton(context),
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
        return const StoreNamesCustomerScreen();
      case 1:
       WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadChatUnreadCount();
           });
        return const ChatCustomerScreen();
      case 2:
        return _buildHomeContent();
      case 3:
        return const NotificationsCustomerScreen();
      case 4:
        return CartCustomerScreen(
          cartItems: _cartItems,
          onRemove: _removeFromCart,
          onUpdateQuantity: _updateQuantity,
          totalPrice: _cartTotal,
        );
      case 5:
        return const AboutUsHomeScreen();
      case 6:
        return FavoritesCustomerScreen(
          favoritePlants: _filteredPlants
              .where((p) => p['isFavorite'] == true)
              .toList(),
          onFavoriteToggle: (name) {
            final plant = _filteredPlants.firstWhere(
              (p) => p['name'] == name,
              orElse: () => {},
            );
            if (plant.isNotEmpty) {
              _toggleFavorite(plant['id']);
            }
          },
          onAddToCart: _addToCart,
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
        return const ProfileCustomerScreen();
      case 8:
        return const ContactUsCustomerScreen();
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
            icon: Icons.shopping_cart,
            title: 'السلة',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 4);
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
                      herbId: plant['id'],
                      imageUrl: plant['imageUrl'],
                      name: plant['name'],
                      benefits: plant['benefits'],
                      howToUse: plant['howToUse'],
                      price: plant['price'],
                       storeName: plant['storeName'],
                       comments: plant['comments'] ?? [],
                      isFavorite: plant['isFavorite'],
                      rating: plant['rating'] ?? 5,
                      onSale: plant['onSale'] ?? false,
                      salePrice: plant['salePrice'],
                      onFavoriteToggle: () => _toggleFavorite(plant['id']),
                      onAddToCart: () => _addToCart(plant),
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
            badgeCount: _chatUnreadCount,
            onTap: () async {
              setState(() => _selectedIndex = 1);

              await _loadChatUnreadCount();
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
              icon: Icons.notifications_none,
              index: 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
              },
            ),
            _navIcon(
              icon: Icons.shopping_cart_outlined,
              index: 4,
              onTap: () {
                setState(() => _selectedIndex = 4);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartChatButton(BuildContext context) {
    return Positioned(
      right: 18,
      bottom: 86,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SmartChatScreen()),
          );
        },
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF8EB69B),
            border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CustomPaint(
                  painter: RobotChatIconPainter(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon({
  required IconData icon,
  required int index,
  required VoidCallback onTap,
  int badgeCount = 0,
}) {
  bool isSelected = _selectedIndex == index;

  return GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF235347),
            size: 32,
          ),
        ),

        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}

class RobotChatIconPainter extends CustomPainter {
  final Color color;

  RobotChatIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.18,
        size.width * 0.76,
        size.height * 0.58,
      ),
      Radius.circular(size.width * 0.18),
    );

    canvas.drawRRect(body, strokePaint);

    canvas.drawCircle(
      Offset(size.width * 0.36, size.height * 0.45),
      size.width * 0.07,
      fillPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.64, size.height * 0.45),
      size.width * 0.07,
      fillPaint,
    );

    final smile = Path()
      ..moveTo(size.width * 0.42, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.68,
        size.width * 0.60,
        size.height * 0.58,
      );
    canvas.drawPath(smile, strokePaint);

    final tail = Path()
      ..moveTo(size.width * 0.40, size.height * 0.76)
      ..lineTo(size.width * 0.24, size.height * 0.94)
      ..lineTo(size.width * 0.27, size.height * 0.72);
    canvas.drawPath(tail, strokePaint);

    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.18),
      Offset(size.width * 0.50, size.height * 0.04),
      strokePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.04),
      size.width * 0.08,
      fillPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.43),
      Offset(size.width * 0.02, size.height * 0.43),
      strokePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.88, size.height * 0.43),
      Offset(size.width * 0.98, size.height * 0.43),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant RobotChatIconPainter oldDelegate) {
    return oldDelegate.color != color;
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
  final String herbId;
final String storeName;
final List<dynamic> comments;

  const HerbCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.benefits,
    required this.howToUse,
    required this.price,
    required this.isFavorite,
    required this.rating,
    required this.onSale,
    required this.salePrice,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onRatingChanged,
    required this.onShareTap,
    required this.herbId,
required this.storeName,
required this.comments,
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
              herbId: widget.herbId,
              imageUrl: widget.imageUrl,
              name: widget.name,
              benefits: widget.benefits,
              howToUse: widget.howToUse,
              price: widget.price,
              storeName: widget.storeName,
              onSale: widget.onSale,
              salePrice: widget.salePrice,
              comments: widget.comments,
              isFavorite: widget.isFavorite,
              onFavoriteToggle: widget.onFavoriteToggle,
              onAddToCart: widget.onAddToCart,
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