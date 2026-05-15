import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'herb_post_dialog.dart';

class ChatDetailCustomerScreen extends StatefulWidget {
  final String chatName;
  final bool isStore;

  const ChatDetailCustomerScreen({
    super.key,
    required this.chatName,
    required this.isStore,
  });

  // Global mock chat history storage
  static Map<String, List<Map<String, dynamic>>> chatHistory = {};

  // Method to mock sharing a post
  static void addSharedPost(String expertName, Map<String, dynamic> plant) {
    if (!chatHistory.containsKey(expertName)) {
      chatHistory[expertName] = [
        {
          'type': 'text',
          'text': 'أهلاً بك! كيف يمكنني مساعدتك؟',
          'isMe': false,
          'time': '10:05 ص',
        },
      ];
    }
    chatHistory[expertName]!.add({
      'type': 'post',
      'herb': plant,
      'isMe': true,
      'time': 'الآن',
    });
  }

  @override
  State<ChatDetailCustomerScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailCustomerScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Initialize dummy data for this chat if empty
    if (!ChatDetailCustomerScreen.chatHistory.containsKey(widget.chatName)) {
      ChatDetailCustomerScreen.chatHistory[widget.chatName] = [
        {
          'type': 'text',
          'text': 'مرحباً، هل يمكنني الاستفسار عن أحد منتجاتكم؟',
          'isMe': true,
          'time': '10:00 ص',
        },
        {
          'type': 'text',
          'text': 'أهلاً بك! بالتأكيد، تفضل كيف يمكنني مساعدتك؟',
          'isMe': false,
          'time': '10:05 ص',
        },
      ];
    }
    // Load local reference
    _messages = ChatDetailCustomerScreen.chatHistory[widget.chatName]!;

    // Scroll to bottom initial wait
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'type': 'text',
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'الآن',
      });
    });
    _messageController.clear();
    _scrollToBottom();

    // Mock reply
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'type': 'text',
            'text': 'شكراً لتواصلك، سنقوم بالرد عليك في أقرب وقت ممكن.',
            'isMe': false,
            'time': 'الآن',
          });
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _messages.add({
          'type': 'image',
          'path': image.path, // Works with Image.network across Web
          'isMe': true,
          'time': 'الآن',
        });
      });
      _scrollToBottom();
    }
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
                widget.chatName,
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
                child: ListView.builder(
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
    bool isMe = message['isMe'];
    Widget messageContent;

    if (message['type'] == 'text') {
      messageContent = Text(
        message['text'],
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
            errorBuilder: (_, _, _) => const Icon(Icons.error, color: Colors.red),
          ),
        ),
      );
    } else if (message['type'] == 'post') {
      final plant = message['herb'];
      messageContent = GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.black54,
            builder: (context) => HerbPostDialog(
              imageUrl: plant['imageUrl'],
              name: plant['name'],
              benefits: plant['benefits'],
              howToUse: plant['howToUse'],
              price: plant['price'],
              isFavorite: plant['isFavorite'] ?? false,
              onFavoriteToggle: () {},
              onAddToCart: () {},
              onShareTap: () {},
            ),
          );
        },
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF8EB69B), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  plant['imageUrl'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.eco, size: 50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'عشبة ${plant['name']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF163832),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                plant['benefits'],
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
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            messageContent,
            const SizedBox(height: 5),
            Text(
              message['time'],
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
