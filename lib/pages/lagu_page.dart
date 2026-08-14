import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web; 
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// 💥 ALAMAT API
const String apiDbUrl = 'https://app.atom.gov.my/ukk_api/'; 
const String apiFileUrl = 'https://app.atom.gov.my/ukk_api'; 

// 🎨 PALET WARNA
const Color darkCard   = Color(0xFF2B2A33);
const Color goldAccent = Color(0xFFC9A96E);
const Color softText   = Color(0xFFB0ADB8);
const Color crimsonRed = Color(0xFFE50914);
const Color bgRoseTop  = Color(0xFFFBF5F3);
const Color bgGoldBot  = Color(0xFFF0E5D2);
const Color solidBlack = Colors.black;
const Color inputDark  = Color(0xFF3E3D47);

// ============================================================================
// DATA GLOBAL
// ============================================================================
List<Map<String, dynamic>> globalMasterCategories = [
  {'id': 1, 'title': 'LAGU RASMI\nATOM', 'category': 'Lagu Rasmi'},
  {'id': 2, 'title': 'LAGU LATAR\n(BGM)', 'category': 'Lagu Latar'},
  {'id': 3, 'title': 'KOLEKSI LAGU\nPATRIOTIK', 'category': 'Lagu Patriotik'},
];

Map<String, List<Map<String, dynamic>>> globalSubCategories = {};

// ═══════════════════════════════════════════════════════
// FUNGSI PEMBERSIH URL
// ═══════════════════════════════════════════════════════
String extractUploadsPath(String rawPath) {
  if (rawPath.isEmpty) return '';
  String pathOnly = Uri.decodeFull(Uri.decodeFull(rawPath)).replaceAll('\\', '/');
  if (pathOnly.contains('uploads/')) {
    return pathOnly.substring(pathOnly.indexOf('uploads/'));
  }
  return pathOnly;
}

String cleanImageUrl(String rawUrl) {
  String pathOnly = extractUploadsPath(rawUrl);
  if (pathOnly.isEmpty) return '';
  return '$apiFileUrl/lihat_gambar.php?path=${Uri.encodeComponent(pathOnly)}';
}

// ═══════════════════════════════════════════════════════
// PENGESAHAN KESELAMATAN
// ═══════════════════════════════════════════════════════
Future<bool> sahkanKeselamatanPadam(BuildContext context, String namaItem) async {
  TextEditingController pwController = TextEditingController();
  bool isError = false;

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setPopupState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400, padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: darkCard, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: crimsonRed.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: crimsonRed.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: crimsonRed.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber_rounded, color: crimsonRed, size: 45),
                  ),
                  const SizedBox(height: 20),
                  const Text('Pengesahan Keselamatan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Masukkan kata laluan untuk memadam\n"$namaItem".', textAlign: TextAlign.center, style: const TextStyle(color: softText, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 25),
                  TextField(
                    controller: pwController, style: const TextStyle(color: Colors.white), obscureText: true,
                    decoration: InputDecoration(
                      filled: true, fillColor: inputDark, hintText: 'Taip "admin123"', hintStyle: const TextStyle(color: Colors.white24),
                      errorText: isError ? 'Pengesahan gagal! Cuba lagi.' : null,
                      prefixIcon: const Icon(Icons.lock_outline, color: goldAccent, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: goldAccent)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: softText))),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: crimsonRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (pwController.text == 'admin123' || pwController.text.toLowerCase() == 'admin') {
                            Navigator.pop(context, true);
                          } else {
                            setPopupState(() => isError = true);
                          }
                        },
                        child: const Text('Sahkan Padam', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      );
    },
  ) ?? false;
}

// ═══════════════════════════════════════════════════════
// POPUP MEDIA (IFRAME) – RESPONSIF
// ═══════════════════════════════════════════════════════
class MediaPopupDialog extends StatefulWidget {
  final String mediaUrl;
  final String title;
  const MediaPopupDialog({super.key, required this.mediaUrl, required this.title});

  @override
  State<MediaPopupDialog> createState() => _MediaPopupDialogState();
}

class _MediaPopupDialogState extends State<MediaPopupDialog> {
  late final String viewType;
  late html.IFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    viewType = 'mediaPopup_${identityHashCode(this)}';

    _iframe = html.IFrameElement()
      ..src = widget.mediaUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#111111'
      ..allow = 'autoplay; fullscreen'
      ..attributes['allowfullscreen'] = 'true';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) => _iframe);
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
              decoration: const BoxDecoration(color: darkCard, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
              child: Row(
                children: [
                  Icon(Icons.play_circle_fill, color: goldAccent, size: isMobile ? 18 : 22),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(child: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14), overflow: TextOverflow.ellipsis)),
                  IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
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
// POPUP WEB (IFRAME) – RESPONSIF
// ═══════════════════════════════════════════════════════
class WebPopupDialog extends StatefulWidget {
  final String url;
  final String title;
  const WebPopupDialog({super.key, required this.url, required this.title});

  @override
  State<WebPopupDialog> createState() => _WebPopupDialogState();
}

class _WebPopupDialogState extends State<WebPopupDialog> {
  late final String viewType;
  late html.IFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    viewType = 'webPopup_${identityHashCode(this)}';

    _iframe = html.IFrameElement()
      ..src = widget.url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#FFFFFF'
      ..attributes['sandbox'] = 'allow-scripts allow-same-origin allow-popups';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) => _iframe);
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
              decoration: const BoxDecoration(color: darkCard, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
              child: Row(
                children: [
                  Icon(Icons.language, color: goldAccent, size: isMobile ? 18 : 22),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(child: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14), overflow: TextOverflow.ellipsis)),
                  IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
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
// HALAMAN UTAMA LAGU (RESPONSIF, TANPA BINGKAI, 3 LAJUR DESKTOP)
// ═══════════════════════════════════════════════════════
class LaguPage extends StatefulWidget {
  final String userRole; 
  const LaguPage({super.key, this.userRole = 'user'}); 
  @override State<LaguPage> createState() => _LaguPageState();
}

class _LaguPageState extends State<LaguPage> {
  List<dynamic> dynamicCategories = [];
  bool isLoadingDB = true;

  @override void initState() { super.initState(); _fetchKotak(); }

  Future<void> _fetchKotak() async {
    setState(() => isLoadingDB = true);
    try {
      final res = await http.get(Uri.parse('$apiDbUrl/get_kotak.php?parent=Lagu'));
      if (res.statusCode == 200) {
        setState(() { dynamicCategories = jsonDecode(res.body) ?? []; isLoadingDB = false; });
      } else { setState(() => isLoadingDB = false); }
    } catch (e) { setState(() { dynamicCategories = []; isLoadingDB = false; }); }
  }

  // ---------- DIALOG MUAT NAIK (RESPONSIF) ----------
  void _showUploadDialog(BuildContext context) {
    List<PlatformFile> selectedFiles = [];         
    double uploadProgress = 0.0;                   
    bool isUploading = false;
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    bool isLinkMode = false;

    Map<String, String> dropdownCategories = {};
    for (var cat in globalMasterCategories) {
      String title = cat['title'].replaceAll('\n', ' ');
      String categoryValue = cat['category'];
      dropdownCategories[title] = categoryValue;
      if (globalSubCategories.containsKey(cat['category'])) {
        for (var sub in globalSubCategories[cat['category']]!) {
          dropdownCategories["$title > ${sub['title']}"] = sub['category'];
        }
      }
    }
    for (var cat in dynamicCategories) {
      String title = cat['nama_kotak'].replaceAll('\n', ' ');
      String categoryValue = 'Lagu ${cat['nama_kotak']}';
      dropdownCategories[title] = categoryValue;
      if (globalSubCategories.containsKey(categoryValue)) {
        for (var sub in globalSubCategories[categoryValue]!) {
          dropdownCategories["$title > ${sub['title']}"] = sub['category'];
        }
      }
    }

    String selectedCategoryKey = dropdownCategories.keys.isNotEmpty ? dropdownCategories.keys.first : '';
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context, barrierDismissible: false, 
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 550,
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent.withOpacity(0.3))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                  decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [Icon(Icons.cloud_upload, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 12), Text('MUAT NAIK AUDIO / PAUTAN', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))]),
                      if (!isUploading) IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 15 : 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = false), child: Container(padding: EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: !isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)), border: Border.all(color: !isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Fail Audio", style: TextStyle(color: !isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
                        Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = true), child: Container(padding: EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)), border: Border.all(color: isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Pautan URL", style: TextStyle(color: isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
                      ]),
                      SizedBox(height: isMobile ? 15 : 25),
                      Text("Kategori Destinasi", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategoryKey, dropdownColor: darkCard, isExpanded: true,
                            icon: Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: isMobile ? 18 : 22)),
                            items: dropdownCategories.keys.map((key) => DropdownMenuItem<String>(value: key, child: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text(key, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14))))).toList(),
                            onChanged: (val) { if (val != null) setDialogState(() => selectedCategoryKey = val); },
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 15),
                      if (isLinkMode) ...[
                        Text("Nama Pautan (Wajib)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        TextField(controller: nameController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: 'Cth: Lagu Merdeka', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                        SizedBox(height: 15),
                        Text("Pautan URL Luar", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        TextField(controller: urlController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(prefixIcon: Icon(Icons.link, color: goldAccent, size: isMobile ? 18 : 20), hintText: 'https://...', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                      ] else ...[
                        Text("Pilih Fail Audio (Max 20)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            // 💥 FIX UPLOAD 1: WAJIB ADA withData: true 💥
                            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true, withData: true);
                            if (result != null) {
                              setDialogState(() {
                                if (result.files.length > 20) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 20 fail sahaja!'), backgroundColor: Colors.orange));
                                  selectedFiles = result.files.take(20).toList();
                                } else { selectedFiles = result.files; }
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity, height: isMobile ? 75 : 90,
                            decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12), border: Border.all(color: selectedFiles.isNotEmpty ? goldAccent : Colors.transparent, width: 1.5)),
                            child: selectedFiles.isNotEmpty
                                ? Padding(padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20), child: Row(children: [
                                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.library_music, color: goldAccent, size: isMobile ? 24 : 30)),
                                    SizedBox(width: 15),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('${selectedFiles.length} Fail Dipilih', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('✓ Sedia dimuat naik', style: TextStyle(color: goldAccent, fontSize: isMobile ? 10 : 11))])),
                                  ]))
                                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, color: softText, size: isMobile ? 20 : 24), SizedBox(width: 12), Text('Klik untuk pilih fail', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13))]),
                          ),
                        ),
                      ],
                      SizedBox(height: isMobile ? 20 : 30),
                      if (isUploading) ...[
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: uploadProgress, minHeight: 10, backgroundColor: Colors.black26, color: goldAccent)),
                        SizedBox(height: 8),
                        Center(child: Text('${(uploadProgress * 100).toInt()}% Dimuat Naik', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13))),
                        SizedBox(height: 15),
                      ],
                      SizedBox(
                        width: double.infinity, height: isMobile ? 42 : 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: (isUploading) ? null : () async {
                            if (isLinkMode && (urlController.text.isEmpty || nameController.text.isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila lengkapkan maklumat!'), backgroundColor: Colors.orange)); return;
                            }
                            if (!isLinkMode && selectedFiles.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila pilih fail audio!'), backgroundColor: Colors.orange)); return;
                            }
                            setDialogState(() { isUploading = true; uploadProgress = 0.0; });
                            try {
                              String finalCategory = dropdownCategories[selectedCategoryKey] ?? 'Lain-Lain';
                              if (isLinkMode) {
                                var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                request.fields['kategori'] = finalCategory;
                                // 💥 FIX UPLOAD 2: BERSIHKAN NAMA URL 💥
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
                                  
                                  // 💥 FIX UPLOAD 3: BERSIHKAN NAMA FAIL FIZIKAL 💥
                                  String safeFileName = file.name.replaceAll(RegExp(r'[^\w\.\-]'), '_');
                                  
                                  var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                  request.fields['kategori'] = finalCategory;
                                  
                                  // 💥 FIX UPLOAD 4: ELAK FAIL KOSONG 💥
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
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berjaya dimuat naik ke $finalCategory!'), backgroundColor: Colors.green));
                            } catch (e) {
                              String ralatMesej = e.toString().replaceAll('Exception: ', '');
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat: $ralatMesej'), backgroundColor: crimsonRed, duration: const Duration(seconds: 4)));
                            } finally { if (mounted) setDialogState(() => isUploading = false); }
                          },
                          child: isUploading ? Text('SEDANG MEMUAT NAIK...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 13)) : Text('MULA MUAT NAIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- URUS ALBUM (RESPONSIF) ----------
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
                    Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 15),
                    Expanded(child: Text('PENGURUSAN ALBUM', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                      onPressed: () async {
                        var result = await showDialog(context: context, builder: (context) => const TambahKategoriDialog());
                        if (result != null) {
                          try {
                            await http.post(Uri.parse('$apiDbUrl/add_kotak.php'), body: {'nama': result['title'], 'parent': 'Lagu', 'icon_code': 'album'});
                            await _fetchKotak(); setModalState((){});
                          } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat API'), backgroundColor: Colors.red)); }
                        }
                      },
                      icon: Icon(Icons.add, size: isMobile ? 14 : 16), label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                    ),
                    SizedBox(width: isMobile ? 4 : 15), IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                  ]),
                ),
                Expanded(
                  child: isLoadingDB
                      ? const Center(child: CircularProgressIndicator(color: goldAccent))
                      : ListView.builder(
                          padding: EdgeInsets.all(isMobile ? 12 : 25), itemCount: dynamicCategories.length,
                          itemBuilder: (ctx, i) {
                            var cat = dynamicCategories[i];
                            return Container(
                              margin: EdgeInsets.only(bottom: isMobile ? 8 : 12), padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                              decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                              child: Row(children: [
                                Icon(Icons.album, color: goldAccent, size: isMobile ? 24 : 30), SizedBox(width: isMobile ? 10 : 15),
                                Expanded(child: Text(cat['nama_kotak'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), onPressed: () async {
                                  bool confirm = await sahkanKeselamatanPadam(context, cat['nama_kotak'].replaceAll('\n', ' '));
                                  if (confirm) { await http.post(Uri.parse('$apiDbUrl/delete_kotak.php'), body: {'id': cat['id'].toString()}); await _fetchKotak(); setModalState((){}); }
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
    bool bolehUpload = widget.userRole == 'super_admin' || widget.userRole == 'admin';
    bool bolehUrusKotak = widget.userRole == 'super_admin';

    return Scaffold(
      backgroundColor: solidBlack,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
            decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
            child: SafeArea(bottom: false, child: isMobile ? _buildMobileHeader() : _buildDesktopHeader()),
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 30, vertical: isMobile ? 15 : 20),
                      constraints: const BoxConstraints(maxWidth: 850),
                      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: goldAccent.withOpacity(0.5))),
                      child: Text('Pusat arkib Audio, Lagu Rasmi & Muzik Latar (BGM).', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 13)),
                    ),
                    SizedBox(height: isMobile ? 30 : 50),
                    Text('A U D I O', style: TextStyle(color: darkCard, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w900, letterSpacing: 5.0)),
                    SizedBox(height: isMobile ? 24 : 40),
                    // Grid kategori induk
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Wrap(
                        spacing: isMobile ? 15 : 25,
                        runSpacing: isMobile ? 15 : 25,
                        alignment: WrapAlignment.center,
                        children: globalMasterCategories.map((cat) => ModernVinylCard(
                          title: cat['title'], isMobile: isMobile,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicAudioCategoryPage(title: cat['title'].replaceAll('\n', ' '), category: cat['category'], userRole: widget.userRole))).then((_) => setState((){})),
                        )).toList(),
                      ),
                    ),
                    if (isLoadingDB)
                      Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator(color: darkCard))
                    else if (dynamicCategories.isNotEmpty) ...[
                      SizedBox(height: isMobile ? 30 : 50),
                      const Divider(color: Colors.black12, thickness: 2),
                      SizedBox(height: isMobile ? 30 : 50),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Wrap(
                          spacing: isMobile ? 15 : 25,
                          runSpacing: isMobile ? 15 : 25,
                          alignment: WrapAlignment.center,
                          children: dynamicCategories.map((cat) => ModernVinylCard(
                            title: cat['nama_kotak'].replaceAll('\n', ' '), isMobile: isMobile,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicAudioCategoryPage(title: cat['nama_kotak'].replaceAll('\n', ' '), category: 'Lagu ${cat['nama_kotak']}', userRole: widget.userRole))).then((_) => setState((){})),
                          )).toList(),
                        ),
                      ),
                    ],
                    SizedBox(height: isMobile ? 60 : 100),
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
        ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15)), onPressed: _bukaUrusKategoriPanel, icon: Icon(Icons.grid_view_rounded, size: 16), label: Text("Urus Album", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
// DIALOG TAMBAH KATEGORI (RESPONSIF)
// ═══════════════════════════════════════════════════════
class TambahKategoriDialog extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  const TambahKategoriDialog({super.key, this.existingData});
  @override State<TambahKategoriDialog> createState() => _TambahKategoriDialogState();
}

class _TambahKategoriDialogState extends State<TambahKategoriDialog> {
  TextEditingController titleCtrl = TextEditingController();
  @override void initState() { super.initState(); if (widget.existingData != null) titleCtrl.text = widget.existingData!['title']; }

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
          Row(children: [Icon(isEdit ? Icons.edit : Icons.add_box, color: goldAccent), SizedBox(width: 10), Text(isEdit ? 'UBAH KOTAK' : 'TAMBAH KOTAK BARU', style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold))]),
          SizedBox(height: isMobile ? 15 : 25),
          Text('Nama Kategori', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(controller: titleCtrl, style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), hintText: 'Cth: Podcast Atom', hintStyle: TextStyle(color: Colors.white24), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          SizedBox(height: isMobile ? 20 : 35),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: softText))),
            SizedBox(width: isMobile ? 8 : 15),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 20, vertical: isMobile ? 12 : 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () {
              if (titleCtrl.text.isNotEmpty) Navigator.pop(context, {'title': titleCtrl.text});
              else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila masukkan nama kotak!'), backgroundColor: Colors.orange));
            }, child: Text('Simpan Kotak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14))),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KAD VINYL (RESPONSIF, SAIZ TETAP)
// ═══════════════════════════════════════════════════════
class ModernVinylCard extends StatefulWidget {
  final String title;
  final VoidCallback? onTap; 
  final bool isMobile;
  const ModernVinylCard({super.key, required this.title, this.onTap, this.isMobile = false});
  @override State<ModernVinylCard> createState() => _ModernVinylCardState();
}

class _ModernVinylCardState extends State<ModernVinylCard> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _spinController;

  @override void initState() { super.initState(); _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(); }
  @override void dispose() { _spinController.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    double width = widget.isMobile ? 160 : 220;
    double height = widget.isMobile ? 160 : 220;
    double imageSize = widget.isMobile ? 90 : 130;

    return MouseRegion(
      onEnter: (_) { setState(() => isHovered = true); _spinController.forward(); },
      onExit: (_) { setState(() => isHovered = false); _spinController.stop(); },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
          width: width, height: height,
          child: Container(
            width: width, height: height,
            decoration: BoxDecoration(
              color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 2),
              boxShadow: [if (isHovered) BoxShadow(color: goldAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10)) else BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Center(
                  child: RotationTransition(
                    turns: _spinController,
                    child: Container(
                      width: imageSize, height: imageSize,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF111111), border: Border.all(color: Colors.grey.shade900, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, spreadRadius: 2)]),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(width: imageSize * 0.8, height: imageSize * 0.8, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12, width: 1))),
                          Container(width: imageSize * 0.6, height: imageSize * 0.6, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12, width: 1))),
                          Container(width: imageSize * 0.4, height: imageSize * 0.4, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12, width: 1))),
                          Container(width: imageSize * 0.35, height: imageSize * 0.35, decoration: BoxDecoration(color: goldAccent, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 3)), child: Center(child: Icon(Icons.music_note, color: solidBlack, size: 20))),
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity, padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 12 : 15, horizontal: 10),
                decoration: BoxDecoration(color: isHovered ? goldAccent : const Color(0xFF1E2025), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22))),
                child: Text(widget.title.replaceAll('\n', ' '), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHovered ? solidBlack : goldAccent, fontSize: widget.isMobile ? 10 : 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HALAMAN DINAMIK AUDIO (RESPONSIF)
// ═══════════════════════════════════════════════════════
class DynamicAudioCategoryPage extends StatefulWidget {
  final String title;
  final String category;
  final String userRole; 
  const DynamicAudioCategoryPage({super.key, required this.title, required this.category, required this.userRole});
  @override State<DynamicAudioCategoryPage> createState() => _DynamicAudioCategoryPageState();
}

class _DynamicAudioCategoryPageState extends State<DynamicAudioCategoryPage> {
  String searchQuery = '';
  String sortOption = 'Terbaru'; 
  List<dynamic> allFiles = [];
  bool isLoading = true;
  bool isDeleteMode = false;
  final Set<String> selectedFilePaths = {};

  @override void initState() { super.initState(); _fetchCategoryFiles(); }

  Future<void> _fetchCategoryFiles() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$apiFileUrl/get_files.php?kategori=${Uri.encodeComponent(widget.category)}'));
      if (response.statusCode == 200) setState(() { allFiles = jsonDecode(response.body); isLoading = false; selectedFilePaths.clear(); });
    } catch (_) { setState(() => isLoading = false); }
  }

  Future<void> _padamFailPukal() async {
    if (selectedFilePaths.isEmpty) return;
    bool confirm = await sahkanKeselamatanPadam(context, "${selectedFilePaths.length} fail");
    if (!confirm) return;
    setState(() => isLoading = true);
    int success = 0;
    for (String path in selectedFilePaths) {
      try { var res = await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': path})); if (res.statusCode == 200) success++; } catch (_) {}
    }
    setState(() { isDeleteMode = false; selectedFilePaths.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$success fail dipadam!'), backgroundColor: Colors.green));
    _fetchCategoryFiles();
  }

  Future<void> _renameFile(String filePath, String currentName) async {
    String clean = currentName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    TextEditingController ctrl = TextEditingController(text: clean);
    bool? ok = await showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: darkCard, title: const Text('Tukar Tajuk', style: TextStyle(color: Colors.white)), content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: inputDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack), onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan'))]));
    if (ok == true && ctrl.text.isNotEmpty) { await http.post(Uri.parse('$apiFileUrl/rename_file.php'), body: jsonEncode({'old_path': filePath, 'new_name': ctrl.text})); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tajuk ditukar!'), backgroundColor: Colors.green)); _fetchCategoryFiles(); }
  }

  void _muatTurunFail(String filePath, String fileName) { 
    // 💥 FIX DOWNLOAD: Tukar 'file=' kepada 'path=' 💥
    html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')..setAttribute('download', fileName)..click(); 
  }

  void _paparImejLuar(String cleanUrl, String fileName) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent, insetPadding: EdgeInsets.all(isMobile ? 15 : 30),
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 700),
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)]),
          padding: EdgeInsets.all(isMobile ? 15 : 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), style: TextStyle(color: goldAccent, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold))),
              IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(ctx)),
            ]),
            const Divider(color: Colors.white24), const SizedBox(height: 10),
            Flexible(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Image.network(cleanUrl, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.white54, size: 80))))),
          ]),
        ),
      ),
    );
  }

  Future<void> _lihatAtauBukaLink(String fileUrl, String ext, String filePath, String displayName) async {
    String e = ext.toLowerCase();
    if (e == 'link') {
      try {
        final res = await http.get(Uri.parse('$apiFileUrl/read_link.php?path=${Uri.encodeComponent(filePath)}'));
        if (res.statusCode == 200) {
          String link = res.body.trim(); 
          if (link.isNotEmpty && !link.toLowerCase().startsWith('ralat')) {
            if (!link.startsWith('http')) link = 'https://$link';
            showDialog(context: context, builder: (_) => WebPopupDialog(url: link, title: displayName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')));
          }
        }
      } catch (_) {}
    } else if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'].contains(e)) {
      _paparImejLuar(cleanImageUrl(fileUrl), displayName);
    } else if (['mp3', 'wav', 'aac', 'ogg', 'mp4', 'webm', 'mov'].contains(e)) {
      showDialog(context: context, builder: (_) => MediaPopupDialog(mediaUrl: cleanImageUrl(fileUrl), title: displayName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format tidak disokong untuk paparan terus.'), backgroundColor: Colors.orange));
    }
  }

  void _bukaUrusSubKotakPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          List<Map<String, dynamic>> subBoxes = globalSubCategories[widget.category] ?? [];
          return Dialog(
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
                      Icon(Icons.create_new_folder_outlined, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 15),
                      Expanded(child: Text('PENGURUSAN SUB-KOTAK', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                        onPressed: () async {
                          var result = await showDialog(context: ctx, builder: (_) => const TambahKategoriDialog());
                          if (result != null) {
                            setModalState(() {
                              globalSubCategories.putIfAbsent(widget.category, () => []);
                              globalSubCategories[widget.category]!.add({'id': DateTime.now().millisecondsSinceEpoch, 'title': result['title'], 'category': '${widget.category} -> ${result['title'].replaceAll('\n', ' ')}'});
                            });
                            setState((){});
                          }
                        },
                        icon: Icon(Icons.add, size: isMobile ? 14 : 16), label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                      ),
                      SizedBox(width: isMobile ? 4 : 15), IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(ctx)),
                    ]),
                  ),
                  Expanded(
                    child: subBoxes.isEmpty
                        ? const Center(child: Text("Tiada sub-kotak.", style: TextStyle(color: softText)))
                        : ListView.builder(
                            padding: EdgeInsets.all(isMobile ? 12 : 25), itemCount: subBoxes.length,
                            itemBuilder: (_, i) {
                              var cat = subBoxes[i];
                              return Container(
                                margin: EdgeInsets.only(bottom: isMobile ? 8 : 12), padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                                decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                                child: Row(children: [
                                  Icon(Icons.folder_open, color: goldAccent, size: isMobile ? 24 : 30), SizedBox(width: isMobile ? 10 : 15),
                                  Expanded(child: Text(cat['title'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                  IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), onPressed: () async {
                                    var result = await showDialog(context: ctx, builder: (_) => TambahKategoriDialog(existingData: cat));
                                    if (result != null) { setModalState(() { cat['title'] = result['title']; cat['category'] = '${widget.category} -> ${result['title'].replaceAll('\n', ' ')}'; }); setState((){}); }
                                  }),
                                  SizedBox(width: 4),
                                  IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), onPressed: () async {
                                    bool confirm = await sahkanKeselamatanPadam(ctx, cat['title'].replaceAll('\n', ' '));
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
          );
        },
      ),
    );
  }

  @override Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    bool bolehUrusKotak = widget.userRole == 'super_admin';
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';
    List<Map<String, dynamic>> subBoxes = globalSubCategories[widget.category] ?? [];

    List<dynamic> filteredFiles = allFiles.where((file) {
      String rawName = file['name']; String display = rawName.contains('_') ? rawName.substring(rawName.indexOf('_')+1) : rawName;
      return display.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (sortOption == 'A-Z') filteredFiles.sort((a,b) => a['name'].substring(a['name'].indexOf('_')+1).compareTo(b['name'].substring(b['name'].indexOf('_')+1)));
    else if (sortOption == 'Z-A') filteredFiles.sort((a,b) => b['name'].substring(b['name'].indexOf('_')+1).compareTo(a['name'].substring(a['name'].indexOf('_')+1)));
    else if (sortOption == 'Lama') filteredFiles.sort((a,b) => a['name'].compareTo(b['name']));
    else filteredFiles.sort((a,b) => b['name'].compareTo(a['name']));

    return Scaffold(
      backgroundColor: solidBlack,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                height: 70, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40),
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
                      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, elevation: 0, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 15, vertical: isMobile ? 8 : 15)), onPressed: _bukaUrusSubKotakPanel, icon: Icon(Icons.create_new_folder_outlined, size: isMobile ? 14 : 16), label: Text("Urus Kotak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12))),
                      SizedBox(width: isMobile ? 6 : 10),
                    ],
                    if (bolehEditDelete) ...[
                      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: isDeleteMode ? crimsonRed : Colors.white10, foregroundColor: Colors.white, elevation: 0, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 15, vertical: isMobile ? 8 : 15)), onPressed: () => setState(() { isDeleteMode = !isDeleteMode; if (!isDeleteMode) selectedFilePaths.clear(); }), icon: Icon(isDeleteMode ? Icons.close : Icons.checklist_rtl_rounded, size: isMobile ? 14 : 16), label: Text(isDeleteMode ? "Batal Padam" : "Mod Padam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12))),
                      SizedBox(width: isMobile ? 6 : 10),
                    ],
                    IconButton(icon: Icon(Icons.refresh, color: goldAccent, size: isMobile ? 18 : 20), onPressed: _fetchCategoryFiles, padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 36, minHeight: 36)),
                  ],
                ),
              ),
              // Body
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
                            Expanded(child: SizedBox(height: isMobile ? 42 : 50, child: TextField(style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: 'Cari fail audio...', hintStyle: TextStyle(color: softText), prefixIcon: Icon(Icons.search, color: goldAccent, size: isMobile ? 18 : 20), filled: true, fillColor: darkCard, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), onChanged: (v) => setState(() => searchQuery = v)))),
                            SizedBox(width: isMobile ? 8 : 15),
                            Container(height: isMobile ? 42 : 50, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(15)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: sortOption, dropdownColor: darkCard, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold), icon: Icon(Icons.sort, color: goldAccent, size: isMobile ? 18 : 20), items: ['Terbaru', 'Lama', 'A-Z', 'Z-A'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => sortOption = v!)))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 10, isMobile ? 16 : 40, isDeleteMode ? 80 : 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subBoxes.isNotEmpty) ...[
                                Text('KOTAK DALAMAN', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                                SizedBox(height: isMobile ? 12 : 20),
                                Wrap(spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 25, children: subBoxes.map((cat) => ModernVinylCard(title: cat['title'], isMobile: isMobile, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicAudioCategoryPage(title: cat['title'].replaceAll('\n', ' '), category: cat['category'], userRole: widget.userRole))).then((_) => setState((){})))).toList()),
                                SizedBox(height: isMobile ? 20 : 40), const Divider(color: Colors.black12, thickness: 2), SizedBox(height: isMobile ? 20 : 40),
                              ],
                              if (isLoading)
                                const Center(child: CircularProgressIndicator(color: darkCard))
                              else if (filteredFiles.isNotEmpty) ...[
                                if (subBoxes.isNotEmpty) Text('SENARAI FAIL AUDIO', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                                SizedBox(height: isMobile ? 12 : 20),
                                ...filteredFiles.map((file) {
                                  String rawName = file['name']; String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_')+1) : rawName;
                                  String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';
                                  bool isSelected = selectedFilePaths.contains(file['path']);
                                  return ModernTrackTile(
                                    index: filteredFiles.indexOf(file) + 1,
                                    fileName: displayName, ext: ext,
                                    showActions: bolehEditDelete && !isDeleteMode,
                                    isSelectMode: isDeleteMode, isSelected: isSelected,
                                    onSelectChanged: (v) => setState(() { if (v == true) selectedFilePaths.add(file['path']); else selectedFilePaths.remove(file['path']); }),
                                    onView: () => _lihatAtauBukaLink(file['url'], ext, file['path'], displayName),
                                    onDownload: () => _muatTurunFail(file['path'], displayName),
                                    onRename: () => _renameFile(file['path'], displayName),
                                    onDelete: () {},
                                  );
                                }),
                              ] else if (subBoxes.isEmpty) ...[
                                Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.library_music_outlined, color: Colors.black26, size: 80), SizedBox(height: 15), Text("Tiada audio dijumpai.", style: TextStyle(color: Colors.black54, fontSize: 14))]))
                              ],
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
          if (isDeleteMode && selectedFilePaths.isNotEmpty)
            Positioned(
              bottom: 20, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 25, vertical: isMobile ? 10 : 15),
                  decoration: BoxDecoration(color: crimsonRed, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: crimsonRed.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('${selectedFilePaths.length} Fail Dipilih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 16)),
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
// TILE AUDIO (RESPONSIF)
// ═══════════════════════════════════════════════════════
class ModernTrackTile extends StatefulWidget {
  final int index;
  final String fileName;
  final String ext;
  final bool showActions; 
  final VoidCallback onView; 
  final VoidCallback onDownload; 
  final VoidCallback onDelete; 
  final VoidCallback onRename;
  final bool isSelectMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;

  const ModernTrackTile({super.key, required this.index, required this.fileName, required this.ext, required this.onView, required this.onDownload, required this.onDelete, required this.onRename, this.showActions = true, this.isSelectMode = false, this.isSelected = false, this.onSelectChanged});

  @override State<ModernTrackTile> createState() => _ModernTrackTileState();
}

class _ModernTrackTileState extends State<ModernTrackTile> {
  bool isHovered = false;

  @override Widget build(BuildContext context) {
    bool isLink = widget.ext == 'link';
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.isSelectMode ? () => widget.onSelectChanged?.call(!widget.isSelected) : null,
        child: Container(
          margin: EdgeInsets.only(bottom: isMobile ? 6 : 10),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: darkCard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.isSelected ? crimsonRed : (isHovered && !widget.isSelectMode ? goldAccent : Colors.transparent), width: widget.isSelected ? 2 : 1),
            boxShadow: [if (isHovered && !widget.isSelectMode) BoxShadow(color: goldAccent.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              if (widget.isSelectMode)
                Checkbox(value: widget.isSelected, onChanged: widget.onSelectChanged, activeColor: crimsonRed, checkColor: Colors.white, side: const BorderSide(color: softText))
              else
                SizedBox(width: 40, child: Center(child: isHovered ? Icon(Icons.play_arrow, color: goldAccent, size: 24) : Text(widget.index.toString(), style: TextStyle(color: softText, fontSize: 16, fontWeight: FontWeight.bold)))),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), style: TextStyle(color: isHovered ? goldAccent : Colors.white, fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(isLink ? 'Pautan Luar' : 'Fail .${widget.ext}', style: TextStyle(color: softText, fontSize: isMobile ? 10 : 12)),
                  ],
                ),
              ),
              if (!widget.isSelectMode && isHovered)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  if (widget.showActions) _btn(Icons.edit, goldAccent, widget.onRename),
                  SizedBox(width: 6),
                  _btn(isLink ? Icons.open_in_new : Icons.remove_red_eye, Colors.blueAccent, widget.onView),
                  if (!isLink) ...[ SizedBox(width: 6), _btn(Icons.download, Colors.greenAccent, widget.onDownload) ],
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(20),
    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5))), child: Icon(icon, color: color, size: 16)),
  );
}