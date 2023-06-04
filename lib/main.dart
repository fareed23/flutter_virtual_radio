import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Virtual Assistant",
      theme: ThemeData(
        // appBarTheme: const AppBarTheme(),
        // textTheme: const TextTheme(),
        useMaterial3: false,
        fontFamily: "Poppins",
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
