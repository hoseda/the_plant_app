import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/model/model.dart';
import 'package:the_plant_app/pages/detail_page.dart';
import 'package:the_plant_app/pages/home_page.dart';
import 'package:the_plant_app/providers/favorites_provider.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritePlantIdsProvider);

    return Scaffold(
      body: favoritesAsync.when(
        data: (favoriteIds) {
          final favoriteItems = Plant.plantList
              .where((plant) => favoriteIds.contains(plant.plantId))
              .toList();

          if (favoriteItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: Image.asset('assets/images/favorited.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ':-| ظاهرا به هیچی علاقه نداشتی',
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

          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              itemCount: favoriteItems.length,
              reverse: false,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast,
              ),
              itemBuilder: (context, index) {
                final plant = favoriteItems[index];
                return Dismissible(
                  key: ValueKey(plant.plantId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // Remove from favorites globally using Riverpod
                    ref
                        .read(favoritesProvider.notifier)
                        .removeFavorite(plant.plantId);
                    plant.isFavorated = false;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${plant.plantName} از علاقه‌مندی‌ها حذف شد',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  background: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Constants.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: DetailPage(plant: plant),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      child: Container(
                        height: 77,
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      width: 75,
                                      height: 75,
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Constants.primaryColor
                                            .withOpacity(0.8),
                                      ),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                ],
                              ),
                              const Spacer(),
                              Text(
                                plant.price.toString().farsiNumber,
                                style: TextStyle(
                                  fontFamily: 'Lalezar',
                                  color: Constants.primaryColor,
                                  fontSize: 23,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 45,
                                child: Image.asset(
                                  'assets/images/PriceUnit-green.png',
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            'خطا در بارگذاری علاقه‌مندی‌ها',
            style: TextStyle(
              fontFamily: 'iranSans',
              color: Constants.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
