<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$host = "127.0.0.1"; 
$user = "root"; 
$pass = ""; 
$db = "ukk_atom_db";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed"]));
}

// Ambil data dari POST
$id         = $_POST['id'] ?? '';
$nama_menu  = $_POST['nama_menu'] ?? null;
$icon_code  = $_POST['icon_code'] ?? null;
$role_akses = $_POST['role_akses'] ?? null;
$is_visible = $_POST['is_visible'] ?? null;
$is_locked  = $_POST['is_locked'] ?? null; // Parameter baru untuk simpan status kunci

if(empty($id)) {
    echo json_encode(["status" => "error", "message" => "ID menu diperlukan"]);
    exit;
}

/**
 * LOGIK DINAMIK:
 * Kita bina query berdasarkan data yang dihantar sahaja. 
 * Ini membolehkan Flutter hantar 'is_locked' sahaja tanpa perlu hantar 'nama_menu' setiap kali.
 */
$updates = [];
$types = "";
$params = [];

if ($nama_menu !== null) { $updates[] = "nama_menu = ?"; $types .= "s"; $params[] = $nama_menu; }
if ($icon_code !== null) { $updates[] = "icon_code = ?"; $types .= "s"; $params[] = $icon_code; }
if ($role_akses !== null) { $updates[] = "role_akses = ?"; $types .= "s"; $params[] = $role_akses; }
if ($is_visible !== null) { $updates[] = "is_visible = ?"; $types .= "i"; $params[] = (int)$is_visible; }
if ($is_locked !== null)  { $updates[] = "is_locked = ?"; $types .= "i"; $params[] = (int)$is_locked; }

if (empty($updates)) {
    echo json_encode(["status" => "error", "message" => "Tiada data untuk dikemaskini"]);
    exit;
}

$sql = "UPDATE menu_dashboard SET " . implode(", ", $updates) . " WHERE id = ?";
$types .= "i";
$params[] = (int)$id;

$stmt = $conn->prepare($sql);
$stmt->bind_param($types, ...$params);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Data berjaya dikemaskini"]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>