import 'package:chat_app/features/setting/presentation/view_model/setting_view_model.dart';
import 'package:chat_app/features/setting/presentation/state/setting_state.dart';
import 'package:chat_app/features/onboarding/presentation/pages/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final avatarRadius = isWide ? 65.0 : 50.0;
    final horizontalPad = isWide ? screenWidth * 0.1 : 16.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad, vertical: 16),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: isWide ? 34 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isWide ? 40 : 32),


                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: const Color(0xFF2C2C2C),
                                backgroundImage: state.profileImage != null &&
                                        state.profileImage!.isNotEmpty
                                    ? NetworkImage(state.profileImage!)
                                    : null,
                                child: (state.profileImage == null ||
                                        state.profileImage!.isEmpty)
                                    ? Text(
                                        state.username.isNotEmpty
                                            ? state.username[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: isWide ? 40 : 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.username,
                                style: TextStyle(
                                  fontSize: isWide ? 26 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.email,
                                style: TextStyle(
                                  fontSize: isWide ? 15 : 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isWide ? 48 : 40),

                        _buildSettingsTile(
                          icon: Icons.person_outline,
                          title: "Update Profile",
                          onTap: () => _showUpdateProfileDialog(
                              context, ref, state.username, state.profileImage),
                        ),
                        _buildSettingsTile(
                          icon: Icons.lock_outline,
                          title: "Update Password",
                          onTap: () => _showUpdatePasswordDialog(context, ref),
                        ),
                        _buildSettingsTile(
                          icon: Icons.location_on_outlined,
                          title: "Copy Current Location",
                          onTap: () => _copyLocation(context),
                        ),

                        const Spacer(),

                        if (state.status == SettingStatus.loading)
                          const Center(child: CircularProgressIndicator())
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.redAccent.withOpacity(0.1),
                                surfaceTintColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: Colors.redAccent, width: 1),
                                ),
                              ),
                              onPressed: () {
                                ref
                                    .read(settingViewModelProvider.notifier)
                                    .logout();
                              },
                              label: Text(
                                'Logout',
                                style: TextStyle(
                                    fontSize: isWide ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied')));
      return;
    } 

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fetching location...')));

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    final String locationText = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
    
    await Clipboard.setData(ClipboardData(text: locationText));
    
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location copied: $locationText')));
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context, WidgetRef ref, String currentUsername, String? currentProfileImage) {
    final controller = TextEditingController(text: currentUsername);
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: selectedImage != null 
                            ? FileImage(selectedImage!) 
                            : (currentProfileImage != null && currentProfileImage!.isNotEmpty 
                                ? NetworkImage(currentProfileImage!) as ImageProvider
                                : null),
                        child: selectedImage == null && (currentProfileImage == null || currentProfileImage!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white, size: 40)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: Colors.white60),
                    hintText: 'New Username',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    ref.read(settingViewModelProvider.notifier).updateProfile(
                      controller.text,
                      profileImage: selectedImage,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPasswordField(currentController, 'Current Password'),
            const SizedBox(height: 12),
            _buildPasswordField(newController, 'New Password'),
            const SizedBox(height: 12),
            _buildPasswordField(confirmController, 'Confirm Password'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}
