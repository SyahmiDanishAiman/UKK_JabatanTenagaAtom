import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// 💥 ALAMAT API UTAMA 💥
const String apiDbUrl = 'https://app.atom.gov.my/ukk_api/';
const String apiFileUrl = 'https://app.atom.gov.my/ukk_api';

// 🎨 PALET WARNA TEMA DASHBOARD
const Color darkCard   = Color(0xFF2B2A33);
const Color goldAccent = Color(0xFFC9A96E);
const Color softText   = Color(0xFFB0ADB8);
const Color crimsonRed = Color(0xFFE50914);
const Color bgRoseTop  = Color(0xFFFBF5F3);
const Color bgGoldBot  = Color(0xFFF0E5D2);
const Color solidBlack = Colors.black;
const Color inputDark  = Color(0xFF3E3D47);

// ============================================================================
// DATA KOTAK GLOBAL & SUB-KOTAK
// ============================================================================
List<Map<String, dynamic>> globalMasterCategories = [
  {'id': 1, 'title': 'LOGO\nUKK', 'category': 'Logo Jabatan', 'imageAsset': 'Assets/Images/LOGO UKK (ORIGINAL).jpeg', 'imageBytes': null},
  {'id': 2, 'title': 'LOGO\nKEMENTERIAN', 'category': 'Logo Kementerian', 'imageAsset': 'Assets/Images/jata-MOSTI.png', 'imageBytes': null},
  {'id': 3, 'title': 'LOGO\nATOM', 'category': 'Logo Agensi', 'imageAsset': 'Assets/Images/LOGO JABATAN TENAGA ATOM_HITAM.png', 'imageBytes': null},
  {'id': 4, 'title': 'LOGO\nSAMBUTAN 40 TAHUN', 'category': 'Logo Sambutan', 'imageAsset': 'Assets/Images/Atom40-bg.png', 'imageBytes': null},
  {'id': 5, 'title': 'LOGO\nAELB', 'category': 'Logo AELB', 'imageAsset': 'Assets/Images/AELB-bg.png', 'imageBytes': null},
  {'id': 6, 'title': 'LOGO\nKKSLPTA', 'category': 'Logo KKSLPTA', 'imageAsset': 'Assets/Images/LOGO KKSLPTA.PNG', 'imageBytes': null},
];

Map<String, List<Map<String, dynamic>>> globalSubCategories = {};

// ============================================================================
// FUNGSI PEMBERSIH URL GAMBAR (Bypass CORS)
// ============================================================================
String cleanImageUrl(String rawUrl) {
  if (rawUrl.isEmpty) return '';
  String pathOnly = Uri.decodeFull(Uri.decodeFull(rawUrl)).replaceAll('\\', '/');
  if (pathOnly.startsWith('http')) {
    pathOnly = pathOnly.replaceFirst('$apiFileUrl/', '');
  }
  if (pathOnly.startsWith('/')) pathOnly = pathOnly.substring(1);
  return '$apiFileUrl/lihat_gambar.php?path=${Uri.encodeComponent(pathOnly)}';
}

// ============================================================================
// FUNGSI GLOBAL: DIALOG PENGESAHAN KESELAMATAN
// ============================================================================
Future<bool> sahkanKeselamatanPadam(BuildContext context, String mesejAmaran) async {
  TextEditingController pwController = TextEditingController();
  bool isError = false;

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setPopupState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                  Text('Masukkan kata laluan untuk memadam:\n"$mesejAmaran".', textAlign: TextAlign.center, style: const TextStyle(color: softText, fontSize: 13, height: 1.5)),
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
// HALAMAN UTAMA: LOGO PAGE (RESPONSIF, TANPA BINGKAI, 3 LAJUR DESKTOP)
// ═══════════════════════════════════════════════════════
class LogoPage extends StatefulWidget {
  final String userRole;
  const LogoPage({super.key, this.userRole = 'user'});
  @override State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {

  void _muatTurunFail(String filePath, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memuat turun $fileName...', style: const TextStyle(color: solidBlack)), backgroundColor: goldAccent));
    final url = '$apiFileUrl/download.php?file=${Uri.encodeComponent(filePath)}';
    html.AnchorElement(href: url)..setAttribute('download', fileName)..click();
  }

  // ---------- DIALOG MUAT NAIK (RESPONSIF) ----------
  void _showUploadDialog(BuildContext context) {
    List<PlatformFile> selectedFiles = [];
    String selectedCategory = globalMasterCategories.isNotEmpty ? globalMasterCategories.first['category'] : 'Panduan Logo';
    bool isUploading = false;
    double uploadProgress = 0.0;
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    bool isLinkMode = false;

    Map<String, String> dropdownCategories = {'Panduan Logo': 'Panduan Logo'};
    for (var cat in globalMasterCategories) {
      String mainTitle = cat['title'].replaceAll('\n', ' ');
      String mainCatVal = cat['category'];
      dropdownCategories[mainTitle] = mainCatVal;
      if (globalSubCategories.containsKey(mainCatVal)) {
        for (var sub in globalSubCategories[mainCatVal]!) {
          dropdownCategories["   ↳ ${sub['title']}"] = sub['category'];
        }
      }
    }

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                          Row(children: [
                            Icon(Icons.cloud_upload, color: goldAccent, size: isMobile ? 18 : 22),
                            SizedBox(width: isMobile ? 8 : 12),
                            Text('MUAT NAIK LOGO / PAUTAN', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold)),
                          ]),
                          if (!isUploading)
                            IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
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
                                  child: Center(child: Text("Fail Logo", style: TextStyle(color: !isLinkMode ? goldAccent : softText, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13))),
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
                                value: selectedCategory, dropdownColor: darkCard, isExpanded: true,
                                icon: Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: isMobile ? 18 : 22)),
                                items: dropdownCategories.entries.map((entry) {
                                  bool isSub = entry.key.startsWith('   ↳');
                                  return DropdownMenuItem<String>(
                                    value: entry.value,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: isSub ? 20.0 : 15.0, right: 15.0),
                                      child: Row(children: [
                                        Icon(isSub ? Icons.subdirectory_arrow_right : Icons.folder, color: goldAccent, size: 18),
                                        SizedBox(width: 10),
                                        Expanded(child: Text(entry.key, style: TextStyle(color: isSub ? Colors.white70 : Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: isSub ? FontWeight.normal : FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ]),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setDialogState(() => selectedCategory = val!),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 15),

                          if (isLinkMode) ...[
                            Text("Nama Pautan (Wajib)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            TextField(controller: nameController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: 'Cth: Pautan Folder AI Logo', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                            SizedBox(height: 15),
                            Text("Pautan URL Luar", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            TextField(controller: urlController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(prefixIcon: Icon(Icons.link, color: goldAccent, size: isMobile ? 18 : 20), hintText: 'https://...', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                          ] else ...[
                            Text("Pilih Fail Fizikal (Max: 20)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);
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
                                decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12), border: Border.all(color: selectedFiles.isNotEmpty ? goldAccent : Colors.transparent, width: 1.5)),
                                child: selectedFiles.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                                        child: Row(children: [
                                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.file_copy, color: goldAccent, size: isMobile ? 24 : 30)),
                                          SizedBox(width: 15),
                                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('${selectedFiles.length} Fail Dipilih', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('✓ Sedia dimuat naik', style: TextStyle(color: goldAccent, fontSize: isMobile ? 10 : 11))])),
                                        ]),
                                      )
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
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila masukkan Nama Pautan dan URL!'), backgroundColor: Colors.orange)); return;
                                }
                                if (!isLinkMode && selectedFiles.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sila pilih fail logo terlebih dahulu!'), backgroundColor: Colors.orange)); return;
                                }

                                setDialogState(() { isUploading = true; uploadProgress = 0.0; });

                                try {
                                  String finalCategory = selectedCategory;

                                  if (isLinkMode) {
                                    var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                    request.fields['kategori'] = finalCategory;
                                    String safeName = nameController.text.trim().replaceAll(RegExp(r'[^\w\s\-]+'), '');
                                    Uint8List urlBytes = Uint8List.fromList(utf8.encode(urlController.text));
                                    request.files.add(http.MultipartFile.fromBytes('file', urlBytes, filename: '$safeName.link'));
                                    await request.send();
                                    setDialogState(() => uploadProgress = 1.0);
                                  } else {
                                    int totalFiles = selectedFiles.length;
                                    for (int i = 0; i < totalFiles; i++) {
                                      var file = selectedFiles[i];
                                      var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                      request.fields['kategori'] = finalCategory;
                                      request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
                                      var response = await request.send();
                                      if(response.statusCode == 200) {
                                        setDialogState(() => uploadProgress = (i + 1) / totalFiles);
                                      }
                                    }
                                  }
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berjaya dimuat naik!'), backgroundColor: Colors.green));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat pelayan! Gagal upload.'), backgroundColor: crimsonRed));
                                } finally {
                                  if (mounted) setDialogState(() => isUploading = false);
                                }
                              },
                              child: isUploading
                                  ? Text('SEDANG MEMUAT NAIK...', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: isMobile ? 10 : 13))
                                  : Text('MULA MUAT NAIK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: isMobile ? 11 : 14)),
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

  // ---------- DIALOG PANDUAN (RESPONSIF) ----------
  void _showPanduanDialog(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<List<dynamic>> fetchPanduanFiles() async {
              try {
                final response = await http.get(Uri.parse('$apiFileUrl/get_files.php?kategori=Panduan Logo'));
                if (response.statusCode == 200) return jsonDecode(response.body);
              } catch (_) {}
              return [];
            }

            Future<void> deleteFile(String filePath, String fileName) async {
              bool confirm = await sahkanKeselamatanPadam(context, fileName);
              if (confirm) {
                final res = await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': filePath}));
                if (res.statusCode == 200) setState(() {});
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 650,
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
                          Row(children: [
                            Icon(Icons.menu_book, color: goldAccent, size: isMobile ? 18 : 22),
                            SizedBox(width: isMobile ? 8 : 15),
                            Text('PANDUAN LOGO', style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold)),
                          ]),
                          Row(children: [
                            IconButton(icon: Icon(Icons.refresh, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => setState(() {})),
                            SizedBox(width: isMobile ? 8 : 15),
                            IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxHeight: isMobile ? 400 : 450),
                      padding: EdgeInsets.all(isMobile ? 15 : 25),
                      child: FutureBuilder<List<dynamic>>(
                        future: fetchPanduanFiles(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: goldAccent));
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.folder_off, color: Colors.white24, size: 60), SizedBox(height: 15), Text("Tiada fail panduan.", style: TextStyle(color: softText))]));

                          return ListView.builder(
                            shrinkWrap: true, itemCount: snapshot.data!.length,
                            itemBuilder: (c, i) {
                              final file = snapshot.data![i];
                              String rawName = file['name'];
                              String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
                              String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';

                              return Container(
                                margin: EdgeInsets.only(bottom: isMobile ? 6 : 12),
                                decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 15, vertical: 5),
                                  leading: Icon(ext == 'pdf' ? Icons.picture_as_pdf : Icons.image, color: goldAccent, size: isMobile ? 20 : 24),
                                  title: Text(displayName, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.w600)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildListBtn(Icons.download, Colors.greenAccent, () => _muatTurunFail(file['path'], displayName)),
                                      if (widget.userRole == 'super_admin' || widget.userRole == 'admin') ...[
                                        SizedBox(width: isMobile ? 4 : 8),
                                        _buildListBtn(Icons.delete_outline, crimsonRed, () => deleteFile(file['path'], displayName)),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
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
      },
    );
  }

  Widget _buildListBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(8),
      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
    );
  }

  // ---------- URUS KOTAK UTAMA (RESPONSIF) ----------
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
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25, vertical: isMobile ? 12 : 20),
                      decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      child: Row(children: [
                        Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22),
                        SizedBox(width: isMobile ? 8 : 15),
                        Expanded(child: Text('PENGURUSAN KOTAK UTAMA', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                          onPressed: () async {
                            var result = await showDialog(context: context, builder: (context) => const TambahKategoriDialog());
                            if (result != null) {
                              setModalState(() {
                                globalMasterCategories.add({
                                  'id': DateTime.now().millisecondsSinceEpoch,
                                  'title': result['title'], 'category': result['title'].replaceAll('\n', ' '),
                                  'imageAsset': null, 'imageBytes': result['imageBytes'],
                                });
                              });
                              setState(() {});
                            }
                          },
                          icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                          label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                        ),
                        SizedBox(width: isMobile ? 4 : 15),
                        IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(isMobile ? 12 : 25),
                        itemCount: globalMasterCategories.length,
                        itemBuilder: (context, index) {
                          var cat = globalMasterCategories[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                            decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                            child: Row(children: [
                              Container(
                                width: isMobile ? 40 : 50, height: isMobile ? 40 : 50,
                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: cat['imageBytes'] != null
                                      ? Image.memory(cat['imageBytes'], fit: BoxFit.cover, filterQuality: FilterQuality.high)
                                      : (cat['imageAsset'] != null
                                          ? Image.asset(cat['imageAsset'], fit: BoxFit.cover, filterQuality: FilterQuality.high, errorBuilder: (c,e,s) => Icon(Icons.folder, color: goldAccent))
                                          : Icon(Icons.folder, color: goldAccent)),
                                ),
                              ),
                              SizedBox(width: isMobile ? 10 : 15),
                              Expanded(child: Text(cat['title'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                              SizedBox(width: 8),
                              IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () async {
                                var result = await showDialog(context: context, builder: (context) => TambahKategoriDialog(existingData: cat));
                                if (result != null) {
                                  setModalState(() {
                                    cat['title'] = result['title'];
                                    cat['category'] = result['title'].replaceAll('\n', ' ');
                                    if (result['imageBytes'] != null) { cat['imageBytes'] = result['imageBytes']; cat['imageAsset'] = null; }
                                  });
                                  setState(() {});
                                }
                              }),
                              SizedBox(width: 4),
                              IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () async {
                                bool confirm = await sahkanKeselamatanPadam(context, cat['title'].replaceAll('\n', ' '));
                                if (confirm) { setModalState(() => globalMasterCategories.removeAt(index)); setState(() {}); }
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
        );
      },
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
          // ======== HEADER ========
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
            decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
            child: SafeArea(
              bottom: false,
              child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
            ),
          ),

          // ======== BODY ========
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 40, horizontal: isMobile ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Kotak Panduan
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 30, vertical: isMobile ? 15 : 20),
                      constraints: const BoxConstraints(maxWidth: 850),
                      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: goldAccent.withOpacity(0.5))),
                      child: Row(children: [
                        Expanded(child: Text('Panduan kepada kakitangan JTA berkenaan penggunaan logo rasmi.', style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 13, letterSpacing: 0.5))),
                        SizedBox(width: isMobile ? 12 : 20),
                        ElevatedButton.icon(
                          onPressed: () => _showPanduanDialog(context),
                          icon: Icon(Icons.menu_book, size: isMobile ? 14 : 16),
                          label: Text('PANDUAN LOGO', style: TextStyle(fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, elevation: 0, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 12 : 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ]),
                    ),
                    SizedBox(height: isMobile ? 30 : 50),
                    Text('L O G O', style: TextStyle(color: darkCard, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w900, letterSpacing: 5.0), textAlign: TextAlign.center),
                    SizedBox(height: isMobile ? 24 : 40),

                    // Grid Kategori Induk (TANPA BINGKAI BESAR, GUNA WRAP)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Wrap(
                        spacing: isMobile ? 15 : 25,
                        runSpacing: isMobile ? 15 : 25,
                        alignment: WrapAlignment.center,
                        children: globalMasterCategories.map((cat) {
                          return HoverableStaticCard(
                            imagePath: cat['imageAsset'],
                            imageBytes: cat['imageBytes'],
                            icon: cat['icon'],
                            title: cat['title'],
                            isMobile: isMobile,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicLogoCategoryPage(title: cat['title'].replaceAll('\n', ' '), category: cat['category'], userRole: widget.userRole))).then((_) => setState((){})),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: isMobile ? 60 : 100),
                  ],
                ),
              ),
            ),
          ),

          // FOOTER
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

  // Header Desktop
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

  // Header Mobile
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
// DIALOG TAMBAH KOTAK
// ═══════════════════════════════════════════════════════
class TambahKategoriDialog extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  const TambahKategoriDialog({super.key, this.existingData});
  @override State<TambahKategoriDialog> createState() => _TambahKategoriDialogState();
}

class _TambahKategoriDialogState extends State<TambahKategoriDialog> {
  TextEditingController titleCtrl = TextEditingController();
  Uint8List? selectedImageBytes;

  @override void initState() {
    super.initState();
    if (widget.existingData != null) titleCtrl.text = widget.existingData!['title'];
  }

  @override Widget build(BuildContext context) {
    bool isEdit = widget.existingData != null;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400, padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 1.5)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(isEdit ? Icons.edit : Icons.add_box, color: goldAccent), SizedBox(width: 10), Text(isEdit ? 'UBAH KOTAK' : 'TAMBAH KOTAK BARU', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
          SizedBox(height: 25),
          Text('Nama Kategori', style: TextStyle(color: softText, fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(controller: titleCtrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: Color(0xFF1E2025), hintText: 'Cth: Logo JPM', hintStyle: TextStyle(color: Colors.white24), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          SizedBox(height: 20),
          Text('Gambar Kotak (Pilihan)', style: TextStyle(color: softText, fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
              if (result != null) setState(() => selectedImageBytes = result.files.first.bytes);
            },
            child: Container(
              width: double.infinity, height: 130,
              decoration: BoxDecoration(color: Color(0xFF1E2025), borderRadius: BorderRadius.circular(12), border: Border.all(color: selectedImageBytes != null ? goldAccent : Colors.transparent, width: 2)),
              child: selectedImageBytes != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(selectedImageBytes!, fit: BoxFit.cover)) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, color: goldAccent, size: 35), SizedBox(height: 8), Text('Klik untuk muat naik gambar', style: TextStyle(color: softText, fontSize: 12))]),
            ),
          ),
          SizedBox(height: 35),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: softText))),
            SizedBox(width: 15),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () {
              if (titleCtrl.text.isNotEmpty) Navigator.pop(context, {'title': titleCtrl.text, 'imageBytes': selectedImageBytes});
              else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sila masukkan nama kotak!'), backgroundColor: Colors.orange));
            }, child: Text('Simpan Kotak', style: TextStyle(fontWeight: FontWeight.bold))),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KAD KATEGORI (HOVER, RESPONSIF, SAIZ TETAP)
// ═══════════════════════════════════════════════════════
class HoverableStaticCard extends StatefulWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final IconData? icon;
  final String title;
  final VoidCallback? onTap;
  final bool isMobile;
  const HoverableStaticCard({super.key, this.imagePath, this.imageBytes, this.icon, required this.title, this.onTap, this.isMobile = false});
  @override State<HoverableStaticCard> createState() => _HoverableStaticCardState();
}

class _HoverableStaticCardState extends State<HoverableStaticCard> {
  bool isHovered = false;
  @override Widget build(BuildContext context) {
    double width = widget.isMobile ? 160 : 220;
    double height = widget.isMobile ? 160 : 220;
    final iconSize = widget.isMobile ? 40.0 : 60.0;

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
          width: width, height: height,
          child: Container(
            width: width, height: height,
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
                    child: widget.imageBytes != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(widget.imageBytes!, fit: BoxFit.contain, filterQuality: FilterQuality.high))
                        : (widget.imagePath != null
                            ? Image.asset(widget.imagePath!, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported_outlined, color: solidBlack, size: iconSize))
                            : Icon(widget.icon ?? Icons.folder_special, color: solidBlack, size: iconSize)),
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
// HALAMAN DINAMIK DALAM FOLDER (RESPONSIF)
// ═══════════════════════════════════════════════════════
class DynamicLogoCategoryPage extends StatefulWidget {
  final String title;
  final String category;
  final String userRole;
  const DynamicLogoCategoryPage({super.key, required this.title, required this.category, required this.userRole});
  @override State<DynamicLogoCategoryPage> createState() => _DynamicLogoCategoryPageState();
}

class _DynamicLogoCategoryPageState extends State<DynamicLogoCategoryPage> {
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
    bool confirm = await sahkanKeselamatanPadam(context, "${selectedFilesToDelete.length} fail yang dipilih");
    if (!confirm) return;
    setState(() => isLoading = true);
    int successCount = 0;
    for (String path in selectedFilesToDelete) {
      try { var res = await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': path})); if (res.statusCode == 200) successCount++; } catch (_) {}
    }
    setState(() { isDeleteMode = false; selectedFilesToDelete.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$successCount Fail Berjaya Dipadam!'), backgroundColor: Colors.green));
    _fetchCategoryFiles();
  }

  Future<void> _renameFile(String filePath, String currentName) async {
    String cleanName = currentName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    TextEditingController renameCtrl = TextEditingController(text: cleanName);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text('Tukar Nama Logo', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: renameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(filled: true, fillColor: inputDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: softText))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan Nama', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true && renameCtrl.text.isNotEmpty) {
      final res = await http.post(Uri.parse('$apiFileUrl/rename_file.php'), body: jsonEncode({'old_path': filePath, 'new_name': renameCtrl.text}));
      if (res.statusCode == 200) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama logo ditukar!'), backgroundColor: Colors.green)); _fetchCategoryFiles(); }
    }
  }

  void _muatTurunFail(String filePath, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memuat turun $fileName...', style: const TextStyle(color: solidBlack)), backgroundColor: goldAccent));
    html.AnchorElement(href: '$apiFileUrl/download.php?file=${Uri.encodeComponent(filePath)}')..setAttribute('download', fileName)..click();
  }

  Future<void> _lihatAtauBukaLink(String fileUrl, String ext, String filePath) async {
    if (ext == 'link') {
      try {
        final response = await http.get(Uri.parse('$apiFileUrl/read_link.php?path=${Uri.encodeComponent(filePath)}'));
        if (response.statusCode == 200) {
          String linkLuar = response.body.trim();
          if (linkLuar.isNotEmpty && !linkLuar.toLowerCase().startsWith('ralat')) {
            if (!linkLuar.startsWith('http')) linkLuar = 'https://$linkLuar';
            html.window.open(linkLuar, '_blank');
          }
        }
      } catch (_) {}
    }
  }

  void _paparImejLuar(String cleanUrl, String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(30),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)]),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), style: const TextStyle(color: goldAccent, fontSize: 16, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    minScale: 0.5, maxScale: 4.0,
                    child: Image.network(cleanUrl, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white54, size: 80)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      Icon(Icons.create_new_folder_outlined, color: goldAccent, size: isMobile ? 18 : 22),
                      SizedBox(width: isMobile ? 8 : 15),
                      Expanded(child: Text('PENGURUSAN SUB-KOTAK', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                        onPressed: () async {
                          var result = await showDialog(context: ctx, builder: (_) => const TambahKategoriDialog());
                          if (result != null) {
                            setModalState(() {
                              globalSubCategories.putIfAbsent(widget.category, () => []);
                              globalSubCategories[widget.category]!.add({
                                'id': DateTime.now().millisecondsSinceEpoch,
                                'title': result['title'],
                                'category': '${widget.category} -> ${result['title'].replaceAll('\n', ' ')}',
                                'imageAsset': null, 'imageBytes': result['imageBytes'],
                              });
                            });
                            setState((){});
                          }
                        },
                        icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                        label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                      ),
                      SizedBox(width: isMobile ? 4 : 15),
                      IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(ctx)),
                    ]),
                  ),
                  Expanded(
                    child: subBoxes.isEmpty
                        ? const Center(child: Text("Tiada sub-kotak.", style: TextStyle(color: softText)))
                        : ListView.builder(
                            padding: EdgeInsets.all(isMobile ? 12 : 25),
                            itemCount: subBoxes.length,
                            itemBuilder: (_, i) {
                              var cat = subBoxes[i];
                              return Container(
                                margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                                decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                                child: Row(children: [
                                  Container(
                                    width: isMobile ? 40 : 50, height: isMobile ? 40 : 50,
                                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                                    child: ClipRRect(borderRadius: BorderRadius.circular(10), child: cat['imageBytes'] != null ? Image.memory(cat['imageBytes'], fit: BoxFit.cover) : Icon(Icons.folder_open, color: goldAccent)),
                                  ),
                                  SizedBox(width: isMobile ? 10 : 15),
                                  Expanded(child: Text(cat['title'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                  IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), onPressed: () async {
                                    var result = await showDialog(context: ctx, builder: (c) => TambahKategoriDialog(existingData: cat));
                                    if (result != null) { setModalState(() { cat['title'] = result['title']; cat['category'] = '${widget.category} -> ${result['title'].replaceAll('\n', ' ')}'; if (result['imageBytes'] != null) cat['imageBytes'] = result['imageBytes']; }); setState((){}); }
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    bool bolehUrusKotak = widget.userRole == 'super_admin';
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';

    List<Map<String, dynamic>> subBoxes = globalSubCategories[widget.category] ?? [];

    List<dynamic> filteredFiles = allFiles.where((file) {
      String rawName = file['name'];
      String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
      return displayName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (sortOption == 'A-Z') filteredFiles.sort((a, b) => a['name'].substring(a['name'].indexOf('_') + 1).compareTo(b['name'].substring(b['name'].indexOf('_') + 1)));
    else if (sortOption == 'Z-A') filteredFiles.sort((a, b) => b['name'].substring(b['name'].indexOf('_') + 1).compareTo(a['name'].substring(a['name'].indexOf('_') + 1)));
    else if (sortOption == 'Lama') filteredFiles.sort((a, b) => a['name'].compareTo(b['name']));
    else filteredFiles.sort((a, b) => b['name'].compareTo(a['name']));

    return Scaffold(
      backgroundColor: solidBlack,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
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
                        onPressed: () => setState(() {
                          isDeleteMode = !isDeleteMode;
                          if (!isDeleteMode) selectedFilesToDelete.clear();
                        }),
                        icon: Icon(isDeleteMode ? Icons.close : Icons.checklist_rtl_rounded, size: isMobile ? 14 : 16),
                        label: Text(isDeleteMode ? "Batal Padam" : "Mod Padam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                      ),
                      SizedBox(width: isMobile ? 6 : 10),
                    ],
                    IconButton(
                      icon: Icon(Icons.refresh, color: goldAccent, size: isMobile ? 18 : 20),
                      onPressed: _fetchCategoryFiles,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
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
                      // Carian & Sort
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
                                    hintText: 'Cari nama logo...',
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
                      // Senarai sub-kotak & fail
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
                                  children: subBoxes.map((cat) => HoverableStaticCard(
                                    title: cat['title'],
                                    imagePath: cat['imageAsset'],
                                    imageBytes: cat['imageBytes'],
                                    isMobile: isMobile,
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicLogoCategoryPage(
                                        title: cat['title'].replaceAll('\n', ' '),
                                        category: cat['category'],
                                        userRole: widget.userRole,
                                      ))).then((_) => setState((){}));
                                    },
                                  )).toList(),
                                ),
                                SizedBox(height: isMobile ? 20 : 40),
                                const Divider(color: Colors.black12, thickness: 2),
                                SizedBox(height: isMobile ? 20 : 40),
                              ],
                              if (isLoading)
                                const Center(child: CircularProgressIndicator(color: darkCard))
                              else if (filteredFiles.isNotEmpty) ...[
                                if (subBoxes.isNotEmpty)
                                  Text('SENARAI FAIL', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                                SizedBox(height: isMobile ? 12 : 20),
                                Wrap(
                                  spacing: isMobile ? 12 : 25,
                                  runSpacing: isMobile ? 12 : 30,
                                  children: filteredFiles.map((file) {
                                    String rawName = file['name'];
                                    String displayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
                                    String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';
                                    bool isSelected = selectedFilesToDelete.contains(file['path']);
                                    return MinimalAssetCard(
                                      fileName: displayName,
                                      imagePath: file['url'],
                                      isMobile: isMobile,
                                      ext: ext,
                                      showActions: bolehEditDelete && !isDeleteMode,
                                      isSelectionMode: isDeleteMode,
                                      isSelected: isSelected,
                                      onToggleSelect: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedFilesToDelete.remove(file['path']);
                                          } else {
                                            selectedFilesToDelete.add(file['path']);
                                          }
                                        });
                                      },
                                      // 💥 FIX LOGIK VIEW SUPAYA TAK RENDER FILE LAIN SEBAGAI GAMBAR 💥
                                      onView: () {
                                        List<String> formatImej = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'];

                                        if (formatImej.contains(ext)) {
                                          _paparImejLuar(cleanImageUrl(file['url']), displayName);
                                        } else if (ext == 'link') {
                                          _lihatAtauBukaLink(file['url'], ext, file['path']);
                                        } else {
                                          // KELUARKAN AMARAN CANTIK JIKA FORMAT LAIN DITEKAN
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: Container(
                                                width: 350,
                                                padding: const EdgeInsets.all(25),
                                                decoration: BoxDecoration(
                                                  color: darkCard,
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: crimsonRed, width: 2),
                                                  boxShadow: [BoxShadow(color: crimsonRed.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)]
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(15),
                                                      decoration: BoxDecoration(color: crimsonRed.withOpacity(0.1), shape: BoxShape.circle),
                                                      child: const Icon(Icons.image_not_supported_outlined, color: crimsonRed, size: 40),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const Text('FAIL TAK BOLEH BUKA', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                                    const SizedBox(height: 10),
                                                    Text('Format fail (.$ext) ini tidak disokong untuk paparan terus di web.\n\nSila muat turun untuk membukanya.', textAlign: TextAlign.center, style: const TextStyle(color: softText, fontSize: 13, height: 1.5)),
                                                    const SizedBox(height: 25),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: softText))),
                                                        const SizedBox(width: 15),
                                                        ElevatedButton.icon(
                                                          style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                          onPressed: () {
                                                            Navigator.pop(ctx);
                                                            _muatTurunFail(file['path'], displayName);
                                                          },
                                                          icon: const Icon(Icons.download, size: 16),
                                                          label: const Text('Muat Turun', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      onDownload: () => _muatTurunFail(file['path'], displayName),
                                      onRename: () => _renameFile(file['path'], displayName),
                                    );
                                  }).toList(),
                                ),
                              ] else if (subBoxes.isEmpty) ...[
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 80),
                                      SizedBox(height: 15),
                                      Text("Tiada fail dijumpai dalam kotak ini.", style: TextStyle(color: Colors.black54, fontSize: 14)),
                                    ],
                                  ),
                                ),
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
          // Floating bar padam pukal
          if (isDeleteMode && selectedFilesToDelete.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 25, vertical: isMobile ? 10 : 15),
                  decoration: BoxDecoration(
                    color: crimsonRed,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: crimsonRed.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${selectedFilesToDelete.length} Fail Dipilih',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 16)),
                      SizedBox(width: isMobile ? 12 : 25),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: crimsonRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: _padamFailPukal,
                        icon: Icon(Icons.delete_forever, size: isMobile ? 16 : 18),
                        label: Text('Padam Semua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 14)),
                      ),
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

// ═══════════════════════════════════════════════════════
// KAD FAIL ASET (RESPONSIF)
// ═══════════════════════════════════════════════════════
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
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;

  const MinimalAssetCard({
    super.key, required this.imagePath, required this.fileName, required this.ext,
    required this.onView, required this.onDownload, this.onDelete, required this.onRename,
    this.showActions = true, this.isMobile = false,
    this.isSelectionMode = false, this.isSelected = false, this.onToggleSelect,
  });

  @override State<MinimalAssetCard> createState() => _MinimalAssetCardState();
}

class _MinimalAssetCardState extends State<MinimalAssetCard> {
  bool isHovered = false;

  Widget _buildIconOrImage() {
    if (widget.ext == 'link') return const Center(child: Icon(Icons.link, color: Colors.greenAccent, size: 60));
    if (widget.ext == 'pdf') return const Center(child: Icon(Icons.picture_as_pdf, color: crimsonRed, size: 60));
    if (widget.ext == 'ai') return const Center(child: Icon(Icons.design_services, color: Colors.orangeAccent, size: 60));
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'].contains(widget.ext.toLowerCase())) {
      return Image.network(
        cleanImageUrl(widget.imagePath), fit: BoxFit.contain, filterQuality: FilterQuality.high,
        errorBuilder: (c, e, s) => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.image, color: goldAccent, size: 50), SizedBox(height: 5), Text('Klik Buka', style: TextStyle(color: softText, fontSize: 10))])),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: goldAccent, strokeWidth: 2));
        },
      );
    }
    return const Center(child: Icon(Icons.insert_drive_file, color: goldAccent, size: 60));
  }

  @override Widget build(BuildContext context) {
    double boxSize = widget.isMobile ? 130 : 220;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.isSelectionMode ? widget.onToggleSelect : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, (isHovered && !widget.isSelectionMode) ? -6.0 : 0.0),
          child: Container(
            width: boxSize, height: boxSize,
            decoration: BoxDecoration(
              color: darkCard, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.isSelected ? crimsonRed : (isHovered && !widget.isSelectionMode ? goldAccent : Colors.transparent), width: widget.isSelected ? 3 : 2),
              boxShadow: [
                if (isHovered && !widget.isSelectionMode)
                  BoxShadow(color: goldAccent.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10))
                else
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(padding: const EdgeInsets.all(15), color: darkCard, child: _buildIconOrImage()),
                  AnimatedOpacity(
                    opacity: (isHovered && !widget.isSelectionMode) ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.95)], stops: const [0.3, 1.0]))),
                  ),
                  if (widget.isSelectionMode)
                    Container(
                      decoration: BoxDecoration(color: widget.isSelected ? crimsonRed.withOpacity(0.3) : Colors.black.withOpacity(0.4)),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(color: widget.isSelected ? crimsonRed : Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.check, size: 16, color: widget.isSelected ? Colors.white : Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  if (isHovered && !widget.isSelectionMode)
                    Positioned(
                      bottom: 12, left: 8, right: 8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
                            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: widget.isMobile ? 11 : 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          SizedBox(height: widget.isMobile ? 8 : 12),
                          Wrap(
                            alignment: WrapAlignment.center, spacing: 6, runSpacing: 6,
                            children: [
                              if (widget.showActions) _btn(Icons.edit_outlined, goldAccent, widget.onRename, 'Edit Nama'),
                              _btn(widget.ext == 'link' ? Icons.open_in_new : Icons.visibility_outlined, Colors.blueAccent, widget.onView, 'Papar'),
                              _btn(Icons.file_download_outlined, Colors.greenAccent, widget.onDownload, 'Muat Turun'),
                            ],
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

  Widget _btn(IconData icon, Color color, VoidCallback action, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5))),
          child: Icon(icon, color: color, size: widget.isMobile ? 14 : 16),
        ),
      ),
    );
  }
}