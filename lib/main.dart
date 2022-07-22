import 'package:csv_fixer/import_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Millenium BCP CSV fix',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImportPage(),
    );
  }
}
