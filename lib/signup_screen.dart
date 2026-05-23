import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'animated_background.dart';
import 'page_transition.dart';
import 'services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _selectedRole = 'زبون';
  final List<String> _roles = ['زبون', 'مالك متجر اعشاب', 'خبير بالاعشاب'];

  bool isLoading = false;
  bool _isPasswordVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeLocationController = TextEditingController();

  final TextEditingController yearsOfExperienceController =
      TextEditingController();
  final TextEditingController certificateUrlController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    ageController.dispose();
    ownerNameController.dispose();
    storeNameController.dispose();
    storeLocationController.dispose();
    yearsOfExperienceController.dispose();
    certificateUrlController.dispose();
    super.dispose();
  }

  String _mapRoleToApiValue() {
    if (_selectedRole == 'زبون') return 'customer';
    if (_selectedRole == 'مالك متجر اعشاب') return 'store_owner';
    return 'herbal_expert';
  }

  void _clearDynamicFields() {
    fullNameController.clear();
    ageController.clear();
    ownerNameController.clear();
    storeNameController.clear();
    storeLocationController.clear();
    yearsOfExperienceController.clear();
    certificateUrlController.clear();
  }

  Future<void> registerUser() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await AuthService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: _mapRoleToApiValue(),
        fullName: (_selectedRole == 'زبون' || _selectedRole == 'خبير بالاعشاب')
            ? fullNameController.text.trim()
            : null,
        age: _selectedRole == 'زبون' && ageController.text.trim().isNotEmpty
            ? int.tryParse(ageController.text.trim())
            : null,
        ownerName: _selectedRole == 'مالك متجر اعشاب'
            ? ownerNameController.text.trim()
            : null,
        storeName: _selectedRole == 'مالك متجر اعشاب'
            ? storeNameController.text.trim()
            : null,
        storeLocation: _selectedRole == 'مالك متجر اعشاب'
            ? storeLocationController.text.trim()
            : null,
        yearsOfExperience:
            _selectedRole == 'خبير بالاعشاب' &&
                yearsOfExperienceController.text.trim().isNotEmpty
            ? int.tryParse(yearsOfExperienceController.text.trim())
            : null,
        certificateUrl: _selectedRole == 'خبير بالاعشاب'
            ? certificateUrlController.text.trim()
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء الحساب بنجاح')));

      emailController.clear();
      passwordController.clear();
      _clearDynamicFields();

      Navigator.push(context, FadePageRoute(page: const LoginScreen()));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إنشاء الحساب: $e')));
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                child: Image.asset(
                                  'assets/images/finalLogo.png',
                                  height: 130,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.eco,
                                        size: 130,
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'إنشاء حساب جديد',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildGlassTextField(
                              label: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                              controller: emailController,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              label: 'كلمة المرور',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              controller: passwordController,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'نوع الحساب:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _roles.map((role) {
                                final isSelected = _selectedRole == role;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedRole = role);
                                    _clearDynamicFields();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Text(
                                      role,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF235347)
                                            : Colors.white,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                key: ValueKey(_selectedRole),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: _buildDynamicFields(),
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: isLoading ? null : registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF235347),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'تسجيل الحساب',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  FadePageRoute(page: const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'لدي حساب مسبقاً؟ تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (_selectedRole == 'زبون') {
      return Column(
        children: [
          _buildGlassTextField(
            label: 'الاسم الكامل',
            icon: Icons.person_outline,
            controller: fullNameController,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            label: 'العمر',
            icon: Icons.calendar_today_outlined,
            controller: ageController,
            keyboardType: TextInputType.number,
          ),
        ],
      );
    } else if (_selectedRole == 'مالك متجر اعشاب') {
      return Column(
        children: [
          _buildGlassTextField(
            label: 'اسم المالك',
            icon: Icons.person_outline,
            controller: ownerNameController,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            label: 'اسم المتجر',
            icon: Icons.storefront,
            controller: storeNameController,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            label: 'موقع المتجر (أو أونلاين)',
            icon: Icons.location_on_outlined,
            controller: storeLocationController,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildGlassTextField(
            label: 'الاسم الكامل',
            icon: Icons.person_outline,
            controller: fullNameController,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            label: 'سنوات الخبرة',
            icon: Icons.timeline,
            controller: yearsOfExperienceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            label: 'رابط الشهادة (URL)',
            icon: Icons.link,
            controller: certificateUrlController,
          ),
        ],
      );
    }
  }

  Widget _buildGlassTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),

        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,

        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
