import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/main.dart';
import 'package:the_plant_app/pages/auth/auth_page.dart';
import 'package:the_plant_app/pages/onBoarding/page_one.dart';
import 'package:the_plant_app/pages/onBoarding/page_three.dart';
import 'package:the_plant_app/pages/onBoarding/page_two.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final controller = PageController();
  double _currentpage = 0;

  void _pageing() {
    if (_currentpage < 2) {
      controller.nextPage(
        duration: const Duration(milliseconds: 900),
        curve: Curves.ease,
      );
      setState(() {
        _currentpage = controller.page!;
      });
    } else {
      Navigator.pushReplacement(
        context,
        PageTransition(child: const AuthPage(), type: PageTransitionType.fade),
      );
      saveOnboardingStatus(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 14),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    child: const AuthPage(),
                    type: PageTransitionType.fade,
                  ),
                );
                saveOnboardingStatus(true);
              },
              child: const Text(
                'رد کردن',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Lalezar',
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 600,
              child: PageView(
                controller: controller,
                // physics: const NeverScrollableScrollPhysics(),
                children: [pageOne, pageTwo, pageThree],
                onPageChanged: (value) {
                  setState(() {
                    _currentpage = value.toDouble();
                  });
                },
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Row(
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: const ExpandingDotsEffect(
                      dotWidth: 9,
                      dotHeight: 9,
                      spacing: 3,
                      expansionFactor: 2,
                      dotColor: Color.fromARGB(255, 41, 110, 72),
                      activeDotColor: Color.fromARGB(255, 41, 110, 72),
                    ),
                  ),
                  const Spacer(),
                  InkResponse(
                    onTap: () => _pageing(),
                    child: CircleAvatar(
                      backgroundColor: Constants.primaryColor,
                      foregroundColor: Colors.white,
                      radius: 27,
                      child: const Icon(Icons.keyboard_arrow_right_rounded),
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
