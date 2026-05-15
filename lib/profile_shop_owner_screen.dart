import 'package:flutter/material.dart';

class ProfileShopOwnerScreen extends StatefulWidget {
  const ProfileShopOwnerScreen({super.key});

  @override
  State<ProfileShopOwnerScreen> createState() => _ProfileShopOwnerScreenState();
}

class _ProfileShopOwnerScreenState extends State<ProfileShopOwnerScreen> {
  // Mock Data
  final TextEditingController _ownerNameController = TextEditingController(
    text: "أحمد محمد",
  );
  final TextEditingController _storeNameController = TextEditingController(
    text: "صيدلية الطبيعة",
  );
  final TextEditingController _storeLocationController = TextEditingController(
    text: "عمان، وسط البلد",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "ahmed@example.com",
  );

  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('ProfileScreen'),
      children: [
        _buildTopAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
              bottom: 90,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAF1DE),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo & Avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          child: Image.asset(
                            'assets/images/finalLogo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.eco,
                              color: Color(0xFF163832),
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(
                            'assets/images/profile_placeholder.png',
                          ),
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF8EB69B),
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Editable Fields
                    _buildProfileField('اسم المالك', _ownerNameController, Icons.person_outline),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      'اسم المتجر',
                      _storeNameController,
                      Icons.storefront,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      'موقع المتجر',
                      _storeLocationController,
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      'البريد الإلكتروني',
                      _emailController,
                      Icons.email,
                    ),
                    const SizedBox(height: 40),

                    // Save / Edit Toggle
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF163832),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isEditing) {
                            // Handle saving logic here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم حفظ التغييرات بنجاح'),
                              ),
                            );
                          }
                          _isEditing = !_isEditing;
                        });
                      },
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isEditing ? 'حفظ التغييرات' : 'تعديل البيانات',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
          // Logo & Profile pic mock (we leave profile empty here as user requested it inside the page body)
          const SizedBox(width: 40), // Spacer

          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الملف الشخصي',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163832), // Dark text to contrast light bar
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

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF235347),
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF163832)),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.white70,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF8EB69B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF163832), width: 2),
        ),
      ),
    );
  }
}
