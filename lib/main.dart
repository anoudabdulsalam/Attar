import 'package:flutter/material.dart';
//import 'welcome_screen.dart';
import 'home_customer_screen.dart';
//import 'home_expert_screen.dart';
//import 'home_shop_owner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attar App',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFDAF1DE),
        primaryColor: const Color(0xFF235347),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF235347)),
        useMaterial3: true,
      ),

      //home: const WelcomeScreen(),
      home: const HomeCustomerScreen(),
      //home: const HomeExpertScreen(),
      //home: const HomeShopOwnerScreen(),
    );
  }
}
