import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HerbPostDialog extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String benefits;
  final String howToUse;
  final String price;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onShareTap;

  const HerbPostDialog({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.benefits,
    required this.howToUse,
    required this.price,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onShareTap,
  });

  @override
  State<HerbPostDialog> createState() => _HerbPostDialogState();
}

class _HerbPostDialogState extends State<HerbPostDialog> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = ['عشبة ممتازة جداً واستفدت منها كتير!'];
  late bool _isFavoriteLocal;

  @override
  void initState() {
    super.initState();
    _isFavoriteLocal = widget.isFavorite;
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, _commentController.text.trim());
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildHerbImage() {
    if (_isNetworkImage(widget.imageUrl)) {
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(
          Icons.eco,
          size: 100,
          color: Color(0xFF8EB69B),
        ),
      );
    }

    return Image.asset(
      widget.imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(
        Icons.eco,
        size: 100,
        color: Color(0xFF8EB69B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 600,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Container(
                color: const Color(0xFFDAF1DE),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF163832)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'منشور العشبة',
                        style: TextStyle(
                          color: Color(0xFF163832),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFF8EB69B),
                              child: Icon(Icons.store, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'متجر الطبيعة والأعشاب',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF051F20),
                                  ),
                                ),
                                Text(
                                  'منذ ساعتين',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'عشبة ${widget.name}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF163832),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'الاستخدام: ${widget.howToUse}\nالفوائد: ${widget.benefits}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 250,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F5F1),
                            ),
                            child: Hero(
                              tag: 'herb_image_${widget.name}',
                              child: _buildHerbImage(),
                            ),
                          ),
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF163832).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isFavoriteLocal = !_isFavoriteLocal;
                                });
                                widget.onFavoriteToggle();
                              },
                              icon: Icon(
                                _isFavoriteLocal
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavoriteLocal
                                    ? Colors.red
                                    : Colors.grey[700],
                              ),
                              label: Text(
                                'إعجاب',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                              },
                              icon: Icon(
                                Icons.comment_outlined,
                                color: Colors.grey[700],
                              ),
                              label: Text(
                                'تعليق',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: widget.onShareTap,
                              icon: Icon(
                                CupertinoIcons.paperplane,
                                color: Colors.grey[700],
                                size: 24,
                              ),
                              label: Text(
                                'مشاركة',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5.0,
                        ),
                        child: const Text(
                          'التعليقات',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF163832),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFDAF1DE),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF163832),
                                  size: 20,
                                ),
                              ),
                              title: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'مستخدم',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _comments[index],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFDAF1DE),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF163832),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'اكتب تعليقاً...',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _addComment(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.paperplane,
                              color: Color(0xFF8EB69B),
                              size: 24,
                            ),
                            onPressed: _addComment,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8EB69B),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            widget.onAddToCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إضافته للسلة بنجاح!'),
                                backgroundColor: Color(0xFF235347),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'إضافة للسلة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}