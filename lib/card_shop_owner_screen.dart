import 'dart:ui';
import 'package:flutter/material.dart';

class CardShopOwnerScreen extends StatefulWidget {
  final double totalPrice;

  const CardShopOwnerScreen({super.key, required this.totalPrice});

  @override
  State<CardShopOwnerScreen> createState() => _CardShopOwnerScreenState();
}

class _CardShopOwnerScreenState extends State<CardShopOwnerScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  void _processPayment({bool isCashOnDelivery = false}) {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF163832),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(
            Icons.check_circle,
            color: Color(0xFF8EB69B),
            size: 60,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCashOnDelivery ? 'تم تأكيد طلبك بنجاح!' : 'تم الدفع بنجاح!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isCashOnDelivery
                    ? 'سيتم تحصيل مبلغ ${widget.totalPrice} ₪ عند الاستلام'
                    : 'تم دفع مبلغ ${widget.totalPrice} ₪',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8EB69B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // pop back to home with success status
                },
                child: const Text(
                  'موافق',
                  style: TextStyle(
                    color: Color(0xFF051F20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF163832),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'الدفع الإلكتروني',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Effect
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
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Amount to pay
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'المبلغ الإجمالي',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${widget.totalPrice} ₪',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Credit Card UI Mock
                      Container(
                        height: 270,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF235347), Color(0xFF163832)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                Text(
                                  'VISA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _cardNumberController.text.isEmpty
                                  ? '**** **** **** ****'
                                  : _cardNumberController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                letterSpacing: 2,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Card Holder',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _nameController.text.isEmpty
                                          ? 'NAME SURNAME'
                                          : _nameController.text.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Expires',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _expiryDateController.text.isEmpty
                                          ? 'MM/YY'
                                          : _expiryDateController.text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Input Fields
                      _buildTextField(
                        'رقم البطاقة',
                        _cardNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField('اسم حامل البطاقة', _nameController),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'تاريخ الانتهاء (MM/YY)',
                              _expiryDateController,
                              keyboardType: TextInputType.datetime,
                              maxLength: 5,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              'CVV',
                              _cvvController,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Pay Button
                      ElevatedButton(
                        onPressed: () =>
                            _processPayment(isCashOnDelivery: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8EB69B),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'تأكيد الدفع',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF051F20),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.payment,
                              color: Color(0xFF051F20),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Cash on Delivery Option
                      OutlinedButton(
                        onPressed: () =>
                            _processPayment(isCashOnDelivery: true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: Color(0xFF8EB69B),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'الدفع عند الاستلام',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() {}), // rebuild to update card UI
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        counterText: '',
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8EB69B), width: 1.5),
        ),
      ),
    );
  }
}
