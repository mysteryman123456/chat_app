import 'package:chat_app/features/setting/presentation/view_model/setting_view_model.dart';
import 'package:chat_app/features/setting/presentation/state/setting_state.dart';
import 'package:chat_app/features/onboarding/presentation/pages/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SettingState>(settingViewModelProvider, (previous, next) {
      if (next.status == SettingStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      } else if (next.status == SettingStatus.success) {
        if (next.isLoggedOut) {
          Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (context) => const FirstScreen()),
             (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully updated!')),
          );
        }
      }
    });

    final state = ref.watch(settingViewModelProvider);

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

              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  "Update Profile",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () {
                  _showUpdateProfileDialog(context, ref);
                },
              ),

              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text(
                  "Update Password",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () {
                  _showUpdatePasswordDialog(context, ref);
                },
              ),

              const Spacer(),
              
              if (state.status == SettingStatus.loading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ref.read(settingViewModelProvider.notifier).logout();
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Update Profile', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                    child: selectedImage == null
                        ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'New Username',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    ref.read(settingViewModelProvider.notifier).updateProfile(
                      controller.text,
                      profileImage: selectedImage,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Update Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Current Password',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'New Password',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              if (currentController.text.isNotEmpty && newController.text.isNotEmpty && confirmController.text.isNotEmpty) {
                ref.read(settingViewModelProvider.notifier).updatePassword(
                  currentController.text,
                  newController.text,
                  confirmController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}
