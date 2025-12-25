import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/pages/home_page.dart';
import 'package:the_plant_app/providers/orders_providers.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سفارش‌های من',
          style: TextStyle(fontFamily: 'iranSans'),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 110,
                    child: Image.asset('assets/images/add-cart.png'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'سبدت خالیه — آماده سفارش جدید؟',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'iranSans',
                      fontSize: 22,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'هیچ سفارشی ثبت نشده‌است. برو خرید کن و گیاهاتو خوشحال کن 🌿',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'iranSans',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final statusText = order.status == 'completed'
                  ? 'تکمیل شده'
                  : order.status == 'pending'
                  ? 'در انتظار پرداخت'
                  : 'لغو شده';
              final statusColor = order.status == 'completed'
                  ? Colors.green
                  : order.status == 'pending'
                  ? Colors.orange
                  : Colors.red;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Constants.primaryColor,
                    ),
                  ),
                  title: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        Text(
                          'سفارش #${order.id}',
                          style: const TextStyle(
                            fontFamily: 'iranSans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontFamily: 'iranSans',
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(order.createdAt),
                              style: const TextStyle(
                                fontFamily: 'iranSans',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            const Text(
                              'مبلغ:',
                              style: TextStyle(
                                fontFamily: 'iranSans',
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.totalPrice.toString().farsiNumber,
                              style: TextStyle(
                                fontFamily: 'Lalezar',
                                color: Constants.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 20,
                              child: Image.asset(
                                'assets/images/PriceUnit-green.png',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_back_ios_new_rounded),
                  onTap: () {
                    _showOrderDetails(context, ref, order.id);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'خطا در خواندن سفارش‌ها',
                style: TextStyle(
                  fontFamily: 'iranSans',
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return 'امروز، ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (orderDate == yesterday) {
      return 'دیروز، ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  void _showOrderDetails(BuildContext context, WidgetRef ref, int orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final orderWithItemsAsync = ref.watch(
              orderWithItemsProvider(orderId),
            );

            return orderWithItemsAsync.when(
              data: (orderWithItems) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, scrollController) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'جزئیات سفارش #${orderWithItems.order.id}',
                                  style: const TextStyle(
                                    fontFamily: 'iranSans',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تاریخ: ${_formatDate(orderWithItems.order.createdAt)}',
                              style: const TextStyle(
                                fontFamily: 'iranSans',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: orderWithItems.items.length,
                                itemBuilder: (context, i) {
                                  final item = orderWithItems.items[i];
                                  final p = item.plant;
                                  final orderItem = item.orderItem;
                                  return ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Constants.primaryColor
                                            .withOpacity(0.1),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          p.imageURL,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      p.plantName,
                                      style: const TextStyle(
                                        fontFamily: 'iranSans',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'تعداد: ${orderItem.quantity.toString().farsiNumber}',
                                      style: const TextStyle(
                                        fontFamily: 'iranSans',
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (orderItem.priceAtTime *
                                                  orderItem.quantity)
                                              .toString()
                                              .farsiNumber,
                                          style: TextStyle(
                                            fontFamily: 'Lalezar',
                                            color: Constants.primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: 20,
                                          child: Image.asset(
                                            'assets/images/PriceUnit-green.png',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'جمع کل:',
                                  style: TextStyle(
                                    fontFamily: 'iranSans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  orderWithItems.order.totalPrice
                                      .toString()
                                      .farsiNumber,
                                  style: TextStyle(
                                    fontFamily: 'Lalezar',
                                    fontSize: 26,
                                    color: Constants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 28,
                                  child: Image.asset(
                                    'assets/images/PriceUnit-green.png',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('خطا: $e'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
