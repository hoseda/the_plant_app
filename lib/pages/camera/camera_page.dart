import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/model/model.dart';
import 'package:the_plant_app/pages/camera/camera_overlay.dart';
import 'package:the_plant_app/pages/detail_page.dart';
import 'package:the_plant_app/providers/scan_providers.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            overlayBuilder: (context, constraint) => QRScannerOverlay(
              overlayColour: Colors.black.withAlpha(123),
              control: controller,
            ),
            onDetect: (capture) async {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final value = barcodes.first.rawValue;
              if (value == null || value.isEmpty) return;

              setState(() {
                _isProcessing = true;
              });

              // پردازش QR کد با Riverpod
              ref.read(scanControllerProvider.notifier).handleScan(value);

              final scanState = ref.read(scanControllerProvider);
              final Plant? plant = scanState.plant;

              if (!mounted) return;

              if (plant == null) {
                // نمایش خطا
                _showErrorDialog(value, scanState.errorMessage);

                // اجازه اسکن مجدد بعد از 2 ثانیه
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _isProcessing = false;
                    });
                    ref.read(scanControllerProvider.notifier).clear();
                  }
                });
                return;
              }

              // توقف اسکنر
              controller.stop();

              // نمایش صفحه جزئیات گیاه
              await Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: DetailPage(plant: plant),
                ),
              );

              // پس از برگشت، پاک کردن وضعیت و شروع مجدد
              if (mounted) {
                ref.read(scanControllerProvider.notifier).clear();
                setState(() {
                  _isProcessing = false;
                });
                controller.start();
              }
            },
          ),

          // نمایشگر پردازش
          if (_isProcessing)
            Container(
              color: Colors.black38,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Constants.primaryColor),
                      const SizedBox(height: 16),
                      const Text(
                        'در حال پردازش...',
                        style: TextStyle(fontFamily: 'iranSans', fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showErrorDialog(String qrCode, String? errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 28),
              const SizedBox(width: 12),
              const Text(
                'گیاه یافت نشد',
                style: TextStyle(fontFamily: 'iranSans', fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMessage ?? 'QR کد اسکن شده مربوط به هیچ گیاهی نیست.',
                style: const TextStyle(fontFamily: 'iranSans', fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'کد اسکن شده:',
                      style: TextStyle(
                        fontFamily: 'iranSans',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      qrCode,
                      style: TextStyle(
                        fontFamily: 'iranSans',
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'فرمت صحیح: شناسه عددی (مثال: 0, 1, 2)',
                        style: TextStyle(
                          fontFamily: 'iranSans',
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'متوجه شدم',
                style: TextStyle(
                  fontFamily: 'iranSans',
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
