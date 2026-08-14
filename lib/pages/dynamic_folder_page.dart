import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:ui_web' as ui_web;

// 💥 ALAMAT API (PASTIKAN BETUL) 💥
const String apiDbUrl   = 'https://app.atom.gov.my/ukk_api/';
const String apiFileUrl = 'https://app.atom.gov.my/ukk_api';

// 🎨 PALET WARNA TEMA DASHBOARD (GOLD & HITAM)
const Color darkCard   = Color(0xFF2B2A33);
const Color goldAccent = Color(0xFFC9A96E);
const Color softText   = Color(0xFFB0ADB8);
const Color crimsonRed = Color(0xFFE50914);
const Color bgRoseTop  = Color(0xFFFBF5F3);
const Color bgGoldBot  = Color(0xFFF0E5D2);
const Color solidBlack = Colors.black;

// ═══════════════════════════════════════════════════════
// PEMETAAN NAMA IKON KE ICON DATA PEMALAR
// ═══════════════════════════════════════════════════════
class DynamicFolderIcons {
  static const Map<String, IconData> nameMap = {
    'folder': Icons.folder,
    'image': Icons.image,
    'videocam': Icons.videocam,
    'music_note': Icons.music_note,
    'insert_drive_file': Icons.insert_drive_file,
    'pie_chart': Icons.pie_chart,
    'campaign': Icons.campaign,
    'event': Icons.event,
    'people': Icons.people,
    'work': Icons.work,
    'folder_special': Icons.folder_special, // fallback default
  };

  static IconData getIcon(String? name) {
    if (name == null || !nameMap.containsKey(name)) return Icons.folder_special;
    return nameMap[name]!;
  }

  static IconData getIconFromCode(dynamic code) {
    if (code == null) return Icons.folder;
    if (code is int) {
      switch (code) {
        case 0xe2c7: return Icons.folder;
        case 0xe3f4: return Icons.image;
        case 0xe04b: return Icons.videocam;
        case 0xe028: return Icons.music_note;
        case 0xe3e3: return Icons.insert_drive_file;
        case 0xe3f5: return Icons.pie_chart;
        case 0xefef: return Icons.campaign;
        case 0xe616: return Icons.event;
        case 0xe7fb: return Icons.people;
        case 0xe7f9: return Icons.work;
        default: return Icons.folder;
      }
    } else if (code is String) {
      return getIcon(code);
    }
    return Icons.folder;
  }
}

String cleanImageUrl(String rawUrl) {
  if (rawUrl.isEmpty) return '';
  String decodedUrl = Uri.decodeFull(Uri.decodeFull(rawUrl));
  String fixedUrl = decodedUrl.replaceAll('\\', '/');
  if (!fixedUrl.startsWith('http')) {
    if (fixedUrl.startsWith('/')) fixedUrl = fixedUrl.substring(1);
    fixedUrl = '$apiFileUrl/$fixedUrl';
  }
  return Uri.encodeFull(fixedUrl);
}

Future<bool> _sahkanPadamDinamik(BuildContext context, String namaItem) async {
  TextEditingController icController = TextEditingController();
  bool isError = false;
  final bool isMobile = MediaQuery.of(context).size.width < 600;

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setPopupState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 400,
              padding: EdgeInsets.all(isMobile ? 15 : 25),
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: crimsonRed.withOpacity(0.5), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: crimsonRed, size: isMobile ? 40 : 50),
                  SizedBox(height: isMobile ? 10 : 15),
                  Text('Pengesahan Keselamatan', style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Sila masukkan kata laluan untuk memadam "$namaItem".', textAlign: TextAlign.center, style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, height: 1.5)),
                  SizedBox(height: isMobile ? 15 : 20),
                  TextField(
                    controller: icController, style: const TextStyle(color: Colors.white), obscureText: true,
                    decoration: InputDecoration(
                      filled: true, fillColor: Colors.black45, hintText: 'Cth: admin', hintStyle: const TextStyle(color: Colors.white24),
                      errorText: isError ? 'Pengesahan gagal! Sila cuba lagi.' : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: crimsonRed)),
                    ),
                  ),
                  SizedBox(height: isMobile ? 15 : 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: TextStyle(color: softText, fontSize: isMobile ? 12 : 14))),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: crimsonRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          if (icController.text.toLowerCase() == 'admin' || icController.text == 'admin123') {
                            Navigator.pop(context, true);
                          } else {
                            setPopupState(() => isError = true);
                          }
                        },
                        child: Text('Sahkan Padam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
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
// HALAMAN UTAMA FOLDER DINAMIK
// ═══════════════════════════════════════════════════════
class DynamicFolderPage extends StatefulWidget {
  final String pageTitle;
  final String userRole;

  const DynamicFolderPage({super.key, required this.pageTitle, this.userRole = 'user'});

  @override
  State<DynamicFolderPage> createState() => _DynamicFolderPageState();
}

class _DynamicFolderPageState extends State<DynamicFolderPage> {
  List<dynamic> dynamicCategories = [];
  bool isLoadingDB = true;

  @override void initState() { super.initState(); _fetchKotak(); }

  Future<void> _fetchKotak() async {
    setState(() => isLoadingDB = true);
    try {
      String t = Uri.encodeComponent(widget.pageTitle.trim());
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final res = await http.get(Uri.parse('$apiDbUrl/get_kotak.php?parent=$t&parent_menu=$t&t=$timestamp'));

      if (res.statusCode == 200) {
        try {
          var data = jsonDecode(res.body);
          if (mounted) setState(() { dynamicCategories = (data is List) ? data : []; isLoadingDB = false; });
        } catch (e) {
          if (mounted) setState(() { dynamicCategories = []; isLoadingDB = false; });
        }
      } else {
        if (mounted) setState(() => isLoadingDB = false);
      }
    } catch (e) {
      if (mounted) setState(() { dynamicCategories = []; isLoadingDB = false; });
    }
  }

  // ---------- DIALOG MUAT NAIK (RESPONSIF) ----------
  void _showUploadDialog(BuildContext context) {
    if (dynamicCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila cipta kotak kategori dahulu menggunakan Urus Kotak!'), backgroundColor: Colors.orange));
      return;
    }

    List<PlatformFile> selectedFiles = [];
    String selectedCategory = dynamicCategories.first['nama_kotak'] ?? dynamicCategories.first['nama'] ?? 'Kotak';
    selectedCategory = selectedCategory.replaceAll('\n', ' ');
    bool isUploading = false;
    double uploadProgress = 0.0;
    String uploadStatus = '';
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    bool isLinkMode = false;

    List<String> dropdownList = dynamicCategories.map((c) {
      String name = c['nama_kotak'] ?? c['nama'] ?? 'Kotak';
      return name.replaceAll('\n', ' ').toString();
    }).toList();

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
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
              // 💥 FIX UPLOAD 1: ZIP Wajib ada withData: true 💥
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip'], allowMultiple: true, withData: true);
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
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                      decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [Icon(Icons.cloud_upload, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 12), Text('MUAT NAIK FAIL / PAUTAN', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))]),
                          if (!isUploading) IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 15 : 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pilihan mod
                          Row(children: [
                            Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = false), child: Container(padding: EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: !isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)), border: Border.all(color: !isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Fail Fizikal", style: TextStyle(color: !isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
                            Expanded(child: InkWell(onTap: () => setDialogState(() => isLinkMode = true), child: Container(padding: EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isLinkMode ? goldAccent.withOpacity(0.15) : const Color(0xFF1E2025), borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)), border: Border.all(color: isLinkMode ? goldAccent : Colors.transparent)), child: Center(child: Text("Pautan URL", style: TextStyle(color: isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)))))),
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
                                items: dropdownList.map((cat) => DropdownMenuItem<String>(value: cat, child: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text(cat, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14))))).toList(),
                                onChanged: (v) => setDialogState(() => selectedCategory = v!),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 15 : 20),
                          Text(isLinkMode ? "Tajuk Pautan (Wajib)" : "Nama Fail (Pilihan)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          TextField(controller: nameController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: isLinkMode ? 'Cth: Pautan Template' : 'Cth: Aset Visual', hintStyle: const TextStyle(color: softText), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                          SizedBox(height: isMobile ? 12 : 20),
                          if (isLinkMode) ...[
                            Text("Pautan URL", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            TextField(controller: urlController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(prefixIcon: Icon(Icons.link, color: goldAccent, size: isMobile ? 18 : 20), hintText: 'https://...', hintStyle: const TextStyle(color: softText), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                          ] else ...[
                            Text("Sumber Fail (Max: 20 Fail)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
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
                                      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: 4),
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Icon(displayName.contains('/') ? Icons.folder : Icons.insert_drive_file, color: goldAccent, size: isMobile ? 16 : 20),
                                          SizedBox(width: isMobile ? 8 : 10),
                                          Expanded(child: Text(displayName, style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          InkWell(
                                            onTap: () => setDialogState(() { selectedFiles.removeAt(i); if (selectedFiles.isEmpty) nameController.clear(); }),
                                            child: Icon(Icons.close, color: Colors.white38, size: isMobile ? 16 : 18)
                                          ),
                                        ]
                                      ),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Row(
                              children: [
                                Expanded(child: _buildActionButton(label: 'Pilih Fail', icon: Icons.image, onTap: () async {
                                  // 💥 FIX UPLOAD 2: withData true untuk fail biasa 💥
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true, withData: true);
                                  if (result != null && result.files.isNotEmpty) {
                                    List<PlatformFile> newFiles = result.files;
                                    if (newFiles.length > 20) { newFiles = newFiles.take(20).toList(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 20 fail sahaja.'), backgroundColor: Colors.amber)); }
                                    setDialogState(() { selectedFiles.addAll(newFiles); if (nameController.text.isEmpty && selectedFiles.isNotEmpty && !(selectedFiles.first.path?.contains('___') ?? false)) nameController.text = selectedFiles.first.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''); });
                                  }
                                }, isMobile: isMobile)),
                                SizedBox(width: isMobile ? 8 : 12),
                                Expanded(child: _buildActionButton(label: 'Pilih Folder', icon: Icons.folder_copy, onTap: () => pickFolder(), isMobile: isMobile)),
                              ],
                            ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Center(child: _buildActionButton(label: 'Pilih Zip', icon: Icons.archive, onTap: () => pickZip(), isMobile: isMobile)),
                          ],
                          
                          if (isUploading) ...[
                            SizedBox(height: isMobile ? 15 : 20),
                            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: uploadProgress, backgroundColor: Colors.white10, color: goldAccent, minHeight: 6)),
                            SizedBox(height: 8),
                            Center(child: Text(uploadStatus, style: TextStyle(color: goldAccent, fontSize: isMobile ? 12 : 13))),
                          ],
                          SizedBox(height: isMobile ? 20 : 28),
                          SizedBox(
                            width: double.infinity, height: isMobile ? 42 : 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: (isUploading || (!isLinkMode && selectedFiles.isEmpty)) ? null : () async {
                                if (isLinkMode && (urlController.text.isEmpty || nameController.text.isEmpty)) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila lengkapkan maklumat!'), backgroundColor: Colors.orange)); return;
                                }

                                setDialogState(() { isUploading = true; uploadProgress = 0.0; uploadStatus = 'Memulakan muat naik...';});
                                try {
                                  String finalCategory = '${widget.pageTitle.trim()} $selectedCategory';

                                  if (isLinkMode) {
                                    var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                    request.fields['kategori'] = finalCategory;
                                    String safeName = nameController.text.trim().replaceAll(RegExp(r'[^\w\s\-]+'), '');
                                    Uint8List urlBytes = Uint8List.fromList(utf8.encode(urlController.text));
                                    request.files.add(http.MultipartFile.fromBytes('file', urlBytes, filename: '$safeName.link'));
                                    await request.send();
                                    setDialogState(() { uploadProgress = 1.0; uploadStatus = 'Selesai 100%'; });
                                  } else {
                                    int total = selectedFiles.length;
                                    for (int i = 0; i < total; i++) {
                                      setDialogState(() => uploadStatus = 'Memuat naik fail ${i + 1}/$total...');
                                      var file = selectedFiles[i];
                                      String fileNameToUpload = file.path ?? file.name;
                                      if (nameController.text.trim().isNotEmpty && total == 1 && !fileNameToUpload.contains('___')) {
                                        String ext = fileNameToUpload.contains('.') ? fileNameToUpload.split('.').last : '';
                                        String safeCustomName = nameController.text.trim().replaceAll(RegExp(r'[^\w\s\-]+'), '');
                                        fileNameToUpload = ext.isNotEmpty ? '$safeCustomName.$ext' : safeCustomName;
                                      }

                                      // 💥 FIX UPLOAD: Buang aksara pelik pada nama 💥
                                      String safeFileName = fileNameToUpload.replaceAll(RegExp(r'[^\w\.\-\/]'), '_');

                                      var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                      request.fields['kategori'] = finalCategory;
                                      if (nameController.text.trim().isNotEmpty && total == 1 && !fileNameToUpload.contains('___')) request.fields['custom_name'] = nameController.text.trim();
                                      
                                      // 💥 FIX UPLOAD: Pastikan data bytes tak kosong 💥
                                      if (file.bytes == null || file.bytes!.isEmpty) {
                                        throw Exception("Data fail '${file.name}' kosong (0 Bytes).");
                                      }

                                      request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: safeFileName));
                                      var response = await request.send();
                                      var responseBody = await response.stream.bytesToString();
                                      
                                      if (response.statusCode == 200) { 
                                        if (responseBody.contains('"status":"error"')) throw Exception("Pelayan menolak fail.");
                                        setDialogState(() => uploadProgress = (i + 1) / total); 
                                      }
                                      else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat muat naik!'), backgroundColor: crimsonRed)); return; }
                                    }
                                  }
                                  setDialogState(() { uploadProgress = 1.0; uploadStatus = 'Selesai!'; });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berjaya dimuat naik ke $finalCategory!'), backgroundColor: Colors.green));
                                } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat pelayan!'), backgroundColor: crimsonRed)); }
                                finally { if (mounted) setDialogState(() => isUploading = false); }
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
            );
          }
        );
      },
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

  void _bukaUrusKategoriPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      barrierDismissible: false,
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
                          Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 15),
                          Expanded(child: Text('PENGURUSAN KOTAK', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 6 : 8)),
                            onPressed: () async {
                              var result = await showDialog(context: context, builder: (context) => const DynTambahKategoriDialog());
                              if (result != null) {
                                setModalState(() => isLoadingDB = true);
                                try {
                                  final response = await http.post(
                                    Uri.parse('$apiDbUrl/add_kotak.php'),
                                    body: {
                                      'nama': result['title'],
                                      'nama_kotak': result['title'],
                                      'parent': widget.pageTitle.trim(),
                                      'parent_menu': widget.pageTitle.trim(),
                                      'icon_code': result['icon_name'], 
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    var data = jsonDecode(response.body);
                                    if (data['status'] == 'success') {
                                      await _fetchKotak();
                                      if (mounted) {
                                        setModalState(() { isLoadingDB = false; });
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kotak berjaya disimpan!'), backgroundColor: Colors.green));
                                      }
                                    } else {
                                      if (mounted) {
                                        setModalState(() { isLoadingDB = false; });
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat: ${data['message']}'), backgroundColor: crimsonRed));
                                      }
                                    }
                                  } else {
                                    if (mounted) { setModalState(() { isLoadingDB = false; }); }
                                  }
                                } catch (e) {
                                  if (mounted) { setModalState(() { isLoadingDB = false; }); }
                                }
                              }
                            },
                            icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                            label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                          ),
                          SizedBox(width: isMobile ? 4 : 10),
                          IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: isLoadingDB
                          ? const Center(child: CircularProgressIndicator(color: goldAccent))
                          : dynamicCategories.isEmpty
                              ? const Center(child: Text("Tiada kotak. Sila tambah.", style: TextStyle(color: softText)))
                              : ListView.builder(
                                  padding: EdgeInsets.all(isMobile ? 15 : 25),
                                  itemCount: dynamicCategories.length,
                                  itemBuilder: (context, index) {
                                    var cat = dynamicCategories[index];
                                    IconData iconDynamic = DynamicFolderIcons.getIconFromCode(cat['icon_code']);
                                    String displayTitle = cat['nama_kotak'] ?? cat['nama'] ?? 'Kotak Baru';

                                    return Container(
                                      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                                      decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Container(
                                          width: isMobile ? 40 : 50, height: isMobile ? 40 : 50, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                                          child: Icon(iconDynamic, color: goldAccent, size: isMobile ? 20 : 24),
                                        ),
                                        title: Text(displayTitle.replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                                        subtitle: Text('Kategori DB: ${widget.pageTitle}', style: TextStyle(color: softText, fontSize: isMobile ? 10 : 12)),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20),
                                          onPressed: () async {
                                            bool confirm = await _sahkanPadamDinamik(context, displayTitle.replaceAll('\n', ' '));
                                            if (confirm) {
                                              setModalState(() => isLoadingDB = true);
                                              try {
                                                final res = await http.post(Uri.parse('$apiDbUrl/delete_kotak.php'), body: {'id': cat['id'].toString()});
                                                if (res.statusCode == 200) {
                                                  var data = jsonDecode(res.body);
                                                  if (data['status'] == 'success') {
                                                    await _fetchKotak();
                                                    if (mounted) { setModalState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kotak dipadam."), backgroundColor: Colors.green)); }
                                                  }
                                                }
                                              } catch (e) {
                                                if (mounted) { setModalState(() { isLoadingDB = false; }); }
                                              }
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    bool bolehUrusKotak = widget.userRole == 'super_admin';
    bool bolehUpload = widget.userRole == 'super_admin' || widget.userRole == 'admin';

    return Scaffold(
      backgroundColor: solidBlack,
      body: Column(
        children: [
          // ==================== HEADER ====================
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
            decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
            child: SafeArea(bottom: false, child: isMobile ? _buildMobileHeader(bolehUrusKotak, bolehUpload) : _buildDesktopHeader(bolehUrusKotak, bolehUpload)),
          ),

          // ==================== BODY ====================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 40, horizontal: isMobile ? 12 : 24),
                child: Column(
                  children: [
                    Text(widget.pageTitle.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: darkCard, fontSize: isMobile ? 24 : 36, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                    const SizedBox(height: 10),
                    Text('PANGKALAN DATA DINAMIK', textAlign: TextAlign.center, style: TextStyle(color: darkCard.withOpacity(0.7), fontSize: isMobile ? 12 : 18, fontWeight: FontWeight.bold, letterSpacing: 4.0)),
                    SizedBox(height: isMobile ? 30 : 60),

                    if (isLoadingDB)
                      const Padding(padding: EdgeInsets.only(top: 50.0), child: CircularProgressIndicator(color: darkCard))
                    else if (dynamicCategories.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.dashboard_customize, color: Colors.black26, size: 60),
                            const SizedBox(height: 20),
                            Text(
                              bolehUrusKotak ? "Tiada kotak kategori.\nSila klik 'Urus Kotak' untuk cipta kotak baharu." : "Tiada data buat masa ini.",
                              textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 16, height: 1.5)
                            )
                          ],
                        )
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Wrap(
                          spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 25, alignment: WrapAlignment.center,
                          children: dynamicCategories.map((cat) {
                            IconData iconDynamic = DynamicFolderIcons.getIconFromCode(cat['icon_code']);
                            String displayTitle = cat['nama_kotak'] ?? cat['nama'] ?? 'Kotak Baru';

                            return DynHoverableCard(
                              title: displayTitle.replaceAll('\n', ' '), icon: iconDynamic, isMobile: isMobile,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynSubAssetPage(title: displayTitle.replaceAll('\n', ' '), category: '${widget.pageTitle} $displayTitle', userRole: widget.userRole))),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: double.infinity, padding: EdgeInsets.all(isMobile ? 10 : 15), color: darkCard, child: Text('Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat, Jabatan Tenaga Atom.', textAlign: TextAlign.center, style: TextStyle(color: softText, fontSize: isMobile ? 9 : 11))),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(bool bolehUrusKotak, bool bolehUpload) {
    return Row(children: [
      Image.asset('Assets/Images/logo_ukk-bg.png', height: 48, errorBuilder: (_,__,___) => Icon(Icons.broken_image, color: goldAccent, size: 48)),
      SizedBox(width: 16),
      Expanded(child: RichText(text: TextSpan(style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5), children: const [TextSpan(text: 'UKK ', style: TextStyle(color: Colors.white)), TextSpan(text: 'JABATAN TENAGA ATOM', style: TextStyle(color: Color(0xFFE0E0E0)))]))),
      Spacer(),
      if (bolehUrusKotak) ...[
        ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15)), onPressed: _bukaUrusKategoriPanel, icon: Icon(Icons.grid_view_rounded, size: 16), label: Text("Urus Kotak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        SizedBox(width: 10),
      ],
      if (bolehUpload) ...[
        ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15)), onPressed: () => _showUploadDialog(context), icon: Icon(Icons.cloud_upload, size: 16), label: Text("Muat Naik", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      ],
    ]);
  }

  Widget _buildMobileHeader(bool bolehUrusKotak, bool bolehUpload) {
    return Row(children: [
      Image.asset('Assets/Images/logo_ukk-bg.png', height: 28, errorBuilder: (_,__,___) => Icon(Icons.broken_image, color: goldAccent, size: 28)),
      SizedBox(width: 8),
      Flexible(child: Text('UKK JTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1), maxLines: 1, overflow: TextOverflow.ellipsis)),
      Spacer(),
      if (bolehUrusKotak)
        IconButton(icon: Icon(Icons.grid_view_rounded, color: Colors.white70, size: 20), onPressed: _bukaUrusKategoriPanel, padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 36, minHeight: 36)),
      if (bolehUpload)
        IconButton(icon: Icon(Icons.cloud_upload, color: goldAccent, size: 20), onPressed: () => _showUploadDialog(context), padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 36, minHeight: 36)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════
// DIALOG TAMBAH KOTAK DINAMIK (RESPONSIF)
// ═══════════════════════════════════════════════════════
class DynTambahKategoriDialog extends StatefulWidget {
  const DynTambahKategoriDialog({super.key});
  @override State<DynTambahKategoriDialog> createState() => _DynTambahKategoriDialogState();
}

class _DynTambahKategoriDialogState extends State<DynTambahKategoriDialog> {
  TextEditingController titleCtrl = TextEditingController();
  String _selectedIconName = 'folder'; 

  static const List<String> iconNames = ['folder','image','videocam','music_note','insert_drive_file','pie_chart','campaign','event','people','work'];

  @override Widget build(BuildContext context) {
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
            Row(children: [Icon(Icons.add_box, color: goldAccent, size: isMobile ? 20 : 24), SizedBox(width: 10), Text('TAMBAH KOTAK BARU', style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold))]),
            SizedBox(height: isMobile ? 15 : 25),
            Text('Nama Kategori / Folder', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: titleCtrl, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), hintText: 'Cth: Gambar Program', hintStyle: const TextStyle(color: Colors.white24), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            SizedBox(height: isMobile ? 15 : 20),
            Text('Pilih Ikon', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: isMobile ? 120 : 150, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12, runSpacing: 12,
                  children: iconNames.map((name) {
                    final icon = DynamicFolderIcons.getIcon(name); final selected = _selectedIconName == name;
                    return InkWell(
                      onTap: () => setState(() => _selectedIconName = name),
                      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: selected ? goldAccent : Colors.transparent, shape: BoxShape.circle), child: Icon(icon, color: selected ? solidBlack : softText, size: isMobile ? 20 : 24)),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 20 : 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: softText, fontSize: isMobile ? 12 : 14))),
                SizedBox(width: isMobile ? 10 : 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 20, vertical: isMobile ? 10 : 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty) Navigator.pop(context, {'title': titleCtrl.text, 'icon_name': _selectedIconName});
                    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila masukkan nama kotak!'), backgroundColor: Colors.orange));
                  },
                  child: Text('Simpan Kotak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HALAMAN SUB ASET (PAPARAN FAIL DALAM KATEGORI)
// ═══════════════════════════════════════════════════════
class DynSubAssetPage extends StatefulWidget {
  final String title;
  final String category;
  final String userRole;

  const DynSubAssetPage({super.key, required this.title, required this.category, this.userRole = 'user'});

  @override State<DynSubAssetPage> createState() => _DynSubAssetPageState();
}

class _DynSubAssetPageState extends State<DynSubAssetPage> {
  String searchQuery = '';
  String sortOption = 'Terbaru';
  List<dynamic> allFiles = [];
  bool isLoading = true;

  @override void initState() { super.initState(); _fetchCategoryFiles(); }

  Future<void> _fetchCategoryFiles() async {
    setState(() => isLoading = true);
    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await http.get(Uri.parse('$apiFileUrl/get_files.php?kategori=${Uri.encodeComponent(widget.category)}&t=$timestamp'));
      if (response.statusCode == 200) {
        if (mounted) setState(() { allFiles = jsonDecode(response.body); isLoading = false; });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteFile(String filePath, String fileName) async {
    bool confirm = await _sahkanPadamDinamik(context, fileName);
    if (confirm) {
      final res = await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': filePath}));
      if (res.statusCode == 200) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fail dipadam!'), backgroundColor: Colors.green)); _fetchCategoryFiles(); }
    }
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
              width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 400, padding: EdgeInsets.all(isMobile ? 15 : 25),
              decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent.withOpacity(0.5))),
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
                      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text("Simpan Nama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)), onPressed: () => Navigator.pop(context, true)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ) ?? false;

    if (confirm && renameCtrl.text.isNotEmpty) {
      final res = await http.post(Uri.parse('$apiFileUrl/rename_file.php'), body: jsonEncode({'old_path': filePath, 'new_name': renameCtrl.text}));
      if (res.statusCode == 200) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama fail ditukar!'), backgroundColor: Colors.green)); _fetchCategoryFiles(); }
    }
  }

  // 💥 FIX DOWNLOAD 3: Tukar 'file=' kepada 'path=' 💥
  void _muatTurunFail(String filePath, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memuat turun $fileName...', style: const TextStyle(color: solidBlack)), backgroundColor: goldAccent));
    html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')..setAttribute('download', fileName)..click();
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
          } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kandungan pautan ralat.'), backgroundColor: Colors.orange)); }
        } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pelayan gagal membaca pautan. (Status: ${response.statusCode})'), backgroundColor: crimsonRed)); }
      } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat sambungan pautan.'), backgroundColor: crimsonRed)); }
    } else if (['pdf'].contains(ext)) { html.window.open(cleanImageUrl(fileUrl), '_blank'); } else { html.window.open(fileUrl, '_blank'); }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';

    List<dynamic> filteredFiles = allFiles.where((file) {
      String rawName = file['name']; String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
      return displayName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (sortOption == 'A-Z') filteredFiles.sort((a, b) => a['name'].substring(a['name'].indexOf('_') + 1).compareTo(b['name'].substring(b['name'].indexOf('_') + 1)));
    else if (sortOption == 'Z-A') filteredFiles.sort((a, b) => b['name'].substring(b['name'].indexOf('_') + 1).compareTo(a['name'].substring(a['name'].indexOf('_') + 1)));
    else if (sortOption == 'Lama') filteredFiles.sort((a, b) => a['name'].compareTo(b['name']));
    else filteredFiles.sort((a, b) => b['name'].compareTo(a['name'])); // Terbaru

    return Scaffold(
      backgroundColor: solidBlack,
      appBar: AppBar(
        backgroundColor: darkCard, iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 20, fontWeight: FontWeight.bold, letterSpacing: 1.5), maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: true, elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: goldAccent), onPressed: _fetchCategoryFiles)],
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: isMobile ? 15 : 25),
              child: Row(
                children: [
                  Expanded(child: SizedBox(height: isMobile ? 42 : 50, child: TextField(style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: 'Cari aset...', hintStyle: const TextStyle(color: softText), prefixIcon: Icon(Icons.search, color: goldAccent, size: isMobile ? 18 : 20), filled: true, fillColor: darkCard, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), onChanged: (value) => setState(() => searchQuery = value)))),
                  SizedBox(width: isMobile ? 8 : 15),
                  Container(height: isMobile ? 42 : 50, padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(15)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: sortOption, dropdownColor: darkCard, style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold), icon: Icon(Icons.sort, color: goldAccent, size: isMobile ? 18 : 20), items: ['Terbaru', 'Lama', 'A-Z', 'Z-A'].map((String sort) => DropdownMenuItem<String>(value: sort, child: Text(sort))).toList(), onChanged: (val) => setState(() => sortOption = val!)))),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: darkCard))
                  : filteredFiles.isEmpty
                      ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.folder_open, color: Colors.black26, size: 80), SizedBox(height: 10), Text("Tiada fail dijumpai.", style: TextStyle(color: Colors.black54, fontSize: 14))]))
                      : SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: 10),
                          child: Wrap(
                            spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 30, alignment: WrapAlignment.start,
                            children: filteredFiles.map((file) {
                              String rawName = file['name'];
                              String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
                              String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';

                              return DynMinimalAssetCard(
                                imagePath: file['url'], fileName: displayName, isMobile: isMobile, ext: ext, showActions: bolehEditDelete,
                                onView: () {
                                  if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(ext)) {
                                    String cleanUrl = cleanImageUrl(file['url']); _paparImejLuar(context, cleanUrl, displayName);
                                  } else if (ext == 'link' || ext == 'pdf') {
                                    _lihatAtauBukaLink(file['url'], ext, file['path']);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila muat turun fail ini untuk melihatnya.'), backgroundColor: Colors.orange));
                                  }
                                },
                                onDownload: () => _muatTurunFail(file['path'], displayName),
                                onDelete: () => _deleteFile(file['path'], displayName),
                                onRename: () => _renameFile(file['path'], displayName),
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

// ═══════════════════════════════════════════════════════
// KAD KATEGORI DINAMIK (RESPONSIF)
// ═══════════════════════════════════════════════════════
class DynHoverableCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile;

  const DynHoverableCard({super.key, required this.title, required this.icon, required this.onTap, this.isMobile = false});

  @override State<DynHoverableCard> createState() => _DynHoverableCardState();
}

class _DynHoverableCardState extends State<DynHoverableCard> {
  bool isHovered = false;

  @override Widget build(BuildContext context) {
    double width = widget.isMobile ? 140 : 220;
    double height = widget.isMobile ? 140 : 220;
    final iconSize = widget.isMobile ? 40.0 : 60.0;
    final fontSize = widget.isMobile ? 11.0 : 13.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true), onExit: (_) => setState(() => isHovered = false), cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
          width: width, height: height,
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 2), boxShadow: [if (isHovered) BoxShadow(color: goldAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10)) else BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: Icon(widget.icon, color: goldAccent, size: iconSize))),
              Container(
                width: double.infinity, padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 10 : 15, horizontal: 10),
                decoration: BoxDecoration(color: isHovered ? goldAccent : const Color(0xFF1E2025), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22))),
                child: Text(widget.title.replaceAll('\n', ' '), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHovered ? solidBlack : goldAccent, fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KAD MINIMAL ASET (RESPONSIF)
// ═══════════════════════════════════════════════════════
class DynMinimalAssetCard extends StatefulWidget {
  final String imagePath, fileName, ext;
  final VoidCallback onView, onDownload, onDelete, onRename;
  final bool showActions, isMobile;

  const DynMinimalAssetCard({
    super.key, required this.imagePath, required this.fileName, required this.ext,
    required this.onView, required this.onDownload, required this.onDelete, required this.onRename,
    this.showActions = true, this.isMobile = false,
  });

  @override State<DynMinimalAssetCard> createState() => _DynMinimalAssetCardState();
}

class _DynMinimalAssetCardState extends State<DynMinimalAssetCard> {
  bool isHovered = false;

  Widget _buildIconOrImage() {
    String ext = widget.ext;
    if (ext == 'pdf') return Center(child: Icon(Icons.picture_as_pdf, color: crimsonRed, size: widget.isMobile ? 40 : 60));
    if (ext == 'link') return Center(child: Icon(Icons.link, color: Colors.greenAccent, size: widget.isMobile ? 40 : 60));
    if (['png', 'jpg', 'jpeg'].contains(ext)) {
      return Image.network(
        cleanImageUrl(widget.imagePath), fit: BoxFit.contain, filterQuality: FilterQuality.high,
        errorBuilder: (c, e, s) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.image, color: goldAccent, size: widget.isMobile ? 30 : 50), const SizedBox(height: 5), Text('Klik Buka', style: TextStyle(color: softText, fontSize: widget.isMobile ? 8 : 10))])),
        loadingBuilder: (context, child, progress) { if (progress == null) return child; return const Center(child: CircularProgressIndicator(color: goldAccent, strokeWidth: 2)); },
      );
    }
    return Center(child: Icon(Icons.insert_drive_file, color: goldAccent, size: widget.isMobile ? 40 : 60));
  }

  @override Widget build(BuildContext context) {
    double boxSize = widget.isMobile ? 140 : 220;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true), onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic, transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
        child: Container(
          width: boxSize, height: boxSize,
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: isHovered ? goldAccent : Colors.transparent, width: 2), boxShadow: [if (isHovered) BoxShadow(color: goldAccent.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10)) else BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(padding: EdgeInsets.all(widget.isMobile ? 8 : 15), color: darkCard, child: _buildIconOrImage()),
                AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0, duration: const Duration(milliseconds: 200),
                  child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.95)], stops: const [0.3, 1.0]))),
                ),
                if (isHovered)
                  Positioned(
                    bottom: widget.isMobile ? 5 : 15, left: 5, right: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: widget.isMobile ? 11 : 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        SizedBox(height: widget.isMobile ? 6 : 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Wrap(
                            alignment: WrapAlignment.center, spacing: 5, runSpacing: 5,
                            children: [
                              if (widget.showActions) _buildMiniBtn(Icons.edit_outlined, goldAccent, widget.onRename, 'Edit Nama'),
                              _buildMiniBtn(widget.ext == 'link' ? Icons.open_in_new : Icons.visibility_outlined, Colors.blueAccent, widget.onView, 'Papar'),
                              if (widget.ext != 'link') _buildMiniBtn(Icons.file_download_outlined, Colors.greenAccent, widget.onDownload, 'Muat Turun'),
                              if (widget.showActions) _buildMiniBtn(Icons.delete_outline, crimsonRed, widget.onDelete, 'Padam'),
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
    );
  }

  Widget _buildMiniBtn(IconData icon, Color color, VoidCallback action, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: action, borderRadius: BorderRadius.circular(30),
        child: Container(padding: EdgeInsets.all(widget.isMobile ? 5 : 8), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5), width: 1)), child: Icon(icon, color: color, size: widget.isMobile ? 14 : 16)),
      ),
    );
  }
}