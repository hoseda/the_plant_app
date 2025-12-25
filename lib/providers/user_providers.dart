import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/data/local/database.dart';
import 'package:the_plant_app/providers/database_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _currentUserEmailKey = 'currentUserEmail';
const _avatarPathKey = 'avatarPath';

/// Provider برای گرفتن کاربر فعلی از Drift بر اساس ایمیل ذخیره‌شده
final currentUserProvider = FutureProvider<User?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString(_currentUserEmailKey);
  if (email == null || email.isEmpty) return null;
  final db = ref.watch(appDatabaseProvider);
  return db.getUserByEmail(email);
});

/// ذخیره ایمیل کاربر وارد شده
Future<void> saveCurrentUserEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_currentUserEmailKey, email);
}

/// پاک کردن ایمیل کاربر (هنگام خروج)
Future<void> clearCurrentUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_currentUserEmailKey);
}

Future<String?> getCurrentUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_currentUserEmailKey);
}

/// کنترلر ساده برای مسیر تصویر پروفایل که در SharedPreferences ذخیره می‌شود.
class AvatarController extends StateNotifier<String?> {
  AvatarController() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_avatarPathKey);
  }

  Future<void> setAvatar(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_avatarPathKey);
      state = null;
    } else {
      await prefs.setString(_avatarPathKey, path);
      state = path;
    }
  }
}

/// Provider وضعیت تصویر پروفایل
final avatarPathProvider = StateNotifierProvider<AvatarController, String?>((
  ref,
) {
  return AvatarController();
});
