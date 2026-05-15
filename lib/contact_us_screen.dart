import 'dart:ui';
import 'package:flutter/material.dart';
import 'page_transition.dart';
import 'main_screen.dart';
import 'about_us_screen.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/contact_service.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  bool _isBranchesOpening = false;
  bool isLoading = false;
  late ScrollController _scrollController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

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
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSignupClicked() async {
    setState(() {
      _isBranchesOpening = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.push(context, FadePageRoute(page: const SignupScreen())).then((
        _,
      ) {
        if (mounted) {
          setState(() {
            _isBranchesOpening = false;
          });
        }
      });
    }
  }

  Future<void> sendContactMessage() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        subjectController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة جميع الحقول'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await ContactService.sendMessage(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال الرسالة بنجاح'),
        ),
      );

      nameController.clear();
      emailController.clear();
      subjectController.clear();
      messageController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الإرسال: $e'),
        ),
      );
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 120.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
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
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
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
                                            'تواصل معنا',
                                            style: TextStyle(
                                              color: Color(0xFF0B2B26),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.eco,
                                        size: 100,
                                        color: Color(0xFF235347),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              'تواصل معنا',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B2B26),
                              ),
                            ),
                            const SizedBox(height: 50),
                            Wrap(
                              spacing: 50,
                              runSpacing: 50,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: [
                                SizedBox(
                                  width: 400,
                                  child: Column(
                                    children: [
                                      _HoverInfoCard(
                                        icon: Icons.phone_android,
                                        title: 'رقم الهاتف',
                                        hoverContent: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              'عنود: 00972599579679',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0B2B26),
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'إيمان: 00970594706065',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0B2B26),
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      _HoverInfoCard(
                                        icon: Icons.link,
                                        title: 'LinkedIn',
                                        hoverContent: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'عنود عبد السلام',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0B2B26),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            InkWell(
                                              onTap: () async {
                                                final Uri url = Uri.parse(
                                                  'https://linkedin.com/in/anoud-abdusalam-065aa1197/',
                                                );
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(
                                                    url,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'linkedin.com/in/anoud-abdusalam-065aa1197/',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blueAccent,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                                textDirection:
                                                    TextDirection.ltr,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text(
                                              'ايمان العط',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0B2B26),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            InkWell(
                                              onTap: () async {
                                                final Uri url = Uri.parse(
                                                  'https://linkedin.com/in/iman-utt-316b02306/',
                                                );
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(
                                                    url,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'linkedin.com/in/iman-utt-316b02306/',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blueAccent,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                                textDirection:
                                                    TextDirection.ltr,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 600,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      const Text(
                                        'إذا كان لديك أي ملاحظات أو واجهت أي مشكلة أثناء استخدامك لموقعنا، أو حتى لديك نصائح واقتراحات تساعدنا على التطوير، يسعدنا تواصلك معنا في أي وقت. رأيك يهمنا ويساهم في تحسين تجربتك وتقديم خدمة أفضل للجميع، فلا تتردد في إرسال شكواك أو ملاحظاتك عبر وسائل التواصل المتاحة.',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          height: 1.8,
                                          color: Color(0xFF235347),
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      const SizedBox(height: 30),
                                      _buildTextField(
                                        label: 'الاسم',
                                        controller: nameController,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'البريد الإلكتروني',
                                        controller: emailController,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'الموضوع',
                                        controller: subjectController,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'الرسالة',
                                        controller: messageController,
                                        maxLines: 5,
                                      ),
                                      const SizedBox(height: 30),
                                      ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : sendContactMessage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0B2B26,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          elevation: 5,
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : const Text(
                                                'إرسال الآن',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ],
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        alignLabelWithHint: maxLines > 1,
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF235347),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF0B2B26), width: 2),
        ),
      ),
    );
  }
}

class _HoverInfoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget hoverContent;

  const _HoverInfoCard({
    required this.icon,
    required this.title,
    required this.hoverContent,
  });

  @override
  State<_HoverInfoCard> createState() => _HoverInfoCardState();
}

class _HoverInfoCardState extends State<_HoverInfoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xFFDAF1DE)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 15 : 5,
              spreadRadius: _isHovered ? 2 : 0,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _isHovered
              ? Center(
                  key: const ValueKey('hovered'),
                  child: widget.hoverContent,
                )
              : Center(
                  key: const ValueKey('normal'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 50,
                        color: const Color(0xFF0B2B26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF235347),
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