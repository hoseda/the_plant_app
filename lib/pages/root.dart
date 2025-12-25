import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/pages/cart.dart';
import 'package:the_plant_app/pages/favorite_page.dart';
import 'package:the_plant_app/pages/home_page.dart';
import 'package:the_plant_app/pages/profile.dart';
import 'package:the_plant_app/providers/cart_providers.dart';

class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key});

  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get cart count for badge
    final cartCount = ref.watch(cartTotalQuantityProvider);

    final List<Widget> pages = [
      const HomePage(),
      const FavoritePage(),
      const CartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'گیاه‌شاپ',
              style: TextStyle(fontFamily: 'Lalezar', fontSize: 24),
            ),
            Icon(Icons.notifications, color: Constants.blackColor),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Constants.primaryColor,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'iranSans',
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'iranSans',
            fontSize: 12,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'خانه',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'علاقه‌مندی‌ها',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cartCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'سبد خرید',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'پروفایل',
            ),
          ],
        ),
      ),
    );
  }
}
