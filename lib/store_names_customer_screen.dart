import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'services/user_service.dart';
import 'services/herb_service.dart';
import 'models/herb_model.dart';
import 'herb_post_dialog.dart';

class StoreNamesCustomerScreen extends StatefulWidget {
  const StoreNamesCustomerScreen({super.key});

  @override
  State<StoreNamesCustomerScreen> createState() =>
      _StoreNamesCustomerScreenState();
}

class _StoreNamesCustomerScreenState extends State<StoreNamesCustomerScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _stores = [];
  List<HerbModel> _herbs = [];

  @override
  void initState() {
    super.initState();
    _loadStoresAndHerbs();
  }

  Future<void> _loadStoresAndHerbs() async {
    try {
      final users = await UserService.getAllUsers();
      final herbsData = await HerbService.getAllHerbs();

      final stores = users.where((user) {
        return user['role'] == 'store_owner';
      }).toList();

      final herbs = herbsData.map((item) => HerbModel.fromJson(item)).toList();

      if (!mounted) return;

      setState(() {
        _stores = stores;
        _herbs = herbs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openStoreDialog(Map<String, dynamic> store) {
    final storeId = store['_id']?.toString() ?? '';

    final storeHerbs = _herbs.where((herb) {
      return herb.storeOwnerId == storeId;
    }).toList();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return StoreDialog(
          store: store,
          herbs: storeHerbs,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('StoreNamesScreen'),
      children: [
        _buildHeader(context, 'المتاجر'),
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'حدث خطأ أثناء تحميل المتاجر\n$_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    if (_stores.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد متاجر حالياً',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _stores.length,
      itemBuilder: (context, index) {
        final store = _stores[index];

        final storeName = store['storeName'] ?? 'متجر غير معروف';
        final ownerName = store['ownerName'] ?? 'صاحب متجر غير معروف';
        final location = store['storeLocation'] ?? 'الموقع غير محدد';

        return GestureDetector(
          onTap: () => _openStoreDialog(store),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFDAF1DE),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFF8EB69B),
                  child: Icon(Icons.store, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          color: Color(0xFF163832),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'صاحب المتجر: $ownerName',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF163832),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                      const SizedBox(height: 4),
                      Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'الموقع: $location',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF235347),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF163832),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
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

class StoreDialog extends StatelessWidget {
  final Map<String, dynamic> store;
  final List<HerbModel> herbs;

  const StoreDialog({
    super.key,
    required this.store,
    required this.herbs,
  });

  @override
  Widget build(BuildContext context) {
    final storeName = store['storeName'] ?? 'متجر غير معروف';
    final ownerName = store['ownerName'] ?? 'صاحب متجر غير معروف';
    final location = store['storeLocation'] ?? 'الموقع غير محدد';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 850,
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            children: [
              Container(
                color: const Color(0xFFDAF1DE),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF163832)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        storeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF163832),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                color: const Color(0xFFF0F5F1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'صاحب المتجر: $ownerName',
                      style: const TextStyle(
                        color: Color(0xFF163832),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الموقع: $location',
                      style: const TextStyle(
                        color: Color(0xFF235347),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: herbs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد أعشاب لهذا المتجر حالياً',
                          style: TextStyle(
                            color: Color(0xFF163832),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: herbs.map((herb) {
                            return StoreHerbCard(
                              herb: herb,
                              storeName: storeName,
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreHerbCard extends StatelessWidget {
  final HerbModel herb;
  final String storeName;

  const StoreHerbCard({
    super.key,
    required this.herb,
    required this.storeName,
  });

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        herb.imageUrl.isNotEmpty ? herb.imageUrl : 'assets/images/finalLogo.png';

    final priceText = '${herb.price.toStringAsFixed(0)} ₪';
    final salePriceText =
        herb.salePrice != null ? '${herb.salePrice!.toStringAsFixed(0)} ₪' : null;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black54,
          builder: (context) => HerbPostDialog(
            herbId: herb.id,
            imageUrl: imageUrl,
            name: herb.name,
            benefits: herb.benefits.isNotEmpty ? herb.benefits : herb.description,
            howToUse: herb.usageMethod.isNotEmpty ? herb.usageMethod : 'غير محدد',
            price: priceText,
            storeName: herb.storeName.isNotEmpty ? herb.storeName : storeName,
            onSale: herb.onSale,
            salePrice: salePriceText,
            comments: herb.comments,
            isFavorite: false,
            onFavoriteToggle: () {},
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة العشبة للسلة'),
                  backgroundColor: Color(0xFF235347),
                ),
              );
            },
          ),
        );
      },
      child: Container(
        width: 220,
        height: 360,
        decoration: BoxDecoration(
          color: const Color(0xFFDAF1DE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 155,
              width: double.infinity,
              child: Stack(
                children: [
                  Center(
                    child: _isNetworkImage(imageUrl)
                        ? Image.network(
                            imageUrl,
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.eco,
                              size: 80,
                              color: Color(0xFF8EB69B),
                            ),
                          )
                        : Image.asset(
                            imageUrl,
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.eco,
                              size: 80,
                              color: Color(0xFF8EB69B),
                            ),
                          ),
                  ),
                  if (herb.onSale)
                    Positioned(
                      top: 12,
                      right: 12,
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
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        herb.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF051F20),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        herb.benefits.isNotEmpty ? herb.benefits : herb.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF051F20),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        herb.usageMethod.isNotEmpty ? herb.usageMethod : 'غير محدد',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF051F20),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (herb.onSale && salePriceText != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              priceText,
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              salePriceText,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          priceText,
                          style: const TextStyle(
                            color: Color(0xFF235347),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Container(
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
                    'عرض التفاصيل',
                    style: TextStyle(
                      color: Color(0xFF051F20),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.eye,
                    color: Color(0xFF051F20),
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}