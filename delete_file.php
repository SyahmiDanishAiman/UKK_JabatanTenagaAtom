<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Terima data JSON dari Flutter
$data = json_decode(file_get_contents("php://input"));

if (isset($data->path)) {
    $filePath = $data->path;
    
    // Pastikan fail betul-betul ada dalam folder uploads sebelum dipadam
    if (strpos($filePath, 'uploads/') === 0 && file_exists($filePath)) {
        if (unlink($filePath)) {
            echo json_encode(["status" => "success", "message" => "Fail berjaya dipadam"]);
        } else {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Gagal padam fail dari server"]);
        }
    } else {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Fail tidak dijumpai"]);
    }
} else {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Laluan (path) fail tidak sah"]);
}
?>