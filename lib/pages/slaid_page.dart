import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:ui_web' as ui_web;

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
const String apiDbUrl   = 'https://app.atom.gov.my/ukk_api/';
const String apiFileUrl = 'https://app.atom.gov.my/ukk_api';

// ═══════════════════════════════════════════════════════
// FUNGSI PEMBERSIH URL
// ═══════════════════════════════════════════════════════
String cleanImageUrl(String rawUrl) {
  if (rawUrl.isEmpty) return '';
  String decoded = Uri.decodeFull(Uri.decodeFull(rawUrl)).replaceAll('\\', '/');
  if (!decoded.startsWith('http')) {
    if (decoded.startsWith('/')) decoded = decoded.substring(1);
    decoded = '$apiFileUrl/$decoded';
  }
  return Uri.encodeFull(decoded);
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
// PEMETAAN NAMA IKON KE ICON DATA PEMALAR
// ═══════════════════════════════════════════════════════
class SlaidIcons {
  static const Map<String, IconData> map = {
    'slideshow_outlined': Icons.slideshow_outlined,
    'ondemand_video': Icons.ondemand_video,
    'computer': Icons.computer,
    'picture_as_pdf': Icons.picture_as_pdf,
    'video_camera_back_outlined': Icons.video_camera_back_outlined,
    'event_available_outlined': Icons.event_available_outlined,
    'public_outlined': Icons.public_outlined,
    'folder_shared_outlined': Icons.folder_shared_outlined,
    'slideshow': Icons.slideshow,
    'folder': Icons.folder,
    'create_new_folder': Icons.create_new_folder_outlined,
  };

  static IconData getIcon(String? name) {
    if (name == null || !map.containsKey(name)) return Icons.slideshow;
    return map[name]!;
  }
}

// ═══════════════════════════════════════════════════════
// DATA SUB-KATEGORI GLOBAL UNTUK SLAID
// ═══════════════════════════════════════════════════════
Map<String, List<Map<String, dynamic>>> globalSlaidSubCategories = {};

// ═══════════════════════════════════════════════════════
// MEDIA POPUP DIALOG (RESPONSIF)
// ═══════════════════════════════════════════════════════
class MediaPopupDialog extends StatefulWidget {
  final String mediaUrl; final String title;
  const MediaPopupDialog({super.key, required this.mediaUrl, required this.title});
  @override State<MediaPopupDialog> createState() => _MediaPopupDialogState();
}

class _MediaPopupDialogState extends State<MediaPopupDialog> {
  late final String viewType;
  late html.IFrameElement _iframe;
  @override void initState() {
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
  @override Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 600),
        decoration: BoxDecoration(color: solidBlack, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 2)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
            decoration: const BoxDecoration(color: darkCard, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
            child: Row(children: [
              Icon(Icons.play_circle_fill, color: goldAccent, size: isMobile ? 18 : 22),
              SizedBox(width: isMobile ? 8 : 10),
              Expanded(child: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14), overflow: TextOverflow.ellipsis)),
              IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ]),
          ),
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)), child: HtmlElementView(viewType: viewType))),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WEB POPUP DIALOG (RESPONSIF)
// ═══════════════════════════════════════════════════════
class WebPopupDialog extends StatefulWidget {
  final String url; final String title;
  const WebPopupDialog({super.key, required this.url, required this.title});
  @override State<WebPopupDialog> createState() => _WebPopupDialogState();
}
class _WebPopupDialogState extends State<WebPopupDialog> {
  late final String viewType;
  late html.IFrameElement _iframe;
  @override void initState() {
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
  @override Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 600),
        decoration: BoxDecoration(color: solidBlack, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 2)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
            decoration: const BoxDecoration(color: darkCard, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
            child: Row(children: [
              Icon(Icons.language, color: goldAccent, size: isMobile ? 18 : 22),
              SizedBox(width: isMobile ? 8 : 10),
              Expanded(child: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14), overflow: TextOverflow.ellipsis)),
              IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ]),
          ),
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)), child: HtmlElementView(viewType: viewType))),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HALAMAN UTAMA SLAID (RESPONSIF, TANPA BINGKAI, 3 LAJUR)
// ═══════════════════════════════════════════════════════
class SlaidPage extends StatefulWidget {
  final String userRole;
  const SlaidPage({super.key, this.userRole = 'user'});
  @override State<SlaidPage> createState() => _SlaidPageState();
}

class _SlaidPageState extends State<SlaidPage> {
  List<Map<String, dynamic>> masterCategories = [
    {'id': 1, 'title': 'SLAID RASMI\nATOM MALAYSIA', 'category': 'Slaid Rasmi', 'icon': Icons.slideshow},
    {'id': 2, 'title': 'SLAID 40\nTAHUN', 'category': 'Slaid 40 Tahun', 'icon': Icons.ondemand_video},
    {'id': 3, 'title': 'LAIN-\nLAIN', 'category': 'Slaid Lain-Lain', 'icon': Icons.more_horiz},
  ];
  List<dynamic> dynamicCategories = [];
  bool isLoadingDB = true;

  @override void initState() { super.initState(); _fetchKotak(); }

  Future<void> _fetchKotak() async {
    setState(() => isLoadingDB = true);
    try {
      final res = await http.get(Uri.parse('$apiDbUrl/get_kotak.php?parent=Slaid'));
      if (res.statusCode == 200) {
        setState(() { dynamicCategories = jsonDecode(res.body) ?? []; isLoadingDB = false; });
      } else { setState(() => isLoadingDB = false); }
    } catch (_) { setState(() { dynamicCategories = []; isLoadingDB = false; }); }
  }

  // ---------- DIALOG MUAT NAIK (RESPONSIF) ----------
  void _showUploadDialog(BuildContext context) {
    List<PlatformFile> selectedFiles = [];
    String selectedCategory = masterCategories.first['title'];
    bool isUploading = false; double uploadProgress = 0.0;
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    bool isLinkMode = false;

    List<String> dropdownList = [];
    for (var cat in masterCategories) dropdownList.add(cat['title']);
    for (var cat in dynamicCategories) dropdownList.add(cat['nama_kotak']);
    globalSlaidSubCategories.forEach((parent, subs) { for (var sub in subs) dropdownList.add("$parent > ${sub['title']}"); });
    if (dropdownList.isNotEmpty && !dropdownList.contains(selectedCategory)) selectedCategory = dropdownList.first;

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 550,
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent.withOpacity(0.4))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [Icon(Icons.slideshow, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 12), Text('MUAT NAIK SLAID / PAUTAN', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))]),
                  if (!isUploading) IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                ]),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 15 : 30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = false), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: !isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)), border: Border.all(color: !isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Fail Slaid", style: TextStyle(color: !isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
                    Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = true), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)), border: Border.all(color: isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Pautan URL", style: TextStyle(color: isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
                  ]),
                  SizedBox(height: isMobile ? 15 : 25),
                  Text("Kategori Destinasi", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownList.contains(selectedCategory) ? selectedCategory : dropdownList.first,
                        dropdownColor: darkCard, isExpanded: true,
                        icon: Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: isMobile ? 18 : 22)),
                        items: dropdownList.map((cat) => DropdownMenuItem<String>(value: cat, child: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text(cat.replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14))))).toList(),
                        onChanged: (v) => setDialogState(() => selectedCategory = v!),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 15 : 20),
                  Text(isLinkMode ? "Tajuk Pautan (Wajib)" : "Nama Fail Slaid (Pilihan)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(controller: nameController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: isLinkMode ? 'Cth: Pautan Slaid Canva' : 'Cth: Slaid Pembentangan', hintStyle: const TextStyle(color: softText), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  SizedBox(height: isMobile ? 12 : 20),
                  if (isLinkMode) ...[
                    Text("Pautan URL", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(controller: urlController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(prefixIcon: Icon(Icons.link, color: goldAccent, size: isMobile ? 18 : 20), hintText: 'https://...', hintStyle: const TextStyle(color: softText), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  ] else ...[
                    Text("Pilih Fail Slaid (Max 10)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        // 💥 FIX UPLOAD 1: WAJIB ADA withData: true 💥
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true, withData: true);
                        if (result != null) {
                          setDialogState(() {
                            if (result.files.length > 10) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 10 fail sahaja!'), backgroundColor: Colors.orange)); selectedFiles = result.files.take(10).toList(); }
                            else { selectedFiles = result.files; }
                            if (nameController.text.isEmpty && selectedFiles.isNotEmpty) nameController.text = selectedFiles.first.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity, height: isMobile ? 75 : 90,
                        decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12), border: Border.all(color: selectedFiles.isNotEmpty ? goldAccent : Colors.transparent, width: 1.5)),
                        child: selectedFiles.isNotEmpty
                            ? Padding(padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.slideshow, color: goldAccent, size: isMobile ? 24 : 30)), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('${selectedFiles.length} Fail Dipilih', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('✓ Sedia dimuat naik', style: TextStyle(color: goldAccent, fontSize: isMobile ? 10 : 11))])),]))
                            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload, color: softText, size: isMobile ? 20 : 24), SizedBox(width: 12), Text('Klik untuk pilih fail', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13))]),
                      ),
                    ),
                  ],
                  SizedBox(height: isMobile ? 20 : 30),
                  if (isUploading) ...[
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: uploadProgress, minHeight: 10, backgroundColor: Colors.black26, color: goldAccent)),
                    SizedBox(height: 8), Center(child: Text('${(uploadProgress * 100).toInt()}% Dimuat Naik', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13))),
                    SizedBox(height: 15),
                  ],
                  SizedBox(
                    width: double.infinity, height: isMobile ? 42 : 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: (isUploading) ? null : () async {
                        if (isLinkMode && (urlController.text.isEmpty || nameController.text.isEmpty)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila lengkapkan maklumat!'), backgroundColor: Colors.orange)); return; }
                        if (!isLinkMode && selectedFiles.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila pilih fail slaid!'), backgroundColor: Colors.orange)); return; }
                        setDialogState(() { isUploading = true; uploadProgress = 0.0; });
                        try {
                          String finalCategory = 'Slaid Lain-Lain';
                          for (var cat in masterCategories) { if (cat['title'] == selectedCategory) { finalCategory = cat['category']; break; } }
                          if (finalCategory == 'Slaid Lain-Lain') { for (var cat in dynamicCategories) { if (cat['nama_kotak'] == selectedCategory) { finalCategory = 'Slaid ${cat['nama_kotak']}'; break; } } }
                          if (isLinkMode) {
                            var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                            request.fields['kategori'] = finalCategory;
                            // 💥 FIX UPLOAD 2: BERSIHKAN NAMA URL 💥
                            String safeName = nameController.text.trim().replaceAll(RegExp(r'[^\w\s\-]+'), '_').replaceAll(' ', '_');
                            request.files.add(http.MultipartFile.fromBytes('file', Uint8List.fromList(utf8.encode(urlController.text)), filename: '$safeName.link'));
                            var response = await request.send();
                            var responseBody = await response.stream.bytesToString();
                            if(response.statusCode == 200 && !responseBody.contains('"status":"error"')) {
                              setDialogState(() => uploadProgress = 1.0);
                            } else {
                              throw Exception("Gagal muat naik pautan.");
                            }
                          } else {
                            int total = selectedFiles.length;
                            for (int i = 0; i < total; i++) {
                              var file = selectedFiles[i];
                              var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                              request.fields['kategori'] = finalCategory;
                              
                              // 💥 FIX UPLOAD 3: BERSIHKAN NAMA FAIL FIZIKAL & CEK KOSONG 💥
                              String safeFileName = file.name.replaceAll(RegExp(r'[^\w\.\-]'), '_');
                              if (file.bytes == null || file.bytes!.isEmpty) throw Exception("Data fail '${file.name}' kosong.");
                              
                              request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: safeFileName));
                              var response = await request.send();
                              var responseBody = await response.stream.bytesToString();
                              if (response.statusCode == 200) {
                                if (responseBody.contains('"status":"error"')) throw Exception("Pelayan menolak fail.");
                                setDialogState(() => uploadProgress = (i + 1) / total);
                              } else {
                                throw Exception("Ralat pelayan IIS");
                              }
                            }
                          }
                          Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berjaya dimuat naik ke $finalCategory!'), backgroundColor: Colors.green));
                        } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat: $e'), backgroundColor: crimsonRed)); }
                        finally { if (mounted) setDialogState(() => isUploading = false); }
                      },
                      child: isUploading ? Text('SEDANG MEMUAT NAIK...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 13)) : Text('MULA MUAT NAIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 14)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ---------- URUS KOTAK (RESPONSIF) ----------
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
            child: Column(children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(children: [
                  Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 15),
                  Expanded(child: Text('PENGURUSAN KOTAK SLAID', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                    onPressed: () async {
                      var result = await showDialog(context: context, builder: (_) => const TambahKategoriSlaidDialog());
                      if (result != null) {
                        try {
                          await http.post(Uri.parse('$apiDbUrl/add_kotak.php'), body: {
                            'nama': result['title'],
                            'parent': 'Slaid',
                            'icon_code': result['icon_name'], 
                          });
                          _fetchKotak(); setModalState((){});
                        } catch (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan kotak'), backgroundColor: crimsonRed)); }
                      }
                    },
                    icon: Icon(Icons.add, size: isMobile ? 14 : 16), label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                  ),
                  SizedBox(width: isMobile ? 4 : 15), IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                ]),
              ),
              Expanded(
                child: isLoadingDB ? const Center(child: CircularProgressIndicator(color: goldAccent)) : ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 25), itemCount: dynamicCategories.length,
                  itemBuilder: (ctx, i) {
                    var cat = dynamicCategories[i];
                    final icon = SlaidIcons.getIcon(cat['icon_code']); 
                    return Container(
                      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12), padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                      decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        CircleAvatar(backgroundColor: goldAccent.withOpacity(0.2), radius: isMobile ? 18 : 20, child: Icon(icon, color: goldAccent, size: isMobile ? 18 : 20)),
                        SizedBox(width: isMobile ? 10 : 15),
                        Expanded(child: Text(cat['nama_kotak'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                        IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), onPressed: () async {
                          var result = await showDialog(context: ctx, builder: (c) => TambahKategoriSlaidDialog(existingData: cat));
                          if (result != null) {
                            await http.post(Uri.parse('$apiDbUrl/update_kotak.php'), body: {
                              'id': cat['id'].toString(),
                              'nama': result['title'],
                              'icon_code': result['icon_name'],
                            });
                            _fetchKotak(); setModalState((){});
                          }
                        }),
                        SizedBox(width: 4),
                        IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), onPressed: () async {
                          bool confirm = await sahkanKeselamatanPadam(context, cat['nama_kotak'].replaceAll('\n', ' '));
                          if (confirm) { await http.post(Uri.parse('$apiDbUrl/delete_kotak.php'), body: {'id': cat['id'].toString()}); _fetchKotak(); setModalState((){}); }
                        }),
                      ]),
                    );
                  },
                ),
              ),
            ]),
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
      body: Column(children: [
        // Header responsif
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
              child: Column(children: [
                Text('S L A I D', style: TextStyle(color: darkCard, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w900, letterSpacing: 5.0)),
                SizedBox(height: isMobile ? 8 : 10),
                Text('Templat pembentangan rasmi jabatan.', style: TextStyle(color: darkCard, fontSize: isMobile ? 12 : 14)),
                SizedBox(height: isMobile ? 30 : 50),
                // Grid master (3 lajur desktop, 2 mobile)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Wrap(
                    spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 25, alignment: WrapAlignment.center,
                    children: masterCategories.map((cat) => HoverableCategoryCard(
                      icon: cat['icon'], title: cat['title'], isMobile: isMobile,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicSlaidCategoryPage(title: cat['title'].replaceAll('\n', ' '), category: cat['category'], userRole: widget.userRole))),
                    )).toList(),
                  ),
                ),
                if (dynamicCategories.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 30 : 40), const Divider(color: Colors.black12, thickness: 2), SizedBox(height: isMobile ? 30 : 40),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Wrap(
                      spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 25, alignment: WrapAlignment.center,
                      children: dynamicCategories.map((cat) {
                        final icon = SlaidIcons.getIcon(cat['icon_code']); // gunakan mapping
                        return HoverableCategoryCard(
                          icon: icon, title: cat['nama_kotak'], isMobile: isMobile,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicSlaidCategoryPage(title: cat['nama_kotak'].replaceAll('\n', ' '), category: 'Slaid ${cat['nama_kotak']}', userRole: widget.userRole))),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                SizedBox(height: isMobile ? 60 : 100),
              ]),
            ),
          ),
        ),
        // Footer
        Container(width: double.infinity, padding: EdgeInsets.all(isMobile ? 12 : 15), color: darkCard, child: Text('Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat, Jabatan Tenaga Atom.', textAlign: TextAlign.center, style: TextStyle(color: softText, fontSize: isMobile ? 10 : 11))),
      ]),
    );
  }

  Widget _buildDesktopHeader() => Row(children: [
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

  Widget _buildMobileHeader() => Row(children: [
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

// ═══════════════════════════════════════════════════════
// DIALOG TAMBAH KOTAK SLAID (GUNA NAMA IKON)
// ═══════════════════════════════════════════════════════
class TambahKategoriSlaidDialog extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  const TambahKategoriSlaidDialog({super.key, this.existingData});
  @override State<TambahKategoriSlaidDialog> createState() => _TambahKategoriSlaidDialogState();
}

class _TambahKategoriSlaidDialogState extends State<TambahKategoriSlaidDialog> {
  TextEditingController titleCtrl = TextEditingController();
  String _selectedIconName = 'slideshow_outlined'; // simpan nama ikon

  // Senarai nama ikon yang selari dengan pemalar Icons
  static const List<String> iconNameList = [
    'slideshow_outlined',
    'ondemand_video',
    'computer',
    'picture_as_pdf',
    'video_camera_back_outlined',
    'event_available_outlined',
    'public_outlined',
    'folder_shared_outlined',
  ];

  @override void initState() {
    super.initState();
    if (widget.existingData != null) {
      titleCtrl.text = widget.existingData!['title'] ?? widget.existingData!['nama_kotak'] ?? '';
      if (widget.existingData!['icon_name'] != null) {
        _selectedIconName = widget.existingData!['icon_name'];
      } else if (widget.existingData!['icon_code'] != null) {
        // jika masih ada data lama, cuba dapatkan nama ikon
        _selectedIconName = widget.existingData!['icon_code'];
      }
    }
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
          Row(children: [Icon(isEdit ? Icons.edit : Icons.add_box, color: goldAccent), SizedBox(width: 10), Text(isEdit ? 'UBAH KOTAK' : 'TAMBAH KOTAK BARU', style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold))]),
          SizedBox(height: isMobile ? 15 : 25),
          Text('Nama Kategori', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12)),
          SizedBox(height: 8),
          TextField(controller: titleCtrl, style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), hintText: 'Cth: Slaid Canva', hintStyle: TextStyle(color: softText), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          SizedBox(height: isMobile ? 12 : 20),
          Text('Pilih Ikon', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12)),
          SizedBox(height: 8),
          Container(
            height: isMobile ? 120 : 150, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              child: Wrap(spacing: 12, runSpacing: 12, children: iconNameList.map((name) {
                final icon = SlaidIcons.getIcon(name);
                final selected = _selectedIconName == name;
                return InkWell(
                  onTap: () => setState(() => _selectedIconName = name),
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
                if (titleCtrl.text.isNotEmpty) Navigator.pop(context, {'title': titleCtrl.text, 'icon_name': _selectedIconName});
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
// KAD KATEGORI (HOVER, SAIZ TETAP)
// ═══════════════════════════════════════════════════════
class HoverableCategoryCard extends StatefulWidget {
  final IconData? icon; final String title; final VoidCallback? onTap; final bool isMobile;
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
      onEnter: (_) => setState(() => isHovered = true), onExit: (_) => setState(() => isHovered = false), cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
          width: width, height: height,
          child: Container(
            width: width, height: height,
            decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(24), border: Border.all(color: solidBlack, width: 4), boxShadow: [if (isHovered) BoxShadow(color: solidBlack.withOpacity(0.3), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10)) else BoxShadow(color: solidBlack.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(child: Padding(padding: const EdgeInsets.all(25.0), child: Icon(widget.icon ?? Icons.slideshow, color: solidBlack, size: iconSize))),
              Container(
                width: double.infinity, padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 12 : 15, horizontal: 10),
                decoration: BoxDecoration(color: isHovered ? solidBlack : Colors.black87, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18))),
                child: Text(widget.title.replaceAll('\n', ' '), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: goldAccent, fontSize: widget.isMobile ? 10 : 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HALAMAN DINAMIK KATEGORI SLAID (RESPONSIF, LENGKAP)
// ═══════════════════════════════════════════════════════
class DynamicSlaidCategoryPage extends StatefulWidget {
  final String title; final String category; final String userRole;
  const DynamicSlaidCategoryPage({super.key, required this.title, required this.category, required this.userRole});
  @override State<DynamicSlaidCategoryPage> createState() => _DynamicSlaidCategoryPageState();
}

class _DynamicSlaidCategoryPageState extends State<DynamicSlaidCategoryPage> {
  String searchQuery = ''; String sortOption = 'Terbaru'; List<dynamic> allFiles = []; bool isLoading = true;
  bool isDeleteMode = false; Set<String> selectedFilesToDelete = {};

  @override void initState() { super.initState(); _fetchCategoryFiles(); }

  Future<void> _fetchCategoryFiles() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('$apiFileUrl/get_files.php?kategori=${Uri.encodeComponent(widget.category)}'));
      if (res.statusCode == 200) setState(() { allFiles = jsonDecode(res.body); isLoading = false; selectedFilesToDelete.clear(); });
      else setState(() => isLoading = false);
    } catch (_) { setState(() => isLoading = false); }
  }

  Future<void> _padamFailPukal() async {
    if (selectedFilesToDelete.isEmpty) return;
    bool confirm = await sahkanKeselamatanPadam(context, "${selectedFilesToDelete.length} fail");
    if (!confirm) return;
    setState(() => isLoading = true);
    int success = 0;
    for (String path in selectedFilesToDelete) {
      try { await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': path})); success++; } catch (_) {}
    }
    setState(() { isDeleteMode = false; selectedFilesToDelete.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$success fail dipadam!'), backgroundColor: Colors.green));
    _fetchCategoryFiles();
  }

  Future<void> _renameFile(String filePath, String currentName) async {
    String clean = currentName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    TextEditingController ctrl = TextEditingController(text: clean);
    bool? ok = await showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: darkCard, title: const Text('Tukar Nama Fail', style: TextStyle(color: Colors.white)), content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: inputDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack), onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan'))]));
    if (ok == true && ctrl.text.isNotEmpty) { await http.post(Uri.parse('$apiFileUrl/rename_file.php'), body: jsonEncode({'old_path': filePath, 'new_name': ctrl.text})); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama ditukar!'), backgroundColor: Colors.green)); _fetchCategoryFiles(); }
  }

  // 💥 FIX DOWNLOAD: Tukar 'file=' kepada 'path=' 💥
  void _muatTurunFail(String filePath, String fileName) { html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')..setAttribute('download', fileName)..click(); }

  void _paparImejLuar(BuildContext context, String cleanUrl, String fileName) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent, insetPadding: EdgeInsets.all(isMobile ? 15 : 30),
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 700),
        decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)]),
        padding: EdgeInsets.all(isMobile ? 15 : 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), style: TextStyle(color: goldAccent, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold))), IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(ctx))]),
          const Divider(color: Colors.white24), const SizedBox(height: 10),
          Flexible(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Image.network(cleanUrl, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.white54, size: 80))))),
        ]),
      ),
    ));
  }

  Future<void> _lihatAtauBukaLink(String fileUrl, String ext, String filePath) async {
    String e = ext.toLowerCase();
    if (e == 'link') {
      try {
        final res = await http.get(Uri.parse('$apiFileUrl/read_link.php?path=${Uri.encodeComponent(filePath)}'));
        if (res.statusCode == 200) {
          String link = res.body.trim(); if (!link.startsWith('http')) link = 'https://$link';
          showDialog(context: context, builder: (_) => WebPopupDialog(url: link, title: filePath.split('/').last.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')));
        }
      } catch (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tak Boleh View'), backgroundColor: Colors.orange)); }
    } else if (['png','jpg','jpeg','gif','bmp','webp','svg'].contains(e)) {
      _paparImejLuar(context, cleanImageUrl(fileUrl), filePath.split('/').last);
    } else if (['mp3','wav','aac','ogg','mp4','webm','mov'].contains(e)) {
      showDialog(context: context, builder: (_) => MediaPopupDialog(mediaUrl: cleanImageUrl(fileUrl), title: filePath.split('/').last.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')));
    } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format fail tidak disokong untuk paparan terus.'), backgroundColor: Colors.orange)); }
  }

  void _bukaUrusSubKotakPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    List<Map<String, dynamic>> subBoxes = globalSlaidSubCategories[widget.category] ?? [];
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 600,
            height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600,
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent.withOpacity(0.3))),
            child: Column(children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(children: [
                  Icon(Icons.create_new_folder_outlined, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 15),
                  Expanded(child: Text('PENGURUSAN SUB-KOTAK', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                    onPressed: () async {
                      var result = await showDialog(context: ctx, builder: (_) => const TambahKategoriSlaidDialog());
                      if (result != null) {
                        setModalState(() {
                          globalSlaidSubCategories.putIfAbsent(widget.category, () => []);
                          globalSlaidSubCategories[widget.category]!.add({
                            'id': DateTime.now().millisecondsSinceEpoch,
                            'title': result['title'],
                            'category': '${widget.category} > ${result['title']}',
                            'icon_name': result['icon_name'],
                          });
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
                child: subBoxes.isEmpty ? const Center(child: Text("Tiada sub-kotak.", style: TextStyle(color: softText))) : ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 25), itemCount: subBoxes.length,
                  itemBuilder: (ctx, i) {
                    var sub = subBoxes[i]; final icon = SlaidIcons.getIcon(sub['icon_name']);
                    return Container(
                      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12), padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                      decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        CircleAvatar(backgroundColor: goldAccent.withOpacity(0.2), radius: isMobile ? 18 : 20, child: Icon(icon, color: goldAccent, size: isMobile ? 18 : 20)),
                        SizedBox(width: isMobile ? 10 : 15),
                        Expanded(child: Text(sub['title'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                        IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), onPressed: () async {
                          var result = await showDialog(context: ctx, builder: (c) => TambahKategoriSlaidDialog(existingData: {'title': sub['title'], 'icon_name': sub['icon_name']}));
                          if (result != null) { setModalState(() { sub['title'] = result['title']; sub['category'] = '${widget.category} > ${result['title'].replaceAll('\n', ' ')}'; sub['icon_name'] = result['icon_name']; }); setState((){}); }
                        }),
                        SizedBox(width: 4),
                        IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), onPressed: () async {
                          bool confirm = await sahkanKeselamatanPadam(ctx, sub['title'].replaceAll('\n', ' '));
                          if (confirm) { setModalState(() => subBoxes.removeAt(i)); setState((){}); }
                        }),
                      ]),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';
    bool bolehUrusKotak = widget.userRole == 'super_admin';
    List<Map<String, dynamic>> subBoxes = globalSlaidSubCategories[widget.category] ?? [];

    List<dynamic> filteredFiles = allFiles.where((f) {
      String name = f['name']; String display = name.contains('_') ? name.substring(name.indexOf('_')+1) : name;
      return display.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    if (sortOption == 'A-Z') filteredFiles.sort((a,b) => a['name'].compareTo(b['name']));
    else if (sortOption == 'Z-A') filteredFiles.sort((a,b) => b['name'].compareTo(a['name']));

    return Scaffold(
      backgroundColor: solidBlack,
      body: Stack(children: [
        Column(children: [
          // Header responsif
          Container(
            height: 70, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40),
            decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
            child: Row(children: [
              IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(context)),
              SizedBox(width: isMobile ? 8 : 12),
              Image.asset('Assets/Images/logo_ukk-bg.png', height: isMobile ? 28 : 35, errorBuilder: (_,__,___) => Icon(Icons.broken_image, color: goldAccent)),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(child: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.bold, letterSpacing: 1.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const Spacer(),
              if (bolehUrusKotak) ...[
                ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, elevation: 0, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 15, vertical: isMobile ? 8 : 15)), onPressed: _bukaUrusSubKotakPanel, icon: Icon(Icons.create_new_folder_outlined, size: isMobile ? 14 : 16), label: Text("Urus Kotak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12))),
                SizedBox(width: isMobile ? 6 : 10),
              ],
              if (bolehEditDelete) ...[
                ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: isDeleteMode ? crimsonRed : Colors.white10, foregroundColor: Colors.white, elevation: 0, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 15, vertical: isMobile ? 8 : 15)), onPressed: () => setState(() { isDeleteMode = !isDeleteMode; if (!isDeleteMode) selectedFilesToDelete.clear(); }), icon: Icon(isDeleteMode ? Icons.close : Icons.checklist_rtl_rounded, size: isMobile ? 14 : 16), label: Text(isDeleteMode ? "Batal Padam" : "Mod Padam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12))),
                SizedBox(width: isMobile ? 6 : 10),
              ],
              IconButton(icon: Icon(Icons.refresh, color: goldAccent, size: isMobile ? 18 : 20), onPressed: _fetchCategoryFiles, padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 36, minHeight: 36)),
            ]),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: isMobile ? 15 : 25),
                  child: Row(children: [
                    Expanded(child: SizedBox(height: isMobile ? 42 : 50, child: TextField(style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: 'Cari fail...', hintStyle: TextStyle(color: softText), prefixIcon: Icon(Icons.search, color: goldAccent, size: isMobile ? 18 : 20), filled: true, fillColor: darkCard, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), onChanged: (v) => setState(() => searchQuery = v)))),
                    SizedBox(width: isMobile ? 8 : 15),
                    Container(height: isMobile ? 42 : 50, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(15)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: sortOption, dropdownColor: darkCard, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold), icon: Icon(Icons.sort, color: goldAccent, size: isMobile ? 18 : 20), items: ['Terbaru','Lama','A-Z','Z-A'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => sortOption = v!)))),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 10, isMobile ? 16 : 40, isDeleteMode ? 80 : 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (subBoxes.isNotEmpty) ...[
                        Text('KOTAK DALAMAN', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                        SizedBox(height: isMobile ? 12 : 20),
                        Wrap(spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 25, children: subBoxes.map((sub) => HoverableCategoryCard(icon: SlaidIcons.getIcon(sub['icon_name']), title: sub['title'], isMobile: isMobile, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicSlaidCategoryPage(title: sub['title'].replaceAll('\n', ' '), category: sub['category'], userRole: widget.userRole))))).toList()),
                        SizedBox(height: isMobile ? 20 : 40), const Divider(color: Colors.black12, thickness: 2), SizedBox(height: isMobile ? 20 : 40),
                      ],
                      if (isLoading) const Center(child: CircularProgressIndicator(color: darkCard))
                      else if (filteredFiles.isNotEmpty) ...[
                        if (subBoxes.isNotEmpty) Text('SENARAI FAIL', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                        SizedBox(height: isMobile ? 12 : 20),
                        Wrap(spacing: isMobile ? 12 : 25, runSpacing: isMobile ? 12 : 30, children: filteredFiles.map((file) {
                          String rawName = file['name']; String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_')+1) : rawName;
                          String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';
                          bool isSelected = selectedFilesToDelete.contains(file['path']);
                          return MinimalSlaidCard(
                            fileName: displayName, ext: ext, isMobile: isMobile,
                            showActions: bolehEditDelete && !isDeleteMode, isSelectionMode: isDeleteMode, isSelected: isSelected,
                            onToggleSelect: () => setState(() { if (isSelected) selectedFilesToDelete.remove(file['path']); else selectedFilesToDelete.add(file['path']); }),
                            onView: () => _lihatAtauBukaLink(file['url'], ext, file['path']),
                            onDownload: () => _muatTurunFail(file['path'], displayName),
                            onRename: () => _renameFile(file['path'], displayName),
                          );
                        }).toList()),
                      ] else if (subBoxes.isEmpty) Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.file_present_outlined, color: softText, size: 50), SizedBox(height: 10), Text("Tiada fail dijumpai.", style: TextStyle(color: softText))])),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ]),
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
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KAD SLAID MINIMALIS (RESPONSIF)
// ═══════════════════════════════════════════════════════
class MinimalSlaidCard extends StatefulWidget {
  final String fileName, ext; final bool showActions, isMobile, isSelectionMode, isSelected;
  final VoidCallback onView, onDownload, onRename; final VoidCallback? onToggleSelect;
  const MinimalSlaidCard({super.key, required this.fileName, required this.ext, required this.onView, required this.onDownload, required this.onRename, this.showActions = true, this.isMobile = false, this.isSelectionMode = false, this.isSelected = false, this.onToggleSelect});
  @override State<MinimalSlaidCard> createState() => _MinimalSlaidCardState();
}

class _MinimalSlaidCardState extends State<MinimalSlaidCard> {
  bool isHovered = false;
  Widget _iconByExt(String ext) {
    if (ext == 'link') return const Icon(Icons.link, color: Colors.greenAccent, size: 50);
    if (ext == 'pdf') return const Icon(Icons.picture_as_pdf, color: crimsonRed, size: 50);
    if (['mp3','wav','aac','ogg'].contains(ext)) return const Icon(Icons.audiotrack, color: Colors.purpleAccent, size: 50);
    if (['png','jpg','jpeg','gif','bmp','webp','svg'].contains(ext)) return const Icon(Icons.image, color: Colors.tealAccent, size: 50);
    if (['mp4','mov','avi','mkv','webm'].contains(ext)) return const Icon(Icons.play_circle_outline, color: goldAccent, size: 50);
    return const Icon(Icons.insert_drive_file, color: goldAccent, size: 50);
  }

  @override Widget build(BuildContext context) {
    double boxSize = widget.isMobile ? 130 : 180;
    bool isLink = widget.ext == 'link';
    bool isViewable = isLink || ['mp4','mov','avi','mkv','webm','ogg'].contains(widget.ext.toLowerCase()) || ['mp3','wav','aac'].contains(widget.ext.toLowerCase()) || ['png','jpg','jpeg','gif','bmp','webp','svg'].contains(widget.ext.toLowerCase());

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true), onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.isSelectionMode ? widget.onToggleSelect : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250), transform: Matrix4.identity()..translate(0.0, (isHovered && !widget.isSelectionMode) ? -6.0 : 0.0),
          child: Container(
            width: boxSize, height: boxSize,
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: widget.isSelected ? crimsonRed : (isHovered && !widget.isSelectionMode ? goldAccent : Colors.transparent), width: widget.isSelected ? 3 : 2), boxShadow: [if (isHovered && !widget.isSelectionMode) BoxShadow(color: goldAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)) else BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(fit: StackFit.expand, children: [
                Container(color: darkCard, child: Center(child: _iconByExt(widget.ext))),
                if (isHovered && !widget.isSelectionMode) Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.9)], stops: const [0.4, 1.0]))),
                if (widget.isSelectionMode) Container(color: widget.isSelected ? crimsonRed.withOpacity(0.3) : Colors.black.withOpacity(0.4), child: Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.all(10), child: Container(decoration: BoxDecoration(color: widget.isSelected ? crimsonRed : Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), padding: const EdgeInsets.all(4), child: Icon(Icons.check, size: 16, color: widget.isSelected ? Colors.white : Colors.transparent))))),
                if (isHovered && !widget.isSelectionMode)
                  Positioned(bottom: 12, left: 8, right: 8, child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: widget.isMobile ? 11 : 13)),
                    SizedBox(height: widget.isMobile ? 8 : 10),
                    Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
                      if (widget.showActions) _btn(Icons.edit, goldAccent, widget.onRename),
                      _btn(isViewable ? (isLink ? Icons.open_in_new : Icons.visibility) : Icons.visibility_off, isViewable ? Colors.blue : Colors.grey, widget.onView),
                      _btn(Icons.download, Colors.green, widget.onDownload),
                    ]),
                  ])),
              ]),
            ),
          ),
        ),
      ),
    );
  }
  Widget _btn(IconData icon, Color color, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(30), child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5))), child: Icon(icon, color: color, size: widget.isMobile ? 14 : 16)));
}