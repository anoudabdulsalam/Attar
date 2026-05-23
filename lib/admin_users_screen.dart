import 'dart:ui';
import 'package:flutter/material.dart';
import 'services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool isLoading = true;
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
      });
      final data = await AdminService.getAllUsers();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في جلب المستخدمين: $e')));
      }
    }
  }

  Future<void> _deleteUser(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: const Text('هل أنت متأكد من حذف هذا المستخدم نهائياً؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await AdminService.deleteUser(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حذف المستخدم بنجاح')));
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ أثناء الحذف: $e')));
      }
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'customer':
        return 'زبون';
      case 'store_owner':
        return 'صاحب متجر';
      case 'herbal_expert':
        return 'خبير أعشاب';
      default:
        return role;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'customer':
        return Icons.person;
      case 'store_owner':
        return Icons.store;
      case 'herbal_expert':
        return Icons.medical_services;
      default:
        return Icons.person_outline;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'customer':
        return Colors.blueGrey;
      case 'store_owner':
        return Colors.orangeAccent;
      case 'herbal_expert':
        return const Color(0xFF235347);
      default:
        return Colors.grey;
    }
  }

  String _formatJoinDate(dynamic createdAt) {
    if (createdAt == null) return 'غير معروف';

    try {
      final date = DateTime.parse(createdAt.toString()).toLocal();
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'غير معروف';
    }
  }

  String _membershipDuration(dynamic createdAt) {
    if (createdAt == null) return 'غير معروف';

    try {
      final joinDate = DateTime.parse(createdAt.toString()).toLocal();
      final now = DateTime.now();

      int years = now.year - joinDate.year;
      int months = now.month - joinDate.month;

      if (now.day < joinDate.day) {
        months--;
      }

      if (months < 0) {
        years--;
        months += 12;
      }

      if (years <= 0 && months <= 0) {
        return 'انضم حديثاً';
      }

      if (years > 0 && months > 0) {
        return '$years سنة و $months شهر';
      }

      if (years > 0) {
        return '$years سنة';
      }

      return '$months شهر';
    } catch (_) {
      return 'غير معروف';
    }
  }

  String _getUserDetails(Map<String, dynamic> user) {
    final role = user['role'];
    if (role == 'customer') {
      return 'العمر: ${user['age'] ?? 'غير محدد'}';
    } else if (role == 'store_owner') {
      return 'المالك: ${user['ownerName'] ?? '-'}\nالمتجر: ${user['storeName'] ?? '-'}\nالموقع: ${user['storeLocation'] ?? '-'}';
    } else if (role == 'herbal_expert') {
      return 'الخبرة: ${user['yearsOfExperience'] ?? '0'} سنوات\nالشهادة: ${user['certificateUrl'] != null && user['certificateUrl'].toString().isNotEmpty ? "مرفقة" : "لا يوجد"}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    color: Colors.white.withOpacity(0.2),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: _getRoleColor(user['role']),
                                child: Icon(
                                  _getRoleIcon(user['role']),
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user['fullName'] ?? user['email'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(user['role']).withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _getRoleName(user['role']),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      user['email'],
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'تاريخ الانضمام: ${_formatJoinDate(user['createdAt'])}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'مدة الانضمام: ${_membershipDuration(user['createdAt'])}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const Divider(color: Colors.white30),
                          Text(
                            _getUserDetails(user),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () => _deleteUser(user['_id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('حذف الحساب'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
