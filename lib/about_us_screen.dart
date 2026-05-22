import 'dart:ui';
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'page_transition.dart';
import 'contact_us_screen.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _isBranchesOpening = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 30 && !_isBranchesOpening) {
        setState(() => _isBranchesOpening = true);
      } else if (_scrollController.offset <= 30 && _isBranchesOpening) {
        setState(() => _isBranchesOpening = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSignupClicked() async {
    setState(() {
      _isBranchesOpening = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.push(
        context,
        FadePageRoute(page: const SignupScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isBranchesOpening = false;
          });
        }
      });
    }
  }

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
                  controller: _scrollController,
                  clipBehavior: Clip.none,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 1400),
                        padding: const EdgeInsets.only(
                          top: 35,
                          bottom: 60,
                          left: 60,
                          right: 60,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 120.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Right side (Start in RTL)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            FadePageRoute(
                                              page: const MainScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'الصفحة الرئيسية',
                                          style: TextStyle(
                                            color: Color(0xFF235347),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Color(0xFF0B2B26),
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'من نحن',
                                            style: TextStyle(
                                              color: Color(0xFF0B2B26),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
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
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Left side (End in RTL)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _onSignupClicked,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(
                                            0xFF235347,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
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
                                      const SizedBox(width: 15),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            FadePageRoute(
                                              page: const LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'تسجيل الدخول',
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
                            const SizedBox(height: 50),

                            // 'تعرف على فريقنا' Title
                            const Text(
                              'تعرف على فريقنا',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B2B26),
                              ),
                            ),
                            const SizedBox(height: 50),

                            // Team Members Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTeamMemberCard(
                                  imageUrl: 'assets/images/Anoud.jpg', 
                                  name: 'عنود عبد السلام',
                                  major: 'هندسة حاسوب',
                                ),
                                const SizedBox(width: 80),
                                _buildTeamMemberCard(
                                  imageUrl: 'assets/images/eman.jpeg', 
                                  name: 'إيمان العط',
                                  major: 'هندسة حاسوب',
                                ),
                              ],
                            ),

                            const SizedBox(height: 60),

                            // Description Paragraph
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'نحن مجموعة من طلاب هندسة الحاسوب في جامعة النجاح الوطنية، وقد قمنا بتطوير هذا الموقع كمشروع تخرج بإشراف الدكتورة أسماء عفيفي. بدأت فكرتنا من ملاحظة عدم وجود تطبيق في فلسطين يجمع بين بائع الأعشاب، وخبير موثوق، وزبون يبحث عن شراء الأعشاب بسهولة مع خدمة التوصيل. لذلك قررنا تبني هذه الفكرة وتحويلها إلى موقع عملي، وتواصلنا مع عدد من بائعي الأعشاب في مدينة نابلس للاستفادة من آرائهم ومعرفة مدى تقبلهم للفكرة، بالإضافة إلى أخذ نصائحهم حول ما يجب تطويره وإضافته لضمان تقديم تجربة مفيدة وموثوقة للمستخدمين.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF235347),
                                  height: 1.8,
                                  fontWeight: FontWeight.w700,
                                ),
                                textDirection: TextDirection.rtl,
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

          // Branch Images moved ON TOP of the white box
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            left: _isBranchesOpening ? -250 : -20,
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
            right: _isBranchesOpening ? -250 : -20,
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

  Widget _buildTeamMemberCard({
    required String imageUrl,
    required String name,
    required String major,
  }) {
    return Column(
      children: [
        Container(
          width: 230,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFDAF1DE),
            border: Border.all(color: const Color(0xFF0B2B26), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 80,
                color: Color(0xFF235347),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B2B26),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          major,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF235347),
          ),
        ),
      ],
    );
  }
}
