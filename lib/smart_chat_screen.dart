import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'services/ai_chat_service.dart';

class SmartChatScreen extends StatefulWidget {
  const SmartChatScreen({super.key});

  @override
  State<SmartChatScreen> createState() => _SmartChatScreenState();
}

class _SmartChatScreenState extends State<SmartChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'مرحباً! أنا Smart Chat. اسألني عن الأعشاب أو الاستخدامات الطبيعية.',
      'isMe': false,
      'time': 'الآن',
    },
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': 'الآن',
      });
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final reply = await AiChatService.sendMessage(text);

      if (!mounted) return;

      setState(() {
        _messages.add({
          'text': reply,
          'isMe': false,
          'time': 'الآن',
        });
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'text': 'حدث خطأ أثناء الاتصال بالمساعد الذكي.',
          'isMe': false,
          'time': 'الآن',
        });
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF163832),
      appBar: AppBar(
        backgroundColor: const Color(0xFF163832),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF8EB69B),
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text(
              'المساعد الذكي',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: const Color(0xFF163832).withOpacity(0.45),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _typingBubble();
                    }
                    return _messageBubble(_messages[index]);
                  },
                ),
              ),
              _inputBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] == true;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
        ),
        child: Text(
          message['text'].toString(),
          style: const TextStyle(fontSize: 16, color: Color(0xFF051F20)),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Smart Chat يكتب...',
          style: TextStyle(
            color: Color(0xFF163832),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF163832),
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