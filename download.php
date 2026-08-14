<?php
// PASTIKAN BARIS PERTAMA ADALAH <?php, JANGAN ADA RUANG KOSONG (SPACE/ENTER) DI ATASNYA!

if (session_status() == PHP_SESSION_ACTIVE) {
    session_write_close();
}
set_time_limit(0);

$laluan_fail = isset($_GET['path']) ? $_GET['path'] : (isset($_GET['file']) ? $_GET['file'] : '');

if (!empty($laluan_fail)) {
    $laluan_fail = urldecode($laluan_fail);
    $file_sebenar = __DIR__ . '/' . ltrim($laluan_fail, '/');

    if (file_exists($file_sebenar)) {
        $saiz_fail = filesize($file_sebenar);
        
        // 💥 CEK KALAU FAIL 0KB (ROSAK)
        if ($saiz_fail == 0) {
            die("💥 RALAT: Fail ini rosak (0KB). Ia mungkin dimuat naik sebelum sistem dibaiki. Sila padam dan muat naik semula fail ini.");
        }

        // Bersihkan SEMUA buffer memori server (IIS selalu tercekik kat sini)
        while (ob_get_level()) {
            ob_end_clean();
        }

        $nama_fail = basename($file_sebenar);

        header('Access-Control-Allow-Origin: *');
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . addslashes($nama_fail) . '"');
        header('Content-Transfer-Encoding: binary');
        header('Expires: 0');
        header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
        header('Pragma: public');
        header('Content-Length: ' . $saiz_fail);

        $file = @fopen($file_sebenar, "rb");
        if ($file) {
            while (!feof($file)) {
                print(fread($file, 1024 * 8)); // Pam 8KB sikit-sikit
                flush(); // Tolak terus ke Chrome
                if (connection_status() != 0) {
                    break; 
                }
            }
            fclose($file);
        }
        exit;
    } else {
        http_response_code(404);
        die("💥 RALAT: Fail tidak dijumpai di pelayan -> " . $file_sebenar);
    }
} else {
    die("💥 RALAT: Tiada laluan fail diberikan.");
}
?>