import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _icController = TextEditingController();
  final FocusNode _icFocusNode = FocusNode(); // Untuk kesan bersinar bila klik kotak IC

  bool _isLoading = false;
  bool _isHovered = false;
  bool _isFocused = false;

  // 🎨 PALET WARNA AESTHETIC KAYANGAN
  // 🌟 Warna Latar Belakang Kecerunan (Gradient)
  static const Color bgRoseSoft = Color(0xFFF9E0E5);   // Soft Rose Gold cerah/pastul
  static const Color bgGoldSoft = Color(0xFFF5E8D0);   // Soft Gold/Champagne cerah

  static const Color darkCard    = Color(0xFF26252D);   // Kad Kelabu Arang Premium
  static const Color inputBg     = Color(0xFF35343D);   // Latar belakang kotak input

  // Warna Logam untuk Gradient (Butang & Bingkai)
  static const Color accelRoseGold = Color(0xFFDCA8A6); // Metallic Rose Gold
  static const Color accelGold     = Color(0xFFD4AF37); // Classic Gold
  static const Color textSoft      = Color(0xFFB0ADB8);

  @override
  void initState() {
    super.initState();
    // Pantau jika boss klik kotak IC untuk bagi efek 'glowing gradient border'
    _icFocusNode.addListener(() {
      setState(() {
        _isFocused = _icFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _icController.dispose();
    _icFocusNode.dispose();
    super.dispose();
  }

  Future<void> _prosesLogin() async {
    String icInput = _icController.text.trim();

    if (icInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila masukkan No. Kad Pengenalan anda!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ✅ KEKAL GUNA PORT 9999
      final url = Uri.parse('https://app.atom.gov.my/ukk_api/login.php');
      final response = await http.post(
        url,
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({'ic_number': icInput}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selamat Datang!'),
            backgroundColor: accelGold,
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(
              userNama: data['nama'],
              userRole: data['role'],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Akses Ditolak!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ralat Server! Pastikan Laragon & API berjalan.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌟🌟🌟 LATAR BELAKANG GRADIENT SOFT ROSEGOLD DAN SOFT GOLD (ATAS KE BAWAH) 🌟🌟🌟
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgRoseSoft, bgGoldSoft],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // 📦 Kad Gelap Premium
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: darkCard.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 8,
                      offset: const Offset(0, 20),
                    ),
                    // soft glow corresponding to background gradient
                    BoxShadow(
                      color: accelRoseGold.withOpacity(0.08),
                      blurRadius: 50,
                      offset: const Offset(-10, 10),
                    ),
                     BoxShadow(
                      color: accelGold.withOpacity(0.08),
                      blurRadius: 50,
                      offset: const Offset(10, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'Assets/Images/logo_ukk-bg.png',
                      height: 85,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tajuk
                    const Text(
                      'SISTEM UKK ATOM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subteks
                    const Text(
                      'Log masuk dengan No. Kad Pengenalan',
                      style: TextStyle(
                        color: textSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Label + Input (BINGKAI GRADIENT BERSINAR 🔥)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NO. KAD PENGENALAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // 🔥 'Glow wrapper' untuk bingkai gradient
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.all(_isFocused ? 2.0 : 1.5), 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.5),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [accelRoseGold, accelGold], // Gradient Bingkai masa fokus
                            ),
                            boxShadow: _isFocused 
                              ? [
                                  BoxShadow(
                                    color: accelGold.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ] 
                              : [],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: _icController,
                              focusNode: _icFocusNode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '000807070959',
                                hintStyle: TextStyle(
                                  color: Color(0xFF8A8792),
                                  letterSpacing: 1.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.credit_card_rounded,
                                  color: Colors.white, 
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              ),
                              onSubmitted: (_) => _prosesLogin(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Butang Log Masuk (GRADIENT BUTANG 🔥)
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: AnimatedScale(
                        scale: _isHovered ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Untuk guna Ink gradient
                              foregroundColor: darkCard,
                              elevation: _isHovered ? 8 : 2,
                              shadowColor: accelGold.withOpacity(0.4),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isLoading ? null : _prosesLogin,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [accelRoseGold, accelGold], // Gradient Butang
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22, height: 22,
                                        child: CircularProgressIndicator(
                                          color: darkCard,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'LOG MASUK',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.4,
                                              color: darkCard,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded, size: 18, color: darkCard),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer (warna digelapkan sikit supaya jelas atas gradient cerah)
          Positioned(
            bottom: 22,
            left: 0, right: 0,
            child: Text(
              'Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat\nJabatan Tenaga Atom Malaysia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkCard.withOpacity(0.7), // Kelabu gelap
                fontSize: 10,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}