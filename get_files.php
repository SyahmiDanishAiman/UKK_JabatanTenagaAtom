<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$kategori = $_GET['kategori'] ?? '';

// Bersihkan nama kategori supaya sama dengan folder masa upload
$kategori_bersih = preg_replace('/[^A-Za-z0-9\-\s]/', '', $kategori);

// Lokasi folder fail tu disimpan
$target_dir = "uploads/" . $kategori_bersih . "/";

// URL untuk Flutter paparkan gambar (Guna port 9999)
$base_url = "http://127.0.0.1:9999/uploads/" . rawurlencode($kategori_bersih) . "/";

$data = [];

// Semak kalau folder tu wujud dan baca isinya
if (is_dir($target_dir)) {
    // Baca semua fail dalam folder tu
    $files = array_diff(scandir($target_dir), array('.', '..'));
    
    foreach ($files as $file) {
        $data[] = [
            "name" => $file,
            "path" => $target_dir . $file, // Laluan fizikal untuk Delete/Download
            "url" => $base_url . rawurlencode($file) // URL untuk UI tengok gambar
        ];
    }
}

// Hantar balik senarai fail ke Flutter
echo json_encode(array_values($data));
?>