import 'package:flutter/material.dart';

class TempahUkkPage extends StatelessWidget {
  const TempahUkkPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema Warna
    const Color darkCharcoal = Color(0xFF16161A);
    const Color headerCharcoal = Color(0xFF0F0F13);
    const Color boldCrimson = Color(0xFFE50914);

    // MENGESAN SAIZ SKRIN (RESPONSIF)
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return Scaffold(
      backgroundColor: darkCharcoal,
      body: Column(
        children: [
          // ==================== HEADER DENGAN MOTA ====================
          _buildHeader(headerCharcoal, context, isMobile),

          // ==================== BODY ====================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('Assets/Images/background_atom.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 30 : 60, 
                  horizontal: isMobile ? 20 : 40
                ),
                child: Column(
                  children: [
                    // ==================== TAJUK UTAMA ====================
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: isMobile ? 26 : 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: isMobile ? 1.5 : 3.0,
                        ),
                        children: const [
                          TextSpan(
                            text: 'PERKHIDMATAN ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'UKK',
                            style: TextStyle(color: boldCrimson),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 40 : 70),

                    // ==================== KANDUNGAN (RESPONSIF) ====================
                    // Wrap akan susun sebelah-menyebelah di PC, atas-bawah di Phone
                    Wrap(
                      spacing: isMobile ? 0 : 80, 
                      runSpacing: isMobile ? 40 : 50,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        
                        // -------- BAHAGIAN GAMBAR & BUTANG --------
                        SizedBox(
                          width: isMobile ? double.infinity : 450, // Penuh skrin jika phone
                          child: Column(
                            children: [
                              // Gambar Tempah.jpg
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white24, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.asset(
                                    'Assets/Images/Tempah.jpg', 
                                    width: double.infinity,
                                    height: isMobile ? 200 : null, // Fix height sikit di phone supaya tak panjang sangat
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.white12,
                                        child: const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              // Butang TEMPAH DISINI 
                              SizedBox(
                                width: isMobile ? double.infinity : 300, // Butang penuh lebar di phone
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () {
                                    print('Butang TEMPAH DISINI ditekan');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: boldCrimson, 
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30), 
                                    ),
                                    elevation: 10,
                                    shadowColor: boldCrimson.withOpacity(0.5),
                                  ),
                                  child: const Text(
                                    'TEMPAH DISINI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // -------- BAHAGIAN TEKS PENERANGAN --------
                        SizedBox(
                          width: isMobile ? double.infinity : 550, // Penuh skrin jika phone
                          child: Column(
                            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start, // Tengah di phone
                            children: [
                              Text(
                                'Platform ini bertujuan memudahkan proses perancangan, penyelarasan dan pengurusan tugasan oleh pihak UKK.',
                                textAlign: isMobile ? TextAlign.center : TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 15 : 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.6,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              Text(
                                'Permohonan yang dibuat akan membantu UKK merancang keperluan sumber, masa dan pelaksanaan dengan lebih tersusun dan berkesan.',
                                textAlign: isMobile ? TextAlign.center : TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 15 : 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.6,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              Text(
                                'SKOP :',
                                style: TextStyle(
                                  color: boldCrimson,
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Senarai Bullet Point
                              _buildBulletText('Reka Bentuk Grafik & Bahan Promosi', isMobile),
                              _buildBulletText('Goodies & Cenderamata Program', isMobile),
                              _buildBulletText('Fotografi & Videografi', isMobile),
                              _buildBulletText('Pengurusan Kandungan Media', isMobile),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================== FOOTER ====================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
            color: headerCharcoal,
            child: Text(
              'Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat, Jabatan Tenaga Atom Malaysia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGET UNTUK BULLET POINT ====================
  Widget _buildBulletText(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start, // Tengah di phone
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 15, left: 5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          // Expanded dibuang jika di phone supaya bullet tak tertarik ke hujung
          isMobile 
            ? Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              )
            : Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ==================== HEADER (RESPONSIF) ====================
  Widget _buildHeader(Color bgColor, BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15.0 : 40.0, vertical: 15.0),
      color: bgColor,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: isMobile ? 20 : 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 20),
          Image.asset('Assets/Images/logo_ukk-bg.png', height: isMobile ? 40 : 50, fit: BoxFit.contain, errorBuilder: (c,e,s) => Container(height: 40, width: 40, color: Colors.white12, child: const Icon(Icons.broken_image, color: Colors.white))),
          SizedBox(width: isMobile ? 10 : 15),
          
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
                children: const [
                  TextSpan(text: 'UKK ', style: TextStyle(color: Color(0xFFE50914))),
                  TextSpan(text: 'ATOM MALAYSIA', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(30)),
              child: const Text('MOTA: Sila buat tempahan anda di sini.', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            
          Container(
            height: isMobile ? 40 : 50,
            width: isMobile ? 40 : 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: DecorationImage(image: AssetImage('Assets/Images/Mota2.png'), fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}