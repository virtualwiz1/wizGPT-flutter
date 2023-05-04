import 'package:flutter/material.dart';
import 'package:wizgpt/pallete.dart';
import 'package:wizgpt/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WizGPT',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        backgroundColor: Pallete.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.backgroundColor,
        ),
      ),
      home: const HomePage(),
    );
  }
}
