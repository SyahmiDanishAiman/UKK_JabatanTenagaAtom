<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$host = "127.0.0.1"; $user = "root"; $pass = ""; $db = "ukk_atom_db";
$conn = new mysqli($host, $user, $pass, $db);

$nama_menu = $_POST['nama_menu'] ?? '';
$jenis_page = $_POST['jenis_page'] ?? 'Dynamic'; 
$icon_code = $_POST['icon_code'] ?? 'folder';
$role_akses = $_POST['role_akses'] ?? 'user';

if(empty($nama_menu)) {
    echo json_encode(["status" => "error", "message" => "Nama menu kosong"]);
    exit;
}

// Cari nombor susunan yang terakhir supaya menu baru duduk bawah sekali
$res = $conn->query("SELECT MAX(susunan) as max_s FROM menu_dashboard");
$row = $res->fetch_assoc();
$next_susunan = intval($row['max_s']) + 1;

// Masukkan data baru (is_visible default 1/Tunjuk)
$stmt = $conn->prepare("INSERT INTO menu_dashboard (nama_menu, jenis_page, icon_code, role_akses, is_visible, susunan) VALUES (?, ?, ?, ?, 1, ?)");
$stmt->bind_param("ssssi", $nama_menu, $jenis_page, $icon_code, $role_akses, $next_susunan);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "id" => $stmt->insert_id]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}
$stmt->close();
$conn->close();
?>