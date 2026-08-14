<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

$conn = new mysqli("127.0.0.1", "root", "", "ukk_atom_db");
$id = $_POST['id'] ?? '';

if ($conn->query("DELETE FROM users WHERE id = '$id'")) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal memadam pengguna."]);
}
$conn->close();
?>