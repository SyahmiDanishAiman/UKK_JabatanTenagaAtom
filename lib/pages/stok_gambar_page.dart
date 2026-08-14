import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
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

// ============================================================================
// DATA SUB-KOTAK GLOBAL
// ============================================================================
Map<String, List<Map<String, dynamic>>> globalSubCategories = {};

// ============================================================================
// FUNGSI PEMBERSIH URL GAMBAR
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
// DIALOG PENGESAHAN KESELAMATAN
// ============================================================================
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
                      filled: true, fillColor: const Color(0xFF1E2025), hintText: 'Taip "admin123"', hintStyle: const TextStyle(color: Colors.white24),
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

// ============================================================================
// HALAMAN UTAMA: STOK GAMBAR PAGE (RESPONSIF)
// ============================================================================
class StokGambarPage extends StatefulWidget {
  final String userRole;
  const StokGambarPage({super.key, this.userRole = 'user'});
  @override State<StokGambarPage> createState() => _StokGambarPageState();
}

class _StokGambarPageState extends State<StokGambarPage> {
  List<dynamic> dynamicCategories = [];
  bool isLoadingDB = true;

  @override void initState() { super.initState(); _fetchKotak(); }

  Future<void> _fetchKotak() async {
    setState(() => isLoadingDB = true);
    try {
      final res = await http.get(Uri.parse('$apiDbUrl/get_kotak.php?parent=Stok Gambar'));
      if (res.statusCode == 200) {
        setState(() { dynamicCategories = jsonDecode(res.body) ?? []; isLoadingDB = false; });
      } else { setState(() => isLoadingDB = false); }
    } catch (e) { setState(() { dynamicCategories = []; isLoadingDB = false; }); }
  }

  // ---------- DIALOG MUAT NAIK (RESPONSIF) ----------
  void _showUploadDialog(BuildContext context) {
    List<PlatformFile> selectedFiles = [];
    double uploadProgress = 0.0;
    String uploadStatus = '';
    String selectedCategory = 'Pengurusan Atom';
    String selectedKerajaanSub = 'PMX';
    String selectedBerajaSub = 'Sultan Selangor';
    bool isUploading = false;
    TextEditingController nameController = TextEditingController();

    List<String> dropdownList = ['Pengurusan Atom', 'Institusi Beraja', 'Kerajaan'];
    for (var cat in dynamicCategories) { dropdownList.add(cat['nama_kotak'].replaceAll('\n', ' ')); }
    globalSubCategories.forEach((parent, subs) { for (var sub in subs) { dropdownList.add("$parent > ${sub['title']}"); } });

    final List<String> kerajaanSubs = ['PMX', 'TPM', 'YBM', 'YBTM', 'KSU', 'TKSUP', 'SUBKP'];
    final List<String> berajaSubs = ['Sultan Selangor', 'Yang di-Pertuan Agong'];
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
              // 💥 FIX UPLOAD: withData true untuk ZIP 💥
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
                          Row(children: [Icon(Icons.cloud_upload, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 12), Text('MUAT NAIK GAMBAR', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))]),
                          if (!isUploading) IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 15 : 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kategori Destinasi", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: dropdownList.contains(selectedCategory) ? selectedCategory : dropdownList.first,
                                dropdownColor: darkCard, isExpanded: true,
                                icon: Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: isMobile ? 18 : 22)),
                                items: dropdownList.map((String cat) => DropdownMenuItem<String>(value: cat, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Row(children: [Icon(cat.contains('>') ? Icons.subdirectory_arrow_right : Icons.folder, color: goldAccent, size: 18), const SizedBox(width: 10), Expanded(child: Text(cat, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), maxLines: 1, overflow: TextOverflow.ellipsis))])) )).toList(),
                                onChanged: (val) => setDialogState(() => selectedCategory = val!),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 15),
                          if (selectedCategory == 'Kerajaan') ...[
                            Text('Bahagian Kerajaan', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Wrap(spacing: 8, runSpacing: 8, children: kerajaanSubs.map((sub) => _buildSubCategoryBtn(sub, selectedKerajaanSub, (val) => setDialogState(() => selectedKerajaanSub = val), isMobile)).toList()),
                            SizedBox(height: 8),
                          ],
                          if (selectedCategory == 'Institusi Beraja') ...[
                            Text('Institusi Beraja', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Wrap(spacing: 8, runSpacing: 8, children: berajaSubs.map((sub) => _buildSubCategoryBtn(sub, selectedBerajaSub, (val) => setDialogState(() => selectedBerajaSub = val), isMobile)).toList()),
                            SizedBox(height: 8),
                          ],
                          SizedBox(height: isMobile ? 12 : 20),
                          Text("Nama Fail / Folder (Pilihan)", style: TextStyle(color: softText, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          TextField(
                            controller: nameController, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                            decoration: InputDecoration(hintText: 'Hanya diguna jika 1 fail dimuat naik', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                          ),
                          SizedBox(height: isMobile ? 12 : 20),
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
                                        Icon(displayName.contains('/') ? Icons.folder : Icons.insert_drive_file, color: goldAccent, size: isMobile ? 18 : 20),
                                        SizedBox(width: 8),
                                        Expanded(child: Text(displayName, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                                // 💥 FIX UPLOAD: withData true untuk FAIL GAMBAR 💥
                                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true, withData: true);
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
                              onPressed: (selectedFiles.isEmpty || isUploading) ? null : () async {
                                String finalCategory = 'Lain-lain';
                                if (selectedCategory == 'Kerajaan') { finalCategory = 'Kerajaan $selectedKerajaanSub'; }
                                else if (selectedCategory == 'Institusi Beraja') { finalCategory = 'Beraja $selectedBerajaSub'; }
                                else if (selectedCategory == 'Pengurusan Atom') { finalCategory = 'Pengurusan Atom'; }
                                else if (selectedCategory.contains(' > ')) {
                                  final parts = selectedCategory.split(' > ');
                                  if (parts.length == 2) {
                                    final parent = parts[0].trim(); final sub = parts[1].trim();
                                    final subs = globalSubCategories[parent] ?? [];
                                    final found = subs.firstWhere((s) => s['title'] == sub, orElse: () => {});
                                    finalCategory = found.isNotEmpty ? found['category'] : 'Stok Gambar $selectedCategory';
                                  }
                                } else {
                                  bool found = false;
                                  for (var dynCat in dynamicCategories) { if (dynCat['nama_kotak'].replaceAll('\n', ' ') == selectedCategory) { finalCategory = 'Stok Gambar ${dynCat['nama_kotak']}'; found = true; break; } }
                                  if (!found) finalCategory = 'Stok Gambar $selectedCategory';
                                }

                                setDialogState(() { isUploading = true; uploadProgress = 0.0; uploadStatus = 'Memulakan muat naik...'; });

                                try {
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

                                    // 💥 FIX UPLOAD: Buang aksara pelik pada nama fizikal 💥
                                    String safeFileName = fileNameToUpload.replaceAll(RegExp(r'[^\w\.\-\/]'), '_');

                                    var request = http.MultipartRequest('POST', Uri.parse('$apiFileUrl/upload.php'));
                                    request.fields['kategori'] = finalCategory;
                                    if (nameController.text.trim().isNotEmpty && total == 1 && !fileNameToUpload.contains('___')) { 
                                      request.fields['custom_name'] = nameController.text.trim(); 
                                    }

                                    // 💥 FIX UPLOAD: Pastikan data tak kosong 💥
                                    if (file.bytes == null || file.bytes!.isEmpty) {
                                      throw Exception("Data fail '${file.name}' kosong (0 Bytes).");
                                    }

                                    request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: safeFileName));
                                    var response = await request.send();
                                    var responseBody = await response.stream.bytesToString();

                                    if (response.statusCode == 200) { 
                                      if (responseBody.contains('"status":"error"')) {
                                        throw Exception("Pelayan menolak fail.");
                                      }
                                      setDialogState(() { uploadProgress = (i + 1) / total; }); 
                                    } else { 
                                      setDialogState(() => isUploading = false); 
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terdapat ralat muat naik.'), backgroundColor: Colors.red)); 
                                      return; 
                                    }
                                  }
                                  setDialogState(() { uploadProgress = 1.0; uploadStatus = 'Selesai!'; });
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$total fail berjaya dimuat naik ke $finalCategory!'), backgroundColor: Colors.green));
                                } catch (e) {
                                  setDialogState(() => isUploading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat Server: $e'), backgroundColor: Colors.red));
                                }
                              },
                              child: isUploading ? Text('SEDANG MEMUAT NAIK...', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: isMobile ? 10 : 13)) : Text('MULA MUAT NAIK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: isMobile ? 11 : 14)),
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
        padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
        decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(12), border: Border.all(color: goldAccent.withOpacity(0.5), width: 1)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: goldAccent, size: isMobile ? 18 : 20),
          SizedBox(width: isMobile ? 6 : 8),
          Text(label, style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13))
        ]),
      ),
    );
  }

  Widget _buildSubCategoryBtn(String title, String currentSelected, Function(String) onTap, bool isMobile) {
    bool isSelected = title == currentSelected;
    return InkWell(
      onTap: () => onTap(title), borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: isMobile ? 10 : 15),
        decoration: BoxDecoration(color: isSelected ? goldAccent.withOpacity(0.2) : const Color(0xFF1E2025), border: Border.all(color: isSelected ? goldAccent : Colors.transparent), borderRadius: BorderRadius.circular(8)),
        child: Text(title, style: TextStyle(color: isSelected ? goldAccent : Colors.white70, fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12))
      ),
    );
  }

  // ---------- URUS KOTAK (RESPONSIF) ----------
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
                      child: Row(
                        children: [
                          Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 15),
                          Expanded(child: Text('PENGURUSAN KOTAK GAMBAR', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                            onPressed: () async {
                              var result = await showDialog(context: context, builder: (_) => const TambahKategoriDialog());
                              if (result != null) {
                                try {
                                  await http.post(Uri.parse('$apiDbUrl/add_kotak.php'), body: {'nama': result['title'], 'parent': 'Stok Gambar'});
                                  await _fetchKotak(); setModalState(() {});
                                } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ralat API.'), backgroundColor: Colors.red)); }
                              }
                            },
                            icon: Icon(Icons.add, size: isMobile ? 14 : 16), label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                          ),
                          SizedBox(width: isMobile ? 4 : 15),
                          IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: isLoadingDB
                          ? const Center(child: CircularProgressIndicator(color: goldAccent))
                          : ListView.builder(
                              padding: EdgeInsets.all(isMobile ? 12 : 25),
                              itemCount: dynamicCategories.length,
                              itemBuilder: (_, index) {
                                var cat = dynamicCategories[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                                  decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                                  child: Row(children: [
                                    Icon(Icons.folder, color: goldAccent, size: isMobile ? 24 : 30),
                                    SizedBox(width: isMobile ? 10 : 15),
                                    Expanded(child: Text(cat['nama_kotak'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20),
                                      onPressed: () async {
                                        bool confirm = await sahkanKeselamatanPadam(context, cat['nama_kotak'].replaceAll('\n', ' '));
                                        if (confirm) {
                                          await http.post(Uri.parse('$apiDbUrl/delete_kotak.php'), body: {'id': cat['id'].toString()});
                                          await _fetchKotak(); setModalState(() {});
                                        }
                                      },
                                    ),
                                  ]),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    bool bolehUpload = widget.userRole == 'super_admin' || widget.userRole == 'admin';
    bool bolehUrusKotak = widget.userRole == 'super_admin';

    return Scaffold(
      backgroundColor: solidBlack,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
            decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
            child: SafeArea(bottom: false, child: isMobile ? _buildMobileHeader() : _buildDesktopHeader()),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 40, horizontal: isMobile ? 12 : 24),
                child: Column(
                  children: [
                    Text('PANGKALAN DATA FOTO', textAlign: TextAlign.center, style: TextStyle(color: darkCard, fontSize: isMobile ? 22 : 36, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                    SizedBox(height: 8),
                    Text('STOK GAMBAR', textAlign: TextAlign.center, style: TextStyle(color: darkCard.withOpacity(0.7), fontSize: isMobile ? 12 : 18, fontWeight: FontWeight.bold, letterSpacing: 4.0)),
                    SizedBox(height: isMobile ? 30 : 40),
                    Wrap(
                      spacing: isMobile ? 15 : 35, runSpacing: isMobile ? 15 : 35, alignment: WrapAlignment.center,
                      children: [
                        HoverableStaticCard(title: 'PENGURUSAN\nATOM', icon: Icons.corporate_fare_outlined, isMobile: isMobile, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicGambarPage(title: 'PENGURUSAN ATOM', category: 'Pengurusan Atom', userRole: widget.userRole)))),
                        HoverableStaticCard(title: 'INSTITUSI\nBERAJA', icon: Icons.workspace_premium, isMobile: isMobile, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubInstitusiBerajaPage(userRole: widget.userRole)))),
                        HoverableStaticCard(title: 'PENTADBIRAN\nKERAJAAN', icon: Icons.gavel_outlined, isMobile: isMobile, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubKerajaanGridPage(userRole: widget.userRole)))),
                      ],
                    ),
                    if (dynamicCategories.isNotEmpty) ...[
                      SizedBox(height: isMobile ? 30 : 50),
                      const Divider(color: Colors.black12, thickness: 2, indent: 100, endIndent: 100),
                      SizedBox(height: isMobile ? 30 : 50),
                      Wrap(
                        spacing: isMobile ? 15 : 35, runSpacing: isMobile ? 15 : 35, alignment: WrapAlignment.center,
                        children: dynamicCategories.map((cat) => HoverableStaticCard(
                          title: cat['nama_kotak'].replaceAll('\n', ' '), isMobile: isMobile,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicGambarPage(title: cat['nama_kotak'].replaceAll('\n', ' '), category: 'Stok Gambar ${cat['nama_kotak']}', userRole: widget.userRole))).then((_) => setState((){}))
                        )).toList(),
                      ),
                    ],
                    SizedBox(height: isMobile ? 60 : 100),
                  ],
                ),
              ),
            ),
          ),
          Container(width: double.infinity, padding: EdgeInsets.all(isMobile ? 12 : 15), color: darkCard, child: Text('Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat, Jabatan Tenaga Atom.', textAlign: TextAlign.center, style: TextStyle(color: softText, fontSize: isMobile ? 10 : 11))),
        ],
      ),
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
// DIALOG TAMBAH KOTAK (RESPONSIF)
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
          Row(children: [Icon(isEdit ? Icons.edit : Icons.add_box, color: goldAccent), const SizedBox(width: 10), Text(isEdit ? 'UBAH KOTAK' : 'TAMBAH KOTAK BARU', style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold))]),
          SizedBox(height: isMobile ? 15 : 25),
          Text('Nama Kategori', style: TextStyle(color: softText, fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(controller: titleCtrl, style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), hintText: 'Cth: Program Sukan', hintStyle: const TextStyle(color: Colors.white24), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
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
// KAD KATEGORI (RESPONSIF, SAIZ TETAP)
// ═══════════════════════════════════════════════════════
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
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
          width: width, height: height,
          child: Container(
            width: width, height: height,
            decoration: BoxDecoration(
              color: darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: goldAccent, width: 2),
              boxShadow: [
                if (isHovered) BoxShadow(color: goldAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10))
                else BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: Icon(widget.icon ?? Icons.folder_special, color: goldAccent, size: iconSize))),
                Container(
                  width: double.infinity, padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 12 : 15, horizontal: 10),
                  decoration: BoxDecoration(color: isHovered ? goldAccent : const Color(0xFF1E2025), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22))),
                  child: Text(widget.title.replaceAll('\n', ' '), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHovered ? solidBlack : goldAccent, fontSize: widget.isMobile ? 10 : 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HALAMAN SUB-KATEGORI STATIK (BERAJA & KERAJAAN) – RESPONSIF
// ============================================================================
class SubInstitusiBerajaPage extends StatelessWidget {
  final String userRole;
  const SubInstitusiBerajaPage({super.key, required this.userRole});
  @override Widget build(BuildContext context) {
    final List<String> items = ['SULTAN\nSELANGOR', 'YANG\nDI-PERTUAN AGONG'];
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: solidBlack,
      appBar: AppBar(backgroundColor: darkCard, iconTheme: const IconThemeData(color: Colors.white), title: Text('INSTITUSI BERAJA', style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold, letterSpacing: 2.0)), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 50, horizontal: isMobile ? 16 : 50),
            child: Wrap(
              spacing: isMobile ? 15 : 35, runSpacing: isMobile ? 15 : 35, alignment: WrapAlignment.center,
              children: items.map((name) => HoverableStaticCard(
                title: name, icon: Icons.workspace_premium, isMobile: isMobile,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicGambarPage(title: 'GAMBAR RASMI (${name.replaceAll('\n', ' ')})', category: 'Beraja ${name.replaceAll('\n', ' ')}', userRole: userRole)))
              )).toList()
            )
          )
        ),
      ),
    );
  }
}

class SubKerajaanGridPage extends StatelessWidget {
  final String userRole;
  const SubKerajaanGridPage({super.key, required this.userRole});
  @override Widget build(BuildContext context) {
    final List<String> items = ['PMX', 'TPM', 'YBM', 'YBTM', 'KSU', 'TKSUP', 'SUBKP'];
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: solidBlack,
      appBar: AppBar(backgroundColor: darkCard, iconTheme: const IconThemeData(color: Colors.white), title: Text('KERAJAAN', style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold, letterSpacing: 2.0)), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgRoseTop, bgGoldBot])),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 50, horizontal: isMobile ? 16 : 50),
            child: Wrap(
              spacing: isMobile ? 15 : 35, runSpacing: isMobile ? 15 : 35, alignment: WrapAlignment.center,
              children: items.map((name) => HoverableStaticCard(
                title: name, icon: Icons.gavel_outlined, isMobile: isMobile,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicGambarPage(title: 'GAMBAR RASMI ($name)', category: 'Kerajaan $name', userRole: userRole)))
              )).toList()
            )
          )
        ),
      ),
    );
  }
}

// ============================================================================
// 💥 HALAMAN DINAMIK GAMBAR (RESPONSIF, LENGKAP)
// ============================================================================
class DynamicGambarPage extends StatefulWidget {
  final String title; final String category; final String userRole;
  const DynamicGambarPage({super.key, required this.title, required this.category, required this.userRole});
  @override State<DynamicGambarPage> createState() => _DynamicGambarPageState();
}

class _DynamicGambarPageState extends State<DynamicGambarPage> {
  String searchQuery = ''; String sortOption = 'Terbaru'; List<dynamic> allFiles = []; bool isLoading = true;
  bool isDeleteMode = false; final Set<String> selectedFilePaths = {};

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
    if (confirm) { await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': filePath})); _fetchCategoryFiles(); }
  }

  Future<void> _deleteSelectedFiles() async {
    if (selectedFilePaths.isEmpty) return;
    bool confirm = await sahkanKeselamatanPadam(context, '${selectedFilePaths.length} fail terpilih');
    if (!confirm) return;
    for (String path in selectedFilePaths.toList()) { try { await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': path})); } catch (_) {} }
    setState(() { selectedFilePaths.clear(); isDeleteMode = false; });
    _fetchCategoryFiles();
  }

  void _muatTurunFail(String filePath, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memuat turun $fileName...', style: const TextStyle(color: solidBlack)), backgroundColor: goldAccent));
    // 💥 FIX DOWNLOAD 1: Tukar 'file=' kepada 'path=' 💥
    html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')..setAttribute('download', fileName)..click();
  }

  Future<void> _renameFile(String filePath, String currentName) async {
    String cleanName = currentName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    TextEditingController renameCtrl = TextEditingController(text: cleanName);
    bool confirm = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400, padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent.withOpacity(0.5))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Tukar Nama Fail", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: renameCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2025), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            const SizedBox(height: 25),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(child: const Text("Batal", style: TextStyle(color: softText)), onPressed: () => Navigator.pop(context, false)),
              const SizedBox(width: 10),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Simpan Nama", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () => Navigator.pop(context, true)),
            ])
          ])
        )
      ),
    ) ?? false;
    if (confirm && renameCtrl.text.isNotEmpty) {
      final res = await http.post(Uri.parse('$apiFileUrl/rename_file.php'), body: jsonEncode({'old_path': filePath, 'new_name': renameCtrl.text}));
      if (res.statusCode == 200) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama fail ditukar!'), backgroundColor: Colors.green)); _fetchCategoryFiles(); }
    }
  }

  void _paparImejLuar(BuildContext context, String cleanUrl, String fileName) {
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

  void _bukaUrusSubKotakPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        Expanded(child: Text('PENGURUSAN KOTAK (SUB-FOLDER)', style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold))),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: solidBlack, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                          onPressed: () async {
                            var result = await showDialog(context: context, builder: (_) => const TambahKategoriDialog());
                            if (result != null) {
                              setModalState(() {
                                globalSubCategories.putIfAbsent(widget.category, () => []);
                                globalSubCategories[widget.category]!.add({'id': DateTime.now().millisecondsSinceEpoch, 'title': result['title'], 'category': '${widget.category} -> ${result['title'].replaceAll('\n', ' ')}'});
                              });
                              setState(() {});
                            }
                          },
                          icon: Icon(Icons.add, size: isMobile ? 14 : 16), label: Text('Tambah Sub-Kotak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
                        ),
                        SizedBox(width: isMobile ? 4 : 15),
                        IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
                      ]),
                    ),
                    Expanded(
                      child: subBoxes.isEmpty
                          ? const Center(child: Text("Tiada kotak sub-folder dicipta lagi.", style: TextStyle(color: softText)))
                          : ListView.builder(
                              padding: EdgeInsets.all(isMobile ? 12 : 25), itemCount: subBoxes.length,
                              itemBuilder: (context, index) {
                                var cat = subBoxes[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: isMobile ? 8 : 12), padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 15),
                                  decoration: BoxDecoration(color: const Color(0xFF1E2025), borderRadius: BorderRadius.circular(16)),
                                  child: Row(children: [
                                    Icon(Icons.folder_open, color: goldAccent, size: isMobile ? 24 : 30), SizedBox(width: isMobile ? 10 : 15),
                                    Expanded(child: Text(cat['title'].replaceAll('\n', ' '), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                    IconButton(icon: Icon(Icons.edit, color: goldAccent, size: isMobile ? 18 : 20), onPressed: () async {
                                      var result = await showDialog(context: context, builder: (context) => TambahKategoriDialog(existingData: cat));
                                      if (result != null) { setModalState(() { cat['title'] = result['title']; cat['category'] = '${widget.category} -> ${result['title'].replaceAll('\n', ' ')}'; }); setState(() {}); }
                                    }),
                                    SizedBox(width: 4),
                                    IconButton(icon: Icon(Icons.delete_outline, color: crimsonRed, size: isMobile ? 18 : 20), onPressed: () async {
                                      bool confirm = await sahkanKeselamatanPadam(context, cat['title'].replaceAll('\n', ' '));
                                      if (confirm) { setModalState(() => subBoxes.removeAt(index)); setState(() {}); }
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
          }
        );
      }
    );
  }

  @override Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';
    bool bolehUrusKotak = widget.userRole == 'super_admin';

    List<Map<String, dynamic>> subBoxes = globalSubCategories[widget.category] ?? [];
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
              Container(
                height: 70, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40),
                decoration: BoxDecoration(color: darkCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
                child: Row(
                  children: [
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
                      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: isDeleteMode ? crimsonRed : Colors.white10, foregroundColor: Colors.white, elevation: 0, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 15, vertical: isMobile ? 8 : 15)), onPressed: () => setState(() { isDeleteMode = !isDeleteMode; if (!isDeleteMode) selectedFilePaths.clear(); }), icon: Icon(isDeleteMode ? Icons.close : Icons.checklist_rtl_rounded, size: isMobile ? 14 : 16), label: Text(isDeleteMode ? "Batal Padam" : "Mod Padam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12))),
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
                        child: Row(children: [
                          Expanded(child: SizedBox(height: isMobile ? 42 : 50, child: TextField(style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14), decoration: InputDecoration(hintText: 'Cari fail/folder maya...', hintStyle: TextStyle(color: softText), prefixIcon: Icon(Icons.search, color: goldAccent, size: isMobile ? 18 : 20), filled: true, fillColor: darkCard, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), onChanged: (v) => setState(() => searchQuery = v)))),
                          SizedBox(width: isMobile ? 8 : 15),
                          Container(height: isMobile ? 42 : 50, padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(15)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: sortOption, dropdownColor: darkCard, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold), icon: Icon(Icons.sort, color: goldAccent, size: isMobile ? 18 : 20), items: ['Terbaru', 'A-Z', 'Z-A'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => sortOption = v!)))),
                        ]),
                      ),
                      Expanded(
                        child: isLoading ? const Center(child: CircularProgressIndicator(color: darkCard))
                            : (displayItems.isEmpty && subBoxes.isEmpty)
                                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.folder_off, color: Colors.black26, size: 80), SizedBox(height: 10), Text("Tiada fail/folder dijumpai.", style: TextStyle(color: Colors.black54, fontSize: 14))]))
                                : SingleChildScrollView(
                                    padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 10, isMobile ? 16 : 40, isDeleteMode ? 80 : 10),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      if (subBoxes.isNotEmpty) ...[
                                        Text('KOTAK DALAMAN', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                                        SizedBox(height: isMobile ? 12 : 20),
                                        Wrap(spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 30, children: subBoxes.map((cat) => HoverableStaticCard(title: cat['title'], isMobile: isMobile, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DynamicGambarPage(title: cat['title'].replaceAll('\n', ' '), category: cat['category'], userRole: widget.userRole))))).toList()),
                                        SizedBox(height: isMobile ? 20 : 40), const Divider(color: Colors.black12, thickness: 2), SizedBox(height: isMobile ? 20 : 40),
                                      ],
                                      if (displayItems.isNotEmpty) ...[
                                        if (subBoxes.isNotEmpty) Text('SENARAI GAMBAR & FOLDER MAYA', style: TextStyle(color: darkCard, fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, letterSpacing: 1.0)),
                                        SizedBox(height: isMobile ? 12 : 20),
                                        Wrap(spacing: isMobile ? 12 : 25, runSpacing: isMobile ? 12 : 30, children: displayItems.map((item) {
                                          if (item['is_folder'] == true) {
                                            return MinimalAssetCard(
                                              imagePath: '', fileName: item['folder_name'], isMobile: isMobile, ext: '', showActions: false,
                                              isFolder: true, isSelectionMode: false, isSelected: false,
                                              onView: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubFolderGambarPage(folderName: item['folder_name'], category: widget.category, userRole: widget.userRole))).then((_) => _fetchCategoryFiles()),
                                              onDownload: () {}, onDelete: () {}, onRename: () {},
                                            );
                                          } else {
                                            var file = item['file'];
                                            String displayName = item['display_name'];
                                            String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';
                                            String filePath = file['path'];
                                            bool isSelected = selectedFilePaths.contains(filePath);
                                            return MinimalAssetCard(
                                              imagePath: file['url'], fileName: displayName, isMobile: isMobile, ext: ext,
                                              showActions: bolehEditDelete && !isDeleteMode, isFolder: false,
                                              isSelectionMode: isDeleteMode, isSelected: isSelected,
                                              onToggleSelect: () => setState(() { if (isSelected) selectedFilePaths.remove(filePath); else selectedFilePaths.add(filePath); }),
                                              onView: () => _paparImejLuar(context, cleanImageUrl(file['url']), displayName),
                                              onDownload: () => _muatTurunFail(file['path'], displayName),
                                              onDelete: () => _deleteSingleFile(file['path'], displayName),
                                              onRename: () => _renameFile(file['path'], displayName),
                                            );
                                          }
                                        }).toList()),
                                      ]
                                    ]),
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
                    ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: crimsonRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: _deleteSelectedFiles, icon: Icon(Icons.delete_forever, size: isMobile ? 16 : 18), label: Text('Padam Semua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 14))),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 💥 HALAMAN SUB-FOLDER GAMBAR (RESPONSIF, LENGKAP)
// ============================================================================
class SubFolderGambarPage extends StatefulWidget {
  final String folderName; final String category; final String userRole;
  const SubFolderGambarPage({super.key, required this.folderName, required this.category, required this.userRole});
  @override State<SubFolderGambarPage> createState() => _SubFolderGambarPageState();
}

class _SubFolderGambarPageState extends State<SubFolderGambarPage> {
  List<dynamic> folderFiles = []; bool isLoading = true;
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
      } else { setState(() => isLoading = false); }
    } catch (e) { setState(() => isLoading = false); }
  }

  void _paparImejLuar(BuildContext context, String cleanUrl, String fileName) {
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

  @override Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    bool bolehEditDelete = widget.userRole == 'super_admin' || widget.userRole == 'admin';

    return Scaffold(
      backgroundColor: solidBlack,
      appBar: AppBar(backgroundColor: darkCard, iconTheme: const IconThemeData(color: goldAccent), title: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.folder_open, color: goldAccent), const SizedBox(width: 10), Text(widget.folderName, style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold))]), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [bgRoseTop, bgGoldBot])),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: darkCard))
            : folderFiles.isEmpty
                ? const Center(child: Text("Folder ini kosong.", style: TextStyle(color: Colors.black54, fontSize: 16)))
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 20 : 40),
                    child: Wrap(
                      spacing: isMobile ? 15 : 25, runSpacing: isMobile ? 15 : 30, alignment: WrapAlignment.center,
                      children: folderFiles.map((file) {
                        String rawName = file['name']; String fullDisplayName = rawName.contains('_') ? rawName.substring(rawName.indexOf('_') + 1) : rawName;
                        String displayName = fullDisplayName.replaceFirst('${widget.folderName}___', '');
                        String ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';
                        String filePath = file['path'];
                        return MinimalAssetCard(
                          imagePath: file['url'], fileName: displayName, isMobile: isMobile, ext: ext, showActions: bolehEditDelete, isFolder: false,
                          onView: () => _paparImejLuar(context, cleanImageUrl(file['url']), displayName),
                          // 💥 FIX DOWNLOAD 2: Tukar 'file=' kepada 'path=' 💥
                          onDownload: () { html.AnchorElement(href: '$apiFileUrl/download.php?path=${Uri.encodeComponent(filePath)}')..setAttribute('download', displayName)..click(); },
                          onDelete: () async { bool confirm = await sahkanKeselamatanPadam(context, displayName); if (confirm) { await http.post(Uri.parse('$apiFileUrl/delete_file.php'), body: jsonEncode({'path': filePath})); _fetchFiles(); } },
                          onRename: () {},
                        );
                      }).toList(),
                    ),
                  ),
      ),
    );
  }
}

// ============================================================================
// WIDGET KAD FAIL ASET & FOLDER (RESPONSIF, LENGKAP)
// ============================================================================
class MinimalAssetCard extends StatefulWidget {
  final String imagePath; final String fileName; final String ext; final bool showActions;
  final VoidCallback onView; final VoidCallback onDownload; final VoidCallback? onDelete; final VoidCallback onRename;
  final bool isMobile; final bool isFolder;
  final bool isSelectionMode; final bool isSelected; final VoidCallback? onToggleSelect;

  const MinimalAssetCard({
    super.key, required this.imagePath, required this.fileName, required this.ext,
    required this.onView, required this.onDownload, this.onDelete, required this.onRename,
    this.showActions = true, this.isMobile = false, this.isFolder = false,
    this.isSelectionMode = false, this.isSelected = false, this.onToggleSelect,
  });

  @override State<MinimalAssetCard> createState() => _MinimalAssetCardState();
}

class _MinimalAssetCardState extends State<MinimalAssetCard> {
  bool isHovered = false;

  Widget _buildIconOrImage() {
    if (widget.isFolder) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.folder_open, color: goldAccent, size: widget.isMobile ? 55 : 70),
          SizedBox(height: 8),
          Text('Buka Folder', style: TextStyle(color: goldAccent, fontSize: widget.isMobile ? 10 : 11, fontWeight: FontWeight.bold))
        ])
      );
    }
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(widget.ext)) {
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
        onTap: (widget.isSelectionMode && !widget.isFolder) ? widget.onToggleSelect : (!widget.isSelectionMode && widget.isFolder ? widget.onView : null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, (isHovered && !widget.isSelectionMode) ? -6.0 : 0.0),
          child: Container(
            width: boxSize, height: boxSize,
            decoration: BoxDecoration(
              color: darkCard, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.isSelected ? crimsonRed : (isHovered && !widget.isSelectionMode ? goldAccent : Colors.transparent), width: widget.isSelected ? 3 : 2),
              boxShadow: [
                if (isHovered && !widget.isSelectionMode) BoxShadow(color: goldAccent.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10))
                else BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(padding: const EdgeInsets.all(15), color: darkCard, child: _buildIconOrImage()),
                  AnimatedOpacity(
                    opacity: (isHovered && !widget.isSelectionMode && !widget.isFolder) ? 1.0 : 0.0, duration: const Duration(milliseconds: 200),
                    child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.95)], stops: const [0.3, 1.0]))),
                  ),
                  if (widget.isSelectionMode && !widget.isFolder)
                    Container(
                      decoration: BoxDecoration(color: widget.isSelected ? crimsonRed.withOpacity(0.3) : Colors.black.withOpacity(0.4)),
                      child: Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.all(10), child: Container(decoration: BoxDecoration(color: widget.isSelected ? crimsonRed : Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), padding: const EdgeInsets.all(4), child: Icon(Icons.check, size: 16, color: widget.isSelected ? Colors.white : Colors.transparent)))),
                    ),
                  if (widget.isFolder)
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(color: isHovered ? goldAccent : Colors.black87),
                        child: Text(widget.fileName, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHovered ? solidBlack : goldAccent, fontSize: widget.isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (isHovered && !widget.isSelectionMode && !widget.isFolder)
                    Positioned(
                      bottom: 12, left: 8, right: 8,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(widget.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: widget.isMobile ? 11 : 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        SizedBox(height: widget.isMobile ? 8 : 12),
                        Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
                          if (widget.showActions) _btn(Icons.edit_outlined, goldAccent, widget.onRename),
                          _btn(Icons.visibility_outlined, Colors.blueAccent, widget.onView),
                          _btn(Icons.file_download_outlined, Colors.greenAccent, widget.onDownload),
                          if (widget.showActions && widget.onDelete != null) _btn(Icons.delete_outline, crimsonRed, widget.onDelete!),
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

  Widget _btn(IconData icon, Color color, VoidCallback action) {
    return Tooltip(
      message: '',
      child: InkWell(
        onTap: action, borderRadius: BorderRadius.circular(30),
        child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5))), child: Icon(icon, color: color, size: widget.isMobile ? 14 : 16)),
      ),
    );
  }
}