import 'package:chat_app/core/services/hive/hive_storage.dart';

import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Example setting option
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  "Account",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () {
                  // Handle navigation
                },
              ),

              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text(
                  "Privacy",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  "About",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  "Logout",
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () async {
                  await HiveStorage.clearUser();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => route.isCurrent,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
