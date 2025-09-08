// ==== lib\screens\main_screen.dart ====

import 'package:flutter/material.dart';
import 'about_screen.dart'; // Import des neuen AboutScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  /// Baut die Benutzeroberfläche des MainScreen auf.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezeptsuche'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          // Info-Button, der zum AboutScreen navigiert.
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            tooltip: 'Über die App',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [],
        ),
      ),
    );
  }
}
