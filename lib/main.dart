import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// PENTING: Kita panggil fail login_page yang baru dibuat tadi
import 'login_page.dart'; // (Kalau awak letak dalam folder pages, tukar jadi 'pages/login_page.dart')

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kekalkan setting Firebase asal awak
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCcoelHAXxMysKrsTadWiLq28d8MMgATqE",
      authDomain: "ukk-atom-2026.firebaseapp.com",
      projectId: "ukk-atom-2026",
      storageBucket: "ukk-atom-2026.firebasestorage.app",
      messagingSenderId: "604874141391",
      appId: "1:604874141391:web:e29d75476de96b4e2391ba",
    ),
  );

  runApp(const UKKApp());
}

class UKKApp extends StatelessWidget {
  const UKKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UKK ATOM Malaysia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      // --- TUKAR: Mula-mula buka app, terus tunjuk Skrin Login ---
      home: const LoginPage(), 
    );
  }
}