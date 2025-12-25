import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/data/local/database.dart';
import 'package:the_plant_app/model/model.dart' as model;
import 'package:the_plant_app/providers/database_providers.dart';
import 'package:the_plant_app/providers/auth_providers.dart';

/// مدل ترکیبی برای نمایش سفارش با آیتم‌هایش
class OrderWithItems {
  final Order order;
  final List<OrderItemWithPlant> items;

  OrderWithItems({required this.order, required this.items});

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.orderItem.quantity);
}

/// مدل ترکیبی برای نمایش آیتم سفارش با اطلاعات گیاه
class OrderItemWithPlant {
  final OrderItem orderItem;
  final model.Plant plant;

  OrderItemWithPlant({required this.orderItem, required this.plant});
}

/// Provider لیست سفارش‌های کاربر فعلی
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final user = authState.user;

  if (user == null) return [];

  final db = ref.watch(appDatabaseProvider);
  return db.getOrdersForUser(user.id);
});

/// Provider برای دریافت آیتم‌های یک سفارش خاص
final orderItemsProvider = FutureProvider.family<List<OrderItem>, int>((
  ref,
  orderId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getOrderItems(orderId);
});

/// Provider برای دریافت سفارش با آیتم‌هایش
final orderWithItemsProvider = FutureProvider.family<OrderWithItems, int>((
  ref,
  orderId,
) async {
  final db = ref.watch(appDatabaseProvider);

  final order = await db.getOrderById(orderId);
  if (order == null) {
    throw Exception('Order not found');
  }

  final orderItems = await db.getOrderItems(orderId);

  final itemsWithPlants = orderItems.map((item) {
    final plant = model.Plant.plantList.firstWhere(
      (p) => p.plantId == item.plantId,
      orElse: () => model.Plant.plantList[0],
    );
    return OrderItemWithPlant(orderItem: item, plant: plant);
  }).toList();

  return OrderWithItems(order: order, items: itemsWithPlants);
});

/// کنترلر سفارش‌ها
class OrdersController {
  final AppDatabase _db;
  final Ref _ref;

  OrdersController(this._db, this._ref);

  /// ایجاد سفارش جدید از سبد خرید فعلی
  Future<int?> createOrderFromCart(List<CartItem> cartItems) async {
    final authState = _ref.read(authControllerProvider);
    final user = authState.user;

    if (user == null) return null;
    if (cartItems.isEmpty) return null;

    // محاسبه قیمت کل و آماده‌سازی آیتم‌ها
    int totalPrice = 0;
    final items = <Map<String, int>>[];

    for (final cartItem in cartItems) {
      final plant = model.Plant.plantList.firstWhere(
        (p) => p.plantId == cartItem.plantId,
        orElse: () => model.Plant.plantList[0],
      );

      totalPrice += plant.price * cartItem.quantity;

      items.add({
        'plantId': cartItem.plantId,
        'quantity': cartItem.quantity,
        'price': plant.price,
      });
    }

    // ایجاد سفارش در دیتابیس
    final orderId = await _db.createOrder(user.id, totalPrice, items);

    // رفرش کردن لیست سفارش‌ها
    _ref.invalidate(ordersProvider);

    return orderId;
  }

  /// تکمیل پرداخت و تأیید سفارش
  Future<bool> completePayment(int orderId) async {
    final success = await _db.completeOrder(orderId);

    if (success) {
      // رفرش کردن لیست سفارش‌ها
      _ref.invalidate(ordersProvider);
      _ref.invalidate(orderWithItemsProvider(orderId));
    }

    return success;
  }

  /// دریافت سفارش با جزئیات
  Future<OrderWithItems?> getOrderWithItems(int orderId) async {
    final order = await _db.getOrderById(orderId);
    if (order == null) return null;

    final orderItems = await _db.getOrderItems(orderId);

    final itemsWithPlants = orderItems.map((item) {
      final plant = model.Plant.plantList.firstWhere(
        (p) => p.plantId == item.plantId,
        orElse: () => model.Plant.plantList[0],
      );
      return OrderItemWithPlant(orderItem: item, plant: plant);
    }).toList();

    return OrderWithItems(order: order, items: itemsWithPlants);
  }
}

/// Provider اصلی برای کنترلر سفارش‌ها
final ordersControllerProvider = Provider<OrdersController>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return OrdersController(db, ref);
});
