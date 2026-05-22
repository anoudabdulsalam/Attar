import 'dart:ui';
import 'package:flutter/material.dart';
import 'animated_background.dart';
import 'page_transition.dart';
import 'login_screen.dart';
import 'services/password_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

 void _resetPassword() async {
  if (passwordController.text.trim().isEmpty ||
      confirmPasswordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text('يرجى ملء جميع الحقول'),
      ),
    );
    return;
  }

  if (passwordController.text !=
      confirmPasswordController.text) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text('كلمات المرور غير متطابقة'),
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    await PasswordService.resetPassword(
      email: widget.email,
      code: widget.otpCode,
      newPassword: passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تغيير كلمة المرور بنجاح'),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      FadePageRoute(page: const LoginScreen()),
      (route) => false,
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                            const Icon(
                              Icons.lock_person_outlined,
                              size: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'كلمة مرور جديدة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'أدخل كلمة المرور الجديدة لحسابك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildGlassTextField(
                              label: 'كلمة المرور الجديدة',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              controller: passwordController,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              label: 'تأكيد كلمة المرور',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              controller: confirmPasswordController,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: isLoading ? null : _resetPassword,
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
                                      'تأكيد',
                                      style: TextStyle(
                                        fontSize: 18,
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

  Widget _buildGlassTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
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
