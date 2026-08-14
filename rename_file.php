<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (isset($data->old_path) && isset($data->new_name)) {
    $oldPath = $data->old_path;
    $newNameRaw = trim($data->new_name);

    if (file_exists($oldPath)) {
        $pathInfo = pathinfo($oldPath);
        $dir = $pathInfo['dirname'] . '/';
        $ext = isset($pathInfo['extension']) ? '.' . $pathInfo['extension'] : '';
        $oldFilename = $pathInfo['basename'];

        // Ambil ID masa (timestamp) lama supaya susunan fail tak lari
        $timestampPrefix = '';
        if (preg_match('/^(\d{10}_)/', $oldFilename, $matches)) {
            $timestampPrefix = $matches[1];
        } else {
            $timestampPrefix = time() . '_'; 
        }

        // Bersihkan nama baru dari simbol pelik
        $cleanName = preg_replace('/[^A-Za-z0-9\- ]/', '', $newNameRaw);
        $cleanName = str_replace(' ', '_', $cleanName);

        // Cantumkan laluan baru
        $newPath = $dir . $timestampPrefix . $cleanName . $ext;

        if (rename($oldPath, $newPath)) {
            echo json_encode(["status" => "success", "message" => "Berjaya ditukar"]);
        } else {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Gagal tukar nama"]);
        }
    } else {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Fail tidak wujud"]);
    }
} else {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
}
?>