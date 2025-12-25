import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:the_plant_app/data/local/database.dart';
import 'package:the_plant_app/providers/database_providers.dart';
import 'package:the_plant_app/providers/user_providers.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.user,
    required this.isLoading,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  static const AuthState initial = AuthState(
    user: null,
    isLoading: false,
    errorMessage: null,
  );
}

class AuthController extends StateNotifier<AuthState> {
  final AppDatabase _db;

  AuthController(this._db) : super(AuthState.initial);

  /// اعتبارسنجی ایمیل
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'ایمیل الزامی است';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'فرمت ایمیل نامعتبر است';
    }
    return null;
  }

  /// اعتبارسنجی رمز عبور
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'رمز عبور الزامی است';
    }
    if (password.length < 6) {
      return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
    }
    return null;
  }

  /// ثبت‌نام کاربر جدید
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final emailError = validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(isLoading: false, errorMessage: emailError);
      return false;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      state = state.copyWith(isLoading: false, errorMessage: passwordError);
      return false;
    }

    try {
      final existing = await _db.getUserByEmail(email);
      if (existing != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'کاربری با این ایمیل وجود دارد',
        );
        return false;
      }

      await _db.insertUser(
        UsersCompanion(
          name: Value(name),
          email: Value(email),
          password: Value(password),
        ),
      );

      final user = await _db.getUserByEmail(email);
      state = state.copyWith(user: user, isLoading: false);
      await saveCurrentUserEmail(email);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در ثبت نام: $e',
      );
      return false;
    }
  }

  /// ورود کاربر موجود
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final emailError = validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(isLoading: false, errorMessage: emailError);
      return false;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      state = state.copyWith(isLoading: false, errorMessage: passwordError);
      return false;
    }

    try {
      final user = await _db.authenticate(email, password);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ایمیل یا رمز عبور اشتباه است',
        );
        return false;
      }

      state = state.copyWith(user: user, isLoading: false);
      await saveCurrentUserEmail(email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'خطا در ورود: $e');
      return false;
    }
  }

  /// خروج کاربر
  Future<void> logout() async {
    state = AuthState.initial;
    await clearCurrentUserEmail();
  }

  /// تنظیم مستقیم کاربر
  void setUser(User? user) {
    state = state.copyWith(user: user, isLoading: false, errorMessage: null);
  }

  /// ویرایش پروفایل کاربر
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    var current = state.user;
    if (current == null) {
      final storedEmail = await getCurrentUserEmail();
      if (storedEmail != null && storedEmail.isNotEmpty) {
        current = await _db.getUserByEmail(storedEmail);
        if (current == null) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'کاربر پیدا نشد',
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'کاربر وارد نشده است',
        );
        return false;
      }
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final emailError = validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(isLoading: false, errorMessage: emailError);
      return false;
    }

    try {
      if (email != current.email) {
        final existing = await _db.getUserByEmail(email);
        if (existing != null) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'ایمیل تکراری است',
          );
          return false;
        }
      }

      final ok = await _db.updateUser(id: current.id, name: name, email: email);
      if (!ok) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ویرایش انجام نشد',
        );
        return false;
      }

      final fresh = await _db.getUserByEmail(email);
      state = state.copyWith(user: fresh, isLoading: false);
      await saveCurrentUserEmail(email);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در ویرایش: $e',
      );
      return false;
    }
  }

  /// تغییر رمز عبور
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'کاربر وارد نشده است',
      );
      return false;
    }

    final passwordError = validatePassword(newPassword);
    if (passwordError != null) {
      state = state.copyWith(isLoading: false, errorMessage: passwordError);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _db.changePassword(
        user.id,
        currentPassword,
        newPassword,
      );
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'رمز عبور فعلی اشتباه است',
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در تغییر رمز عبور: $e',
      );
      return false;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final db = ref.watch(appDatabaseProvider);
    return AuthController(db);
  },
);
