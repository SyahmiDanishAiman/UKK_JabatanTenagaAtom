import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data'; 
import 'dart:ui_web' as ui_web;
import 'package:file_picker/file_picker.dart'; 
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════
// PALET WARNA PREMIUM
// ═══════════════════════════════════════════════════════
const Color darkCard   = Color(0xFF2B2A33);
const Color goldAccent = Color(0xFFC9A96E);
const Color softText   = Color(0xFFB0ADB8);
const Color crimsonRed = Color(0xFFE50914);
const Color bgRoseTop  = Color(0xFFFBF5F3);
const Color bgGoldBot  = Color(0xFFF0E5D2);
const Color solidBlack = Colors.black;
const Color inputDark  = Color(0xFF3E3D47);

// ═══════════════════════════════════════════════════════
// ALAMAT API
// ═══════════════════════════════════════════════════════
const String apiFileUrl = 'https://app.atom.gov.my/ukk_api';

// ═══════════════════════════════════════════════════════
// FUNGSI PEMBERSIH URL (BUANG IP LOCALHOST) 
// ═══════════════════════════════════════════════════════
String cleanImageUrl(String rawUrl) {
  if (rawUrl.isEmpty) return '';
  String decoded = Uri.decodeFull(Uri.decodeFull(rawUrl)).replaceAll('\\', '/');
  
  if (decoded.contains('uploads/')) {
    String pathOnly = decoded.substring(decoded.indexOf('uploads/'));
    return '$apiFileUrl/lihat_gambar.php?path=${Uri.encodeComponent(pathOnly)}';
  }
  return Uri.encodeFull(decoded.replaceAll('http://127.0.0.1:9999', apiFileUrl));
}

String cleanVideoUrl(String rawUrl) {
  if (rawUrl.isEmpty) return '';
  String decoded = Uri.decodeFull(Uri.decodeFull(rawUrl)).replaceAll('\\', '/');
  
  if (decoded.contains('uploads/')) {
    String pathOnly = decoded.substring(decoded.indexOf('uploads/'));
    return Uri.encodeFull('$apiFileUrl/$pathOnly');
  }
  return Uri.encodeFull(decoded.replaceAll('http://127.0.0.1:9999', apiFileUrl));
}

// ═══════════════════════════════════════════════════════
// PENGESAHAN KESELAMATAN
// ═══════════════════════════════════════════════════════
Future<bool> sahkanKeselamatanPadam(BuildContext context, String namaItem) async {
  TextEditingController pwCtrl = TextEditingController();
  bool isError = false;
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setPopupState) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text('Pengesahan Keselamatan', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Masukkan kata laluan untuk memadam "$namaItem".', style: const TextStyle(color: softText)),
            const SizedBox(height: 15),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'admin123',
                hintStyle: const TextStyle(color: softText),
                filled: true,
                fillColor: inputDark,
                errorText: isError ? 'Kata laluan salah!' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: softText))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: crimsonRed, foregroundColor: Colors.white),
            onPressed: () {
              if (pwCtrl.text == 'admin123' || pwCtrl.text.toLowerCase() == 'admin') {
                Navigator.pop(ctx, true);
              } else {
                setPopupState(() => isError = true);
              }
            },
            child: const Text('Sahkan Padam'),
          ),
        ],
      ),
    ),
  ) ?? false;
}

// ═══════════════════════════════════════════════════════
// DATA SUB-KATEGORI GLOBAL UNTUK VIDEO
// ═══════════════════════════════════════════════════════
Map<String, List<Map<String, dynamic>>> globalVideoSubCategories = {};

// ═══════════════════════════════════════════════════════
// DIALOG POPUP VIDEO (HTML5 VIDEO ELEMENT)
// ═══════════════════════════════════════════════════════
class VideoPopupDialog extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPopupDialog({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPopupDialog> createState() => _VideoPopupDialogState();
}

class _VideoPopupDialogState extends State<VideoPopupDialog> {
  late final String viewType;
  late html.VideoElement _videoElement;

  @override
  void initState() {
    super.initState();
    viewType = 'videoPopup_${identityHashCode(this)}';

    _videoElement = html.VideoElement()
      ..src = widget.videoUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#000000'
      ..controls = true
      ..autoplay = true
      ..crossOrigin = 'anonymous' // Atasi isu CORS
      ..setAttribute('controlsList', 'nodownload')
      ..setAttribute('playsinline', 'true');
    
    _videoElement.style.objectFit = 'contain';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) => _videoElement);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 600),
        decoration: BoxDecoration(
          color: solidBlack,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: goldAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
              decoration: const BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  Icon(Icons.play_circle_fill, color: goldAccent, size: isMobile ? 18 : 22),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                child: HtmlElementView(viewType: viewType),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HALAMAN UTAMA VIDEO 
// ═══════════════════════════════════════════════════════
class VideoPage extends StatefulWidget {
  final String userRole;
  const VideoPage({super.key, this.userRole = 'user'});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<Map<String, dynamic>> masterCategories = [
    {'id': 1, 'title': 'KORPORAT\nATOM MALAYSIA', 'category': 'Video Korporat', 'icon': Icons.business},
    {'id': 2, 'title': 'HKHM\n2024', 'category': 'Video HKHM', 'icon': Icons.event},
    {'id': 3, 'title': 'LAGU\nNEGARAKU', 'category': 'Video Negaraku', 'icon': Icons.flag},
    {'id': 4, 'title': 'FOOTAGE\nLOGO ATOM', 'category': 'Footage Logo', 'icon': Icons.animation},
    {'id': 5, 'title': 'VIDEO\nAPK', 'category': 'Video APK', 'icon': Icons.android},
    {'id': 6, 'title': 'LAIN-\nLAIN', 'category': 'Video Lain-Lain', 'icon': Icons.more_horiz},
  ];

  void _showUploadDialog(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    List<PlatformFile> selectedFiles = []; 
    String selectedCategory = masterCategories.first['title'];
    bool isUploading = false;
    double uploadProgress = 0.0;
    int? uploadStartTime;
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    bool isLinkMode = false;

    Map<String, IconData> dropdownCats = {};
    for (var cat in masterCategories) {
      dropdownCats[cat['title']] = cat['icon'] as IconData;
    }
    globalVideoSubCategories.forEach((parentCat, subList) {
      for (var sub in subList) {
        dropdownCats["$parentCat → ${sub['title']}"] = sub['icon'] ?? Icons.video_library;
      }
    });

    String formatETA(double progress, int startTimeMs) {
      if (progress <= 0) return 'Mengira...';
      int elapsed = DateTime.now().millisecondsSinceEpoch - startTimeMs;
      double totalEstimated = elapsed / progress;
      int remaining = (totalEstimated - elapsed).toInt();
      if (remaining < 1000) return 'Hampir siap';
      int seconds = (remaining / 1000).round();
      if (seconds < 60) return '$seconds saat';
      int minutes = seconds ~/ 60;
      return '$minutes minit ${seconds % 60} saat';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 550,
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: goldAccent.withOpacity(0.4)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3E3D47),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.cloud_upload, color: goldAccent, size: isMobile ? 18 : 22),
                            SizedBox(width: isMobile ? 8 : 12),
                            Text('MUAT NAIK FAIL / PAUTAN',
                                style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold)),
                          ]),
                          if (!isUploading)
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 15 : 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setDialogState(() => isLinkMode = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025),
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                    border: Border.all(color: !isLinkMode ? goldAccent : Colors.transparent),
                                  ),
                                  child: Center(child: Text("Fail Komputer", style: TextStyle(color: !isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13))),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setDialogState(() => isLinkMode = true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025),
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                    border: Border.all(color: isLinkMode ? goldAccent : Colors.transparent),
                                  ),
                                  child: Center(child: Text("Pautan URL", style: TextStyle(color: isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13))),
                                ),
                              ),
                            ),
                          ]),
                          SizedBox(height: isMobile ? 15 : 25),

                          Text("Kategori Destinasi", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: dropdownCats.containsKey(selectedCategory) ? selectedCategory : dropdownCats.keys.first,
                                dropdownColor: darkCard,
                                isExpanded: true,
                                icon: Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: isMobile ? 18 : 22)),
                                items: dropdownCats.keys.map((cat) => DropdownMenuItem<String>(
                                  value: cat,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(children: [
                                      Icon(dropdownCats[cat], color: goldAccent, size: 18),
                                      SizedBox(width: 10),
                                      Expanded(child: Text(cat.replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ]),
                                  ),
                                )).toList(),
                                onChanged: (v) => setDialogState(() => selectedCategory = v!),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 20),
                          
                          if (isLinkMode) ...[
                            Text("Tajuk Pautan (Wajib)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                              decoration: InputDecoration(
                                hintText: 'Cth: Pautan YouTube',
                                hintStyle: TextStyle(color: softText),
                                filled: true,
                                fillColor: const Color(0xFF1E2025),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text("Pautan URL Luar", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            TextField(
                              controller: urlController,
                              style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.link, color: goldAccent, size: isMobile ? 18 : 20),
                                hintText: 'https://...',
                                hintStyle: TextStyle(color: softText),
                                filled: true,
                                fillColor: const Color(0xFF1E2025),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ] else ...[
                            Text("Pilih Fail (Semua Format Disokong, Max 20)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true, withData: true);
                                if (result != null) {
                                  setDialogState(() {
                                    if (result.files.length > 20) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 20 fail sahaja dibenarkan!'), backgroundColor: Colors.orange));
                                      selectedFiles = result.files.take(20).toList();
                                    } else {
                                      selectedFiles = result.files;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity, height: isMobile ? 75 : 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2025), 
                                  borderRadius: BorderRadius.circular(12), 
                                  border: Border.all(color: selectedFiles.isNotEmpty ? goldAccent : Colors.transparent, width: 1.5)
                                ),
                                child: selectedFiles.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                                        child: Row(children: [
                                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.video_library, color: goldAccent, size: isMobile ? 24 : 30)),
                                          SizedBox(width: 15),
                                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('${selectedFiles.length} Fail Dipilih', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('✓ Sedia dimuat naik', style: TextStyle(color: goldAccent, fontSize: isMobile ? 10 : 11))])),
                                        ]),
                                      )
                                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, color: softText, size: isMobile ? 20 : 24), SizedBox(width: 12), Text('Klik untuk pilih fail video', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13))]),
                              ),
                            ),
                          ],
                          SizedBox(height: isMobile ? 20 : 30),
                          
                          if (isUploading) ...[
                            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: uploadProgress, minHeight: 10, backgroundColor: Colors.black26, color: goldAccent)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${(uploadProgress * 100).toInt()}%', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                                if (uploadStartTime != null)
                                  Text(formatETA(uploadProgress, uploadStartTime!), style: TextStyle(color: softText, fontSize: isMobile ? 10 : 12)),
                              ],
                            ),
                            SizedBox(height: 15),
                          ],
                          
                          if (!isUploading)
                            SizedBox(
                              width: double.infinity,
                              height: isMobile ? 42 : 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goldAccent,
                                  foregroundColor: solidBlack,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  if (isLinkMode && (urlController.text.isEmpty || nameController.text.isEmpty)) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila lengkapkan maklumat!'), backgroundColor: Colors.orange));
                                    return;
                                  }
                                  if (!isLinkMode && selectedFiles.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila pilih fail terlebih dahulu!'), backgroundColor: Colors.orange));
                                    return;
                                  }

                                  setDialogState(() {
                                    isUploading = true;
                                    uploadProgress = 0.0;
                                    uploadStartTime = DateTime.now().millisecondsSinceEpoch;
                                  });

                                  try {
                                    String finalCategory = 'Video Lain-Lain';
                                    bool found = false;
                                    for (var cat in masterCategories) {
                                      if (cat['title'] == selectedCategory || cat['title'].replaceAll('\n', ' ') == selectedCategory) {
                                        finalCategory = cat['category'];
                                        found = true;
                                        break;
                                      }
                                    }
                                    if (!found) {
                                      globalVideoSubCategories.forEach((parent, subs) {
                                        for (var sub in subs) {
                                          if ("$parent → ${sub['title']}" == selectedCategory) {
                                            finalCategory = sub['category'];
                                            found = true;
                                          }
                                        }
                                      });
                                    }

                                    if (isLinkMode) {
                                      var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                      request.fields['kategori'] = finalCategory;
                                      String safeName = nameController.text.trim().replaceAll(RegExp(r'[^\w\s\-]+'), '_').replaceAll(' ', '_');
                                      Uint8List urlBytes = Uint8List.fromList(utf8.encode(urlController.text));
                                      request.files.add(http.MultipartFile.fromBytes('file', urlBytes, filename: '$safeName.link'));
                                      
                                      var response = await request.send();
                                      var responseBody = await response.stream.bytesToString();
                                      
                                      if(response.statusCode == 200 && !responseBody.contains('"status":"error"')) {
                                        setDialogState(() => uploadProgress = 1.0);
                                      } else {
                                        throw Exception("Gagal muat naik pautan.");
                                      }
                                    } else {
                                      int totalFiles = selectedFiles.length;
                                      for (int i = 0; i < totalFiles; i++) {
                                        var file = selectedFiles[i];
                                        String safeFileName = file.name.replaceAll(RegExp(r'[^\w\.\-]'), '_');
                                        var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                        request.fields['kategori'] = finalCategory;

                                        if (file.bytes == null || file.bytes!.isEmpty) {
                                          throw Exception("Data fail '${file.name}' kosong (0 Bytes).");
                                        }

                                        request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: safeFileName));

                                        var response = await request.send();
                                        var responseBody = await response.stream.bytesToString();
                                        
                                        if(response.statusCode == 200) {
                                          if (responseBody.contains('"status":"error"')) {
                                            throw Exception("Pelayan menolak fail.");
                                          }
                                          setDialogState(() => uploadProgress = (i + 1) / totalFiles);
                                        } else {
                                          throw Exception("Ralat pelayan IIS");
                                        }
                                      }
                                    }
                                    
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berjaya dimuat naik ke $finalCategory!'), backgroundColor: Colors.green));
                                  } catch (e) {
                                    String ralatMesej = e.toString().replaceAll('Exception: ', '');
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat: $ralatMesej'), backgroundColor: crimsonRed, duration: const Duration(seconds: 4)));
                                  } finally {
                                    if (mounted) setDialogState(() => isUploading = false);
                                  }
                                },
                                child: Text('MULA MUAT NAIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14)),
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

  void _bukaUrusKategoriPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 600,
            height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600,
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent.withOpacity(0.3))),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                  decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Row(children: [
                    Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22),
                    SizedBox(width: isMobile ? 8 : 15),
                    Expanded(child: Text('PENGURUSAN KOTAK VIDEO', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                      onPressed: () async {
                        var result = await showDialog(context: context, builder: (context) => const TambahKategoriDialog());
                        if (result != null) {
                          setModalState(() { masterCategories.add({'id': DateTime.now().millisecondsSinceEpoch, 'title': result['title'], 'category': result['title'].replaceAll('\n', ' '), 'icon': result['icon'] ?? Icons.movie}); });
                          setState((){});
                        }
                      },
                      icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                      label: Text('Tambah Kotak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                    ),
                    SizedBox(width: isMobile ? 4 : 15),
                    IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                  ]),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 12 : 25),
                    itemCount: masterCategories.length,
                    itemBuilder: (context, index) {
                      var cat = masterCategories[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                        decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [
                          CircleAvatar(backgroundColor: goldAccent.withOpacity(0.2), radius: isMobile ? 18 : 20, child: Icon(cat['icon'], color: goldAccent, size: isMobile ? 18 : 20)),
                          SizedBox(width: isMobile ? 10 : 15),
                          Expanded(child: Text(cat['title'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                          IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () async {
                            var result = await showDialog(context: context, builder: (context) => TambahKategoriDialog(existingData: cat));
                            if (result != null) { setModalState(() { cat['title'] = result['title']; cat['category'] = result['title'].replaceAll('\n', ' '); if (result['icon'] != null) cat['icon'] = result['icon']; }); setState((){}); }
                          }),
                          SizedBox(width: 4),
                          IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () async {
                            bool confirm = await sahkanKeselamatanPadam(context, cat['title'].replaceAll('\n', ' '));
                            if (confirm) { setModalState(() => masterCategories.removeAt(index)); setState((){}); }
                          }),
                        ]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    bool bolehUrusKotak = widget.userRole == 'super_admin';
    bool bolehUpload = widget.userRole == 'super_admin' || widget.userRole == 'admin';

    return Scaffold(
      backgroundColor: solidBlack,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
            decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
            child: SafeArea(
              bottom: false,
              child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
            ),
          ),
          // Body
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 40, horizontal: isMobile ? 12 : 24),
                child: Column(
                  children: [
                    Text('VIDEO', style: TextStyle(color: darkCard, fontSize: isMobile ? 22 : 24, fontWeight: FontWeight.w900, letterSpacing: 5.0)),
                    SizedBox(height: isMobile ? 12 : 20),
                    Text('Pusat arkib video & pautan korporat.', style: TextStyle(color: darkCard, fontSize: isMobile ? 12 : 14)),
                    SizedBox(height: isMobile ? 30 : 50),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Wrap(
                        spacing: isMobile ? 15 : 25,
                        runSpacing: isMobile ? 15 : 25,
                        alignment: WrapAlignment.center,
                        children: masterCategories.map((cat) {
                          return HoverableCategoryCard(
                            icon: cat['icon'],
                            title: cat['title'],
                            isMobile: isMobile,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicVideoCategoryPage(title: cat['title'].replaceAll('\n', ' '), category: cat['category'], userRole: widget.userRole)));
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 15),
            color: darkCard,
            child: Text('Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat, Jabatan Tenaga Atom.', textAlign: TextAlign.center, style: TextStyle(color: softText, fontSize: isMobile ? 10 : 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Row(children: [
      Image.asset('Assets/Images/logo_ukk-bg.png', height: 48, errorBuilder: (_,__,___) => Icon(Icons.broken_image, color: goldAccent, size: 48)),
      SizedBox(width: 16),
      Expanded(child: RichText(text: TextSpan(style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5), children: const [TextSpan(text: 'UKK ', style: TextStyle(color: Colors.white)), TextSpan(text: 'JABATAN TENAGA ATOM', style: TextStyle(color: Color(0xFFE0E0E0)))]))),
      Spacer(),
      if (widget.userRole == 'super_admin') ...[
        ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15)), onPressed: _bukaUrusKategoriPanel, icon: Icon(Icons.grid_view_rounded, size: 16), label: Text("Urus Kotak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        SizedBox(width: 10),
      ],
      if (widget.userRole == 'super_admin' || widget.userRole == 'admin') ...[
        ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15)), onPressed: () => _showUploadDialog(context), icon: Icon(Icons.cloud_upload, size: 16), label: Text("Muat Naik", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      ],
    ]);
  }

  Widget _buildMobileHeader() {
    return Row(children: [
      Image.asset('Assets/Images/logo_ukk-bg.png', height: 28, errorBuilder: (_,__,___) => Icon(Icons.broken_image, color: goldAccent, size: 28)),
      SizedBox(width: 8),
      Flexible(child: Text('UKK JTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1), maxLines: 1, overflow: TextOverflow.ellipsis)),
      Spacer(),
      if (widget.userRole == 'super_admin')
        IconButton(icon: Icon(Icons.grid_view_rounded, color: Colors.white70, size: 20), onPressed: _bukaUrusKategoriPanel, padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 36, minHeight: 36)),
      if (widget.userRole == 'super_admin' || widget.userRole == 'admin')
        IconButton(icon: Icon(Icons.cloud_upload, color: goldAccent, size: 20), onPressed: () => _showUploadDialog(context), padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 36, minHeight: 36)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════
// DIALOG TAMBAH / EDIT KATEGORI 
// ═══════════════════════════════════════════════════════
class TambahKategoriDialog extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  const TambahKategoriDialog({super.key, this.existingData});
  @override State<TambahKategoriDialog> createState() => _TambahKategoriDialogState();
}

class _TambahKategoriDialogState extends State<TambahKategoriDialog> {
  TextEditingController titleCtrl = TextEditingController();
  IconData? _selectedIcon;
  final List<IconData> iconChoices = [Icons.movie, Icons.video_library, Icons.play_circle_fill, Icons.animation, Icons.business, Icons.event, Icons.flag, Icons.android, Icons.camera_alt, Icons.star, Icons.public, Icons.science];

  @override void initState() {
    super.initState();
    if (widget.existingData != null) { titleCtrl.text = widget.existingData!['title']; _selectedIcon = widget.existingData!['icon'] as IconData?; }
    else { _selectedIcon = iconChoices[0]; }
  }

  @override Widget build(BuildContext context) {
    bool isEdit = widget.existingData != null;
    final bool isMobile = MediaQuery.of(context).size.width < 500;
    final double dialogWidth = isMobile ? MediaQuery.of(context).size.width * 0.9 : 400;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 1.5)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(isEdit ? Icons.edit : Icons.add_box, color: goldAccent), const SizedBox(width: 10), Text(isEdit ? 'UBAH KOTAK' : 'TAMBAH KOTAK BARU', style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold))]),
          SizedBox(height: isMobile ? 15 : 25),
          Text('Nama Kategori', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(controller: titleCtrl, style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), hintText: 'Cth: Temuramah Khas', hintStyle: TextStyle(color: softText), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          SizedBox(height: isMobile ? 12 : 20),
          Text('Pilih Ikon', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            height: isMobile ? 120 : 150,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              child: Wrap(spacing: 12, runSpacing: 12, children: iconChoices.map((icon) {
                bool selected = _selectedIcon == icon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: selected ? goldAccent : Colors.black26, shape: BoxShape.circle), child: Icon(icon, color: selected ? solidBlack : softText, size: 24)),
                );
              }).toList()),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 35),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: softText))),
            SizedBox(width: isMobile ? 8 : 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 20, vertical: isMobile ? 12 : 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) Navigator.pop(context, {'title': titleCtrl.text, 'icon': _selectedIcon});
                else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila masukkan nama kotak!'), backgroundColor: Colors.orange));
              },
              child: Text('Simpan Kotak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14)),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KAD KATEGORI
// ═══════════════════════════════════════════════════════
class HoverableCategoryCard extends StatefulWidget {
  final IconData? icon;
  final String title;
  final VoidCallback? onTap;
  final bool isMobile;
  const HoverableCategoryCard({super.key, this.icon, required this.title, this.onTap, this.isMobile = false});
  @override State<HoverableCategoryCard> createState() => _HoverableCategoryCardState();
}

class _HoverableCategoryCardState extends State<HoverableCategoryCard> {
  bool isHovered = false;
  @override Widget build(BuildContext context) {
    double width = widget.isMobile ? 160 : 220;
    double height = widget.isMobile ? 160 : 220;
    final iconSize = widget.isMobile ? 45.0 : 60.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
          width: width,
          height: height,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: goldAccent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: solidBlack, width: 4),
              boxShadow: [
                if (isHovered)
                  BoxShadow(color: solidBlack.withOpacity(0.3), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10))
                else
                  BoxShadow(color: solidBlack.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Icon(widget.icon ?? Icons.movie, color: solidBlack, size: iconSize),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 12 : 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isHovered ? solidBlack : Colors.black87,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                  ),
                  child: Text(
                    widget.title.replaceAll('\n', ' '),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: goldAccent, fontSize: widget.isMobile ? 10 : 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HALAMAN DINAMIK KATEGORI VIDEO
// ═══════════════════════════════════════════════════════
class DynamicVideoCategoryPage extends StatefulWidget {
  final String title;
  final String category;
  final String userRole;
  const DynamicVideoCategoryPage({super.key, required this.title, required this.category, required this.userRole});
  @override State<DynamicVideoCategoryPage> createState() => _DynamicVideoCategoryPageState();
}

class _DynamicVideoCategoryPageState extends State<DynamicVideoCategoryPage> {
  String searchQuery = '';
  String sortOption = 'Terbaru';
  List<dynamic> allFiles = [];
  bool isLoading = true;
  bool isDeleteMode = false;
  Set<String> selectedFilesToDelete = {};

  @override void initState() { super.initState(); _fetchCategoryFiles(); }

  Future<void> _fetchCategoryFiles() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$apiFileUrl/get_files.php?kategori=${Uri.encodeComponent(widget.category)}'));
      if (response.statusCode == 200) setState(() { allFiles = jsonDecode(response.body); isLoading = false; selectedFilesToDelete.clear(); });
    } catch (_) { setState(() => isLoading = false); }
  }

  Future<void> _padamFailPukal() async {
    if (selectedFilesToDelete.isEmpty) return;
    bool confirm = await sahkanKeselamatanPadam(context, "${selectedFilesToDelete.length} fail");
    if (!confirm) return;
    setState(() => isLoading = true);
    int success = 0;
    for (String path in selectedFilesToDelete) {
      try { var res = await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': path})); if (res.statusCode == 200) success++; } catch (_) {}
    }
    setState(() { isDeleteMode = false; selectedFilesToDelete.clear(); });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$success fail dipadam!'), backgroundColor: Colors.green));
    _fetchCategoryFiles();
  }

  Future<void> _renameFile(String filePath, String currentName) async {
    String cleanName = currentName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    TextEditingController renameCtrl = TextEditingController(text: cleanName);
    bool? confirm = await showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: darkCard, title: const Text('Tukar Nama Fail', style: TextStyle(color: Colors.white)), content: TextField(controller: renameCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: inputDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack), onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan'))]));
    if (confirm == true && renameCtrl.text.isNotEmpty) { 
      String ext = filePath.contains('.') ? filePath.split('.').last : '';
      String newFullName = ext.isNotEmpty ? '${renameCtrl.text}.$ext' : renameCtrl.text;
      await http.post(Uri.parse('$apiFileUrl/rename_file.php'), body: jsonEncode({'old_path': filePath, 'new_name': newFullName})); 
      _fetchCategoryFiles(); 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama ditukar!'), backgroundColor: Colors.green)); 
    }
  }

  void _muatTurunFail(String filePath, String fileName) { 
    html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')..setAttribute('download', fileName)..click(); 
  }

  void _paparImejLuar(BuildContext context, String cleanUrl, String fileName) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isMobile ? 15 : 30),
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 700),
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)]),
          padding: EdgeInsets.all(isMobile ? 15 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), style: TextStyle(color: goldAccent, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold))),
                IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(ctx)),
              ]),
              Divider(color: Colors.white24),
              SizedBox(height: 10),
              Flexible(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Image.network(cleanUrl, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.white54, size: 80))))),
            ],
          ),
        ),
      ),
    );
  }

  // 💥 FIX: SEMUA JENIS VIDEO SEKARANG BOLEH DIBUKA DALAM POPUP 💥
  Future<void> _lihatAtauBukaLink(String fileUrl, String ext, String filePath, String displayName) async {
    String e = ext.toLowerCase();
    if (e == 'link') {
      try {
        final res = await http.get(Uri.parse('$apiFileUrl/read_link.php?path=${Uri.encodeComponent(filePath)}'));
        if (res.statusCode == 200) { 
          String link = res.body.trim(); 
          if (link.isNotEmpty && !link.toLowerCase().startsWith('ralat')) {
            if (!link.startsWith('http')) link = 'https://$link'; 
            html.window.open(link, '_blank'); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kandungan pautan ralat.'), backgroundColor: Colors.orange));
          }
        }
      } catch (_) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat sambungan pautan.'), backgroundColor: crimsonRed));
      }
    } else if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'].contains(e)) {
      String cleanUrl = cleanImageUrl(fileUrl); 
      _paparImejLuar(context, cleanUrl, displayName);
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', 'ogg', 'wmv', 'flv', '3gp', 'm4v', 'ts'].contains(e)) {
      // DAH BUANG "PENGAWAL", SEMUA VIDEO MASUK SINI
      showDialog(
        context: context,
        builder: (_) => VideoPopupDialog(
          videoUrl: cleanVideoUrl(fileUrl),
          title: displayName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format fail ini tidak disokong untuk paparan terus. Sila muat turun.', style: TextStyle(color: solidBlack)), backgroundColor: goldAccent));
    }
  }

  void _bukaUrusSubKotakPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    List<Map<String, dynamic>> subBoxes = globalVideoSubCategories[widget.category] ?? [];
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 600,
            height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600,
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent.withOpacity(0.3))),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                  decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Row(children: [
                    Icon(Icons.create_new_folder_outlined, color: goldAccent, size: isMobile ? 18 : 22),
                    SizedBox(width: isMobile ? 8 : 15),
                    Expanded(child: Text('PENGURUSAN SUB-KOTAK', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                      onPressed: () async {
                        var result = await showDialog(context: ctx, builder: (c) => const TambahKategoriDialog());
                        if (result != null) {
                          setModalState(() {
                            globalVideoSubCategories.putIfAbsent(widget.category, () => []);
                            globalVideoSubCategories[widget.category]!.add({
                              'id': DateTime.now().millisecondsSinceEpoch,
                              'title': result['title'],
                              'category': '${widget.category} → ${result['title'].replaceAll('\n', ' ')}',
                              'icon': result['icon'] ?? Icons.video_library,
                            });
                          });
                          setState((){});
                        }
                      },
                      icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                      label: Text('Tambah Sub-Kotak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                    ),
                    SizedBox(width: isMobile ? 4 : 15),
                    IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(ctx)),
                  ]),
                ),
                Expanded(
                  child: subBoxes.isEmpty
                      ? const Center(child: Text("Tiada sub-kotak.", style: TextStyle(color: softText)))
                      : ListView.builder(
                          padding: EdgeInsets.all(isMobile ? 12 : 25), itemCount: subBoxes.length,
                          itemBuilder: (ctx, i) {
                            var sub = subBoxes[i];
                            return Container(
                              margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                              decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                              child: Row(children: [
                                CircleAvatar(backgroundColor: goldAccent.withOpacity(0.2), radius: isMobile ? 18 : 20, child: Icon(sub['icon'] ?? Icons.folder, color: goldAccent, size: isMobile ? 18 : 20)),
                                SizedBox(width: isMobile ? 10 : 15),
                                Expanded(child: Text(sub['title'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () async {
                                  var result = await showDialog(context: ctx, builder: (c) => TambahKategoriDialog(existingData: sub));
                                  if (result != null) { setModalState(() { sub['title'] = result['title']; sub['category'] = '${widget.category} → ${result['title'].replaceAll('\n', ' ')}'; if (result['icon'] != null) sub['icon'] = result['icon']; }); setState((){}); }
                                }),
                                SizedBox(width: 4),
                                IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () async {
                                  bool confirm = await sahkanKeselamatanPadam(ctx, sub['title'].replaceAll('\n', ' '));
                                  if (confirm) { setModalState(() => subBoxes.removeAt(i)); setState((){}); }
                                }),
                              ]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';
    bool bolehUrusKotak = widget.userRole == 'super_admin';
    List<Map<String, dynamic>> subBoxes = globalVideoSubCategories[widget.category] ?? [];

    List<dynamic> filteredFiles = allFiles.where((f) {
      String name = f['name']; String display = name.contains('_') ? name.substring(name.indexOf('_')+1) : name;
      return display.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (sortOption == 'A-Z') filteredFiles.sort((a,b) => a['name'].compareTo(b['name']));
    else if (sortOption == 'Z-A') filteredFiles.sort((a,b) => b['name'].compareTo(a['name']));
    else filteredFiles.sort((a,b) => b['name'].compareTo(a['name']));

    return Scaffold(
      backgroundColor: solidBlack,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40),
                decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
                child: Row(
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(context)),
                    SizedBox(width: isMobile ? 8 : 12),
                    Image.asset('Assets/Images/logo_ukk-bg.png', height: isMobile ? 28 : 35, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: goldAccent)),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(child: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.bold, letterSpacing: 1.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const Spacer(),
                    if (bolehUrusKotak) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, elevation: 0, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 15, vertical: isMobile ? 8 : 15)),
                        onPressed: _bukaUrusSubKotakPanel,
                        icon: Icon(Icons.create_new_folder_outlined, size: isMobile ? 14 : 16),
                        label: Text("Urus Kotak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                      ),
                      SizedBox(width: isMobile ? 6 : 10),
                    ],
                    if (bolehEditDelete) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDeleteMode ? crimsonRed : Colors.white10,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 15, vertical: isMobile ? 8 : 15),
                        ),
                        onPressed: () => setState(() { isDeleteMode = !isDeleteMode; if (!isDeleteMode) selectedFilesToDelete.clear(); }),
                        icon: Icon(isDeleteMode ? Icons.close : Icons.checklist_rtl_rounded, size: isMobile ? 14 : 16),
                        label: Text(isDeleteMode ? "Batal Padam" : "Mod Padam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                      ),
                      SizedBox(width: isMobile ? 6 : 10),
                    ],
                    IconButton(icon: Icon(Icons.refresh, color: goldAccent, size: isMobile ? 18 : 20), onPressed: _fetchCategoryFiles, padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 36, minHeight: 36)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: isMobile ? 15 : 25),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: isMobile ? 42 : 50,
                                child: TextField(
                                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                                  decoration: InputDecoration(
                                    hintText: 'Cari fail...',
                                    hintStyle: TextStyle(color: softText),
                                    prefixIcon: Icon(Icons.search, color: goldAccent, size: isMobile ? 18 : 20),
                                    filled: true,
                                    fillColor: darkCard,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  ),
                                  onChanged: (v) => setState(() => searchQuery = v),
                                ),
                              ),
                            ),
                            SizedBox(width: isMobile ? 8 : 15),
                            Container(
                              height: isMobile ? 42 : 50,
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                              decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(15)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: sortOption,
                                  dropdownColor: darkCard,
                                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold),
                                  icon: Icon(Icons.sort, color: goldAccent, size: isMobile ? 18 : 20),
                                  items: ['Terbaru', 'Lama', 'A-Z', 'Z-A'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) => setState(() => sortOption = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 16 : 40,
                            10,
                            isMobile ? 16 : 40,
                            isDeleteMode ? 80 : 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subBoxes.isNotEmpty) ...[
                                Text('KOTAK DALAMAN', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                                SizedBox(height: isMobile ? 12 : 20),
                                Wrap(
                                  spacing: isMobile ? 15 : 25,
                                  runSpacing: isMobile ? 15 : 25,
                                  children: subBoxes.map((sub) => HoverableCategoryCard(
                                    icon: sub['icon'] ?? Icons.folder,
                                    title: sub['title'],
                                    isMobile: isMobile,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicVideoCategoryPage(title: sub['title'].replaceAll('\n', ' '), category: sub['category'], userRole: widget.userRole))),
                                  )).toList(),
                                ),
                                SizedBox(height: isMobile ? 20 : 40),
                                const Divider(color: Colors.black12, thickness: 2),
                                SizedBox(height: isMobile ? 20 : 40),
                              ],
                              if (isLoading)
                                const Center(child: CircularProgressIndicator(color: darkCard))
                              else if (filteredFiles.isEmpty && subBoxes.isEmpty)
                                const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.videocam_off, color: softText, size: 50), SizedBox(height: 10), Text("Tiada fail dijumpai.", style: TextStyle(color: softText))]))
                              else if (filteredFiles.isNotEmpty)
                                Wrap(
                                  spacing: isMobile ? 12 : 25,
                                  runSpacing: isMobile ? 12 : 30,
                                  children: filteredFiles.map((file) {
                                    String rawName = file['name'];
                                    String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_')+1) : rawName;
                                    
                                    String filePath = file['path'] ?? file['url'] ?? '';
                                    String ext = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';

                                    bool isSelected = selectedFilesToDelete.contains(file['path']);
                                    return MinimalVideoCard(
                                      fileName: displayName, 
                                      ext: ext, 
                                      imagePath: file['url'], 
                                      isMobile: isMobile,
                                      showActions: bolehEditDelete && !isDeleteMode,
                                      isSelectionMode: isDeleteMode, isSelected: isSelected,
                                      onToggleSelect: () => setState(() { if (isSelected) selectedFilesToDelete.remove(file['path']); else selectedFilesToDelete.add(file['path']); }),
                                      onView: () => _lihatAtauBukaLink(file['url'], ext, file['path'], displayName),
                                      onDownload: () => _muatTurunFail(file['path'], displayName),
                                      onRename: () => _renameFile(file['path'], displayName),
                                      onDelete: () {},
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isDeleteMode && selectedFilesToDelete.isNotEmpty)
            Positioned(
              bottom: 20, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 25, vertical: isMobile ? 10 : 15),
                  decoration: BoxDecoration(color: crimsonRed, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: crimsonRed.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('${selectedFilesToDelete.length} Fail Dipilih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 16)),
                    SizedBox(width: isMobile ? 12 : 25),
                    ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: crimsonRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: _padamFailPukal, icon: Icon(Icons.delete_forever, size: isMobile ? 16 : 18), label: Text('Padam Semua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 14))),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KAD VIDEO MINIMALIS
// ═══════════════════════════════════════════════════════
class MinimalVideoCard extends StatefulWidget {
  final String fileName, ext;
  final String? imagePath; 
  final bool showActions, isMobile, isSelectionMode, isSelected;
  final VoidCallback onView, onDownload, onDelete, onRename;
  final VoidCallback? onToggleSelect;
  const MinimalVideoCard({super.key, required this.fileName, required this.ext, this.imagePath, required this.onView, required this.onDownload, required this.onDelete, required this.onRename, this.showActions = true, this.isMobile = false, this.isSelectionMode = false, this.isSelected = false, this.onToggleSelect});
  @override State<MinimalVideoCard> createState() => _MinimalVideoCardState();
}

class _MinimalVideoCardState extends State<MinimalVideoCard> {
  bool isHovered = false;

  Widget _buildIconOrImage() {
    String e = widget.ext.toLowerCase();

    if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'].contains(e) && widget.imagePath != null) {
      return Image.network(
        cleanImageUrl(widget.imagePath!),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (c, err, s) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.broken_image, color: crimsonRed, size: widget.isMobile ? 30 : 40), SizedBox(height: 5), Text('Ralat', style: TextStyle(color: softText, fontSize: widget.isMobile ? 8 : 10))])),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: goldAccent, strokeWidth: 2));
        },
      );
    }

    IconData iconData = Icons.insert_drive_file;
    Color iconColor = softText;
    if (e == 'link') { iconData = Icons.link; iconColor = Colors.blueAccent; }
    else if (['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'ogg', 'ts', '3gp'].contains(e)) { iconData = Icons.play_circle_outline; iconColor = goldAccent; }
    else if (['mp3', 'wav', 'aac'].contains(e)) { iconData = Icons.audiotrack; iconColor = Colors.purpleAccent; }
    else if (e == 'pdf') { iconData = Icons.picture_as_pdf; iconColor = crimsonRed; }
    else if (['zip', 'rar', '7z', 'tar'].contains(e)) { iconData = Icons.folder_zip; iconColor = Colors.orangeAccent; }
    else if (['doc', 'docx', 'txt'].contains(e)) { iconData = Icons.description; iconColor = Colors.blue; }
    else if (['xls', 'xlsx', 'csv'].contains(e)) { iconData = Icons.table_chart; iconColor = Colors.green; }
    else if (['ppt', 'pptx'].contains(e)) { iconData = Icons.slideshow; iconColor = Colors.orange; }
    else if (['ai', 'eps', 'psd'].contains(e)) { iconData = Icons.design_services; iconColor = Colors.pinkAccent; }
    
    return Center(child: Icon(iconData, color: iconColor, size: widget.isMobile ? 40 : 50));
  }

  @override Widget build(BuildContext context) {
    double boxSize = widget.isMobile ? 130 : 180;
    bool isLink = widget.ext == 'link';
    bool isViewable = isLink || 
        ['mp4', 'mov', 'avi', 'mkv', 'webm', 'ogg', 'wmv', 'flv', '3gp', 'm4v', 'ts'].contains(widget.ext.toLowerCase()) || 
        ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'].contains(widget.ext.toLowerCase());

    bool isImage = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'].contains(widget.ext.toLowerCase());

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.isSelectionMode ? widget.onToggleSelect : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.identity()..translate(0.0, (isHovered && !widget.isSelectionMode) ? -6.0 : 0.0),
          child: Container(
            width: boxSize, height: boxSize,
            decoration: BoxDecoration(
              color: darkCard, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.isSelected ? crimsonRed : (isHovered && !widget.isSelectionMode ? goldAccent : Colors.transparent), width: widget.isSelected ? 3 : 2),
              boxShadow: [if (isHovered && !widget.isSelectionMode) BoxShadow(color: goldAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)) else BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    padding: isImage ? EdgeInsets.zero : const EdgeInsets.all(15), 
                    color: darkCard, 
                    child: _buildIconOrImage()
                  ),
                  if (isHovered && !widget.isSelectionMode) Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.9)], stops: const [0.4, 1.0]))),
                  if (widget.isSelectionMode) Container(color: widget.isSelected ? crimsonRed.withOpacity(0.3) : Colors.black.withOpacity(0.4), child: Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.all(10), child: Container(decoration: BoxDecoration(color: widget.isSelected ? crimsonRed : Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), padding: const EdgeInsets.all(4), child: Icon(Icons.check, size: 16, color: widget.isSelected ? Colors.white : Colors.transparent))))),
                  if (isHovered && !widget.isSelectionMode)
                    Positioned(
                      bottom: 12, left: 8, right: 8,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: widget.isMobile ? 11 : 13)),
                        SizedBox(height: widget.isMobile ? 8 : 10),
                        Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
                          if (widget.showActions) _btn(Icons.edit, goldAccent, widget.onRename),
                          _btn(isViewable ? (isLink ? Icons.open_in_new : Icons.visibility) : Icons.visibility_off, isViewable ? Colors.blue : Colors.grey, widget.onView),
                          _btn(Icons.download, Colors.green, widget.onDownload),
                        ]),
                      ]),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _btn(IconData icon, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(30),
    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5))), child: Icon(icon, color: color, size: widget.isMobile ? 14 : 16)),
  );
}