import 'package:chat_app/core/services/hive/hive_service.dart';
import 'package:chat_app/features/onboarding/presentation/pages/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await registerHiveAdapters();
  runApp(
    const ProviderScope(
      child: ChatApp(),
    ),
  );
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
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
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
