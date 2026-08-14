<?php
// BUKA PINTU UNTUK CORS (Macam login.php tadi)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = "127.0.0.1"; $user = "root"; $pass = ""; $db = "ukk_atom_db";
$conn = new mysqli($host, $user, $pass, $db);

// Baca data JSON dari Flutter
$data = json_decode(file_get_contents("php://input"), true);
$nama = trim($data['nama'] ?? '');
$ic_number = trim($data['ic_number'] ?? '');
$role = trim($data['role'] ?? 'user'); // Default user biasa

// Semak kalau ada yang kosong
if(empty($nama) || empty($ic_number)) {
    echo json_encode(["status" => "error", "message" => "Sila isikan semua maklumat!"]);
    exit;
}

// SECURITY: Semak kalau IC ni dah pernah didaftarkan
$check = $conn->prepare("SELECT id FROM users WHERE ic_number = ?");
$check->bind_param("s", $ic_number);
$check->execute();
if($check->get_result()->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Gagal! No. IC ini telah pun didaftarkan."]);
    exit;
}
$check->close();

// Masukkan data staf baru ke dalam database
$stmt = $conn->prepare("INSERT INTO users (ic_number, nama, role) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $ic_number, $nama, $role);

if($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Staf '$nama' berjaya didaftarkan sebagai $role!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Ralat sistem pangkalan data."]);
}

$stmt->close();
$conn->close();
?>