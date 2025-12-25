import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/model/model.dart';
import 'package:the_plant_app/pages/detail_page.dart';
import 'package:the_plant_app/pages/camera/scan_page.dart';
import 'package:the_plant_app/providers/favorites_provider.dart';
import 'package:the_plant_app/providers/cart_providers.dart';

extension FarsiNumberExtension on String {
  String get farsiNumber {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], farsi[i]);
    }
    return result;
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'همه',
    'پیشنهادی',
    'آپارتمانی',
    'محل‌کار',
    'باغچه‌ای',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch favorites and cart to update UI
    final favoritesIds = ref.watch(favoritesProvider);
    final cartItems = ref.watch(cartControllerProvider);

    List<Plant> filteredPlants = Plant.plantList.where((plant) {
      // Filter by search query
      bool matchesSearch = true;
      if (searchQuery.isNotEmpty) {
        matchesSearch =
            plant.plantName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            plant.category.contains(searchQuery);
      }

      // Filter by category
      bool matchesCategory = true;
      if (selectedIndex != 0) {
        matchesCategory = plant.category == categories[selectedIndex];
      }

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Scan Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'جستجو',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // QR Code Scan Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const ScanPage(),
                          type: PageTransitionType.bottomToTop,
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selectedIndex == index
                              ? Constants.primaryColor
                              : Constants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              fontFamily: 'iranSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selectedIndex == index
                                  ? Colors.white
                                  : Constants.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Plants Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: filteredPlants.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'نتیجه‌ای یافت نشد',
                              style: TextStyle(
                                fontFamily: 'iranSans',
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'لطفاً کلمات دیگری را امتحان کنید',
                              style: TextStyle(
                                fontFamily: 'iranSans',
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: filteredPlants.length,
                      itemBuilder: (context, index) {
                        final plant = filteredPlants[index];
                        final isFavorite = favoritesIds.contains(plant.plantId);
                        final isInCart = cartItems.any(
                          (item) => item.plantId == plant.plantId,
                        );

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: DetailPage(plant: plant),
                                type: PageTransitionType.bottomToTop,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Constants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                // Favorite Button
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(favoritesProvider.notifier)
                                          .toggleFavorite(plant.plantId);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),

                                // Plant Image
                                Positioned(
                                  top: 40,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: SizedBox(
                                      height: 100,
                                      child: Image.asset(
                                        plant.imageURL,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                // Plant Info
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          plant.plantName,
                                          style: TextStyle(
                                            fontFamily: 'iranSans',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Constants.blackColor,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          plant.category,
                                          style: TextStyle(
                                            fontFamily: 'iranSans',
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Add to Cart Button
                                            GestureDetector(
                                              onTap: () {
                                                ref
                                                    .read(
                                                      cartControllerProvider
                                                          .notifier,
                                                    )
                                                    .addToCart(
                                                      plant.plantId,
                                                      quantity: 1,
                                                    );

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'به سبد خرید اضافه شد',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 1,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isInCart
                                                      ? Constants.primaryColor
                                                            .withOpacity(0.3)
                                                      : Constants.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  isInCart
                                                      ? Icons.check
                                                      : Icons.add_shopping_cart,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),

                                            // Price
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  child: Image.asset(
                                                    'assets/images/PriceUnit-green.png',
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  plant.price
                                                      .toString()
                                                      .farsiNumber,
                                                  style: TextStyle(
                                                    fontFamily: 'Lalezar',
                                                    fontSize: 18,
                                                    color:
                                                        Constants.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
