import 'package:flutter/material.dart';
import 'screens/main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const darkSlate = Color(0xFF1E293B);
    const offWhite = Color(0xFFF8FAFC);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: offWhite,
        useMaterial3: true,
      ),
      home: const MainScaffold(
        primaryColor: primaryColor,
        darkSlate: darkSlate,
      ),
    );
  }
}
