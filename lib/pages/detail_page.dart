import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/model/model.dart';
import 'package:the_plant_app/pages/home_page.dart';
import 'package:the_plant_app/providers/favorites_provider.dart';
import 'package:the_plant_app/providers/cart_providers.dart';

class DetailPage extends ConsumerWidget {
  final Plant plant;

  const DetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force rebuild when favorites or cart changes
    ref.watch(favoritesProvider);
    ref.watch(cartControllerProvider);

    final favorites = ref.read(favoritesProvider);
    final isFavorite = favorites.contains(plant.plantId);

    final cart = ref.read(cartControllerProvider);
    final isInCart = cart.any((item) => item.plantId == plant.plantId);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // دکمه‌های بالا
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(plant.plantId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'از علاقه‌مندی‌ها حذف شد'
                                : 'به علاقه‌مندی‌ها اضافه شد',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // تصویر گیاه
            Positioned(
              top: 110,
              left: 40,
              child: SizedBox(
                height: 340,
                width: 300,
                child: Center(
                  child: Image.asset(plant.imageURL, fit: BoxFit.contain),
                ),
              ),
            ),

            // اطلاعات سمت راست
            Positioned(
              top: 110,
              right: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'اندازه‌گیاه',
                    style: TextStyle(
                      fontFamily: 'Lalezar',
                      color: Constants.blackColor,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    plant.size,
                    style: TextStyle(
                      fontFamily: 'Lalezar',
                      color: Constants.primaryColor,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'رطوبت‌هوا',
                    style: TextStyle(
                      fontFamily: 'Lalezar',
                      color: Constants.blackColor,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    plant.humidity.toString().farsiNumber,
                    style: TextStyle(
                      fontFamily: 'Lalezar',
                      color: Constants.primaryColor,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'دمای‌نهگداری',
                    style: TextStyle(
                      fontFamily: 'Lalezar',
                      color: Constants.blackColor,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    plant.temperature.farsiNumber,
                    style: TextStyle(
                      fontFamily: 'Lalezar',
                      color: Constants.primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // پنل پایین
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 475,
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withAlpha(100),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 93),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          plant.plantName,
                          style: TextStyle(
                            fontFamily: 'Lalezar',
                            fontSize: 29,
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Constants.primaryColor,
                            size: 30,
                          ),
                          Text(
                            plant.rating.toString().farsiNumber,
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 25,
                              color: Constants.primaryColor,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 30,
                            child: Image.asset(
                              'assets/images/PriceUnit-green.png',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            plant.price.toString().farsiNumber,
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 30,
                              color: Constants.blackColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        plant.decription,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'iranSans',
                          color: Constants.blackColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // دکمه‌های پایین
            Positioned(
              bottom: 20,
              left: 25,
              right: 25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // آیکون سبد خرید
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                      ),
                      if (isInCart)
                        Positioned(
                          right: 3,
                          top: 1,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 211, 0, 0),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(-1, 3),
                                  blurRadius: 0.8,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  // دکمه اضافه به سبد خرید
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .addToCart(plant.plantId, quantity: 1);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          showCloseIcon: true,
                          closeIconColor: Colors.white,
                          dismissDirection: DismissDirection.horizontal,
                          margin: const EdgeInsets.only(
                            bottom: 100,
                            left: 20,
                            right: 20,
                          ),
                          content: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Center(
                              child: Text(
                                isInCart
                                    ? '${plant.plantName} در سبد خرید موجود است'
                                    : '${plant.plantName} به سبد خرید اضافه شد',
                                style: const TextStyle(
                                  fontFamily: 'iranSans',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(280, 55),
                      maximumSize: const Size(280, 55),
                    ),
                    child: Text(
                      isInCart ? 'افزودن بیشتر' : 'افزودن به سبد خرید',
                      style: const TextStyle(
                        fontFamily: 'Lalezar',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
