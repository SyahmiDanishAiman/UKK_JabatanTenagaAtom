<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$host = "127.0.0.1"; $user = "root"; $pass = ""; $db = "ukk_atom_db";
$conn = new mysqli($host, $user, $pass, $db);

$id = $_POST['id'] ?? '';

if(empty($id)) {
    echo json_encode(["status" => "error", "message" => "ID menu tiada"]);
    exit;
}

$stmt = $conn->prepare("DELETE FROM menu_dashboard WHERE id=?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}
$stmt->close();
$conn->close();
?>