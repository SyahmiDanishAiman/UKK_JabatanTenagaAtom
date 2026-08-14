<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$host = "127.0.0.1";
$user = "root";
$pass = "";
$db = "ukk_atom_db";

// Sambung ke database
$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Tarik semua data menu ikut susunan
$sql = "SELECT * FROM menu_dashboard ORDER BY susunan ASC, id ASC";
$result = $conn->query($sql);

$menus = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // --- FIX UNTUK FLUTTER ---
        
        // 1. Tukar status Paparan (Visible)
        $row['is_visible'] = ($row['is_visible'] == 1);
        
        // 2. Tukar status Kunci (Locked) - Ini yang baru
        // Kita pastikan kalau NULL atau 0, dia jadi false. Kalau 1 jadi true.
        $row['is_locked'] = (isset($row['is_locked']) && $row['is_locked'] == 1);
        
        // 3. Pastikan ID dihantar sebagai Integer jika perlu
        $row['id'] = (int)$row['id'];

        $menus[] = $row;
    }
}

// Pulangkan dalam bentuk JSON
echo json_encode($menus);
$conn->close();
?>