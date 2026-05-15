import 'package:flutter/material.dart';

class AboutUsHomeScreen extends StatelessWidget {
  const AboutUsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('AboutUsScreen'),
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
                  'تعرف على فريقنا',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTeamMemberCard(
                        imageUrl: 'assets/images/Anoud.jpg',
                        name: 'عنود عبد السلام',
                        major: 'هندسة حاسوب',
                      ),
                      const SizedBox(width: 30),
                      _buildTeamMemberCard(
                        imageUrl: 'assets/images/Eman.jpg',
                        name: 'إيمان العط',
                        major: 'هندسة حاسوب',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAF1DE),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'نحن مجموعة من طلاب هندسة الحاسوب في جامعة النجاح الوطنية، وقد قمنا بتطوير هذا الموقع كمشروع تخرج بإشراف الدكتورة أسماء عفيفي. بدأت فكرتنا من ملاحظة عدم وجود تطبيق في فلسطين يجمع بين بائع الأعشاب، وخبير موثوق، وزبون يبحث عن شراء الأعشاب بسهولة مع خدمة التوصيل. لذلك قررنا تبني هذه الفكرة وتحويلها إلى موقع عملي، وتواصلنا مع عدد من بائعي الأعشاب في مدينة نابلس للاستفادة من آرائهم ومعرفة مدى تقبلهم للفكرة، بالإضافة إلى أخذ نصائحهم حول ما يجب تطويره وإضافته لضمان تقديم تجربة مفيدة وموثوقة للمستخدمين.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF163832),
                      height: 1.8,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
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
                'من نحن',
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

  Widget _buildTeamMemberCard({
    required String imageUrl,
    required String name,
    required String major,
  }) {
    return Column(
      children: [
        Container(
          width: 180,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFDAF1DE),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 60, color: Color(0xFF235347)),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          major,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
