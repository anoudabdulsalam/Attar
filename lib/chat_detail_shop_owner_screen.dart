import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'herb_post_dialog.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';

class ChatDetailShopOwnerScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverRole;
  final String currentUserRole;
  final bool isStore;

  const ChatDetailShopOwnerScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverRole,
    required this.currentUserRole,
    required this.isStore,
  });

  @override
  State<ChatDetailShopOwnerScreen> createState() => _ChatDetailShopOwnerScreenState();
}

class _ChatDetailShopOwnerScreenState extends State<ChatDetailShopOwnerScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _messages = [];

  String? _conversationId;
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupConversation();
  }

  Future<void> _setupConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('userId');

      if (_currentUserId == null || _currentUserId!.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final conversation = await ChatService.createConversation(
        user1Id: _currentUserId!,
        user1Role: widget.currentUserRole,
        user2Id: widget.receiverId,
        user2Role: widget.receiverRole,
        chatName: widget.receiverName,
      );

      _conversationId = conversation['_id']?.toString();

      if (_conversationId != null) {
        await ChatService.markMessagesAsRead(
          conversationId: _conversationId!,
          userId: _currentUserId!,
        );

        final dbMessages = await ChatService.getMessages(_conversationId!);

        _messages = dbMessages.map<Map<String, dynamic>>((msg) {
          return {
            'type': msg['type'] ?? 'text',
            'text': msg['text'] ?? '',
            'herb': msg['herb'],
            'isMe': msg['senderId']?.toString() == _currentUserId,
            'time': _formatTime(msg['createdAt']),
          };
        }).toList();
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('CHAT LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل المحادثة: $e')),
      );
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return 'الآن';

    try {
      final date = DateTime.parse(createdAt.toString()).toLocal();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return 'الآن';
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم الحالي')),
      );
      return;
    }

    setState(() {
      _messages.add({
        'type': 'text',
        'text': text,
        'isMe': true,
        'time': 'الآن',
      });
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      if (_conversationId == null) {
        await _setupConversation();
      }

      if (_conversationId == null) return;

      await ChatService.sendMessage(
        conversationId: _conversationId!,
        senderId: _currentUserId!,
        senderRole: widget.currentUserRole,
        receiverId: widget.receiverId,
        receiverRole: widget.receiverRole,
        text: text,
      );

      await NotificationService.createNotification(
        userId: widget.receiverId,
        targetRole: widget.receiverRole,
        title: 'رسالة جديدة',
        body: 'وصلتك رسالة جديدة من ${widget.receiverName}',
        type: 3,
        senderName: widget.receiverName,
      );
    } catch (e) {
      debugPrint('SEND MESSAGE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إرسال الرسالة: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _messages.add({
          'type': 'image',
          'path': image.path,
          'isMe': true,
          'time': 'الآن',
        });
      });

      _scrollToBottom();
    }
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF163832),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF8EB69B),
              child: Icon(
                widget.isStore ? Icons.store : Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.receiverName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF163832),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginBachground1.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      const Color(0xFF163832).withOpacity(0.5),
                      const Color(0xFF163832).withOpacity(0.6),
                      Colors.white.withOpacity(0.15),
                    ],
                    stops: const [0.0, 0.3, 0.8, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد رسائل بعد',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 20,
                            ),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return _buildMessageBubble(message);
                            },
                          ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isMe = message['isMe'] ?? false;
    Widget messageContent;

    if (message['type'] == 'text') {
      messageContent = Text(
        message['text'] ?? '',
        style: TextStyle(
          color: isMe ? const Color(0xFF051F20) : const Color(0xFF163832),
          fontSize: 16,
        ),
      );
    } else if (message['type'] == 'image') {
      messageContent = ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 250,
          ),
          child: Image.network(
            message['path'],
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.error, color: Colors.red),
          ),
        ),
      );
    } else if (message['type'] == 'post') {
      final plant = Map<String, dynamic>.from(message['herb'] ?? {});

      messageContent = GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.black54,
            builder: (context) => HerbPostDialog(
              herbId: plant['id'] ?? plant['_id'] ?? '',
              imageUrl: plant['imageUrl'] ?? '',
              name: plant['name'] ?? '',
              benefits: plant['benefits'] ?? '',
              howToUse: plant['howToUse'] ?? plant['usageMethod'] ?? '',
              price: plant['price'].toString(),
              storeName: plant['storeName'] ?? 'متجر غير معروف',
              storeOwnerId: plant['storeOwnerId'],
              onSale: plant['onSale'] ?? false,
              salePrice: plant['salePrice']?.toString(),
              comments: plant['comments'] ?? [],
              isFavorite: plant['isFavorite'] ?? false,
              onFavoriteToggle: () {},
              onAddToCart: () {},
            ),
          );
        },
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF8EB69B),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((plant['imageUrl'] ?? '').toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _isNetworkImage(plant['imageUrl'].toString())
                      ? Image.network(
                          plant['imageUrl'],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.eco, size: 50),
                        )
                      : Image.asset(
                          plant['imageUrl'],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.eco, size: 50),
                        ),
                ),
              const SizedBox(height: 8),
              Text(
                'عشبة ${plant['name'] ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF163832),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                plant['benefits'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'عرض التفاصيل >>',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      messageContent = const SizedBox();
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF8EB69B) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            messageContent,
            const SizedBox(height: 5),
            Text(
              message['time'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Color(0xFF8EB69B)),
              onPressed: _pickImage,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'اكتب رسالة...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF163832),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.paperplane,
                  color: Colors.white,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
