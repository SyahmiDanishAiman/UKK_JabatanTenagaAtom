<?php
// Kebenaran (CORS) supaya Flutter Web boleh hantar data
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$kategori = isset($_POST['kategori']) ? $_POST['kategori'] : 'Lain-lain';
$kategori = str_replace(array('%20', '%2520'), ' ', $kategori);
$target_dir = "uploads/" . $kategori . "/";

if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
}

if (isset($_FILES["file"])) {
    
    // 💥 MESIN X-RAY: KITA CHECK KALAU FAIL ROSAK SEBELUM SIMPAN 💥
    if ($_FILES['file']['error'] !== UPLOAD_ERR_OK) {
        $error_messages = array(
            UPLOAD_ERR_INI_SIZE   => 'Saiz fail melebihi had upload_max_filesize dalam php.ini.',
            UPLOAD_ERR_FORM_SIZE  => 'Saiz fail melebihi had MAX_FILE_SIZE dalam form HTML.',
            UPLOAD_ERR_PARTIAL    => 'Fail hanya berjaya dimuat naik sebahagian sahaja (terputus).',
            UPLOAD_ERR_NO_FILE    => 'Tiada fail yang dijumpai untuk dimuat naik.',
            UPLOAD_ERR_NO_TMP_DIR => 'Folder sementara (Temp) di Windows Server tiada atau tidak wujud.',
            UPLOAD_ERR_CANT_WRITE => 'Windows IIS sekat! Gagal menulis fail ke cakera (Check Write Permission).',
            UPLOAD_ERR_EXTENSION  => 'Proses muat naik dihentikan oleh extension PHP.'
        );
        
        $error_code = $_FILES['file']['error'];
        $punca = isset($error_messages[$error_code]) ? $error_messages[$error_code] : 'Ralat yang tidak diketahui.';
        
        echo json_encode([
            "status" => "error",
            "message" => "Sistem Sekat: " . $punca
        ]);
        exit(); // Berhenti di sini
    }

    $asalName = basename($_FILES["file"]["name"]);
    $ext = pathinfo($asalName, PATHINFO_EXTENSION);
    
    if (isset($_POST['custom_name']) && !empty(trim($_POST['custom_name']))) {
        $safeName = preg_replace('/[^\w\s\-]/', '', $_POST['custom_name']);
        $fileName = time() . "_" . trim($safeName) . ($ext ? "." . $ext : "");
    } else {
        $fileName = time() . "_" . $asalName;
    }
    
    $target_file = $target_dir . $fileName;
    
    // Simpan fail ke dalam folder
    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
        echo json_encode([
            "status" => "success",
            "message" => "Fail berjaya dimuat naik ke folder $kategori!",
            "path" => $target_file
        ]);
    } else {
        // Kalau sampai sini, maksudnya Permission Windows masih sangkut kat folder
        echo json_encode([
            "status" => "error",
            "message" => "PHP dah cuba simpan, tapi Windows IIS halang (move_uploaded_file gagal). Sila check Permission Full Control folder $kategori."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Tiada fail diterima oleh server. Pastikan nama field adalah 'file'."
    ]);
}
?>