import 'package:flutter/material.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/model/model.dart';
import 'package:the_plant_app/pages/home_page.dart';

class OrderSuccessPage extends StatelessWidget {
  final int orderId;
  final List<Plant> items;
  final int totalPrice;

  const OrderSuccessPage({
    super.key,
    required this.orderId,
    required this.items,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // آیکون موفقیت
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Constants.primaryColor,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'پرداخت موفق!',
                style: TextStyle(
                  fontFamily: 'Lalezar',
                  fontSize: 32,
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'سفارش شما با موفقیت ثبت شد',
                style: TextStyle(
                  fontFamily: 'iranSans',
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 32),

              // اطلاعات سفارش
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Constants.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'شماره سفارش:',
                          style: TextStyle(
                            fontFamily: 'iranSans',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '#$orderId'.farsiNumber,
                          style: TextStyle(
                            fontFamily: 'Lalezar',
                            fontSize: 18,
                            color: Constants.blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تعداد آیتم‌ها:',
                          style: TextStyle(
                            fontFamily: 'iranSans',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          items.length.toString().farsiNumber,
                          style: TextStyle(
                            fontFamily: 'Lalezar',
                            fontSize: 18,
                            color: Constants.blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'مبلغ پرداختی:',
                          style: TextStyle(
                            fontFamily: 'iranSans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              totalPrice.toString().farsiNumber,
                              style: TextStyle(
                                fontFamily: 'Lalezar',
                                fontSize: 24,
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
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // لیست محصولات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'محصولات سفارش:',
                      style: TextStyle(
                        fontFamily: 'iranSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final p = items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Constants.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      p.imageURL,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.plantName,
                                        style: const TextStyle(
                                          fontFamily: 'iranSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        p.category,
                                        style: TextStyle(
                                          fontFamily: 'iranSans',
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      p.price.toString().farsiNumber,
                                      style: TextStyle(
                                        fontFamily: 'Lalezar',
                                        color: Constants.primaryColor,
                                        fontSize: 16,
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
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // دکمه بازگشت
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'بازگشت به فروشگاه',
                    style: TextStyle(
                      fontFamily: 'iranSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
