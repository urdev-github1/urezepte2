// lib/main.dart

import 'package:flutter/material.dart';
import 'package:urezepte2/screens/main_screen.dart'; // Korrekter Import für MainScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uRezepte2', // Du kannst hier den Namen deiner App anpassen
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Passend zu deiner App-Bar Farbe
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(), // Der MainScreen ist der Startbildschirm
      debugShowCheckedModeBanner: false, // Optional: Entfernt das Debug-Banner
    );
  }
}
