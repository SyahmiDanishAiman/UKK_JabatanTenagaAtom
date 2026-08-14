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
// 💥 FIX UTAMA: FUNGSI PEMBERSIH URL GAMBAR (Bypass CORS) 💥
// ═══════════════════════════════════════════════════════
String cleanImageUrl(String rawUrl) {
  if (rawUrl.isEmpty) return '';
  String pathOnly = Uri.decodeFull(Uri.decodeFull(rawUrl)).replaceAll('\\', '/');
  if (pathOnly.startsWith('http')) {
    pathOnly = pathOnly.replaceFirst('$apiFileUrl/', '');
  }
  if (pathOnly.startsWith('/')) pathOnly = pathOnly.substring(1);
  return '$apiFileUrl/lihat_gambar.php?path=${Uri.encodeComponent(pathOnly)}';
}

// ═══════════════════════════════════════════════════════
// DATA KOTAK GLOBAL & SUB-KOTAK
// ═══════════════════════════════════════════════════════
List<Map<String, dynamic>> globalMasterCategories = [
  {'id': 1, 'title': 'WALLPAPER\nDESKTOP', 'category': 'Data Wallpaper', 'icon': Icons.desktop_windows_outlined},
  {'id': 2, 'title': 'TEMPLAT\nSIJIL', 'category': 'Data Sijil', 'icon': Icons.military_tech_outlined},
  {'id': 3, 'title': 'LETTER\nHEAD', 'category': 'Data Letter Head', 'icon': Icons.description_outlined},
  {'id': 4, 'title': 'MASKOT\nJABATAN', 'category': 'Data Maskot', 'icon': Icons.smart_toy_outlined},
  {'id': 5, 'title': 'SOCIAL MEDIA\n(SOCMED)', 'category': 'Data Socmed', 'icon': Icons.share_outlined},
];

Map<String, List<Map<String, dynamic>>> globalSubCategories = {};

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
// MEDIA POPUP DIALOG (Untuk audio / video)
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
// WEB POPUP DIALOG (Untuk pautan luar)
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
// HALAMAN UTAMA: DATA ANALITIK PAGE
// ═══════════════════════════════════════════════════════
class DataPage extends StatefulWidget {
  final String userRole; 
  const DataPage({super.key, this.userRole = 'user'});
  
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List<dynamic> dynamicCategories = [];
  bool isLoadingDB = true;

  @override
  void initState() { super.initState(); _fetchKotak(); }

  Future<void> _fetchKotak() async {
    setState(() => isLoadingDB = true);
    try {
      final res = await http.get(Uri.parse('$apiDbUrl/get_kotak.php?parent=Data Analitik'));
      if (res.statusCode == 200) {
        setState(() { dynamicCategories = jsonDecode(res.body) ?? []; isLoadingDB = false; });
      } else { setState(() => isLoadingDB = false); }
    } catch (e) { setState(() { dynamicCategories = []; isLoadingDB = false; }); }
  }

  // ---------- DIALOG UPLOAD ----------
  void _showUploadDialog(BuildContext context) {
    List<PlatformFile> selectedFiles = [];
    double uploadProgress = 0.0;
    String uploadStatus = '';
    String selectedCategory = globalMasterCategories.isNotEmpty ? globalMasterCategories.first['title'].replaceAll('\n', ' ') : 'Wallpaper Desktop';
    String selectedSocmedSub = 'LOWER THIRD';
    bool isUploading = false;
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    bool isLinkMode = false;

    List<String> dropdownList = [];
    for (var cat in globalMasterCategories) { dropdownList.add(cat['title'].replaceAll('\n', ' ')); }
    for (var cat in dynamicCategories) { dropdownList.add(cat['nama_kotak'].replaceAll('\n', ' ')); }
    globalSubCategories.forEach((parent, subs) { for (var sub in subs) { dropdownList.add("$parent > ${sub['title']}"); } });

    final List<String> socmedSubs = ['LOWER THIRD', 'GMAIL SIGNATURE', 'FOOTER', 'QR CODE', 'IKON-IKON'];
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context, barrierDismissible: false, 
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            Future<void> pickFolder() async {
              final html.InputElement uploadInput = html.InputElement(type: 'file');
              uploadInput.setAttribute('webkitdirectory', 'true');
              uploadInput.setAttribute('directory', 'true');
              uploadInput.multiple = true;
              uploadInput.click();

              final completer = Completer<List<html.File>?>();
              uploadInput.onChange.listen((e) => completer.complete(uploadInput.files));
              Timer(const Duration(seconds: 10), () { if (!completer.isCompleted) completer.complete(null); });

              final files = await completer.future;
              if (files == null || files.isEmpty) return;

              List<html.File> validFiles = files;
              if (validFiles.length > 20) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 20 fail sahaja dibenarkan!'), backgroundColor: Colors.orange));
                validFiles = validFiles.take(20).toList();
              }

              List<Future<PlatformFile?>> tasks = [];
              for (int i = 0; i < validFiles.length; i++) {
                final f = validFiles[i];
                tasks.add(() async {
                  final reader = html.FileReader();
                  reader.readAsArrayBuffer(f);
                  final fileCompleter = Completer<List<int>?>();
                  reader.onLoadEnd.listen((_) => fileCompleter.complete(reader.result as List<int>?));
                  reader.onError.listen((_) => fileCompleter.complete(null));
                  
                  final bytes = await fileCompleter.future;
                  if (bytes != null) {
                    final rawRelative = f.relativePath?.isNotEmpty == true ? f.relativePath! : f.name;
                    final safeName = rawRelative.replaceAll('/', '___').replaceAll('\\', '___');
                    return PlatformFile(name: f.name, size: f.size, bytes: Uint8List.fromList(bytes), path: safeName);
                  }
                  return null;
                }());
              }

              final results = await Future.wait(tasks);
              final newFiles = results.whereType<PlatformFile>().toList();
              if (newFiles.isNotEmpty) { setDialogState(() { selectedFiles.addAll(newFiles); }); }
            }

            Future<void> pickZip() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom, allowedExtensions: ['zip'], allowMultiple: true, withData: true
              );
              if (result != null && result.files.isNotEmpty) {
                List<PlatformFile> newFiles = result.files;
                int remaining = 20 - selectedFiles.length;
                if (newFiles.length > remaining) {
                  newFiles = newFiles.take(remaining).toList();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hanya $remaining fail zip lagi dibenarkan (maks 20).'), backgroundColor: Colors.amber));
                }
                setDialogState(() {
                  selectedFiles.addAll(newFiles);
                  if (nameController.text.isEmpty && selectedFiles.isNotEmpty && !(selectedFiles.first.path?.contains('___') ?? false)) {
                    nameController.text = selectedFiles.first.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
                  }
                });
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 550, 
                decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent.withOpacity(0.3))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 25, vertical: isMobile ? 15 : 20),
                      decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [Icon(Icons.cloud_upload, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 12), Text('MUAT NAIK DATA / PAUTAN', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))]),
                          if (!isUploading) IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 22), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 15 : 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = false), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: !isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)), border: Border.all(color: !isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Fail Fizikal", style: TextStyle(color: !isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
                              Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = true), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)), border: Border.all(color: isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Pautan URL", style: TextStyle(color: isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
                            ],
                          ),
                          SizedBox(height: isMobile ? 15 : 25),

                          Text("Kategori Destinasi", style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: dropdownList.contains(selectedCategory) ? selectedCategory : dropdownList.first,
                                dropdownColor: darkCard, isExpanded: true,
                                icon: Padding(padding: const EdgeInsets.only(right: 15), child: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: isMobile ? 18 : 22)),
                                items: dropdownList.map((String cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat, 
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15), 
                                      child: Row(
                                        children: [
                                          Icon(cat.contains('>') ? Icons.subdirectory_arrow_right : Icons.folder, color: goldAccent, size: isMobile ? 16 : 18), 
                                          const SizedBox(width: 10), 
                                          Expanded(child: Text(cat, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), maxLines: 1, overflow: TextOverflow.ellipsis))
                                        ]
                                      )
                                    )
                                  );
                                }).toList(),
                                onChanged: (val) => setDialogState(() => selectedCategory = val!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: selectedCategory == 'SOCIAL MEDIA (SOCMED)' 
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [
                                    const SizedBox(height: 10), 
                                    Text('Pilih Bahan Social Media', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)), 
                                    const SizedBox(height: 10), 
                                    Wrap(spacing: 8, runSpacing: 8, children: socmedSubs.map((sub) => _buildSubCategoryBtn(sub, selectedSocmedSub, (val) => setDialogState(() => selectedSocmedSub = val), isMobile)).toList())
                                  ]
                                )
                              : const SizedBox.shrink(),
                          ),
                          SizedBox(height: isMobile ? 10 : 20),

                          if (isLinkMode) ...[
                            Text("Nama Pautan (Wajib)", style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                              decoration: InputDecoration(hintText: 'Cth: Pautan Folder AI Data', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                            ),
                            SizedBox(height: isMobile ? 12 : 20),
                            Text("Pautan URL Luar", style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: urlController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                              decoration: InputDecoration(prefixIcon: Icon(Icons.link, color: goldAccent, size: isMobile ? 18 : 22), hintText: 'https://...', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                            ),
                          ] else ...[
                            Text("Nama Fail / Folder (Pilihan)", style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                              decoration: InputDecoration(hintText: 'Hanya diguna jika 1 fail dimuat naik', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                            ),
                            SizedBox(height: isMobile ? 12 : 20),

                            Text("Sumber Fail (Max: 20 Fail)", style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (selectedFiles.isNotEmpty)
                              Container(
                                constraints: BoxConstraints(maxHeight: isMobile ? 90 : 110),
                                decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
                                child: ListView.builder(
                                  shrinkWrap: true, itemCount: selectedFiles.length,
                                  itemBuilder: (_, i) {
                                    final file = selectedFiles[i];
                                    final displayName = (file.path ?? file.name).replaceAll('___', '/'); 
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), 
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Icon(displayName.contains('/') ? Icons.folder : Icons.insert_drive_file, color: goldAccent, size: isMobile ? 16 : 20), 
                                          SizedBox(width: isMobile ? 8 : 10),
                                          Expanded(child: Text(displayName, style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          InkWell(
                                            onTap: () => setDialogState(() { 
                                              selectedFiles.removeAt(i); 
                                              if (selectedFiles.isEmpty) nameController.clear(); 
                                            }), 
                                            child: Icon(Icons.close, color: Colors.white38, size: isMobile ? 16 : 18)
                                          ),
                                        ]
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    label: 'Pilih Fail', icon: Icons.file_copy, isMobile: isMobile,
                                    onTap: () async {
                                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true, withData: true);
                                      if (result != null && result.files.isNotEmpty) {
                                        List<PlatformFile> newFiles = result.files;
                                        if (newFiles.length > 20) { 
                                          newFiles = newFiles.take(20).toList(); 
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 20 fail sahaja.'), backgroundColor: Colors.amber)); 
                                        }
                                        setDialogState(() { 
                                          selectedFiles.addAll(newFiles); 
                                          if (nameController.text.isEmpty && selectedFiles.isNotEmpty && !(selectedFiles.first.path?.contains('___') ?? false)) { 
                                            nameController.text = selectedFiles.first.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''); 
                                          } 
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(label: 'Pilih Folder', icon: Icons.folder_copy, onTap: () => pickFolder(), isMobile: isMobile)
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: _buildActionButton(
                                label: 'Pilih Zip', icon: Icons.archive, isMobile: isMobile,
                                onTap: () => pickZip(),
                              ),
                            ),
                          ],
                          
                          if (isUploading) ...[
                            const SizedBox(height: 20),
                            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: uploadProgress, backgroundColor: Colors.white10, color: goldAccent, minHeight: 6)),
                            const SizedBox(height: 10),
                            Center(child: Text(uploadStatus, style: TextStyle(color: goldAccent, fontSize: isMobile ? 11 : 13))),
                          ],
                          
                          SizedBox(height: isMobile ? 20 : 28),
                          SizedBox(
                            width: double.infinity, height: isMobile ? 40 : 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: (selectedFiles.isEmpty && !isLinkMode || isUploading) ? null : () async {
                                String finalCategory = 'Lain-lain';
                                if (selectedCategory == 'SOCIAL MEDIA (SOCMED)') {
                                  finalCategory = 'Socmed $selectedSocmedSub';
                                } else if (selectedCategory.contains(' > ')) {
                                  final parts = selectedCategory.split(' > ');
                                  if (parts.length == 2) {
                                    final parent = parts[0].trim();
                                    final sub = parts[1].trim();
                                    final subs = globalSubCategories[parent] ?? [];
                                    final found = subs.firstWhere((s) => s['title'] == sub, orElse: () => {});
                                    if (found.isNotEmpty) {
                                      finalCategory = found['category'];
                                    } else {
                                      finalCategory = 'Data $selectedCategory';
                                    }
                                  }
                                } else {
                                  bool found = false;
                                  for (var cat in globalMasterCategories) { 
                                    if (cat['title'].replaceAll('\n', ' ') == selectedCategory) { 
                                      finalCategory = cat['category']; found = true; break; 
                                    } 
                                  }
                                  if (!found) finalCategory = 'Data $selectedCategory';
                                }

                                setDialogState(() { isUploading = true; uploadProgress = 0.0; uploadStatus = 'Memulakan muat naik...'; });

                                try {
                                  if (isLinkMode) {
                                    var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                    request.fields['kategori'] = finalCategory;
                                    String safeName = nameController.text.trim().replaceAll(RegExp(r'[^\w\s\-]+'), '');
                                    Uint8List urlBytes = Uint8List.fromList(utf8.encode(urlController.text));
                                    request.files.add(http.MultipartFile.fromBytes('file', urlBytes, filename: '$safeName.link'));
                                    
                                    await request.send();
                                    setDialogState(() { uploadProgress = 1.0; uploadStatus = 'Selesai 100%'; });
                                  } else {
                                    final total = selectedFiles.length;
                                    for (int i = 0; i < total; i++) {
                                      setDialogState(() => uploadStatus = 'Memuat naik fail ${i + 1}/$total...');
                                      var file = selectedFiles[i];
                                      String fileNameToUpload = file.path ?? file.name; 

                                      if (nameController.text.trim().isNotEmpty && total == 1 && !fileNameToUpload.contains('___')) {
                                        String ext = fileNameToUpload.contains('.') ? fileNameToUpload.split('.').last : '';
                                        String safeCustomName = nameController.text.trim().replaceAll(RegExp(r'[^\w\s\-]+'), '');
                                        fileNameToUpload = ext.isNotEmpty ? '$safeCustomName.$ext' : safeCustomName;
                                      }

                                      var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                      request.fields['kategori'] = finalCategory;
                                      if (nameController.text.trim().isNotEmpty && total == 1 && !fileNameToUpload.contains('___')) {
                                        request.fields['custom_name'] = nameController.text.trim();
                                      }
                                      request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: fileNameToUpload));

                                      var response = await request.send();
                                      if (response.statusCode == 200) {
                                        setDialogState(() { uploadProgress = (i + 1) / total; });
                                      } else {
                                        setDialogState(() { isUploading = false; });
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terdapat ralat muat naik.'), backgroundColor: Colors.red));
                                        return;
                                      }
                                    }
                                  }
                                  
                                  setDialogState(() { uploadProgress = 1.0; uploadStatus = 'Selesai!'; });
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berjaya dimuat naik ke $finalCategory!'), backgroundColor: Colors.green));
                                  
                                } catch (e) {
                                  setDialogState(() => isUploading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat Server.'), backgroundColor: Colors.red));
                                }
                              },
                              child: isUploading ? Text('SEDANG MEMUAT NAIK...', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: isMobile ? 11 : 13)) : Text('MULA MUAT NAIK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: isMobile ? 12 : 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onTap, bool isMobile = false}) { 
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12), 
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 18), 
        decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12), border: Border.all(color: goldAccent.withOpacity(0.5), width: 1)), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [Icon(icon, color: goldAccent, size: isMobile ? 16 : 20), SizedBox(width: isMobile ? 6 : 8), Text(label, style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13))]
        )
      )
    ); 
  }

  Widget _buildSubCategoryBtn(String title, String currentSelected, Function(String) onTap, bool isMobile) { 
    bool isSelected = title == currentSelected; 
    return InkWell(
      onTap: () => onTap(title), borderRadius: BorderRadius.circular(8), 
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8, horizontal: isMobile ? 10 : 15), 
        decoration: BoxDecoration(color: isSelected ? goldAccent.withOpacity(0.2) : const Color(0xFF1E2025), border: Border.all(color: isSelected ? goldAccent : Colors.transparent), borderRadius: BorderRadius.circular(8)), 
        child: Text(title, style: TextStyle(color: isSelected ? goldAccent : Colors.white70, fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12))
      )
    ); 
  }

  void _bukaUrusKategoriPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 600, 
                height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600, 
                decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent.withOpacity(0.3))),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 25, vertical: isMobile ? 15 : 20), 
                      decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      child: Row(
                        children: [
                          Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 10 : 15),
                          Expanded(child: Text('PENGURUSAN KOTAK ANALITIK', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 6 : 8)),
                            onPressed: () async {
                              var result = await showDialog(context: context, builder: (_) => const TambahKategoriDialog());
                              if (result != null) {
                                try {
                                  await http.post(Uri.parse('$apiDbUrl/add_kotak.php'), body: {'nama': result['title'], 'parent': 'Data Analitik'});
                                  await _fetchKotak(); 
                                  setModalState(() {}); 
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat memanggil API Pangkalan Data.'), backgroundColor: Colors.red));
                                }
                              }
                            },
                            icon: Icon(Icons.add, size: isMobile ? 14 : 16), label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                          ),
                          SizedBox(width: isMobile ? 5 : 15),
                          IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: isLoadingDB
                          ? const Center(child: CircularProgressIndicator(color: goldAccent))
                          : ListView.builder(
                              padding: EdgeInsets.all(isMobile ? 15 : 25),
                              itemCount: dynamicCategories.length,
                              itemBuilder: (_, index) {
                                var cat = dynamicCategories[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: isMobile ? 8 : 12), padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                                  decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(width: isMobile ? 40 : 50, height: isMobile ? 40 : 50, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.pie_chart, color: goldAccent, size: isMobile ? 20 : 24)),
                                    title: Text(cat['nama_kotak'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                                    subtitle: Text('Folder DB: Data ${cat['nama_kotak']}', style: TextStyle(color: softText, fontSize: isMobile ? 10 : 12)),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 22),
                                      onPressed: () async {
                                        bool confirm = await sahkanKeselamatanPadam(context, cat['nama_kotak'].replaceAll('\n', ' '));
                                        if (confirm) {
                                          await http.post(Uri.parse('$apiDbUrl/delete_kotak.php'), body: {'id': cat['id'].toString()});
                                          await _fetchKotak(); setModalState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;
    bool bolehUpload = widget.userRole == 'super_admin' || widget.userRole == 'admin';
    bool bolehUrusKotak = widget.userRole == 'super_admin'; 

    return Scaffold(
      backgroundColor: solidBlack,
      body: Column(
        children: [
          // ==================== HEADER ====================
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
            decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
            child: SafeArea(bottom: false, child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(bolehUrusKotak, bolehUpload)),
          ),

          // ==================== BODY ====================
          Expanded(
            child: Container(
              width: double.infinity, 
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 30 : 60, horizontal: isMobile ? 15 : 0),
                child: Column(
                  children: [
                    Text('PANGKALAN DATA ASET', textAlign: TextAlign.center, style: TextStyle(color: darkCard, fontSize: isMobile ? 20 : 32, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                    const SizedBox(height: 10), 
                    Text('DATA ANALITIK', textAlign: TextAlign.center, style: TextStyle(color: darkCard.withOpacity(0.7), fontSize: isMobile ? 11 : 14, fontWeight: FontWeight.bold, letterSpacing: 4.0)),
                    SizedBox(height: isMobile ? 30 : 60),

                    // KOTAK UTAMA (STATIK)
                    Wrap(
                      spacing: isMobile ? 15 : 30, runSpacing: isMobile ? 15 : 30, alignment: WrapAlignment.center,
                      children: globalMasterCategories.map((cat) {
                        return HoverableStaticCard(
                          title: cat['title'], icon: cat['icon'], isMobile: isMobile, 
                          onTap: () {
                            if (cat['title'].contains('SOCIAL MEDIA')) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SubSocialMediaPage(userRole: widget.userRole))).then((_) => setState((){}));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicDataCategoryPage(title: cat['title'].replaceAll('\n', ' '), category: cat['category'], userRole: widget.userRole))).then((_) => setState((){}));
                            }
                          }
                        );
                      }).toList(),
                    ),
                    if (dynamicCategories.isNotEmpty) ...[
                      SizedBox(height: isMobile ? 30 : 50), 
                      const Divider(color: Colors.black12, thickness: 2, indent: 50, endIndent: 50), 
                      SizedBox(height: isMobile ? 30 : 50),
                      
                      // KOTAK DINAMIK
                      Wrap(
                        spacing: isMobile ? 15 : 30, runSpacing: isMobile ? 15 : 30, alignment: WrapAlignment.center,
                        children: dynamicCategories.map((cat) { 
                          return HoverableStaticCard(
                            title: cat['nama_kotak'].replaceAll('\n', ' '), icon: Icons.pie_chart_outline, isMobile: isMobile, 
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicDataCategoryPage(title: cat['nama_kotak'].replaceAll('\n', ' '), category: 'Data ${cat['nama_kotak']}', userRole: widget.userRole))).then((_) => setState((){}))
                          ); 
                        }).toList(),
                      ),
                    ],
                    SizedBox(height: isMobile ? 50 : 100),
                  ],
                ),
              ),
            ),
          ),
          Container(width: double.infinity, padding: EdgeInsets.all(isMobile ? 10 : 15), color: darkCard, child: Text('Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat, Jabatan Tenaga Atom.', textAlign: TextAlign.center, style: TextStyle(color: softText, fontSize: isMobile ? 9 : 11)))
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(bool bolehUrus, bool bolehUpload) => Row(children: [
    Image.asset('Assets/Images/logo_ukk-bg.png', height: 48, errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: goldAccent, size: 48)),
    const SizedBox(width: 16),
    Expanded(child: RichText(text: const TextSpan(style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5), children: [TextSpan(text: 'UKK ', style: TextStyle(color: Colors.white)), TextSpan(text: 'JABATAN TENAGA ATOM', style: TextStyle(color: Color(0xFFE0E0E0)))]))),
    const Spacer(),
    if (bolehUrus) ...[
      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)), onPressed: _bukaUrusKategoriPanel, icon: const Icon(Icons.grid_view_rounded, size: 16), label: const Text("Urus Kotak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      const SizedBox(width: 10),
    ],
    if (bolehUpload) ...[
      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)), onPressed: () => _showUploadDialog(context), icon: const Icon(Icons.cloud_upload, size: 16), label: const Text("Muat Naik", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
    ],
  ]);

  Widget _buildMobileHeader() => Row(children: [
    Image.asset('Assets/Images/logo_ukk-bg.png', height: 28, errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: goldAccent, size: 28)),
    const SizedBox(width: 8),
    const Flexible(child: Text('UKK JTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1), maxLines: 1, overflow: TextOverflow.ellipsis)),
    const Spacer(),
    if (widget.userRole == 'super_admin')
      IconButton(icon: const Icon(Icons.grid_view_rounded, color: Colors.white70, size: 20), onPressed: _bukaUrusKategoriPanel, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
    if (widget.userRole == 'super_admin' || widget.userRole == 'admin')
      IconButton(icon: const Icon(Icons.cloud_upload, color: goldAccent, size: 20), onPressed: () => _showUploadDialog(context), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
  ]);
}

class SubSocialMediaPage extends StatelessWidget {
  final String userRole; 
  const SubSocialMediaPage({super.key, required this.userRole});
  
  @override 
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'title': 'LOWER\nTHIRD', 'category': 'Socmed LOWER THIRD', 'icon': Icons.video_label_outlined},
      {'title': 'GMAIL\nSIGNATURE', 'category': 'Socmed GMAIL SIGNATURE', 'icon': Icons.mark_email_read_outlined},
      {'title': 'FOOTER', 'category': 'Socmed FOOTER', 'icon': Icons.call_to_action_outlined},
      {'title': 'QR CODE', 'category': 'Socmed QR CODE', 'icon': Icons.qr_code_2},
      {'title': 'IKON-IKON', 'category': 'Socmed IKON-IKON', 'icon': Icons.dashboard_customize_outlined},
    ];
    bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: solidBlack, 
      appBar: AppBar(backgroundColor: darkCard, iconTheme: const IconThemeData(color: Colors.white), title: Text('BAHAN SOCIAL MEDIA', style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, letterSpacing: 2.0)), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 30 : 50, horizontal: isMobile ? 20 : 50), 
            child: Wrap(
              spacing: isMobile ? 15 : 30, runSpacing: isMobile ? 15 : 30, alignment: WrapAlignment.center, 
              children: items.map((item) { 
                return HoverableStaticCard(
                  title: item['title'], icon: item['icon'], isMobile: isMobile, 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicDataCategoryPage(title: item['title'].replaceAll('\n', ' '), category: item['category'], userRole: userRole)))
                ); 
              }).toList()
            )
          )
        ),
      ),
    );
  }
}

class TambahKategoriDialog extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  const TambahKategoriDialog({super.key, this.existingData});
  @override State<TambahKategoriDialog> createState() => _TambahKategoriDialogState();
}

class _TambahKategoriDialogState extends State<TambahKategoriDialog> {
  TextEditingController titleCtrl = TextEditingController();
  @override void initState() {
    super.initState();
    if (widget.existingData != null) titleCtrl.text = widget.existingData!['title'];
  }

  @override Widget build(BuildContext context) {
    bool isEdit = widget.existingData != null;
    bool isMobile = MediaQuery.of(context).size.width < 500;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 400, 
        padding: EdgeInsets.all(isMobile ? 20 : 30),
        decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 1.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(isEdit ? Icons.edit : Icons.add_box, color: goldAccent, size: isMobile ? 18 : 24), SizedBox(width: 10), Text(isEdit ? 'UBAH KOTAK' : 'TAMBAH KOTAK BARU', style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold))]),
            SizedBox(height: isMobile ? 15 : 25),
            Text('Nama Kategori', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: titleCtrl, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), hintText: 'Cth: Laporan Tahunan', hintStyle: const TextStyle(color: Colors.white24), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            SizedBox(height: isMobile ? 20 : 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, 
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: softText, fontSize: isMobile ? 12 : 14))),
                SizedBox(width: isMobile ? 10 : 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 20, vertical: isMobile ? 10 : 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty) Navigator.pop(context, {'title': titleCtrl.text});
                    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila masukkan nama kotak!'), backgroundColor: Colors.orange));
                  },
                  child: Text('Simpan Kotak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}

class HoverableStaticCard extends StatefulWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isMobile;
  const HoverableStaticCard({super.key, required this.title, this.icon, this.onTap, this.isMobile = false});
  @override State<HoverableStaticCard> createState() => _HoverableStaticCardState();
}
class _HoverableStaticCardState extends State<HoverableStaticCard> {
  bool isHovered = false;
  @override Widget build(BuildContext context) {
    double width = widget.isMobile ? 140 : 180;
    double height = widget.isMobile ? 140 : 180;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, isHovered ? -5.0 : 0.0),
          child: Container(
            width: width, height: height,
            decoration: BoxDecoration(
              color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: goldAccent, width: 1.5),
              boxShadow: [
                if (isHovered) BoxShadow(color: goldAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))
                else BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon ?? Icons.insert_drive_file_outlined, color: goldAccent, size: widget.isMobile ? 35 : 45),
                SizedBox(height: widget.isMobile ? 10 : 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(widget.title.replaceAll('\n', '\n'), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHovered ? Colors.white : goldAccent, fontSize: widget.isMobile ? 10 : 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DynamicDataCategoryPage extends StatefulWidget {
  final String title; 
  final String category; 
  final String userRole;
  const DynamicDataCategoryPage({super.key, required this.title, required this.category, required this.userRole});
  @override State<DynamicDataCategoryPage> createState() => _DynamicDataCategoryPageState();
}

class _DynamicDataCategoryPageState extends State<DynamicDataCategoryPage> {
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
      if (response.statusCode == 200) {
        setState(() { allFiles = jsonDecode(response.body); isLoading = false; selectedFilePaths.clear(); });
      } else { setState(() => isLoading = false); }
    } catch (e) { setState(() => isLoading = false); }
  }

  Future<void> _deleteSingleFile(String filePath, String fileName) async {
    bool confirm = await sahkanKeselamatanPadam(context, fileName);
    if (confirm) { 
      await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': filePath})); 
      _fetchCategoryFiles(); 
    }
  }

  Future<void> _deleteSelectedFiles() async {
    if (selectedFilePaths.isEmpty) return;
    bool confirm = await sahkanKeselamatanPadam(context, '${selectedFilePaths.length} fail terpilih');
    if (!confirm) return;
    for (String path in selectedFilePaths.toList()) { 
      try { await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': path})); } catch (_) {} 
    }
    setState(() { selectedFilePaths.clear(); isDeleteMode = false; }); 
    _fetchCategoryFiles();
  }

  void _muatTurunFail(String filePath, String fileName) {
    String ext = filePath.contains('.') ? filePath.split('.').last : '';
    String finalName = fileName;
    if (ext.isNotEmpty && !finalName.toLowerCase().endsWith('.${ext.toLowerCase()}')) {
      finalName = '$finalName.$ext';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memuat turun $finalName...', style: const TextStyle(color: solidBlack)), backgroundColor: goldAccent));
    html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')
      ..setAttribute('download', finalName)
      ..click();
  }

  Future<void> _renameFile(String filePath, String currentName) async {
    String cleanName = currentName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    TextEditingController renameCtrl = TextEditingController(text: cleanName);
    bool isMobile = MediaQuery.of(context).size.width < 500;
    
    bool confirm = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 400, padding: EdgeInsets.all(isMobile ? 20 : 25), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent.withOpacity(0.5))),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tukar Nama Fail", style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
              SizedBox(height: isMobile ? 15 : 20),
              TextField(controller: renameCtrl, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              SizedBox(height: isMobile ? 15 : 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(child: Text("Batal", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 14)), onPressed: () => Navigator.pop(context, false)),
                  SizedBox(width: isMobile ? 5 : 10),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)), onPressed: () => Navigator.pop(context, true)),
                ],
              )
            ]
          )
        )
      ),
    ) ?? false;

    if (confirm && renameCtrl.text.isNotEmpty) {
      String ext = filePath.contains('.') ? filePath.split('.').last : '';
      String newFullName = ext.isNotEmpty ? '${renameCtrl.text}.$ext' : renameCtrl.text;

      final res = await http.post(Uri.parse('$apiFileUrl/rename_file.php'), body: jsonEncode({'old_path': filePath, 'new_name': newFullName}));
      if (res.statusCode == 200) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama fail ditukar!'), backgroundColor: Colors.green)); _fetchCategoryFiles(); }
    }
  }

  void _paparImejLuar(BuildContext context, String cleanUrl, String fileName) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent, insetPadding: EdgeInsets.all(isMobile ? 15 : 30),
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 700),
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)]),
          padding: EdgeInsets.all(isMobile ? 15 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), style: TextStyle(color: goldAccent, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold))),
                  IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 22), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(color: Colors.white24), const SizedBox(height: 10),
              Flexible(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Image.network(cleanUrl, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white54, size: 80))))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _lihatAtauBukaLink(String fileUrl, String ext, String filePath) async {
    if (ext == 'link') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membaca pautan dari pelayan...', style: TextStyle(color: solidBlack)), backgroundColor: goldAccent));
      try {
        final response = await http.get(Uri.parse('$apiFileUrl/read_link.php?path=${Uri.encodeComponent(filePath)}'));
        if (response.statusCode == 200) {
          String linkLuar = response.body.trim();
          if (linkLuar.isNotEmpty && !linkLuar.toLowerCase().startsWith('ralat')) {
            if (!linkLuar.startsWith('http')) linkLuar = 'https://$linkLuar';
            html.window.open(linkLuar, '_blank');
          } else {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kandungan pautan: $linkLuar'), backgroundColor: Colors.orange));
          }
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pelayan gagal membaca pautan. (Status: ${response.statusCode})'), backgroundColor: Colors.red));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat sambungan: $e'), backgroundColor: Colors.red));
      }
    } else if (['pdf'].contains(ext)) {
      html.window.open(cleanImageUrl(fileUrl), '_blank');
    } else {
      html.window.open(fileUrl, '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;
    
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';

    List<dynamic> displayItems = [];
    Set<String> folderNames = {};

    for (var file in allFiles) {
      String rawName = file['name'];
      String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
      
      if (displayName.contains('___')) {
        String folderName = displayName.split('___').first; 
        if (folderName.toLowerCase().contains(searchQuery.toLowerCase())) {
          if (!folderNames.contains(folderName)) {
            folderNames.add(folderName);
            displayItems.add({'is_folder': true, 'folder_name': folderName, 'files': <dynamic>[]});
          }
          var folderObj = displayItems.firstWhere((item) => item['is_folder'] == true && item['folder_name'] == folderName);
          folderObj['files'].add(file); 
        }
      } else {
        if (displayName.toLowerCase().contains(searchQuery.toLowerCase())) {
          displayItems.add({'is_folder': false, 'file': file, 'display_name': displayName});
        }
      }
    }

    displayItems.sort((a, b) {
      if (a['is_folder'] && !b['is_folder']) return -1;
      if (!a['is_folder'] && b['is_folder']) return 1;
      String nameA = a['is_folder'] ? a['folder_name'] : a['display_name'];
      String nameB = b['is_folder'] ? b['folder_name'] : b['display_name'];
      if (sortOption == 'A-Z') return nameA.compareTo(nameB);
      if (sortOption == 'Z-A') return nameB.compareTo(nameA);
      return 0; 
    });

    return Scaffold(
      backgroundColor: solidBlack,
      body: Stack(
        children: [
          Column(
            children: [
              // HEADER DENGAN BUTANG MOD PADAM
              Container(
                height: isMobile ? 60 : 70, padding: EdgeInsets.symmetric(horizontal: isMobile ? 10.0 : 40.0),
                decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
                child: Row(
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: isMobile ? 16 : 18), onPressed: () => Navigator.pop(context)),
                    SizedBox(width: isMobile ? 5 : 15),
                    Image.asset('Assets/Images/logo_ukk-bg.png', height: isMobile ? 28 : 35, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: goldAccent)),
                    const SizedBox(width: 15),
                    Expanded(child: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.bold, letterSpacing: 1.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    
                    if (bolehEditDelete) ...[
                      if (isMobile)
                        IconButton(icon: Icon(isDeleteMode ? Icons.close : Icons.checklist_rtl_rounded, color: Colors.white), onPressed: () => setState(() { isDeleteMode = !isDeleteMode; if (!isDeleteMode) selectedFilePaths.clear(); }))
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: isDeleteMode ? crimsonRed : Colors.white10, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)),
                          onPressed: () => setState(() { isDeleteMode = !isDeleteMode; if (!isDeleteMode) selectedFilePaths.clear(); }), 
                          icon: Icon(isDeleteMode ? Icons.close : Icons.checklist_rtl_rounded, size: 16), 
                          label: Text(isDeleteMode ? "Batal" : "Mod Padam", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      SizedBox(width: isMobile ? 5 : 10),
                    ],
                    IconButton(icon: Icon(Icons.refresh, color: goldAccent, size: isMobile ? 18 : 24), onPressed: _fetchCategoryFiles),
                  ],
                ),
              ),
              
              Expanded(
                child: Container(
                  width: double.infinity, height: double.infinity, 
                  decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: isMobile ? 15 : 25),
                        child: Row(
                          children: [
                            Expanded(child: SizedBox(height: isMobile ? 42 : 50, child: TextField(style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: 'Cari fail / folder...', hintStyle: const TextStyle(color: softText), prefixIcon: Icon(Icons.search, color: goldAccent, size: isMobile ? 18 : 20), filled: true, fillColor: darkCard, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), onChanged: (value) => setState(() => searchQuery = value)))),
                            const SizedBox(width: 15),
                            Container(height: isMobile ? 42 : 50, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(15)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: sortOption, dropdownColor: darkCard, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold), icon: Icon(Icons.sort, color: goldAccent, size: isMobile ? 18 : 20), items: ['Terbaru', 'A-Z', 'Z-A'].map((String sort) => DropdownMenuItem<String>(value: sort, child: Text(sort))).toList(), onChanged: (val) => setState(() => sortOption = val!)))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isLoading ? const Center(child: CircularProgressIndicator(color: darkCard))
                            : displayItems.isEmpty
                                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.folder_off, color: Colors.black26, size: 60), SizedBox(height: 10), Text("Tiada fail dijumpai.", style: TextStyle(color: Colors.black54, fontSize: 14))]))
                                : GridView.builder(
                                    padding: EdgeInsets.fromLTRB(isMobile ? 15 : 40, 10, isMobile ? 15 : 40, isDeleteMode ? 100 : 10),
                                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: isMobile ? 140 : 180, 
                                      crossAxisSpacing: isMobile ? 12 : 20,
                                      mainAxisSpacing: isMobile ? 12 : 20,
                                      childAspectRatio: 0.85, 
                                    ),
                                    itemCount: displayItems.length,
                                    itemBuilder: (context, index) {
                                      var item = displayItems[index];
                                      if (item['is_folder'] == true) {
                                        return MinimalAssetCard(
                                          imagePath: '', fileName: item['folder_name'], isMobile: isMobile, ext: '', showActions: false, 
                                          isFolder: true, isSelectionMode: false, isSelected: false,
                                          onView: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => SubFolderDataPage(folderName: item['folder_name'], category: widget.category, userRole: widget.userRole))).then((_) => _fetchCategoryFiles()); 
                                          },
                                          onDownload: () {}, onDelete: () {}, onRename: () {},
                                        );
                                      } else {
                                        var file = item['file'];
                                        String displayName = item['display_name'];
                                        
                                        String filePath = file['path'] ?? file['url'] ?? '';
                                        String ext = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';
                                        
                                        bool isSelected = selectedFilePaths.contains(filePath);
                                        
                                        return MinimalAssetCard(
                                          imagePath: file['url'], fileName: displayName, isMobile: isMobile, ext: ext, 
                                          showActions: bolehEditDelete && !isDeleteMode, isFolder: false, 
                                          isSelectionMode: isDeleteMode, isSelected: isSelected,
                                          onToggleSelect: () => setState(() { 
                                            if (isSelected) { selectedFilePaths.remove(filePath); } 
                                            else { selectedFilePaths.add(filePath); } 
                                          }),
                                          onView: () {
                                            if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(ext)) {
                                              String cleanUrl = cleanImageUrl(file['url']); 
                                              _paparImejLuar(context, cleanUrl, displayName);
                                            } else if (ext == 'link' || ext == 'pdf') {
                                              _lihatAtauBukaLink(file['url'], ext, filePath);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila muat turun dokumen ini untuk melihatnya.'), backgroundColor: Colors.amber));
                                            }
                                          },
                                          onDownload: () => _muatTurunFail(file['path'], displayName),
                                          onDelete: () => _deleteSingleFile(file['path'], displayName),
                                          onRename: () => _renameFile(file['path'], displayName),
                                        );
                                      }
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BAR TIMBUL UNTUK DELETE PUKAL
          if (isDeleteMode && selectedFilePaths.isNotEmpty)
            Positioned(
              bottom: 20, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 25, vertical: isMobile ? 10 : 15),
                  decoration: BoxDecoration(
                    color: crimsonRed, borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: crimsonRed.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${selectedFilePaths.length} Fail Dipilih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 16)),
                      SizedBox(width: isMobile ? 15 : 25),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: crimsonRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: _deleteSelectedFiles, 
                        icon: Icon(Icons.delete_forever, size: isMobile ? 16 : 18), label: Text('Padam Semua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 14))
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SubFolderDataPage extends StatefulWidget {
  final String folderName;
  final String category;
  final String userRole;

  const SubFolderDataPage({super.key, required this.folderName, required this.category, required this.userRole});

  @override
  State<SubFolderDataPage> createState() => _SubFolderDataPageState();
}

class _SubFolderDataPageState extends State<SubFolderDataPage> {
  List<dynamic> folderFiles = [];
  bool isLoading = true;

  @override void initState() { super.initState(); _fetchFiles(); }

  Future<void> _fetchFiles() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$apiFileUrl/get_files.php?kategori=${Uri.encodeComponent(widget.category)}'));
      if (response.statusCode == 200) {
        List<dynamic> allFiles = jsonDecode(response.body);
        setState(() {
          folderFiles = allFiles.where((f) {
            String rawName = f['name'];
            String disp = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
            return disp.startsWith('${widget.folderName}___');
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) { setState(() => isLoading = false); }
  }

  void _paparImejLuar(BuildContext context, String cleanUrl, String fileName) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent, insetPadding: EdgeInsets.all(isMobile ? 15 : 30),
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900, maxHeight: isMobile ? 400 : 700),
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)]),
          padding: EdgeInsets.all(isMobile ? 15 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), style: TextStyle(color: goldAccent, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold))),
                  IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(color: Colors.white24), const SizedBox(height: 10),
              Flexible(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Image.network(cleanUrl, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white54, size: 80))))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _lihatAtauBukaLink(String fileUrl, String ext, String filePath) async {
    if (ext == 'link') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membaca pautan dari pelayan...', style: TextStyle(color: solidBlack)), backgroundColor: goldAccent));
      try {
        final response = await http.get(Uri.parse('$apiFileUrl/read_link.php?path=${Uri.encodeComponent(filePath)}'));
        if (response.statusCode == 200) {
          String linkLuar = response.body.trim();
          if (linkLuar.isNotEmpty && !linkLuar.toLowerCase().startsWith('ralat')) {
            if (!linkLuar.startsWith('http')) linkLuar = 'https://$linkLuar';
            html.window.open(linkLuar, '_blank');
          } else {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kandungan pautan: $linkLuar'), backgroundColor: Colors.orange));
          }
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pelayan gagal membaca pautan. (Status: ${response.statusCode})'), backgroundColor: Colors.red));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat sambungan: $e'), backgroundColor: Colors.red));
      }
    } else if (['pdf'].contains(ext)) {
      html.window.open(cleanImageUrl(fileUrl), '_blank');
    } else {
      html.window.open(fileUrl, '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 850;
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';

    return Scaffold(
      backgroundColor: solidBlack,
      appBar: AppBar(
        backgroundColor: darkCard, iconTheme: const IconThemeData(color: goldAccent), 
        title: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Icon(Icons.folder_open, color: goldAccent), const SizedBox(width: 10), 
            Text(widget.folderName, style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold))
          ]
        ), 
        centerTitle: true, elevation: 0,
      ),
      body: Container(
        width: double.infinity, height: double.infinity, 
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [bgRoseTop, bgGoldBot])),
        child: isLoading 
            ? const Center(child: CircularProgressIndicator(color: darkCard))
            : folderFiles.isEmpty 
                ? const Center(child: Text("Folder ini kosong.", style: TextStyle(color: Colors.black54, fontSize: 16)))
                : GridView.builder(
                    padding: EdgeInsets.all(isMobile ? 15 : 40),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isMobile ? 140 : 180, 
                      crossAxisSpacing: isMobile ? 12 : 20,
                      mainAxisSpacing: isMobile ? 12 : 20,
                      childAspectRatio: 0.85, 
                    ),
                    itemCount: folderFiles.length,
                    itemBuilder: (context, index) {
                      var file = folderFiles[index];
                      String rawName = file['name'];
                      String fullDisplayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
                      String displayName = fullDisplayName.replaceFirst('${widget.folderName}___', '');
                      
                      String filePath = file['path'] ?? file['url'] ?? '';
                      String ext = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';

                      return MinimalAssetCard(
                        imagePath: file['url'], fileName: displayName, isMobile: isMobile, ext: ext, showActions: bolehEditDelete, isFolder: false, 
                        onView: () { 
                          if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(ext)) {
                            String cleanUrl = cleanImageUrl(file['url']); _paparImejLuar(context, cleanUrl, displayName);
                          } else if (ext == 'link' || ext == 'pdf') {
                            _lihatAtauBukaLink(file['url'], ext, filePath);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila muat turun dokumen ini untuk melihatnya.'), backgroundColor: Colors.amber));
                          }
                        },
                        onDownload: () { 
                          String finalName = displayName;
                          if (ext.isNotEmpty && !finalName.toLowerCase().endsWith('.$ext')) {
                            finalName = '$finalName.$ext';
                          }
                          html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')
                            ..setAttribute('download', finalName)..click(); 
                        },
                        onDelete: () async {
                          bool confirm = await sahkanKeselamatanPadam(context, displayName);
                          if (confirm) { 
                            await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': filePath})); 
                            _fetchFiles(); 
                          }
                        },
                        onRename: () {}, 
                      );
                    },
                  ),
      ),
    );
  }
}

class MinimalAssetCard extends StatefulWidget {
  final String imagePath;
  final String fileName;
  final String ext;
  final bool showActions;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback? onDelete;
  final VoidCallback onRename;
  final bool isMobile;
  final bool isFolder;
  
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;

  const MinimalAssetCard({
    super.key, required this.imagePath, required this.fileName, required this.ext, 
    required this.onView, required this.onDownload, this.onDelete, required this.onRename, 
    this.showActions = true, this.isMobile = false, this.isFolder = false,
    this.isSelectionMode = false, this.isSelected = false, this.onToggleSelect,
  });

  @override
  State<MinimalAssetCard> createState() => _MinimalAssetCardState();
}

class _MinimalAssetCardState extends State<MinimalAssetCard> {
  bool isHovered = false;

  Widget _buildIconOrImage() {
    if (widget.isFolder) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Icon(Icons.folder, color: goldAccent, size: widget.isMobile ? 35 : 50), 
            SizedBox(height: widget.isMobile ? 5 : 10), 
            Text('Buka Folder', style: TextStyle(color: goldAccent, fontSize: widget.isMobile ? 9 : 10, fontWeight: FontWeight.bold))
          ]
        )
      );
    }

    if (widget.ext == 'link') return Center(child: Icon(Icons.link, color: Colors.greenAccent, size: widget.isMobile ? 35 : 50));
    if (widget.ext == 'pdf') return Center(child: Icon(Icons.picture_as_pdf, color: crimsonRed, size: widget.isMobile ? 35 : 50));
    if (['xlsx', 'xls', 'csv'].contains(widget.ext)) return Center(child: Icon(Icons.table_chart, color: Colors.green, size: widget.isMobile ? 35 : 50));
    if (['docx', 'doc'].contains(widget.ext)) return Center(child: Icon(Icons.description, color: Colors.blueAccent, size: widget.isMobile ? 35 : 50));
    if (['pptx', 'ppt'].contains(widget.ext)) return Center(child: Icon(Icons.co_present, color: Colors.orangeAccent, size: widget.isMobile ? 35 : 50));

    if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(widget.ext)) {
      String cleanUrl = cleanImageUrl(widget.imagePath);
      return Image.network(
        cleanUrl, fit: BoxFit.contain, filterQuality: FilterQuality.high,
        errorBuilder: (c, e, s) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.broken_image, color: crimsonRed, size: widget.isMobile ? 30 : 40), SizedBox(height: 5), Text('Ralat Paparan', style: TextStyle(color: softText, fontSize: widget.isMobile ? 8 : 9))])),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: goldAccent, strokeWidth: 2));
        },
      );
    }
    return Center(child: Icon(Icons.insert_drive_file, color: goldAccent, size: widget.isMobile ? 35 : 50));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: (widget.isSelectionMode && !widget.isFolder) ? widget.onToggleSelect : (!widget.isSelectionMode && widget.isFolder ? widget.onView : null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic,
              transform: Matrix4.identity()..translate(0.0, (isHovered && !widget.isSelectionMode) ? -5.0 : 0.0),
              child: Container(
                decoration: BoxDecoration(
                  color: darkCard, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.isSelected ? crimsonRed : (isHovered && !widget.isSelectionMode ? goldAccent : Colors.white12), width: widget.isSelected ? 2.5 : 1.5),
                  boxShadow: [
                    if (isHovered && !widget.isSelectionMode) BoxShadow(color: goldAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))
                    else BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(padding: EdgeInsets.all(widget.isMobile ? 8 : 15), color: darkCard, child: _buildIconOrImage()),
                      AnimatedOpacity(
                        opacity: (isHovered && !widget.isSelectionMode && !widget.isFolder) ? 1.0 : 0.0, duration: const Duration(milliseconds: 200),
                        child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.95)], stops: const [0.3, 1.0]))),
                      ),
                      if (widget.isSelectionMode && !widget.isFolder)
                        Container(
                          decoration: BoxDecoration(color: widget.isSelected ? crimsonRed.withOpacity(0.3) : Colors.black.withOpacity(0.4)),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                decoration: BoxDecoration(color: widget.isSelected ? crimsonRed : Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                padding: const EdgeInsets.all(3),
                                child: Icon(Icons.check, size: 16, color: widget.isSelected ? Colors.white : Colors.transparent),
                              ),
                            ),
                          ),
                        ),
                      if (widget.isFolder)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(color: isHovered ? goldAccent : Colors.black45),
                            child: Text(widget.fileName, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHovered ? solidBlack : Colors.white70, fontSize: widget.isMobile ? 10 : 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        ),
                      if (isHovered && !widget.isSelectionMode && !widget.isFolder)
                        Positioned(
                          bottom: widget.isMobile ? 5 : 10, left: 5, right: 5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: widget.isMobile ? 10 : 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              SizedBox(height: widget.isMobile ? 5 : 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Wrap(
                                  alignment: WrapAlignment.center, spacing: 5, runSpacing: 5,
                                  children: [
                                    if (widget.showActions) _buildActionBtn(Icons.edit_outlined, goldAccent, widget.onRename, 'Edit Nama'),
                                    _buildActionBtn(widget.ext == 'link' ? Icons.open_in_new : Icons.visibility_outlined, Colors.blueAccent, widget.onView, 'Papar/Buka'),
                                    if (widget.ext != 'link') _buildActionBtn(Icons.file_download_outlined, Colors.greenAccent, widget.onDownload, 'Muat Turun'),
                                    if (widget.showActions && widget.onDelete != null) _buildActionBtn(Icons.delete_outline, crimsonRed, widget.onDelete!, 'Padam'),
                                  ],
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
          ),
        );
      }
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback action, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: action, borderRadius: BorderRadius.circular(30),
        child: Container(padding: EdgeInsets.all(widget.isMobile ? 4 : 6), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5), width: 1)), child: Icon(icon, color: color, size: widget.isMobile ? 12 : 14)),
      ),
    );
  }
}