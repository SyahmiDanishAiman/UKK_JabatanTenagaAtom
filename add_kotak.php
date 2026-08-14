<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");

$conn = new mysqli("localhost", "root", "", "ukk_atom_db"); 

if ($conn->connect_error) { 
    die(json_encode(["status" => "error", "message" => "DB Connection Failed"])); 
}

// Tangkap data yang Flutter hantar
$nama_kotak = $_POST['nama_kotak'] ?? $_POST['nama'] ?? '';
$parent_menu = $_POST['parent_menu'] ?? $_POST['parent'] ?? '';
$icon_code = $_POST['icon_code'] ?? 'folder';

if (!empty($nama_kotak) && !empty($parent_menu)) {
    // Masukkan tepat ke dalam table kotak_kategori
    $stmt = $conn->prepare("INSERT INTO kotak_kategori (nama_kotak, parent_menu, icon_code) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $nama_kotak, $parent_menu, $icon_code);
    
    if ($stmt->execute()) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Data kosong"]);
}
?>