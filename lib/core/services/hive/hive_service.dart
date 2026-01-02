import 'package:chat_app/features/auth/data/models/auth_hive_model.dart';
import 'package:hive/hive.dart';

Future<void> registerHiveAdapters() async {
  try {
    Hive.registerAdapter(AuthHiveModelAdapter());
    if (!Hive.isBoxOpen('auth_storage')) {
      authStorage = await Hive.openBox<AuthHiveModel>('auth_storage');
    } else {
      authStorage = Hive.box<AuthHiveModel>('auth_storage');
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
}

late Box<AuthHiveModel> authStorage;
