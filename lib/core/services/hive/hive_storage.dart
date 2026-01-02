import 'package:chat_app/core/services/hive/hive_service.dart';
import 'package:chat_app/features/auth/data/models/auth_hive_model.dart';

class HiveStorage {
  static const String _auth = "auth";

  static Future<void> saveUser(AuthHiveModel user) async {
    try {
      await authStorage.put(_auth, user);
    } catch (error) {
      // ignore: avoid_print
      print("update error: $error");
    }
  }

  static AuthHiveModel? getUser() {
    return authStorage.get(_auth);
  }

  static Future<void> clearUser() async {
    await authStorage.delete(_auth);
  }

  static Future<void> updateUser(AuthHiveModel user) async {
    try {
      await authStorage.put(_auth, user);
    } catch (error) {
      // ignore: avoid_print
      print("hivebooking $error");
    }
  }
}
