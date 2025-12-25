import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/data/local/database.dart';

/// Provider سطح بالا برای دیتابیس Drift
/// Top-level provider that exposes a single AppDatabase instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // دیتابیس در زمان dispose اپ بسته می‌شود
  // Close the database when provider is destroyed.
  ref.onDispose(() {
    db.close();
  });
  return db;
});
