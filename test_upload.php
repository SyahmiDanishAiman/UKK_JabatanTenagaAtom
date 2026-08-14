<!DOCTYPE html>
<html>
<head><title>Ujian Upload X-Ray</title></head>
<body style="padding: 20px; font-family: Arial;">
    <h2>Ujian X-Ray Upload IIS</h2>
    <form method="POST" enctype="multipart/form-data">
        <input type="file" name="file" required>
        <button type="submit" name="submit">Upload Sekarang</button>
    </form>
    <hr>
    <?php
    if (isset($_POST['submit'])) {
        echo "<h3>Keputusan:</h3>";
        
        $file = $_FILES['file'];
        
        // 1. Cek Ralat Asas PHP
        if ($file['error'] !== UPLOAD_ERR_OK) {
            die("<b style='color:red;'>💥 GAGAL! Kod Ralat PHP: " . $file['error'] . " (Kalau kod 1 atau 2, maknanya saiz gambar terlalu besar. Kalau kod 6, folder Temp Windows tak wujud/rosak).</b>");
        }

        // 2. Set laluan (Kita test masuk folder Logo_UKK terus)
        $target_dir = __DIR__ . "/uploads/Logo_UKK/";
        $target_file = $target_dir . basename($file["name"]);
        
        // 3. Uji Kebenaran Menulis (Folder Permission)
        if (!is_writable($target_dir)) {
            die("<b style='color:red;'>💥 GAGAL! IIS beritahu folder Logo_UKK TIDAK BOLEH DITULIS (No Write Permission). Mesti kena cek balik Security IIS_IUSRS kat Windows!</b>");
        }

        // 4. Cuba Pindahkan Fail
        if (move_uploaded_file($file["tmp_name"], $target_file)) {
            echo "<b style='color:green;'>✅ BERJAYA! Fail selamat mendarat dalam server. Isu sebelum ni confirm salah Flutter / salah nama kategori.</b>";
        } else {
            echo "<b style='color:red;'>💥 GAGAL! Gagal 'move_uploaded_file'. PHP boleh baca, folder dah Full Control, tapi Windows tetap halang laluan terakhir ni.</b>";
        }
    }
    ?>
</body>
</html>