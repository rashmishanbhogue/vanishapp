// app.dart

import 'package:flutter/material.dart';

class VanishApp extends StatelessWidget {
  const VanishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vanish',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFAF8F5),
          brightness: Brightness.light,
        ),
      ),
      home: const Scaffold(body: Center(child: Text('vanish'))),
    );
  }
}
