import 'dart:ui';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'page_transition.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isButtonHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginBachground1.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxWidth: 1400,
                        ), // restrict max width for large screens
                        padding: const EdgeInsets.only(
                          top: 35,
                          bottom: 90,
                          left: 60,
                          right: 60,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.55,
                          ), // Whiter glass effect
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top Navigation Links
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing:
                                  80, // give good width between links to match image
                              runSpacing: 10,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      FadePageRoute(page: const MainScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'الصفحة الرئيسية',
                                    style: TextStyle(
                                      color: Color(0xFF235347),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      FadePageRoute(
                                        page: const AboutUsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'من نحن',
                                    style: TextStyle(
                                      color: Color(0xFF235347),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      FadePageRoute(
                                        page: const ContactUsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'تواصل معنا',
                                    style: TextStyle(
                                      color: Color(0xFF235347),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Logo
                            Image.asset(
                              'assets/images/finalLogo.png',
                              height: 350,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.eco,
                                    color: Color(0xFF235347),
                                    size: 150,
                                  ),
                            ),
                            const SizedBox(height: 30),

                            // Description
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: const Text(
                                'تطبيقنا "عطار" هو وجهتك السهلة لاكتشاف وشراء أفضل الأعشاب الطبيعية والزيوت والتوابل بجودة عالية. نوفر لك تجربة مريحة مع معلومات مفيدة لتعيش أسلوب حياة صحي بطريقة عصرية.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF235347),
                                  height: 1.6,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),

                            // Buttons
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _HoverScaleButton(
                                  onHoverChanged: (isHovered) {
                                    setState(() {
                                      _isButtonHovered = isHovered;
                                    });
                                  },
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        FadePageRoute(
                                          page: const SignupScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF235347),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 60,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'إنشاء حساب',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                    'لديك حساب؟ سجل الدخول',
                                    style: TextStyle(
                                      color: Color(0xFF235347),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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

          // Branch Images moved ON TOP of the white box
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            left: _isButtonHovered ? -250 : -20,
            top: -20,
            bottom: -20,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/WelcomeBranchLeft.png',
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            right: _isButtonHovered ? -250 : -20,
            top: -20,
            bottom: -20,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/WelcomeBranchRight.png',
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverScaleButton extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool>? onHoverChanged;
  const _HoverScaleButton({required this.child, this.onHoverChanged});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHoverChanged?.call(true);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        widget.onHoverChanged?.call(false);
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}
