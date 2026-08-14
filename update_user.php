<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

$conn = new mysqli("127.0.0.1", "root", "", "ukk_atom_db");

$id = $_POST['id'] ?? '';
$nama = $_POST['nama'] ?? '';
$role = $_POST['role'] ?? '';

$stmt = $conn->prepare("UPDATE users SET nama=?, role=? WHERE id=?");
$stmt->bind_param("ssi", $nama, $role, $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal mengemaskini data pengguna."]);
}
$stmt->close(); $conn->close();
?>