import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/contact_service.dart';

class ContactUsCustomerScreen extends StatefulWidget {
  const ContactUsCustomerScreen({super.key});

  @override
  State<ContactUsCustomerScreen> createState() =>
      _ContactUsCustomerScreenState();
}

class _ContactUsCustomerScreenState extends State<ContactUsCustomerScreen> {
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendContactMessage() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        subjectController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى تعبئة جميع الحقول')));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال الرسالة بنجاح')));

      nameController.clear();
      emailController.clear();
      subjectController.clear();
      messageController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الإرسال: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('ContactUsCustomerScreen'),
      children: [
        _buildTopAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 10.0,
              bottom: 90.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'تواصل معنا',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    SizedBox(
                      width: 350,
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
                          const SizedBox(height: 20),
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
                                        mode: LaunchMode.externalApplication,
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
                                      decoration: TextDecoration.underline,
                                    ),
                                    textDirection: TextDirection.ltr,
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
                                        mode: LaunchMode.externalApplication,
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
                                      decoration: TextDecoration.underline,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 500,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          textDirection: TextDirection.rtl,
                          children: [
                            const Text(
                              'إذا كان لديك أي ملاحظات أو واجهت أي مشكلة أثناء استخدامك لموقعنا، أو حتى لديك نصائح واقتراحات تساعدنا على التطوير، يسعدنا تواصلك معنا في أي وقت.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.8,
                                color: Color(0xFF235347),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 25),
                            _buildTextField(
                              label: 'الاسم',
                              controller: nameController,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              label: 'البريد الإلكتروني',
                              controller: emailController,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              label: 'الموضوع',
                              controller: subjectController,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              label: 'الرسالة',
                              controller: messageController,
                              maxLines: 5,
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: isLoading ? null : sendContactMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B2B26),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'إرسال الآن',
                                      style: TextStyle(
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
                  ],
                ),
              ],
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'تواصل معنا',
                style: TextStyle(
                  fontSize: 30,
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
        fillColor: Colors.white,
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
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(25),
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
