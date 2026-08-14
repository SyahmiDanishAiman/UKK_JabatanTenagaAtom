import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// HALAMAN UTAMA: LOWER THIRD PAGE
// ============================================================================
class LowerThirdPage extends StatefulWidget {
  const LowerThirdPage({super.key});

  @override
  State<LowerThirdPage> createState() => _LowerThirdPageState();
}

class _LowerThirdPageState extends State<LowerThirdPage> {
  
  // --- FUNGSI DIALOG UPLOAD ---
  void _showUploadDialog(BuildContext context) {
    PlatformFile? selectedFile;
    String selectedCategory = 'SOCMED';
    bool isUploading = false;
    TextEditingController nameController = TextEditingController();

    final Map<String, IconData> categories = {
      'SOCMED': Icons.share_outlined, 
      'GMAIL SIGNATURE': Icons.mark_email_read_outlined, 
      'FOOTER': Icons.call_to_action_outlined, 
      'QR CODE': Icons.qr_code_2, 
      'IKON-IKON': Icons.dashboard_customize_outlined
    };

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 450,
                decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // HEADER DIALOG
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFE50914), Color(0xFF8B0000)]),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.cloud_upload, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text('MUAT NAIK ASET BARU', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ],
                          ),
                          if (!isUploading)
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)),
                            ),
                        ],
                      ),
                    ),

                    // BODY DIALOG
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Kategori Destinasi", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFF2A2D34), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                dropdownColor: const Color(0xFF2A2D34),
                                isExpanded: true,
                                icon: const Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.keyboard_arrow_down, color: Colors.white54)),
                                items: categories.keys.map((String cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat, 
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        children: [
                                          Icon(categories[cat], color: Colors.blueAccent, size: 18),
                                          const SizedBox(width: 10),
                                          Text(cat, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                        ],
                                      ),
                                    )
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => selectedCategory = val!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text("Nama Fail (Pilihan)", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Cth: Footer Rasmi',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: const Color(0xFF2A2D34),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ========================================================
                          // PENAMBAHBAIKAN: KOTAK PILIH FAIL NIPIS & KEMAS
                          // ========================================================
                          const Text("Pilih Fail", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
                              if (result != null) setState(() => selectedFile = result.files.first);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 85, // Kekal nipis 85px
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2D34).withOpacity(0.5), 
                                borderRadius: BorderRadius.circular(12), 
                                border: Border.all(color: selectedFile != null ? Colors.green : Colors.white24, width: 2, style: BorderStyle.solid) 
                              ),
                              child: selectedFile != null
                                  ? _buildFilePreview(selectedFile!)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.cloud_upload, color: Colors.blueAccent, size: 24)),
                                        const SizedBox(width: 15),
                                        const Text('Klik untuk cari fail', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity, height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE50914), 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                                shadowColor: Colors.redAccent.withOpacity(0.5)
                              ),
                              onPressed: (selectedFile == null || isUploading)
                                  ? null
                                  : () async {
                                      setState(() => isUploading = true);
                                      try {
                                        var request = http.MultipartRequest('POST', Uri.parse('http://localhost/ukk_api/upload.php'));
                                        request.fields['kategori'] = selectedCategory; 
                                        request.fields['custom_name'] = nameController.text;
                                        
                                        if (selectedFile!.bytes != null) {
                                          request.files.add(http.MultipartFile.fromBytes('file', selectedFile!.bytes!, filename: selectedFile!.name));
                                          var response = await request.send();
                                          if (response.statusCode == 200) {
                                            Navigator.pop(context); 
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berjaya muat naik ke $selectedCategory!'), backgroundColor: Colors.green));
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal muat naik!'), backgroundColor: Colors.red));
                                          }
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat sistem!'), backgroundColor: Colors.red));
                                      } finally {
                                        if (mounted) setState(() => isUploading = false);
                                      }
                                    },
                              child: isUploading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('MULA MUAT NAIK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // PENAMBAHBAIKAN: REKAAN "FILE SELECTED" (ATTACHMENT STYLE) & PREVIEW
  // ============================================================================
  Widget _buildFilePreview(PlatformFile file) {
    String ext = file.extension?.toLowerCase() ?? '';
    bool isImage = ['png', 'jpg', 'jpeg'].contains(ext) && file.bytes != null;
    
    IconData fileIcon = ext == 'pdf' ? Icons.picture_as_pdf : (ext == 'ai' ? Icons.design_services : Icons.image);
    Color iconColor = ext == 'pdf' ? Colors.redAccent : (ext == 'ai' ? Colors.orangeAccent : Colors.blueAccent);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // 1. IKON/THUMBNAIL FAIL (Kiri)
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: isImage ? Colors.transparent : Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12)
            ),
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(file.bytes!, fit: BoxFit.cover),
                  )
                : Icon(fileIcon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 15),
          
          // 2. MAKLUMAT FAIL (Tengah)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  file.name, 
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 4),
                const Text(
                  '✓ Sedia dimuat naik. Klik untuk tukar.', 
                  style: TextStyle(color: Colors.greenAccent, fontSize: 11)
                ),
              ],
            ),
          ),

          // 3. BUTANG VIEW (Kanan) - Hanya untuk gambar
          if (isImage)
            InkWell(
              onTap: () {
                // Tunjuk Pop-up Preview
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          // GUNA CONSTRAINED BOX (Sama macam LogoPage)
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 600),
                            child: Image.memory(file.bytes!, fit: BoxFit.contain),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.white, size: 35),
                            onPressed: () => Navigator.pop(context),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.blue, width: 1.5)),
                child: const Icon(Icons.visibility, color: Colors.blue, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkCharcoal = Color(0xFF16161A);
    const Color headerCharcoal = Color(0xFF0F0F13);
    const Color boldCrimson = Color(0xFFE50914);

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    final List<Map<String, dynamic>> itemList = [
      {'title': 'SOCMED', 'icon': Icons.share_outlined, 'category': 'SOCMED'},
      {'title': 'GMAIL SIGNATURE', 'icon': Icons.mark_email_read_outlined, 'category': 'GMAIL SIGNATURE'},
      {'title': 'FOOTER', 'icon': Icons.call_to_action_outlined, 'category': 'FOOTER'},
      {'title': 'QR CODE', 'icon': Icons.qr_code_2, 'category': 'QR CODE'},
      {'title': 'IKON-IKON', 'icon': Icons.dashboard_customize_outlined, 'category': 'IKON-IKON'},
    ];

    return Scaffold(
      backgroundColor: darkCharcoal,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context),
        backgroundColor: boldCrimson,
        icon: const Icon(Icons.cloud_upload, color: Colors.white, size: 20),
        label: const Text("MUAT NAIK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15.0 : 40.0, vertical: 15.0),
            decoration: BoxDecoration(color: headerCharcoal, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(context)),
                ),
                SizedBox(width: isMobile ? 10 : 20),
                Image.asset('Assets/Images/logo_ukk-bg.png', height: isMobile ? 35 : 45, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white)),
                SizedBox(width: isMobile ? 10 : 15),
                Expanded(
                  child: RichText(
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(fontSize: isMobile ? 16 : 22, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      children: const [TextSpan(text: 'UKK ', style: TextStyle(color: Color(0xFFE50914))), TextSpan(text: 'ATOM MALAYSIA', style: TextStyle(color: Colors.grey))],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: const AssetImage('Assets/Images/background_atom.png'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)),
              ),
              child: SingleChildScrollView( 
                padding: EdgeInsets.symmetric(vertical: isMobile ? 30.0 : 50.0, horizontal: isMobile ? 20.0 : 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: isMobile ? 30 : 50), 
                      child: Column(
                        children: [
                          Text('Lower Third / QR / Icon / Footer', textAlign: TextAlign.center, style: TextStyle(color: boldCrimson, fontSize: isMobile ? 16 : 24, fontWeight: FontWeight.bold, letterSpacing: isMobile ? 1.5 : 3.0)),
                          const SizedBox(height: 10),
                          Text('Koleksi aset untuk kegunaan kreatif', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: isMobile ? 12 : 14, letterSpacing: 1.5)),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 900, 
                      child: Wrap(
                        spacing: isMobile ? 20.0 : 40.0, 
                        runSpacing: isMobile ? 20.0 : 30.0, 
                        alignment: WrapAlignment.center,
                        children: itemList.map((item) {
                          return HoverableIconCard(
                            title: item['title'],
                            icon: item['icon'],
                            isMobile: isMobile,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicLowerThirdPage(title: item['title'], category: item['category']))),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FOOTER
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            color: headerCharcoal,
            child: Text('Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat, Jabatan Tenaga Atom Malaysia.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HALAMAN DINAMIK UNTUK SEMUA ASET LOWER THIRD
// ============================================================================
class DynamicLowerThirdPage extends StatefulWidget {
  final String title;
  final String category;

  const DynamicLowerThirdPage({super.key, required this.title, required this.category});

  @override
  State<DynamicLowerThirdPage> createState() => _DynamicLowerThirdPageState();
}

class _DynamicLowerThirdPageState extends State<DynamicLowerThirdPage> {
  String searchQuery = '';
  String sortOption = 'Terbaru'; 
  List<dynamic> allFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryFiles();
  }

  Future<void> _fetchCategoryFiles() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost/ukk_api/get_files.php?kategori=${widget.category}'));
      if (response.statusCode == 200) {
        setState(() {
          allFiles = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) { 
      print(e); 
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteFile(String filePath, String fileName) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Pengesahan", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text("Padam fail '$fileName'?", style: const TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(child: const Text("Batal", style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Padam", style: TextStyle(color: Colors.white)), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final res = await http.post(Uri.parse('http://localhost/ukk_api/delete_file.php'), body: jsonEncode({'path': filePath}));
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fail berjaya dipadam!'), backgroundColor: Colors.green));
        _fetchCategoryFiles(); 
      }
    }
  }

  // --- FUNGSI TUKAR NAMA (RENAME) DITAMBAH ---
  Future<void> _renameFile(String filePath, String currentName) async {
    String cleanName = currentName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    TextEditingController renameCtrl = TextEditingController(text: cleanName);
    
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Tukar Nama Fail", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: renameCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2025),
            hintText: "Masukkan nama baharu",
            hintStyle: const TextStyle(color: Colors.white30),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(child: const Text("Batal", style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
            child: const Text("Simpan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
            onPressed: () => Navigator.pop(context, true)
          ),
        ],
      ),
    ) ?? false;

    if (confirm && renameCtrl.text.isNotEmpty) {
      try {
        final res = await http.post(
          Uri.parse('http://localhost/ukk_api/rename_file.php'), 
          body: jsonEncode({'old_path': filePath, 'new_name': renameCtrl.text})
        );
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama fail berjaya ditukar!'), backgroundColor: Colors.green));
          _fetchCategoryFiles(); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menukar nama.'), backgroundColor: Colors.red));
        }
      } catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _muatTurunFail(String filePath, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memuat turun $fileName...', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
    final url = 'http://localhost/ukk_api/download.php?file=${Uri.encodeComponent(filePath)}';
    html.AnchorElement(href: url)..setAttribute('download', fileName)..click();
  }

  void _lihatFailWeb(String url) { html.window.open(url, '_blank'); }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    List<dynamic> filteredFiles = allFiles.where((file) {
      String rawName = file['name'];
      String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
      return displayName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (sortOption == 'A-Z') {
      filteredFiles.sort((a, b) => a['name'].substring(a['name'].indexOf('_') + 1).compareTo(b['name'].substring(b['name'].indexOf('_') + 1)));
    } else if (sortOption == 'Z-A') {
      filteredFiles.sort((a, b) => b['name'].substring(b['name'].indexOf('_') + 1).compareTo(a['name'].substring(a['name'].indexOf('_') + 1)));
    } else if (sortOption == 'Lama') {
      filteredFiles.sort((a, b) => a['name'].compareTo(b['name'])); 
    } else { 
      filteredFiles.sort((a, b) => b['name'].compareTo(a['name']));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF16161A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F13), 
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)), 
        centerTitle: true, 
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _fetchCategoryFiles)],
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(image: DecorationImage(image: const AssetImage('Assets/Images/background_atom.png'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken))),
        child: Column(
          children: [
            // BAR CARIAN & SORTING
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Cari aset...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 18),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sortOption,
                        dropdownColor: const Color(0xFF2A2D34),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        icon: const Icon(Icons.sort, color: Colors.white, size: 18),
                        items: ['Terbaru', 'Lama', 'A-Z', 'Z-A'].map((String sort) => DropdownMenuItem<String>(value: sort, child: Text(sort))).toList(),
                        onChanged: (val) => setState(() => sortOption = val!),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // GRID MINIMALIS
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                  : filteredFiles.isEmpty
                      ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.folder_open, color: Colors.white30, size: 50), SizedBox(height: 10), Text("Tiada fail dijumpai.", style: TextStyle(color: Colors.white54, fontSize: 14))]))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          child: Wrap(
                            spacing: 20, runSpacing: 25, alignment: WrapAlignment.center,
                            children: filteredFiles.map((file) {
                              String rawName = file['name'];
                              String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
                              String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';
                              
                              return MinimalAssetCard(
                                imagePath: file['url'],
                                fileName: displayName,
                                isMobile: isMobile,
                                onView: () {
                                  // SEKATAN PREVIEW (PREVIEW BLOCKER) UNTUK FAIL NON-IMAGE
                                  if (['ai', 'docx', 'doc', 'pptx', 'ppt'].contains(ext)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Fail dokumen ini tidak boleh dipratonton di web. Sila klik butang Muat Turun (Hijau).'), backgroundColor: Colors.orange)
                                    );
                                  } else {
                                    _lihatFailWeb(file['url']);
                                  }
                                },
                                onDownload: () => _muatTurunFail(file['path'], displayName),
                                onDelete: () => _deleteFile(file['path'], displayName),
                                onRename: () => _renameFile(file['path'], displayName), // PANGGIL RENAME
                              );
                            }).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET BANTUAN: KAD IKON UNTUK MENU UTAMA (LOWER THIRD)
// ============================================================================
class HoverableIconCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile; 

  const HoverableIconCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isMobile = false,
  });

  @override
  State<HoverableIconCard> createState() => _HoverableIconCardState();
}

class _HoverableIconCardState extends State<HoverableIconCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),   
      onExit: (_) => setState(() => isHovered = false),  
      cursor: SystemMouseCursors.click, 
      child: GestureDetector(
        onTap: widget.onTap, 
        child: AnimatedScale(
          scale: isHovered ? 1.08 : 1.0, 
          duration: const Duration(milliseconds: 200), 
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.isMobile ? 120 : 150, 
            width: widget.isMobile ? 140 : 200,  
            alignment: Alignment.center, 
            padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 10 : 20, vertical: 15), 
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D34), 
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: isHovered ? const Color(0xFFE50914) : Colors.transparent, width: 2.0),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isHovered ? 0.6 : 0.3), blurRadius: isHovered ? 25 : 15, spreadRadius: isHovered ? 3 : 0, offset: const Offset(0, 5))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: widget.isMobile ? 35 : 45, color: isHovered ? const Color(0xFFE50914) : Colors.white),
                SizedBox(height: widget.isMobile ? 10 : 15),
                Text(widget.title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: widget.isMobile ? 11 : 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET BANTUAN: KAD ASET MINIMALIS (SAMA SEPERTI LOGO & DATA PAGE)
// ============================================================================
class MinimalAssetCard extends StatefulWidget {
  final String imagePath;
  final String fileName;
  final VoidCallback onView; 
  final VoidCallback onDownload; 
  final VoidCallback onDelete; 
  final VoidCallback onRename; // DITAMBAH RENAME
  final bool isMobile;

  const MinimalAssetCard({
    super.key, 
    required this.imagePath, 
    required this.fileName,
    required this.onView, 
    required this.onDownload,
    required this.onDelete,
    required this.onRename,
    this.isMobile = false, 
  });

  @override
  State<MinimalAssetCard> createState() => _MinimalAssetCardState();
}

class _MinimalAssetCardState extends State<MinimalAssetCard> {
  bool isHovered = false;

  Widget _buildIconOrImage() {
    String ext = widget.fileName.contains('.') ? widget.fileName.split('.').last.toLowerCase() : '';
    
    if (ext == 'pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 45);
    } else if (ext == 'ai') {
      return const Icon(Icons.design_services, color: Colors.orangeAccent, size: 45);
    } else if (['png', 'jpg', 'jpeg'].contains(ext)) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(widget.imagePath, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.white30, size: 45)),
      );
    } else {
      return const Icon(Icons.insert_drive_file, color: Colors.blueAccent, size: 45);
    }
  }

  @override
  Widget build(BuildContext context) {
    double boxSize = widget.isMobile ? 130 : 160;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: boxSize, height: boxSize,
          decoration: BoxDecoration(
            color: const Color(0xFF252830), 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHovered ? Colors.white30 : Colors.transparent, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Center(child: _buildIconOrImage())),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: const BoxDecoration(color: Color(0xFF1A1C21), borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
                    child: Tooltip(
                      message: widget.fileName, 
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      child: Text(
                        widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), 
                        textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, height: 1.2)
                      ),
                    ),
                  )
                ],
              ),
              if (isHovered)
                Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.85), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMiniBtn(Icons.edit, Colors.orangeAccent, widget.onRename), // BUTANG RENAME
                        const SizedBox(width: 5),
                        _buildMiniBtn(Icons.visibility, Colors.blue, widget.onView),
                        const SizedBox(width: 5),
                        _buildMiniBtn(Icons.download, Colors.green, widget.onDownload),
                        const SizedBox(width: 5),
                        _buildMiniBtn(Icons.delete, Colors.red, widget.onDelete),
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

  Widget _buildMiniBtn(IconData icon, Color color, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(6), // Padding kecil untuk 4 butang
        decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}