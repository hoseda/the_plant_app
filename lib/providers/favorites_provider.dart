import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/data/local/database.dart';
import 'package:the_plant_app/providers/database_providers.dart';
import 'package:the_plant_app/providers/auth_providers.dart';

/// Provider برای دریافت لیست ID گیاهان مورد علاقه کاربر فعلی
final favoritePlantIdsProvider = FutureProvider<List<int>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final user = authState.user;

  if (user == null) return [];

  final db = ref.watch(appDatabaseProvider);
  return db.getFavoritePlantIds(user.id);
});

/// State Notifier برای مدیریت علاقه‌مندی‌ها
class FavoritesNotifier extends StateNotifier<List<int>> {
  final AppDatabase _db;
  final Ref _ref;
  final int? _userId;

  FavoritesNotifier(this._db, this._ref, this._userId) : super([]) {
    if (_userId != null) {
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    if (_userId == null) {
      state = [];
      return;
    }

    final favorites = await _db.getFavoritePlantIds(_userId!);
    state = favorites;
  }

  Future<void> addFavorite(int plantId) async {
    if (_userId == null) return;

    if (!state.contains(plantId)) {
      await _db.addFavorite(_userId!, plantId);
      state = [...state, plantId];
      // Force refresh the FutureProvider
      _ref.invalidate(favoritePlantIdsProvider);
    }
  }

  Future<void> removeFavorite(int plantId) async {
    if (_userId == null) return;

    await _db.removeFavorite(_userId!, plantId);
    state = state.where((id) => id != plantId).toList();
    // Force refresh the FutureProvider
    _ref.invalidate(favoritePlantIdsProvider);
  }

  Future<void> toggleFavorite(int plantId) async {
    if (_userId == null) return;

    if (state.contains(plantId)) {
      await removeFavorite(plantId);
    } else {
      await addFavorite(plantId);
    }
  }

  bool isFavorite(int plantId) {
    return state.contains(plantId);
  }

  /// رفرش کردن لیست از دیتابیس
  Future<void> refresh() async {
    await _loadFavorites();
  }
}

/// Provider اصلی برای مدیریت علاقه‌مندی‌ها
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<int>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.id;

  return FavoritesNotifier(db, ref, userId);
});
