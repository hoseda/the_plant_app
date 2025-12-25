import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:the_plant_app/pages/camera/camera_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.share, color: Constants.primaryColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 240),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const CameraPage(),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 180,
                        child: Image.asset('assets/images/code-scan.png'),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'برای اسکن گیاهان , کلیک کنید',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Lalezar',
                        fontSize: 23,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
