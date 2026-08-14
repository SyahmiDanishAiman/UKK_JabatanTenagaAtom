<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$conn = new mysqli("127.0.0.1", "root", "", "ukk_atom_db");
$result = $conn->query("SELECT id, ic_number, nama, role FROM users ORDER BY role, nama");

$users = [];
while($row = $result->fetch_assoc()) {
    $users[] = $row;
}
echo json_encode($users);
$conn->close();
?>