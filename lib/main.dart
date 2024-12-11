import 'package:flutter/material.dart';
import 'package:mycal/mycalculator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mycalculator',
      theme: ThemeData.light(),
      home: const MycalculatorScreen(),
    );
  }
}
