import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// جدول کاربران
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get avatarPath => text().nullable()();
}

/// جدول گیاهان - اطلاعات پایه محصولات
class Plants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().unique()();
  TextColumn get plantName => text()();
  TextColumn get category => text()();
  IntColumn get price => integer()();
  TextColumn get size => text()();
  RealColumn get rating => real()();
  IntColumn get humidity => integer()();
  TextColumn get temperature => text()();
  TextColumn get imageURL => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// جدول علاقه‌مندی‌ها - ارتباط بین کاربر و گیاه
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get plantId =>
      integer().references(Plants, #plantId, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, plantId}
      ];
}

/// جدول سبد خرید - ارتباط بین کاربر و گیاه با تعداد
class CartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get plantId =>
      integer().references(Plants, #plantId, onDelete: KeyAction.cascade)();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, plantId}
      ];
}

/// جدول سفارش‌ها
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get totalPrice => integer()();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // pending, completed, cancelled
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// جدول آیتم‌های سفارش - جزئیات هر سفارش
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId =>
      integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  IntColumn get plantId => integer().references(Plants, #plantId)();
  IntColumn get quantity => integer()();
  IntColumn get priceAtTime => integer()(); // قیمت در زمان خرید
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
    tables: [Users, Plants, Favorites, CartItems, Orders, OrderItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          // حذف و ساخت مجدد تمام جداول
          await m.deleteTable('favorites');
          await m.deleteTable('cart_items');
          await m.deleteTable('order_items');
          await m.deleteTable('orders');
          await m.createTable(favorites);
          await m.createTable(cartItems);
          await m.createTable(orders);
          await m.createTable(orderItems);
        }
      },
    );
  }

  // ==================== USER METHODS ====================

  Future<int> insertUser(UsersCompanion entry) {
    return into(users).insert(entry);
  }

  Future<User?> getUserByEmail(String email) {
    return (select(users)..where((tbl) => tbl.email.equals(email)))
        .getSingleOrNull();
  }

  Future<User?> authenticate(String email, String password) {
    return (select(users)
          ..where((tbl) => tbl.email.equals(email))
          ..where((tbl) => tbl.password.equals(password)))
        .getSingleOrNull();
  }

  Future<bool> updateUser({
    required int id,
    String? name,
    String? email,
    String? password,
    String? avatarPath,
  }) async {
    final companion = UsersCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      email: email != null ? Value(email) : const Value.absent(),
      password: password != null ? Value(password) : const Value.absent(),
      avatarPath: avatarPath != null ? Value(avatarPath) : const Value.absent(),
    );

    final updated = await (update(users)..where((tbl) => tbl.id.equals(id)))
        .write(companion);
    return updated > 0;
  }

  Future<bool> changePassword(
      int userId, String currentPassword, String newPassword) async {
    final user = await (select(users)..where((tbl) => tbl.id.equals(userId)))
        .getSingleOrNull();
    if (user == null || user.password != currentPassword) {
      return false;
    }

    return await updateUser(id: userId, password: newPassword);
  }

  // ==================== PLANT METHODS ====================

  Future<int> insertPlant(PlantsCompanion entry) {
    return into(plants).insert(entry);
  }

  Future<List<Plant>> getAllPlants() {
    return select(plants).get();
  }

  Future<Plant?> getPlantByPlantId(int plantId) {
    return (select(plants)..where((tbl) => tbl.plantId.equals(plantId)))
        .getSingleOrNull();
  }

  // ==================== FAVORITES METHODS ====================

  Future<void> addFavorite(int userId, int plantId) async {
    await into(favorites).insertOnConflictUpdate(
      FavoritesCompanion.insert(
        userId: userId,
        plantId: plantId,
      ),
    );
  }

  Future<void> removeFavorite(int userId, int plantId) {
    return (delete(favorites)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .go();
  }

  Future<List<int>> getFavoritePlantIds(int userId) async {
    final result = await (select(favorites)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
    return result.map((e) => e.plantId).toList();
  }

  Future<bool> isFavorite(int userId, int plantId) async {
    final result = await (select(favorites)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .getSingleOrNull();
    return result != null;
  }

  // ==================== CART METHODS ====================

  Future<void> addToCart(int userId, int plantId, {int quantity = 1}) async {
    final existing = await (select(cartItems)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(cartItems)..where((tbl) => tbl.id.equals(existing.id)))
          .write(CartItemsCompanion(
              quantity: Value(existing.quantity + quantity)));
    } else {
      await into(cartItems).insert(
        CartItemsCompanion.insert(
          userId: userId,
          plantId: plantId,
          quantity: Value(quantity),
        ),
      );
    }
  }

  Future<void> removeFromCart(int userId, int plantId) {
    return (delete(cartItems)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .go();
  }

  Future<void> updateCartQuantity(int userId, int plantId, int quantity) async {
    await (update(cartItems)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .write(CartItemsCompanion(quantity: Value(quantity)));
  }

  Future<List<CartItem>> getCartItemsForUser(int userId) {
    return (select(cartItems)..where((tbl) => tbl.userId.equals(userId))).get();
  }

  Future<void> clearCartForUser(int userId) {
    return (delete(cartItems)..where((tbl) => tbl.userId.equals(userId))).go();
  }

  // ==================== ORDER METHODS ====================

  Future<int> createOrder(
      int userId, int totalPrice, List<Map<String, int>> items) async {
    return await transaction(() async {
      // ایجاد سفارش
      final orderId = await into(orders).insert(
        OrdersCompanion.insert(
          userId: userId,
          totalPrice: totalPrice,
          status: const Value('pending'),
        ),
      );

      // اضافه کردن آیتم‌های سفارش
      for (final item in items) {
        await into(orderItems).insert(
          OrderItemsCompanion.insert(
            orderId: orderId,
            plantId: item['plantId']!,
            quantity: item['quantity']!,
            priceAtTime: item['price']!,
          ),
        );
      }

      return orderId;
    });
  }

  Future<bool> completeOrder(int orderId) async {
    final updated = await (update(orders)
          ..where((tbl) => tbl.id.equals(orderId)))
        .write(const OrdersCompanion(status: Value('completed')));
    return updated > 0;
  }

  Future<List<Order>> getOrdersForUser(int userId) {
    return (select(orders)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();
  }

  Future<Order?> getOrderById(int orderId) {
    return (select(orders)..where((tbl) => tbl.id.equals(orderId)))
        .getSingleOrNull();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) {
    return (select(orderItems)..where((tbl) => tbl.orderId.equals(orderId)))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(dir.path, 'plant_app_v3.db');
    final File dbFile = File(dbPath);

    return NativeDatabase(
      dbFile,
      logStatements: true,
    );
  });
}
