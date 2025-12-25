import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/data/local/database.dart';
import 'package:the_plant_app/providers/database_providers.dart';
import 'package:the_plant_app/providers/auth_providers.dart';
import 'package:the_plant_app/model/model.dart' as model;

/// Provider لیست موارد سبد خرید کاربر فعلی
final cartItemsProvider = FutureProvider<List<CartItem>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final user = authState.user;
  if (user == null) return [];

  final db = ref.watch(appDatabaseProvider);
  return db.getCartItemsForUser(user.id);
});

/// مدل ترکیبی برای نمایش آیتم سبد خرید با اطلاعات گیاه
class CartItemWithPlant {
  final CartItem cartItem;
  final model.Plant plant;

  CartItemWithPlant({required this.cartItem, required this.plant});

  int get totalPrice => plant.price * cartItem.quantity;
}

/// Provider برای دریافت آیتم‌های سبد خرید با اطلاعات کامل گیاه
final cartItemsWithPlantsProvider = FutureProvider<List<CartItemWithPlant>>((
  ref,
) async {
  final cartItems = await ref.watch(cartItemsProvider.future);

  return cartItems.map((item) {
    final plant = model.Plant.plantList.firstWhere(
      (p) => p.plantId == item.plantId,
      orElse: () => model.Plant.plantList[0],
    );
    return CartItemWithPlant(cartItem: item, plant: plant);
  }).toList();
});

/// کنترلر سبد خرید
class CartController extends StateNotifier<List<CartItem>> {
  final AppDatabase _db;
  final Ref _ref;
  final int? _userId;

  CartController(this._db, this._ref, this._userId) : super([]) {
    if (_userId != null) {
      _loadCart();
    }
  }

  Future<void> _loadCart() async {
    if (_userId == null) {
      state = [];
      return;
    }

    final items = await _db.getCartItemsForUser(_userId!);
    state = items;
  }

  /// اضافه کردن به سبد خرید
  Future<void> addToCart(int plantId, {int quantity = 1}) async {
    if (_userId == null) return;

    await _db.addToCart(_userId!, plantId, quantity: quantity);
    await _loadCart();
    _ref.invalidate(cartItemsProvider);
    _ref.invalidate(cartItemsWithPlantsProvider);
  }

  /// حذف از سبد خرید
  Future<void> removeFromCart(int plantId) async {
    if (_userId == null) return;

    await _db.removeFromCart(_userId!, plantId);
    await _loadCart();
    _ref.invalidate(cartItemsProvider);
    _ref.invalidate(cartItemsWithPlantsProvider);
  }

  /// افزایش تعداد
  Future<void> incrementQuantity(int plantId) async {
    if (_userId == null) return;

    final item = state.firstWhere(
      (item) => item.plantId == plantId,
      orElse: () => throw Exception('Item not found'),
    );

    await updateQuantity(plantId, item.quantity + 1);
  }

  /// کاهش تعداد
  Future<void> decrementQuantity(int plantId) async {
    if (_userId == null) return;

    final item = state.firstWhere(
      (item) => item.plantId == plantId,
      orElse: () => throw Exception('Item not found'),
    );

    if (item.quantity > 1) {
      await updateQuantity(plantId, item.quantity - 1);
    } else {
      await removeFromCart(plantId);
    }
  }

  /// به‌روزرسانی تعداد
  Future<void> updateQuantity(int plantId, int quantity) async {
    if (_userId == null) return;

    if (quantity <= 0) {
      await removeFromCart(plantId);
    } else {
      await _db.updateCartQuantity(_userId!, plantId, quantity);
      await _loadCart();
      _ref.invalidate(cartItemsProvider);
      _ref.invalidate(cartItemsWithPlantsProvider);
    }
  }

  /// خالی کردن سبد خرید
  Future<void> clearCart() async {
    if (_userId == null) return;

    await _db.clearCartForUser(_userId!);
    state = [];
    _ref.invalidate(cartItemsProvider);
    _ref.invalidate(cartItemsWithPlantsProvider);
  }

  /// دریافت تعداد کل محصولات
  int getTotalQuantity() {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  /// دریافت قیمت کل
  int getTotalPrice() {
    int total = 0;
    for (var item in state) {
      final plant = model.Plant.plantList.firstWhere(
        (p) => p.plantId == item.plantId,
        orElse: () => model.Plant.plantList[0],
      );
      total += plant.price * item.quantity;
    }
    return total;
  }

  /// بررسی اینکه آیا گیاه در سبد خرید هست
  bool isInCart(int plantId) {
    return state.any((item) => item.plantId == plantId);
  }

  /// دریافت تعداد یک گیاه خاص در سبد خرید
  int getQuantity(int plantId) {
    final item = state.firstWhere(
      (item) => item.plantId == plantId,
      orElse: () => CartItem(
        id: 0,
        userId: _userId ?? 0,
        plantId: plantId,
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  /// رفرش کردن سبد خرید
  Future<void> refresh() async {
    await _loadCart();
  }
}

/// Provider اصلی برای کنترلر سبد خرید
final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartItem>>((ref) {
      final authState = ref.watch(authControllerProvider);
      final userId = authState.user?.id;
      final db = ref.watch(appDatabaseProvider);

      return CartController(db, ref, userId);
    });

/// Provider برای تعداد کل آیتم‌ها در سبد خرید
final cartTotalQuantityProvider = Provider<int>((ref) {
  final cart = ref.watch(cartControllerProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

/// Provider برای قیمت کل سبد خرید
final cartTotalPriceProvider = Provider<int>((ref) {
  final cart = ref.watch(cartControllerProvider);
  int total = 0;
  for (var item in cart) {
    final plant = model.Plant.plantList.firstWhere(
      (p) => p.plantId == item.plantId,
      orElse: () => model.Plant.plantList[0],
    );
    total += plant.price * item.quantity;
  }
  return total;
});
