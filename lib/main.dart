import 'package:chat_app/screens/on_boarding_screen/first_screen.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: FirstScreen(),
    );
  }
}
