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
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  "About",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
