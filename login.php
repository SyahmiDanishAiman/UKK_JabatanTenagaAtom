<?php
// BUKA PINTU UNTUK SEMUA (CORS)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json');

// KALAU FLUTTER HANTAR 'OPTIONS', KITA BAGI JAWAPAN 'OK' (200) DAN BERHENTI DI SINI
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = "127.0.0.1"; 
$user = "root"; 
$pass = ""; 
$db = "ukk_atom_db";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Gagal sambung ke database"]);
    exit;
}

// BACA DATA JSON DARI FLUTTER
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Kalau JSON tak jadi, cuba POST biasa
$ic_number = isset($data['ic_number']) ? $data['ic_number'] : (isset($_POST['ic_number']) ? $_POST['ic_number'] : '');
$ic_number = trim($ic_number);

if(empty($ic_number)) {
    echo json_encode(["status" => "error", "message" => "Sila masukkan No. Kad Pengenalan"]);
    exit;
}

$stmt = $conn->prepare("SELECT nama, role FROM users WHERE ic_number = ?");
$stmt->bind_param("s", $ic_number);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        "status" => "success",
        "nama" => $row['nama'],
        "role" => $row['role']
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Akses Ditolak! No. IC tidak berdaftar."]);
}

$stmt->close();
$conn->close();
?>