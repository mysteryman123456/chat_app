import 'package:chat_app/screens/on_boarding_screen/first_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Manrope"),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: "Manrope",
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),

      home: const FirstScreen(),
    );
  }
}
