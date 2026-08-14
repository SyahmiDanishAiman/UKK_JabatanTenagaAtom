<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");

$conn = new mysqli("localhost", "root", "", "ukk_atom_db");

$id = $_POST['id'] ?? '';

if (!empty($id)) {
    // Padam tepat dari kotak_kategori
    $stmt = $conn->prepare("DELETE FROM kotak_kategori WHERE id = ?");
    $stmt->bind_param("s", $id);
    if($stmt->execute()) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "ID tiada"]);
}
?>