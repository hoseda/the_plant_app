import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/pages/detail_page.dart';
import 'package:the_plant_app/pages/home_page.dart';
import 'package:the_plant_app/pages/order_success_page.dart';
import 'package:the_plant_app/providers/cart_providers.dart';
import 'package:the_plant_app/providers/orders_providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force rebuild when cart changes
    ref.watch(cartControllerProvider);
    final cartItemsAsync = ref.watch(cartItemsWithPlantsProvider);

    return Scaffold(
      body: cartItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 130,
                    child: Image.asset('assets/images/add-cart.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ':-|  سبدخرید تار عنکبوت بسته است',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: 'iranSans',
                      fontSize: 23,
                      color: Constants.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          final totalPrice = ref.watch(cartTotalPriceProvider);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.only(top: 10),
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final plant = item.plant;
                    final cartItem = item.cartItem;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      child: Dismissible(
                        key: ValueKey(cartItem.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(cartControllerProvider.notifier)
                              .removeFromCart(plant.plantId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('از سبد حذف شد')),
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: DetailPage(plant: plant),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Constants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // تصویر گیاه
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 75,
                                        height: 75,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          color: Constants.primaryColor
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        child: SizedBox(
                                          height: 85,
                                          width: 85,
                                          child: Image.asset(plant.imageURL),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),

                                  // اطلاعات گیاه
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          plant.category,
                                          style: TextStyle(
                                            fontFamily: 'Lalezar',
                                            color: Constants.blackColor,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          plant.plantName,
                                          style: TextStyle(
                                            fontFamily: 'iranSans',
                                            color: Constants.blackColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              plant.price
                                                  .toString()
                                                  .farsiNumber,
                                              style: TextStyle(
                                                fontFamily: 'Lalezar',
                                                color: Constants.primaryColor,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            SizedBox(
                                              width: 25,
                                              child: Image.asset(
                                                'assets/images/PriceUnit-green.png',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // دکمه‌های + و -
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Constants.primaryColor.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(
                                                  cartControllerProvider
                                                      .notifier,
                                                )
                                                .decrementQuantity(
                                                  plant.plantId,
                                                );
                                          },
                                          color: Constants.primaryColor,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            cartItem.quantity
                                                .toString()
                                                .farsiNumber,
                                            style: TextStyle(
                                              fontFamily: 'Lalezar',
                                              fontSize: 18,
                                              color: Constants.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          onPressed: () {
                                            ref
                                                .read(
                                                  cartControllerProvider
                                                      .notifier,
                                                )
                                                .incrementQuantity(
                                                  plant.plantId,
                                                );
                                          },
                                          color: Constants.primaryColor,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(indent: 15, endIndent: 15, thickness: 1),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Text(
                        'جمع کل',
                        style: TextStyle(
                          fontFamily: 'Lalezar',
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        totalPrice.toString().farsiNumber,
                        style: TextStyle(
                          fontFamily: 'Lalezar',
                          fontSize: 30,
                          color: Constants.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 40,
                        child: Image.asset('assets/images/PriceUnit-green.png'),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _processPayment(context, ref, items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ادامه پرداخت',
                      style: TextStyle(fontFamily: 'iranSans', fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('خطا در بارگذاری سبد خرید: $e')),
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    WidgetRef ref,
    List<CartItemWithPlant> items,
  ) async {
    // Calculate total price BEFORE any operations
    int totalPrice = 0;
    for (var item in items) {
      totalPrice += item.plant.price * item.cartItem.quantity;
    }

    // نمایش دیالوگ در حال پردازش
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'در حال اتصال به درگاه پرداخت...',
                style: TextStyle(fontFamily: 'iranSans'),
              ),
            ],
          ),
        );
      },
    );

    // شبیه‌سازی ۳ ثانیه تأخیر پردازش پرداخت
    await Future.delayed(const Duration(seconds: 3));

    if (!context.mounted) return;
    Navigator.of(context).pop(); // بستن دیالوگ

    try {
      // ایجاد سفارش
      final cartItems = items.map((e) => e.cartItem).toList();
      final ordersController = ref.read(ordersControllerProvider);
      final orderId = await ordersController.createOrderFromCart(cartItems);

      if (orderId == null) {
        throw Exception('خطا در ایجاد سفارش');
      }

      // تکمیل پرداخت
      final success = await ordersController.completePayment(orderId);

      if (!success) {
        throw Exception('خطا در تکمیل پرداخت');
      }

      // خالی کردن سبد خرید
      await ref.read(cartControllerProvider.notifier).clearCart();

      // نمایش صفحه موفقیت با قیمت صحیح
      if (!context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            orderId: orderId,
            items: items.map((e) => e.plant).toList(),
            totalPrice: totalPrice, // استفاده از قیمت محاسبه شده
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در پردازش پرداخت: ${e.toString()}')),
      );
    }
  }
}
