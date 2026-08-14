import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import page sedia ada
import 'pages/logo_page.dart';
import 'pages/video_page.dart';
import 'pages/data_page.dart';
import 'pages/lagu_page.dart';
import 'pages/slaid_page.dart';
import 'pages/stok_gambar_page.dart';
import 'pages/tempah_ukk_page.dart';
import 'pages/dynamic_folder_page.dart';
import 'login_page.dart';

// Class untuk buang scrollbar visual
class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class Dashboard extends StatefulWidget {
  final String userNama;
  final String userRole;

  const Dashboard({
    super.key,
    required this.userNama,
    required this.userRole,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String currentRole;
  List<dynamic> dynamicMenu = [];
  bool isLoadingMenu = true;

  // 🎨 Palet warna
  static const Color darkCard   = Color(0xFF2B2A33);
  static const Color goldAccent = Color(0xFFC9A96E);
  static const Color softText   = Color(0xFFB0ADB8);
  static const Color crimsonRed = Color(0xFFE50914);

  @override
  void initState() {
    super.initState();
    currentRole = widget.userRole;
    _fetchDynamicMenu();
  }

  Future<void> _fetchDynamicMenu() async {
    setState(() => isLoadingMenu = true);
    try {
      final response = await http.get(Uri.parse('https://app.atom.gov.my/ukk_api/get_menu.php'));
      if (response.statusCode == 200) {
        setState(() {
          dynamicMenu = jsonDecode(response.body);
          isLoadingMenu = false;
        });
      } else {
        setState(() => isLoadingMenu = false);
      }
    } catch (e) {
      setState(() => isLoadingMenu = false);
    }
  }

  void _navigasiKePage(String label) {
    Widget? targetPage;
    switch (label) {
      case 'Logo':
        targetPage = LogoPage(userRole: currentRole);
        break;
      case 'Video':
        targetPage = VideoPage(userRole: currentRole);
        break;
      case 'Lagu':
        targetPage = LaguPage(userRole: currentRole);
        break;
      case 'Stok Gambar':
        targetPage = StokGambarPage(userRole: currentRole);
        break;
      case 'Slaid':
        targetPage = SlaidPage(userRole: currentRole);
        break;
      case 'Data Analitik':
        targetPage = DataPage(userRole: currentRole);
        break;
      case 'Tempah UKK':
        targetPage = const TempahUkkPage();
        break;
      default:
        targetPage = DynamicFolderPage(pageTitle: label, userRole: currentRole);
    }
    if (targetPage != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage!));
    }
  }

  IconData getIconData(String iconCode) {
    switch (iconCode) {
      case 'image_outlined':
        return Icons.image_outlined;
      case 'video_library_outlined':
        return Icons.video_library_outlined;
      case 'music_note_outlined':
        return Icons.music_note_outlined;
      case 'photo_library_outlined':
        return Icons.photo_library_outlined;
      case 'slideshow_outlined':
        return Icons.slideshow_outlined;
      case 'bar_chart_outlined':
        return Icons.bar_chart_outlined;
      case 'pie_chart_outlined':
        return Icons.pie_chart_outline; // DIBAIKI
      case 'link_outlined':
        return Icons.link_outlined;
      case 'campaign_outlined':
        return Icons.campaign_outlined;
      case 'event_available_outlined':
        return Icons.event_available_outlined;
      case 'color_lens_outlined':
        return Icons.color_lens_outlined;
      case 'folder_open_rounded':
        return Icons.folder_open_rounded;
      case 'settings_outlined':
        return Icons.settings_outlined;
      case 'article_outlined':
        return Icons.article_outlined;
      case 'assignment_outlined':
        return Icons.assignment_outlined;
      case 'build_outlined':
        return Icons.build_outlined;
      case 'cloud_outlined':
        return Icons.cloud_outlined;
      case 'contacts_outlined':
        return Icons.contacts_outlined;
      case 'description_outlined':
        return Icons.description_outlined;
      case 'email_outlined':
        return Icons.email_outlined;
      case 'language_outlined':
        return Icons.language_outlined;
      case 'public_outlined':
        return Icons.public_outlined;
      case 'storage_outlined':
        return Icons.storage_outlined;
      case 'work_outline':
        return Icons.work_outline;
      case 'groups_outlined':
        return Icons.groups_outlined;
      case 'notifications_outlined':
        return Icons.notifications_outlined;
      case 'security_outlined':
        return Icons.security_outlined;
      default:
        return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    var ikonAktif = dynamicMenu.where((item) => item['is_visible'] == 1 || item['is_visible'] == true).toList();

    // ===== Desktop TETAP KEKAL SEPERTI ASAL =====
    // ===== Mobile DIPISAHKAN DENGAN REKA BENTUK KHAS =====
    return Scaffold(
      backgroundColor: darkCard,
      body: ScrollConfiguration(
        behavior: NoThumbScrollBehavior(),
        child: Column(
          children: [
            // ======== HEADER ========
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40, vertical: isMobile ? 8 : 12),
              decoration: BoxDecoration(
                  color: darkCard,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
              child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
            ),

            // ======== BODY ========
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFBF5F3), Color(0xFFF0E5D2)]),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 40, horizontal: isMobile ? 16 : 24),
                    child: Column(
                      children: [
                        Text('SELAMAT DATANG KE PORTAL',
                            style: TextStyle(
                                color: darkCard.withOpacity(0.7),
                                letterSpacing: isMobile ? 2 : 4,
                                fontWeight: FontWeight.w700,
                                fontSize: isMobile ? 9 : 12),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        Text('Pusat Akses Visual & Media',
                            style: TextStyle(
                                color: darkCard,
                                fontSize: isMobile ? 22 : 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5),
                            textAlign: TextAlign.center),
                        SizedBox(height: isMobile ? 20 : 40),

                        // Kotak dashboard
                        Container(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10))
                              ]),
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 12 : 24),
                            decoration: BoxDecoration(
                                color: goldAccent,
                                borderRadius: BorderRadius.circular(26)),
                            child: isLoadingMenu
                                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                                : _buildResponsiveGrid(ikonAktif, isMobile),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ======== FOOTER ========
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 20, horizontal: 10),
              color: darkCard,
              child: Text(
                'Hak Cipta Terpelihara © 2026 Unit Komunikasi Korporat\nJabatan Tenaga Atom.',
                textAlign: TextAlign.center,
                style: TextStyle(color: softText, fontSize: isMobile ? 10 : 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HEADER DESKTOP (ASAL) ----------
  Widget _buildDesktopHeader() {
    return Row(
      children: [
        Image.asset('Assets/Images/logo_ukk-bg.png', height: 48,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: goldAccent, size: 48)),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            text: TextSpan(
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                children: const [
                  TextSpan(text: 'UKK ', style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'JABATAN TENAGA ATOM',
                      style: TextStyle(color: Color(0xFFE0E0E0)))
                ]),
          ),
        ),
        const Spacer(),
        // Nama pengguna
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30)),
          child: Row(children: [
            Icon(
                currentRole == 'super_admin'
                    ? Icons.admin_panel_settings
                    : Icons.person,
                color: goldAccent,
                size: 16),
            const SizedBox(width: 8),
            Text(widget.userNama.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ]),
        ),
        if (currentRole == 'super_admin')
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded, color: goldAccent),
            tooltip: 'Pengurusan Pengguna',
            onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const UserManagerDialog()),
          ),
        PremiumLogoutButton(
          darkCard: darkCard,
          goldAccent: goldAccent,
          white: Colors.white,
        ),
      ],
    );
  }

  // ---------- HEADER MOBILE ----------
  Widget _buildMobileHeader() {
    return Row(
      children: [
        Image.asset('Assets/Images/logo_ukk-bg.png', height: 28,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: goldAccent, size: 28)),
        const SizedBox(width: 8),
        Flexible(
          child: Text('UKK JTA',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const Spacer(),
        if (currentRole == 'super_admin')
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded, color: goldAccent, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const UserManagerDialog()),
          ),
        const SizedBox(width: 4),
        PremiumLogoutButton(
          darkCard: darkCard,
          goldAccent: goldAccent,
          white: Colors.white,
          isMobile: true,
        ),
      ],
    );
  }

  // ---------- GRID RESPONSIF ----------
  Widget _buildResponsiveGrid(List<dynamic> items, bool isMobile) {
    final ikonAktif = items;
    final totalItems = currentRole == 'super_admin' ? ikonAktif.length + 1 : ikonAktif.length;

    // Saiz ikut peranti
    final iconSize = isMobile ? 32.0 : 42.0;
    final fontSize = isMobile ? 10.0 : 13.0;
    final maxCrossAxisExtent = isMobile ? 130.0 : 180.0;
    final spacing = isMobile ? 8.0 : 16.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 0.9,
      ),
      itemCount: totalItems,
      itemBuilder: (_, index) {
        if (currentRole == 'super_admin' && index == ikonAktif.length) {
          return HoverIconItem(
            icon: Icons.add_to_photos_rounded,
            label: 'Urus Ikon',
            onTapOverride: () => showDialog(
                context: context,
                builder: (_) => IconManagerDialog(
                    dynamicMenu: dynamicMenu,
                    refreshParent: _fetchDynamicMenu)),
            iconSize: iconSize,
            fontSize: fontSize,
          );
        }
        final item = ikonAktif[index];
        return HoverIconItem(
          icon: getIconData(item['icon_code']),
          label: item['nama_menu'],
          onTapOverride: () => _navigasiKePage(item['nama_menu']),
          iconSize: iconSize,
          fontSize: fontSize,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════
// DIALOG URUS IKON (RESPONSIF SEPENUHNYA)
// ═══════════════════════════════════════════════════
class IconManagerDialog extends StatefulWidget {
  final List<dynamic> dynamicMenu;
  final VoidCallback refreshParent;
  const IconManagerDialog({super.key, required this.dynamicMenu, required this.refreshParent});
  @override State<IconManagerDialog> createState() => _IconManagerDialogState();
}

class _IconManagerDialogState extends State<IconManagerDialog> {
  bool isProcessing = false;
  static const darkCard   = Color(0xFF2B2A33);
  static const goldAccent = Color(0xFFC9A96E);
  static const softText   = Color(0xFFB0ADB8);
  static const inputDark  = Color(0xFF3E3D47);
  static const crimsonRed = Color(0xFFE50914);

  // ---------- Fungsi-fungsi asal ----------
  Future<void> _toggleLock(int index, String id, bool currentStatus) async {
    if (currentStatus) {
      TextEditingController pw = TextEditingController();
      bool? ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: darkCard,
          title: const Text('Buka Kunci', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: pw,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                hintText: 'Kata Laluan (admin123)',
                hintStyle: TextStyle(color: softText),
                filled: true,
                fillColor: inputDark),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: softText))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: darkCard), onPressed: () => Navigator.pop(ctx, pw.text == 'admin123'), child: const Text('OK'))
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => isProcessing = true);
    try {
      await http.post(Uri.parse('https://app.atom.gov.my/ukk_api/update_menu.php'), body: {'id': id, 'is_locked': (!currentStatus) ? '1' : '0'});
      setState(() { widget.dynamicMenu[index]['is_locked'] = (!currentStatus) ? 1 : 0; });
      widget.refreshParent();
    } catch (e) {}
    setState(() => isProcessing = false);
  }

  Future<void> _deleteIcon(String id, String nama) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkCard, title: const Text('Padam Ikon?', style: TextStyle(color: Colors.white)), content: Text('Pasti mahu padam "$nama"?', style: const TextStyle(color: softText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: softText))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: crimsonRed, foregroundColor: Colors.white), onPressed: () => Navigator.pop(ctx, true), child: const Text('Padam')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => isProcessing = true);
      await http.post(Uri.parse('https://app.atom.gov.my/ukk_api/delete_menu.php'), body: {'id': id});
      widget.refreshParent();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _bukaAddEditDialog({int? editIndex}) async {
    var itemToEdit = editIndex != null ? widget.dynamicMenu[editIndex] : null;
    bool? result = await showDialog(context: context, barrierDismissible: false, builder: (_) => AddEditIconDialog(existingData: itemToEdit));
    if (result == true) { widget.refreshParent(); Navigator.pop(context); }
  }

  IconData getIconData(String iconCode) {
    switch (iconCode) {
      case 'image_outlined': return Icons.image_outlined;
      case 'video_library_outlined': return Icons.video_library_outlined;
      case 'music_note_outlined': return Icons.music_note_outlined;
      case 'photo_library_outlined': return Icons.photo_library_outlined;
      case 'slideshow_outlined': return Icons.slideshow_outlined;
      case 'bar_chart_outlined': return Icons.bar_chart_outlined;
      case 'pie_chart_outlined': return Icons.pie_chart_outline;
      case 'link_outlined': return Icons.link_outlined;
      case 'campaign_outlined': return Icons.campaign_outlined;
      case 'event_available_outlined': return Icons.event_available_outlined;
      case 'color_lens_outlined': return Icons.color_lens_outlined;
      case 'folder_open_rounded': return Icons.folder_open_rounded;
      case 'settings_outlined': return Icons.settings_outlined;
      case 'article_outlined': return Icons.article_outlined;
      case 'assignment_outlined': return Icons.assignment_outlined;
      case 'build_outlined': return Icons.build_outlined;
      case 'cloud_outlined': return Icons.cloud_outlined;
      case 'contacts_outlined': return Icons.contacts_outlined;
      case 'description_outlined': return Icons.description_outlined;
      case 'email_outlined': return Icons.email_outlined;
      case 'language_outlined': return Icons.language_outlined;
      case 'public_outlined': return Icons.public_outlined;
      case 'storage_outlined': return Icons.storage_outlined;
      case 'work_outline': return Icons.work_outline;
      case 'groups_outlined': return Icons.groups_outlined;
      case 'notifications_outlined': return Icons.notifications_outlined;
      case 'security_outlined': return Icons.security_outlined;
      default: return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double dialogWidth = isMobile ? MediaQuery.of(context).size.width * 0.95 : 650.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: goldAccent.withOpacity(0.3))),
        child: Column(
          children: [
            // Header seragam
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
              child: Row(children: [
                Icon(Icons.dashboard_customize, color: goldAccent, size: isMobile ? 18 : 22),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(child: Text('URUS IKON', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: isMobile ? 13 : 14))),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: darkCard, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)),
                  onPressed: () => _bukaAddEditDialog(),
                  icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                  label: Text('Tambah', style: TextStyle(fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: isMobile ? 4 : 8),
                IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
              ]),
            ),
            // Senarai ikon
            Flexible(
              child: isProcessing
                  ? const Center(child: CircularProgressIndicator(color: goldAccent))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: widget.dynamicMenu.length,
                      itemBuilder: (ctx, i) {
                        final item = widget.dynamicMenu[i];
                        final id = item['id'].toString();
                        final isVisible = item['is_visible'] == 1 || item['is_visible'] == true;
                        final isLocked = item['is_locked'] == 1 || item['is_locked'] == true;

                        if (isMobile) {
                          return _buildMobileTile(item, id, isVisible, isLocked, i);
                        } else {
                          return _buildDesktopTile(item, id, isVisible, isLocked, i);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Tile untuk DESKTOP (kekal seperti asal) ----------
  Widget _buildDesktopTile(dynamic item, String id, bool isVisible, bool isLocked, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFF44414D) : inputDark,
        borderRadius: BorderRadius.circular(12),
        border: isLocked ? Border.all(color: Colors.orange, width: 1.2) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
            backgroundColor: isVisible ? goldAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            child: Icon(getIconData(item['icon_code']), color: isVisible ? goldAccent : softText, size: 20)),
        title: Text(item['nama_menu'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(isLocked ? '🔒 Protected' : (isVisible ? 'Dipaparkan' : 'Disembunyikan'),
            style: TextStyle(fontSize: 12, color: isLocked ? Colors.orange : (isVisible ? goldAccent : softText))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(isLocked ? Icons.lock : Icons.lock_open, color: isLocked ? Colors.orange : softText, size: 20),
                onPressed: () => _toggleLock(index, id, isLocked)),
            Switch(
                value: isVisible,
                activeColor: goldAccent,
                onChanged: isLocked
                    ? null
                    : (v) {
                        setState(() => item['is_visible'] = v);
                        http.post(Uri.parse('https://app.atom.gov.my/ukk_api/update_menu.php'),
                            body: {'id': id, 'is_visible': v ? '1' : '0'});
                        widget.refreshParent();
                      }),
            IconButton(
                icon: const Icon(Icons.edit, color: goldAccent, size: 20),
                onPressed: isLocked ? null : () => _bukaAddEditDialog(editIndex: index)),
            IconButton(
                icon: Icon(Icons.delete_outline, color: isLocked ? Colors.grey : crimsonRed, size: 20),
                onPressed: isLocked ? null : () => _deleteIcon(id, item['nama_menu'])),
          ],
        ),
      ),
    );
  }

  // ---------- Tile untuk MOBILE (disusun semula supaya tidak serabut) ----------
  Widget _buildMobileTile(dynamic item, String id, bool isVisible, bool isLocked, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFF44414D) : inputDark,
        borderRadius: BorderRadius.circular(12),
        border: isLocked ? Border.all(color: Colors.orange, width: 1.2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: ikon + nama + status kecil
          Row(children: [
            CircleAvatar(
                backgroundColor: isVisible ? goldAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                radius: 16,
                child: Icon(getIconData(item['icon_code']), color: isVisible ? goldAccent : softText, size: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item['nama_menu'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: isLocked ? Colors.orange.withOpacity(0.2) : (isVisible ? goldAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(isLocked ? '🔒' : (isVisible ? 'ON' : 'OFF'),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLocked ? Colors.orange : (isVisible ? goldAccent : softText))),
            ),
          ]),
          const SizedBox(height: 6),
          // Baris bawah: butang kawalan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _miniButton(isLocked ? Icons.lock : Icons.lock_open, isLocked ? Colors.orange : softText,
                  () => _toggleLock(index, id, isLocked)),
              _miniButton(Icons.visibility, isVisible ? goldAccent : Colors.grey, () {
                setState(() => item['is_visible'] = !isVisible);
                http.post(Uri.parse('https://app.atom.gov.my/ukk_api/update_menu.php'),
                    body: {'id': id, 'is_visible': item['is_visible'] ? '1' : '0'});
                widget.refreshParent();
              }),
              if (!isLocked) ...[
                _miniButton(Icons.edit, goldAccent, () => _bukaAddEditDialog(editIndex: index)),
                _miniButton(Icons.delete_outline, crimsonRed, () => _deleteIcon(id, item['nama_menu'])),
              ] else ...[
                _miniButton(Icons.edit, Colors.grey, null),
                _miniButton(Icons.delete_outline, Colors.grey, null),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniButton(IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1), shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4))),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// DIALOG TAMBAH/EDIT IKON (TETAP SEPERTI ASAL)
class AddEditIconDialog extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  const AddEditIconDialog({super.key, this.existingData});
  @override State<AddEditIconDialog> createState() => _AddEditIconDialogState();
}
class _AddEditIconDialogState extends State<AddEditIconDialog> {
  final _label = TextEditingController();
  String _selectedIcon = 'folder_open_rounded';
  bool saving = false;

  final List<Map<String, dynamic>> iconChoices = [
    {'code': 'folder_open_rounded', 'icon': Icons.folder_open_rounded},
    {'code': 'image_outlined', 'icon': Icons.image_outlined},
    {'code': 'video_library_outlined', 'icon': Icons.video_library_outlined},
    {'code': 'music_note_outlined', 'icon': Icons.music_note_outlined},
    {'code': 'photo_library_outlined', 'icon': Icons.photo_library_outlined},
    {'code': 'slideshow_outlined', 'icon': Icons.slideshow_outlined},
    {'code': 'bar_chart_outlined', 'icon': Icons.bar_chart_outlined},
    {'code': 'pie_chart_outlined', 'icon': Icons.pie_chart_outline}, // DIBAIKI
    {'code': 'campaign_outlined', 'icon': Icons.campaign_outlined},
    {'code': 'event_available_outlined', 'icon': Icons.event_available_outlined},
    {'code': 'color_lens_outlined', 'icon': Icons.color_lens_outlined},
    {'code': 'settings_outlined', 'icon': Icons.settings_outlined},
    {'code': 'link_outlined', 'icon': Icons.link_outlined},
    {'code': 'article_outlined', 'icon': Icons.article_outlined},
    {'code': 'assignment_outlined', 'icon': Icons.assignment_outlined},
    {'code': 'build_outlined', 'icon': Icons.build_outlined},
    {'code': 'cloud_outlined', 'icon': Icons.cloud_outlined},
    {'code': 'contacts_outlined', 'icon': Icons.contacts_outlined},
    {'code': 'description_outlined', 'icon': Icons.description_outlined},
    {'code': 'email_outlined', 'icon': Icons.email_outlined},
    {'code': 'language_outlined', 'icon': Icons.language_outlined},
    {'code': 'public_outlined', 'icon': Icons.public_outlined},
    {'code': 'storage_outlined', 'icon': Icons.storage_outlined},
    {'code': 'work_outline', 'icon': Icons.work_outline},
    {'code': 'groups_outlined', 'icon': Icons.groups_outlined},
    {'code': 'notifications_outlined', 'icon': Icons.notifications_outlined},
    {'code': 'security_outlined', 'icon': Icons.security_outlined},
  ];

  @override void initState() {
    super.initState();
    if (widget.existingData != null) {
      _label.text = widget.existingData!['nama_menu'];
      _selectedIcon = widget.existingData!['icon_code'];
    }
  }
  Future<void> _simpan() async {
    if (_label.text.isEmpty) return;
    setState(() => saving = true);
    try {
      if (widget.existingData == null) {
        await http.post(Uri.parse('https://app.atom.gov.my/ukk_api/add_menu.php'),
            body: {'nama_menu': _label.text, 'icon_code': _selectedIcon, 'jenis_page': 'Dynamic', 'role_akses': 'user'});
      } else {
        await http.post(Uri.parse('https://app.atom.gov.my/ukk_api/update_menu.php'),
            body: {'id': widget.existingData!['id'].toString(), 'nama_menu': _label.text, 'icon_code': _selectedIcon});
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {}
    if (mounted) setState(() => saving = false);
  }
  @override Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 500;
    final double dialogWidth = isMobile ? MediaQuery.of(context).size.width * 0.9 : 440.0;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF2B2A33), borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.existingData == null ? 'TAMBAH IKON' : 'EDIT IKON',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12), const Text('Nama Menu', style: TextStyle(color: Color(0xFFB0ADB8))),
          TextField(controller: _label, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF3E3D47), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          const SizedBox(height: 12), const Text('Pilih Ikon', style: TextStyle(color: Color(0xFFB0ADB8))),
          Container(
            height: 140, margin: const EdgeInsets.only(top: 8),
            child: SingleChildScrollView(
              child: Wrap(spacing: 8, runSpacing: 8, children: iconChoices.map((m) {
                bool selected = _selectedIcon == m['code'];
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = m['code']),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected ? const Color(0xFFC9A96E) : const Color(0xFF3E3D47), shape: BoxShape.circle), child: Icon(m['icon'], color: selected ? Colors.black : Colors.white, size: 20)),
                );
              }).toList()),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Color(0xFFB0ADB8)))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A96E), foregroundColor: Colors.black), onPressed: saving ? null : _simpan, child: const Text('Simpan')),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// KOMPONEN HOVER IKON
// ═══════════════════════════════════════════════════
class HoverIconItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTapOverride;
  final double iconSize;
  final double fontSize;

  const HoverIconItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTapOverride,
    this.iconSize = 42,
    this.fontSize = 13,
  });

  @override State<HoverIconItem> createState() => _HoverIconItemState();
}
class _HoverIconItemState extends State<HoverIconItem> {
  bool hover = false;
  @override Widget build(BuildContext context) {
    final iconColor = hover ? Colors.white : Colors.black87;
    final textColor = hover ? Colors.white : Colors.black87;
    final hoverBg = Colors.black.withOpacity(0.15);

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTapOverride,
        child: AnimatedScale(
          scale: hover ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(widget.iconSize * 0.4),
                decoration: BoxDecoration(color: hover ? hoverBg : Colors.transparent, shape: BoxShape.circle),
                child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
              ),
              SizedBox(height: widget.iconSize * 0.15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.fontSize,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: hover ? 24 : 0,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// DIALOG PENGGUNA (USER MANAGER) & ADD/EDIT
// ═══════════════════════════════════════════════════
class UserManagerDialog extends StatefulWidget {
  const UserManagerDialog({super.key});
  @override State<UserManagerDialog> createState() => _UserManagerDialogState();
}
class _UserManagerDialogState extends State<UserManagerDialog> {
  List<dynamic> users = [];
  bool isLoading = true;
  @override void initState() { super.initState(); _fetchUsers(); }
  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('https://app.atom.gov.my/ukk_api/get_users.php'));
      if (res.statusCode == 200) setState(() { users = jsonDecode(res.body); isLoading = false; });
    } catch (_) { setState(() => isLoading = false); }
  }

  Future<void> _deleteUser(String id, String nama) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2B2A33), title: const Text('Padam Pengguna', style: TextStyle(color: Colors.white)), content: Text('Padam "$nama"?', style: const TextStyle(color: Color(0xFFB0ADB8))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Color(0xFFB0ADB8)))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), foregroundColor: Colors.white), onPressed: () => Navigator.pop(ctx, true), child: const Text('Padam')),
        ],
      ),
    );
    if (confirmed == true) {
      await http.post(Uri.parse('https://app.atom.gov.my/ukk_api/delete_user.php'), body: {'id': id});
      _fetchUsers();
    }
  }

  Future<void> _bukaAddEditUser({Map<String, dynamic>? existingUser}) async {
    bool? res = await showDialog(context: context, barrierDismissible: false, builder: (_) => AddEditUserDialog(existingUser: existingUser));
    if (res == true) _fetchUsers();
  }

  @override Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double dialogWidth = isMobile ? MediaQuery.of(context).size.width * 0.95 : 650.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(color: const Color(0xFF2B2A33), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFC9A96E).withOpacity(0.3))),
        child: Column(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFF3E3D47), borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
            child: Row(children: [
              Icon(Icons.manage_accounts, color: const Color(0xFFC9A96E), size: isMobile ? 18 : 22), SizedBox(width: isMobile ? 8 : 12),
              Expanded(child: Text('URUS PENGGUNA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: isMobile ? 13 : 14))),
              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A96E), foregroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8)), onPressed: () => _bukaAddEditUser(), icon: Icon(Icons.add, size: isMobile ? 14 : 16), label: Text('Tambah', style: TextStyle(fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.bold))),
              SizedBox(width: isMobile ? 4 : 8), IconButton(icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Flexible(
            child: isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A96E))) : ListView.builder(
              padding: const EdgeInsets.all(12), itemCount: users.length,
              itemBuilder: (ctx, i) {
                var user = users[i]; Color roleColor = user['role'] == 'super_admin' ? const Color(0xFFC9A96E) : (user['role'] == 'admin' ? Colors.blue : Colors.green);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: const Color(0xFF3E3D47), borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 4),
                    leading: CircleAvatar(backgroundColor: roleColor.withOpacity(0.2), child: Icon(Icons.person, color: roleColor, size: 20)),
                    title: Text(user['nama'], style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: isMobile ? 12 : 14)),
                    subtitle: Text('IC: ${user['ic_number']}  |  ${user['role'].toUpperCase()}', style: TextStyle(color: const Color(0xFFB0ADB8), fontSize: isMobile ? 10 : 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFFC9A96E), size: 20), onPressed: () => _bukaAddEditUser(existingUser: user)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFE50914), size: 20), onPressed: () => _deleteUser(user['id'].toString(), user['nama'])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// DIALOG TAMBAH/EDIT PENGGUNA (TETAP)
class AddEditUserDialog extends StatefulWidget {
  final Map<String, dynamic>? existingUser;
  const AddEditUserDialog({super.key, this.existingUser});
  @override State<AddEditUserDialog> createState() => _AddEditUserDialogState();
}
class _AddEditUserDialogState extends State<AddEditUserDialog> {
  final _nama = TextEditingController(), _ic = TextEditingController();
  String _role = 'user'; bool saving = false;
  @override void initState() {
    super.initState();
    if (widget.existingUser != null) { _nama.text = widget.existingUser!['nama']; _ic.text = widget.existingUser!['ic_number']; _role = widget.existingUser!['role']; }
  }
  Future<void> _save() async {
    if (_nama.text.isEmpty || _ic.text.isEmpty) return;
    setState(() => saving = true);
    try {
      if (widget.existingUser == null) {
        await http.post(Uri.parse('https://app.atom.gov.my/ukk_api/register.php'), headers: {"Content-Type": "application/json"}, body: jsonEncode({'nama': _nama.text, 'ic_number': _ic.text, 'role': _role}));
      } else {
        await http.post(Uri.parse('https://app.atom.gov.my/ukk_api/update_user.php'), body: {'id': widget.existingUser!['id'].toString(), 'nama': _nama.text, 'role': _role});
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {}
    if (mounted) setState(() => saving = false);
  }
  @override Widget build(BuildContext context) {
    bool edit = widget.existingUser != null;
    final bool isMobile = MediaQuery.of(context).size.width < 500;
    final double dialogWidth = isMobile ? MediaQuery.of(context).size.width * 0.9 : 400.0;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF2B2A33), borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(edit ? 'EDIT PENGGUNA' : 'DAFTAR PENGGUNA', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12), const Text('Nama', style: TextStyle(color: Color(0xFFB0ADB8))),
          TextField(controller: _nama, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF3E3D47), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          const SizedBox(height: 10), const Text('No. IC', style: TextStyle(color: Color(0xFFB0ADB8))),
          TextField(controller: _ic, enabled: !edit, style: TextStyle(color: edit ? Colors.grey : Colors.white), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF3E3D47), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          const SizedBox(height: 10), const Text('Pangkat', style: TextStyle(color: Color(0xFFB0ADB8))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: const Color(0xFF3E3D47), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _role, isExpanded: true, dropdownColor: const Color(0xFF2B2A33), style: const TextStyle(color: Colors.white),
              items: const [DropdownMenuItem(value: 'user', child: Text('User')), DropdownMenuItem(value: 'admin', child: Text('Admin')), DropdownMenuItem(value: 'super_admin', child: Text('Super Admin'))],
              onChanged: (v) => setState(() => _role = v!),
            )),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Color(0xFFB0ADB8)))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A96E), foregroundColor: Colors.black), onPressed: saving ? null : _save, child: const Text('Simpan')),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// KOMPONEN LOGOUT
// ═══════════════════════════════════════════════════
class PremiumLogoutButton extends StatelessWidget {
  final Color darkCard, goldAccent, white;
  final bool isMobile;
  const PremiumLogoutButton({
    super.key,
    required this.darkCard,
    required this.goldAccent,
    required this.white,
    this.isMobile = false,
  });
  @override Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: white.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: white, size: isMobile ? 18 : 16),
            if (!isMobile) ...[
              const SizedBox(width: 6),
              Text('LOG KELUAR', style: TextStyle(color: white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}