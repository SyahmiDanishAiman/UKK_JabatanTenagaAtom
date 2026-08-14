<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");

if (isset($_GET['path'])) {
    $path_kotor = urldecode($_GET['path']);
    $nama_fail_sahaja = basename(parse_url($path_kotor, PHP_URL_PATH));

    $folder_utama = __DIR__ . '/uploads';
    $laluan_sebenar = false;

    if (is_dir($folder_utama)) {
        $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($folder_utama));
        foreach ($iterator as $file) {
            if ($file->isFile() && $file->getFilename() === $nama_fail_sahaja) {
                $laluan_sebenar = $file->getPathname();
                break;
            }
        }
    }

    if ($laluan_sebenar && file_exists($laluan_sebenar)) {
        $mime = mime_content_type($laluan_sebenar);
        header("Content-Type: $mime");
        readfile($laluan_sebenar);
        exit;
    }

    http_response_code(404);
    echo "PENCARIAN FORENSIK GAGAL:<br>";
    echo "Sistem cuba mencari fail bernama: <b>" . $nama_fail_sahaja . "</b><br>";
    echo "Tetapi fail ini tiada secara fizikal dalam mana-mana folder uploads.";
    exit;
}
?>