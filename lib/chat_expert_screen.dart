import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_detail_expert_screen.dart';
import 'services/chat_service.dart';
import 'services/user_service.dart';

class ChatExpertScreen extends StatefulWidget {
  final VoidCallback? onUnreadChanged;

  const ChatExpertScreen({super.key, this.onUnreadChanged});

  @override
  State<ChatExpertScreen> createState() => _ChatExpertScreenState();
}

class _ChatExpertScreenState extends State<ChatExpertScreen> {
  String searchQuery = '';
  bool _isLoading = true;
  String? _currentUserId;
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('userId') ?? '';

      if (_currentUserId!.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final data = await ChatService.getConversations(_currentUserId!);
      final enriched = <Map<String, dynamic>>[];

      for (final item in data) {
        final conversation = Map<String, dynamic>.from(item as Map);
        final otherId = _getOtherUserId(conversation);
        final otherRole = _getOtherUserRole(conversation);

        String otherName = conversation['chatName']?.toString() ?? 'مستخدم';

        if (otherId.isNotEmpty) {
          try {
            final user = await UserService.getUserById(otherId);
            otherName = _displayUserName(user);
          } catch (_) {}
        }

        conversation['otherUserId'] = otherId;
        conversation['otherUserRole'] = otherRole;
        conversation['otherUserName'] = otherName;

        enriched.add(conversation);
      }

      if (!mounted) return;

      setState(() {
        _conversations = enriched;
        _isLoading = false;
      });

      widget.onUnreadChanged?.call();
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل المحادثات: $e')),
      );
    }
  }

  String _displayUserName(Map<String, dynamic> user) {
    return (user['fullName'] ??
            user['ownerName'] ??
            user['storeName'] ??
            user['email'] ??
            'مستخدم')
        .toString();
  }

  String _getOtherUserId(Map<String, dynamic> conversation) {
    final participants = conversation['participants'] as List? ?? [];

    final other = participants.firstWhere(
      (p) => p['userId'].toString() != _currentUserId,
      orElse: () => {},
    );

    return other['userId']?.toString() ?? '';
  }

  String _getOtherUserRole(Map<String, dynamic> conversation) {
    final participants = conversation['participants'] as List? ?? [];

    final other = participants.firstWhere(
      (p) => p['userId'].toString() != _currentUserId,
      orElse: () => {},
    );

    return other['role']?.toString() ?? 'customer';
  }

  String _roleName(String role) {
    if (role == 'store_owner') return 'صاحب متجر';
    if (role == 'herbal_expert') return 'خبير';
    return 'زبون';
  }

  String _formatTime(dynamic value) {
    if (value == null) return '';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      final now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        final hour = date.hour.toString().padLeft(2, '0');
        final minute = date.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }

      return '${date.year}/${date.month}/${date.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredConversations = _conversations.where((conversation) {
      final name = (conversation['otherUserName'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      key: const ValueKey('ChatScreen'),
      children: [
        _buildHeader(context, 'المحادثات'),
        _buildSearchBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredConversations.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد محادثات حالياً',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 90),
                        itemCount: filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = filteredConversations[index];
                          return _buildChatTile(conversation);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() => searchQuery = value);
          },
          decoration: const InputDecoration(
            hintText: 'ابحث عن مستخدم...',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Color(0xFF163832)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.0),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> conversation) {
    final receiverId = conversation['otherUserId']?.toString() ?? '';
    final receiverRole = conversation['otherUserRole']?.toString() ?? 'customer';
    final receiverName =
        conversation['otherUserName']?.toString() ?? 'مستخدم غير معروف';

    final unreadCount = (conversation['unreadCount'] as num?)?.toInt() ?? 0;
    final hasUnread = unreadCount > 0;
    final isStore = receiverRole == 'store_owner';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailExpertScreen(
                receiverId: receiverId,
                receiverName: receiverName,
                receiverRole: receiverRole,
                currentUserRole: 'herbal_expert',
                isStore: isStore,
              ),
            ),
          );

          await _loadConversations();
          widget.onUnreadChanged?.call();
        },
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF8EB69B),
          child: Icon(
            isStore ? Icons.store : Icons.person,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          '$receiverName - ${_roleName(receiverRole)}',
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF163832),
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            conversation['lastMessage']?.toString() ?? '',
            style: TextStyle(
              color: hasUnread ? const Color(0xFF163832) : Colors.grey[700],
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(conversation['lastMessageAt']),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (hasUnread) ...[
                const SizedBox(height: 5),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF163832),
            ),
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
}
