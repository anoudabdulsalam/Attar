import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/user_service.dart';

class ProfileExpertScreen extends StatefulWidget {
  const ProfileExpertScreen({super.key});

  @override
  State<ProfileExpertScreen> createState() => _ProfileExpertScreenState();
}

class _ProfileExpertScreenState extends State<ProfileExpertScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    _certificateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      if (_userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final user = await UserService.getUserById(_userId!);

      if (!mounted) return;

      setState(() {
        _nameController.text = user['fullName'] ?? '';
        _emailController.text = user['email'] ?? '';
        _experienceController.text =
            user['yearsOfExperience']?.toString() ?? '';
        _certificateController.text = user['certificateUrl'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات: $e')),
      );
    }
  }

  Future<void> _saveUserData() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم')),
      );
      return;
    }

    try {
      await UserService.updateUserById(_userId!, {
        'fullName': _nameController.text.trim(),
        'yearsOfExperience':
            int.tryParse(_experienceController.text.trim()),
        'certificateUrl': _certificateController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

                    _buildProfileField('الاسم', _nameController, Icons.person),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      'البريد الإلكتروني',
                      _emailController,
                      Icons.email,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      'سنوات الخبرة',
                      _experienceController,
                      Icons.timeline,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      'رابط الشهادة (URL)',
                      _certificateController,
                      Icons.link,
                    ),
                    const SizedBox(height: 40),

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
                      onPressed: () async {
                        if (_isEditing) {
                          await _saveUserData();
                        }

                        if (!mounted) return;

                        setState(() {
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
          const SizedBox(width: 40),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الملف الشخصي',
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

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
  }) {
    final canEdit = enabled && _isEditing;

    return TextField(
      controller: controller,
      enabled: canEdit,
      keyboardType: label == 'سنوات الخبرة'
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF235347),
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF163832)),
        filled: true,
        fillColor: canEdit ? Colors.white : Colors.white70,
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