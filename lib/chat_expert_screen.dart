import 'package:flutter/material.dart';
import 'chat_detail_expert_screen.dart';

class ChatExpertScreen extends StatefulWidget {
  const ChatExpertScreen({super.key});

  @override
  State<ChatExpertScreen> createState() => _ChatExpertScreenState();
}

class _ChatExpertScreenState extends State<ChatExpertScreen> {
  String searchQuery = '';

  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'د. أحمد قاسم',
      'lastMessage': 'أهلاً بك، كيف يمكنني مساعدتك؟',
      'time': '10:30 ص',
      'unread': 2,
      'isStore': false,
    },
    {
      'id': '2',
      'name': 'صيدلية الطبيعة',
      'lastMessage': 'تم استلام طلبك بنجاح',
      'time': 'الأمس',
      'unread': 0,
      'isStore': true,
    },
    {
      'id': '3',
      'name': 'مزرعة الريحان',
      'lastMessage': 'نعم، هذا المنتج متوفر حالياً',
      'time': 'الإثنين',
      'unread': 0,
      'isStore': true,
    },
    {
      'id': '4',
      'name': 'د. منى علي',
      'lastMessage': 'أنصحك باستخدام البابونج قبل النوم',
      'time': 'الأسبوع الماضي',
      'unread': 1,
      'isStore': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredChats = _chats
        .where(
          (chat) =>
              chat['name'].toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Column(
      key: const ValueKey('ChatScreen'),
      children: [
        _buildHeader(context, 'المحادثات'),
        _buildSearchBar(),
        Expanded(
          child: filteredChats.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد محادثات مطابقة',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 90),
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return _buildChatTile(chat);
                  },
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'ابحث عن خبير أو متجر...',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Color(0xFF163832)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.0),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    bool hasUnread = chat['unread'] > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailExpertScreen(
                chatName: chat['name'],
                isStore: chat['isStore'],
              ),
            ),
          );
        },
        leading: SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF8EB69B),
                child: Icon(
                  chat['isStore'] ? Icons.store : Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              if (chat['isStore'])
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF163832),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          chat['name'],
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF163832),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            chat['lastMessage'],
            style: TextStyle(
              color: hasUnread ? const Color(0xFF163832) : Colors.grey[700],
              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat['time'],
                style: TextStyle(
                  color: hasUnread ? const Color(0xFF235347) : Colors.grey,
                  fontSize: 12,
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (hasUnread) ...[
                const SizedBox(height: 5),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    '${chat['unread']}',
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
