import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'email';
  static const String _keyUsername = 'username';
  static const String _keyProfilePicture = 'profile_picture';
  static const String _keyfullName = 'full_name';
  static const String _keyphoneNumber = 'phone_number';
  static const String _keyRole = 'role';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveUserSession({
    required String userId,
    String? email,
    String? username,
    String? profilePicture,
    String? fullName,
    String? phoneNumber,
    String? role,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);

    if (email != null) {
      await _prefs.setString(_keyEmail, email);
    }

    if (username != null) {
      await _prefs.setString(_keyUsername, username);
    }

    if (profilePicture != null) {
      await _prefs.setString(_keyProfilePicture, profilePicture);
    }

    if (fullName != null) {
      await _prefs.setString(_keyfullName, fullName);
    }

    if (phoneNumber != null) {
      await _prefs.setString(_keyphoneNumber, phoneNumber);
    }

    if (role != null) {
      await _prefs.setString(_keyRole, role);
    }
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getCurrentUserEmail() {
    return _prefs.getString(_keyEmail);
  }

  String? getCurrentUsername() {
    return _prefs.getString(_keyUsername);
  }

  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyProfilePicture);
  }

  String? getCurrentUserFullName() {
    return _prefs.getString(_keyfullName);
  }

  String? getCurrentUserPhoneNumber() {
    return _prefs.getString(_keyphoneNumber);
  }

  String? getCurrentUserRole() {
    return _prefs.getString(_keyRole);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyProfilePicture);
    await _prefs.remove(_keyfullName);
    await _prefs.remove(_keyphoneNumber);
    await _prefs.remove(_keyRole);
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
}