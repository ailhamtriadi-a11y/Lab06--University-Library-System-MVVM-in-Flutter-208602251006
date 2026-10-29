import 'package:flutter/material.dart';
import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryViewModel = LibraryViewModel();

    return MaterialApp(
      title: 'University Library',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00696E),
      ),
      home: LibraryScreen(viewModel: libraryViewModel),
    );
  }
}