import 'package:flutter/material.dart';
import 'services/user_service.dart';
import 'services/herb_service.dart';
import 'models/herb_model.dart';
import 'widgets/store_dialog.dart';

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
        return StoreDialog(store: store, herbs: storeHerbs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('StoreNamesScreen'),
      children: [
        _buildHeader(context, 'المتاجر'),
        Expanded(child: _buildBody()),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          storeName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFF163832),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'صاحب المتجر: $ownerName',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF163832),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الموقع: $location',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF235347),
                          fontSize: 15,
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
