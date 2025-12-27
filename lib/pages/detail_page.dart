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
    final size = MediaQuery.of(context).size;
    final favorites = ref.watch(favoritesProvider);
    final cart = ref.watch(cartControllerProvider);

    final isFavorite = favorites.contains(plant.plantId);
    final isInCart = cart.any((item) => item.plantId == plant.plantId);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            Column(
              children: [
                // Image and info section (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.5,
                          child: Stack(
                            children: [
                              // Plant image - centered and properly constrained
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 80,
                                    right: 80,
                                    left: 20,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: size.height * 0.35,
                                      maxWidth: size.width * 0.5,
                                    ),
                                    child: Image.asset(
                                      plant.imageURL,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),

                              // Right side plant info
                              Positioned(
                                top: 100,
                                right: 30,
                                child: _buildPlantInfoColumn(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom details panel (fixed at bottom)
                _buildDetailsPanel(context, ref, isFavorite, isInCart),
              ],
            ),

            // Top action buttons (fixed)
            _buildTopActionBar(context, ref, isFavorite),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActionBar(
    BuildContext context,
    WidgetRef ref,
    bool isFavorite,
  ) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
          _buildActionButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            onTap: () => _toggleFavorite(context, ref, isFavorite),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Constants.primaryColor),
      ),
    );
  }

  Widget _buildPlantInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildInfoItem('اندازه‌گیاه', plant.size),
        const SizedBox(height: 15),
        _buildInfoItem('رطوبت‌هوا', plant.humidity.toString().farsiNumber),
        const SizedBox(height: 15),
        _buildInfoItem('دمای‌نگهداری', plant.temperature.farsiNumber),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lalezar',
            color: Constants.blackColor,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lalezar',
            color: Constants.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    WidgetRef ref,
    bool isFavorite,
    bool isInCart,
  ) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withAlpha(100),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Plant name
                  Text(
                    plant.plantName,
                    style: TextStyle(
                      fontFamily: 'Lalezar',
                      fontSize: 30,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Rating and price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Constants.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            plant.rating.toString().farsiNumber,
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 24,
                              color: Constants.primaryColor,
                            ),
                          ),
                        ],
                      ),

                      // Price
                      Row(
                        children: [
                          Text(
                            plant.price.toString().farsiNumber,
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 28,
                              color: Constants.blackColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.asset(
                              'assets/images/PriceUnit-green.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    plant.decription,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'iranSans',
                      color: Constants.blackColor,
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed action buttons at bottom
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Cart icon with indicator
                _buildCartIcon(isInCart),

                const SizedBox(width: 15),

                // Add to cart button
                Expanded(child: _buildAddToCartButton(context, ref, isInCart)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartIcon(bool isInCart) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Constants.primaryColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        if (isInCart)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFD30000),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddToCartButton(
    BuildContext context,
    WidgetRef ref,
    bool isInCart,
  ) {
    return ElevatedButton(
      onPressed: () => _addToCart(context, ref, isInCart),
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 2,
      ),
      child: Text(
        isInCart ? 'افزودن بیشتر' : 'افزودن به سبد خرید',
        style: const TextStyle(fontFamily: 'Lalezar', fontSize: 20),
      ),
    );
  }

  void _toggleFavorite(BuildContext context, WidgetRef ref, bool isFavorite) {
    ref.read(favoritesProvider.notifier).toggleFavorite(plant.plantId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'از علاقه‌مندی‌ها حذف شد' : 'به علاقه‌مندی‌ها اضافه شد',
          style: const TextStyle(fontFamily: 'iranSans'),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, bool isInCart) {
    ref
        .read(cartControllerProvider.notifier)
        .addToCart(plant.plantId, quantity: 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
        closeIconColor: Colors.white,
        margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            isInCart
                ? '${plant.plantName} در سبد خرید موجود است'
                : '${plant.plantName} به سبد خرید اضافه شد',
            style: const TextStyle(fontFamily: 'iranSans', fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
