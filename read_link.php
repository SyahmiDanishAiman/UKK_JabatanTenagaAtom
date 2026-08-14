<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: text/plain');

// Ambil path fail yang dihantar dari Flutter
$file_path = $_GET['path'] ?? '';

if (empty($file_path)) {
    http_response_code(400);
    echo "Ralat: Laluan fail tidak disertakan.";
    exit;
}

// Pastikan fail wujud sebelum dibaca
if (file_exists($file_path)) {
    // Baca keseluruhan isi fail
    $content = file_get_contents($file_path);
    // Bersihkan sebarang ruang kosong atau newline
    echo trim($content);
} else {
    http_response_code(404);
    echo "Ralat: Fail pautan tidak dijumpai.";
}
?>