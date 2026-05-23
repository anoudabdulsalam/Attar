import 'package:flutter/material.dart';
import 'animated_background.dart';
import 'admin_users_screen.dart';
import 'admin_stats_screen.dart';
import 'admin_messages_screen.dart';
import 'login_screen.dart';
import 'page_transition.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      FadePageRoute(page: const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        title: const Text(
          'لوحة تحكم المسؤول',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'المستخدمين'),
            Tab(icon: Icon(Icons.bar_chart), text: 'إحصائيات المتاجر'),
            Tab(icon: Icon(Icons.message), text: 'رسائل المستخدمين'),
          ],
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          TabBarView(
            controller: _tabController,
            children: const [
              AdminUsersScreen(),
              AdminStatsScreen(),
              AdminMessagesScreen(),
            ],
          ),
        ],
      ),
    );
  }
}
