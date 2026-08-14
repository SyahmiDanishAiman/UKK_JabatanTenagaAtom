<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "ukk_atom_db");

$parent_menu = $_GET['parent_menu'] ?? $_GET['parent'] ?? '';

// Tarik data tepat dari kotak_kategori
$stmt = $conn->prepare("SELECT * FROM kotak_kategori WHERE parent_menu = ? ORDER BY id ASC");
$stmt->bind_param("s", $parent_menu);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>