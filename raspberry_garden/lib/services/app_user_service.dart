import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppUserService {
  static const String _key = 'app_user_id';

  static Future<String> getOrCreateAppUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    if (saved != null && saved.isNotEmpty) {
      return saved;
    }

    final id = const Uuid().v4();
    await prefs.setString(_key, id);
    return id;
  }
}
