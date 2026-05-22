import 'dart:ui';
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';
import 'page_transition.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isBranchesOpening = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isBranchesOpening) {
        setState(() => _isBranchesOpening = true);
      } else if (_scrollController.offset <= 50 && _isBranchesOpening) {
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
    // Wait for animation to finish
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.push(
        context,
        FadePageRoute(page: const SignupScreen()),
      ).then((_) {
        // Reset branches when returning from SignupScreen
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
                                            'الصفحة الرئيسية',
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
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            FadePageRoute(page: const ContactUsScreen()),
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
                            const SizedBox(height: 30),

                            // Logo
                            Image.asset(
                              'assets/images/finalLogo.png',
                              height: 250,
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
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: const Text(
                                'عطّار هو منصة متكاملة تتيح لك التسجيل كزبون، أو مالك متجر لبيع الأعشاب، أو خبير أعشاب لتقديم النصائح ومشاركة المعرفة. يوفّر التطبيق عرضًا واضحًا للأعشاب المتاحة مع معلومات تفصيلية عن كل عشبة تشمل صورتها، فوائدها، طريقة استخدامها، وسعرها، مع إمكانية طلبها بسهولة. كما يمكنك الدفع عبر بطاقة Visa أو عند الاستلام، والتواصل مباشرة مع مالك المتجر أو الخبير من خلال المحادثة. ويتيح لك التطبيق أيضًا مشاركة تجربتك من خلال إضافة تقييم و مشاركتنا رايك لكل عشبة قمت بشرائها، مما يساعد الآخرين على اختيار الأفضل.',
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
                            const SizedBox(height: 50),

                            // Thin Divider with Text
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: const Color(
                                      0xFF235347,
                                    ).withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    ' اعشاب متوفرة على موقعنا',
                                    style: TextStyle(
                                      color: Color(0xFF235347),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: const Color(
                                      0xFF235347,
                                    ).withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // Herbs Grid Background
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: const Color(0xFF235347),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                clipBehavior: Clip.none,
                                child: Row(
                                  children: const [
                                    HerbCard(
                                      imageUrl: 'assets/images/Aloe Vera.png',
                                      name: 'الألوفيرا',
                                      benefits: 'مفيد للبشرة والهضم',
                                      howToUse: 'يستخدم جل',
                                      price: ' ',
                                    ),
                                    SizedBox(width: 30),
                                    HerbCard(
                                      imageUrl: 'assets/images/Anise.png',
                                      name: 'اليانسون',
                                      benefits: 'مفيد للسعال والهضم',
                                      howToUse: 'يشرب مغلي',
                                      price: ' ',
                                    ),
                                    SizedBox(width: 30),
                                    HerbCard(
                                      imageUrl: 'assets/images/Basil.png',
                                      name: 'الريحان',
                                      benefits: 'مضاد للالتهاب',
                                      howToUse: 'يستخدم في الطعام أو كشاي',
                                      price: ' ',
                                    ),
                                    SizedBox(width: 30),
                                    HerbCard(
                                      imageUrl: 'assets/images/Bay Leaf.png',
                                      name: 'ورق الغار',
                                      benefits: 'مفيد للهضم',
                                      howToUse: 'يستخدم في الطبخ',
                                      price: ' ',
                                    ),
                                    SizedBox(width: 30),
                                    HerbCard(
                                      imageUrl: 'assets/images/Black Seed.png',
                                      name: 'حبة البركة',
                                      benefits: 'تقوي المناعة',
                                      howToUse: 'تؤكل أو تستخدم بالزيت',
                                      price: ' ',
                                    ),
                                    SizedBox(width: 30),
                                    HerbCard(
                                      imageUrl: 'assets/images/Cardamom.png',
                                      name: 'الهيل',
                                      benefits: 'يحسن الهضم',
                                      howToUse: 'يضاف للمشروبات',
                                      price: ' ',
                                    ),
                                    SizedBox(width: 30),
                                    HerbCard(
                                      imageUrl: 'assets/images/Chamomile.png',
                                      name: 'البابونج',
                                      benefits: 'مهدئ للأعصاب ويساعد على النوم',
                                      howToUse: 'يشرب كشاي',
                                      price: ' ',
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
}

class HerbCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String benefits;
  final String howToUse;
  final String price;

  const HerbCard({
    required this.imageUrl,
    required this.name,
    required this.benefits,
    required this.howToUse,
    required this.price,
    super.key,
  });

  @override
  State<HerbCard> createState() => _HerbCardState();
}

class _HerbCardState extends State<HerbCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 250,
          height: 320,
          decoration: BoxDecoration(
            color: const Color(0xFFDAF1DE),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 5),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Base Card Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(widget.imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 20,
                      left: 15,
                      right: 15,
                    ),
                    color: const Color(0xFFDAF1DE),
                    child: Column(
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF235347),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.price,
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Animated Hover Overlay (Slide up from bottom)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: _isHovered ? 0 : -220, // Slide up using negative bottom
                left: 0,
                right: 0,
                height: 220,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.3, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    textDirection: TextDirection.rtl,
                    children: [
                      const Text(
                        'فوائدها:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.benefits,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'الاستخدام:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.howToUse,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
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
