import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/herb_service.dart';
import 'services/user_service.dart';
import 'widgets/store_dialog.dart';
import 'models/herb_model.dart';

class HerbPostDialog extends StatefulWidget {
  final String herbId;
  final String imageUrl;
  final String name;
  final String benefits;
  final String howToUse;
  final String price;
  final String storeName;
  final String? storeOwnerId;
  final bool onSale;
  final String? salePrice;
  final List<dynamic> comments;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;

  const HerbPostDialog({
    super.key,
    required this.herbId,
    required this.imageUrl,
    required this.name,
    required this.benefits,
    required this.howToUse,
    required this.price,
    required this.storeName,
    this.storeOwnerId,
    required this.onSale,
    this.salePrice,
    required this.comments,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  State<HerbPostDialog> createState() => _HerbPostDialogState();
}

class _HerbPostDialogState extends State<HerbPostDialog> {
  final TextEditingController _commentController = TextEditingController();
  late List<dynamic> _comments;
  late bool _isFavoriteLocal;

  String? _currentUserId;
  String _currentUserName = 'مستخدم';
  String _currentUserRole = 'customer';

  @override
  void initState() {
    super.initState();
    _comments = List<dynamic>.from(widget.comments);
    _isFavoriteLocal = widget.isFavorite;
    _loadCurrentUser();
    _fetchLatestHerbData();
  }

  Future<void> _fetchLatestHerbData() async {
    try {
      final herb = await HerbService.getHerbById(widget.herbId);
      if (!mounted) return;
      setState(() {
        _comments = herb['comments'] ?? [];
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');

    if (_currentUserId == null) return;

    final user = await UserService.getUserById(_currentUserId!);

    if (!mounted) return;

    setState(() {
      _currentUserRole = user['role'] ?? 'customer';
      _currentUserName =
          user['fullName'] ??
          user['ownerName'] ??
          user['storeName'] ??
          user['email'] ??
          'مستخدم';
    });
  }

  String _roleText(String role) {
    if (role == 'store_owner') return 'صاحب متجر';
    if (role == 'herbal_expert') return 'خبير أعشاب';
    return 'زبون';
  }

  String _formatPostTime() {
    try {
      final herbId = widget.herbId;

      if (herbId.length < 8) {
        return 'منذ قليل';
      }

      final timestampHex = herbId.substring(0, 8);

      final timestamp = int.parse(timestampHex, radix: 16);

      final postDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

      final now = DateTime.now();

      final diff = now.difference(postDate);

      if (diff.inMinutes < 1) {
        return 'الآن';
      }

      if (diff.inHours < 24 && now.day == postDate.day) {
        final hour = postDate.hour > 12 ? postDate.hour - 12 : postDate.hour;

        final minute = postDate.minute.toString().padLeft(2, '0');

        final period = postDate.hour >= 12 ? 'م' : 'ص';

        return '$hour:$minute $period';
      }

      if (diff.inDays == 1) {
        return 'البارحة';
      }

      return '${postDate.year}/${postDate.month}/${postDate.day}';
    } catch (_) {
      return 'منذ قليل';
    }
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();

    if (text.isEmpty || _currentUserId == null) return;

    try {
      final updatedHerb = await HerbService.addComment(
        herbId: widget.herbId,
        userId: _currentUserId!,
        userName: _currentUserName,
        userRole: _currentUserRole,
        text: text,
      );

      if (!mounted) return;

      setState(() {
        _comments = updatedHerb['comments'] ?? [];
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل حفظ التعليق: $e')));
    }
  }

  Future<void> _showShareDialog() async {
    try {
      final allUsers = await UserService.getAllUsers();
      final users = allUsers.where((user) {
        if (_currentUserRole == 'customer' && user['role'] == 'customer') {
          return false;
        }
        return true;
      }).toList();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: const Color(0xFFDAF1DE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إرسال المنشور إلى:',
                    style: TextStyle(
                      color: Color(0xFF163832),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مستخدم...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        final name =
                            user['fullName'] ??
                            user['ownerName'] ??
                            user['storeName'] ??
                            user['email'] ??
                            'مستخدم';

                        final role = user['role'] ?? 'customer';

                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF8EB69B),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            '$name - ${_roleText(role)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFF163832),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              CupertinoIcons.paperplane,
                              color: Color(0xFF235347),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم إرسال المنشور إلى $name'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحميل المستخدمين: $e')));
    }
  }

  Future<void> _handleUserTap(String? userId, String? role) async {
    if (userId == null || role == null) return;

    try {
      if (role == 'store_owner') {
        final user = await UserService.getUserById(userId);
        final herbsData = await HerbService.getHerbsByOwnerId(userId);
        final herbs = herbsData.map((h) => HerbModel.fromJson(h)).toList();

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => StoreDialog(store: user, herbs: herbs),
        );
      } else if (role == 'herbal_expert') {
        final user = await UserService.getUserById(userId);

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: const Color(0xFFDAF1DE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 600,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF163832),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          user['fullName'] ?? 'خبير أعشاب',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF163832),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _infoRow(
                          Icons.email,
                          'الإيميل:',
                          user['email'] ?? 'غير متوفر',
                        ),
                        _infoRow(
                          Icons.work,
                          'سنوات الخبرة:',
                          '${user['yearsOfExperience'] ?? 'غير متوفر'}',
                        ),
                        _infoRow(
                          Icons.description,
                          'الشهادة:',
                          user['certificateUrl'] ?? 'لا يوجد رابط',
                          isLink: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8EB69B),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'إغلاق',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحميل البيانات: $e')));
    }
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF163832), size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF163832),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isLink ? Colors.blue : Colors.black87,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(String commentId, List<dynamic>? likes) async {
    if (_currentUserId == null) return;

    try {
      final updatedHerb = await HerbService.likeComment(
        herbId: widget.herbId,
        commentId: commentId,
        userId: _currentUserId!,
      );

      if (!mounted) return;

      setState(() {
        _comments = updatedHerb['comments'] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الإعجاب: $e')));
    }
  }

  Future<void> _showReplyDialog(String commentId) async {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رد على التعليق', textAlign: TextAlign.right),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'اكتب ردك هنا...'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (replyController.text.trim().isEmpty || _currentUserId == null)
                return;

              Navigator.pop(context);

              try {
                final updatedHerb = await HerbService.replyToComment(
                  herbId: widget.herbId,
                  commentId: commentId,
                  userId: _currentUserId!,
                  userName: _currentUserName,
                  userRole: _currentUserRole,
                  text: replyController.text.trim(),
                );

                if (!mounted) return;

                setState(() {
                  _comments = updatedHerb['comments'] ?? [];
                });
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('فشل إضافة الرد: $e')));
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  Widget _buildHerbImage() {
    if (_isNetworkImage(widget.imageUrl)) {
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.eco, size: 100, color: Color(0xFF8EB69B)),
      );
    }

    return Image.asset(
      widget.imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.eco, size: 100, color: Color(0xFF8EB69B)),
    );
  }

  Widget _buildPriceBadge() {
    if (widget.onSale &&
        widget.salePrice != null &&
        widget.salePrice!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF163832).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              widget.price,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.salePrice!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'عرض',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              children: [
                                InkWell(
                                  onTap: () => _handleUserTap(
                                    widget.storeOwnerId,
                                    'store_owner',
                                  ),
                                  child: Text(
                                    widget.storeName.isEmpty
                                        ? 'متجر غير معروف'
                                        : widget.storeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF235347),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatPostTime(),
                                  style: const TextStyle(
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
                            if (widget.onSale) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'يوجد عرض خاص على هذه العشبة',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                            child: _buildPriceBadge(),
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
                              onPressed: _showShareDialog,
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
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5.0,
                        ),
                        child: Text(
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
                          final comment = _comments[index];
                          final likes =
                              comment['likes'] as List<dynamic>? ?? [];
                          final replies =
                              comment['replies'] as List<dynamic>? ?? [];
                          final bool isLiked =
                              _currentUserId != null &&
                              likes.contains(_currentUserId);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () => _handleUserTap(
                                            comment['userId'],
                                            comment['userRole'],
                                          ),
                                          child: Text(
                                            '${comment['userName'] ?? 'مستخدم'} - ${_roleText(comment['userRole'] ?? 'customer')}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color:
                                                  (comment['userRole'] ==
                                                          'herbal_expert' ||
                                                      comment['userRole'] ==
                                                          'store_owner')
                                                  ? Colors.blue[700]
                                                  : Colors.black,
                                              decoration:
                                                  (comment['userRole'] ==
                                                          'herbal_expert' ||
                                                      comment['userRole'] ==
                                                          'store_owner')
                                                  ? TextDecoration.underline
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          comment['text'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      right: 10.0,
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _toggleLike(
                                            comment['_id'],
                                            likes,
                                          ),
                                          child: Text(
                                            'إعجاب (${likes.length})',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isLiked
                                                  ? Colors.blue
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        GestureDetector(
                                          onTap: () =>
                                              _showReplyDialog(comment['_id']),
                                          child: Text(
                                            'رد',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (replies.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 50.0,
                                      top: 5.0,
                                    ),
                                    child: Column(
                                      children: replies.map((reply) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Color(
                                                  0xFFDAF1DE,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 14,
                                                  color: Color(0xFF163832),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            _handleUserTap(
                                                              reply['userId'],
                                                              reply['userRole'],
                                                            ),
                                                        child: Text(
                                                          '${reply['userName']} - ${_roleText(reply['userRole'])}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                (reply['userRole'] ==
                                                                        'herbal_expert' ||
                                                                    reply['userRole'] ==
                                                                        'store_owner')
                                                                ? Colors
                                                                      .blue[700]
                                                                : Colors.black,
                                                            decoration:
                                                                (reply['userRole'] ==
                                                                        'herbal_expert' ||
                                                                    reply['userRole'] ==
                                                                        'store_owner')
                                                                ? TextDecoration
                                                                      .underline
                                                                : TextDecoration
                                                                      .none,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        reply['text'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
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
