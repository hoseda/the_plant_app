import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/model/model.dart';
import 'package:share_plus/share_plus.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  Plant? selectedPlant;
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ساخت QR کد گیاهان',
          style: TextStyle(fontFamily: 'iranSans'),
        ),
        actions: [
          if (selectedPlant != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _saveQRCode,
              tooltip: 'ذخیره QR کد',
            ),
          if (selectedPlant != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareQRCode,
              tooltip: 'اشتراک‌گذاری',
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Plant Selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Constants.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Plant>(
                    isExpanded: true,
                    value: selectedPlant,
                    hint: const Text(
                      'یک گیاه انتخاب کنید',
                      style: TextStyle(fontFamily: 'iranSans'),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Constants.primaryColor,
                    ),
                    items: Plant.plantList.map((plant) {
                      return DropdownMenuItem<Plant>(
                        value: plant,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Image.asset(plant.imageURL),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    plant.plantName,
                                    style: const TextStyle(
                                      fontFamily: 'iranSans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'شناسه: ${plant.plantId}',
                                    style: TextStyle(
                                      fontFamily: 'iranSans',
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Plant? plant) {
                      setState(() {
                        selectedPlant = plant;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // QR Code Display
            if (selectedPlant != null) ...[
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // QR Code with border
                        RepaintBoundary(
                          key: _qrKey,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: selectedPlant!.plantId.toString(),
                                  version: QrVersions.auto,
                                  size: 250,
                                  backgroundColor: Colors.white,
                                  eyeStyle: QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Constants.primaryColor,
                                  ),
                                  dataModuleStyle: QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Constants.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  selectedPlant!.plantName,
                                  style: TextStyle(
                                    fontFamily: 'iranSans',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Constants.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'شناسه: ${selectedPlant!.plantId}',
                                  style: TextStyle(
                                    fontFamily: 'iranSans',
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Plant Info Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Image.asset(selectedPlant!.imageURL),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedPlant!.plantName,
                                          style: const TextStyle(
                                            fontFamily: 'iranSans',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          selectedPlant!.category,
                                          style: TextStyle(
                                            fontFamily: 'iranSans',
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.qr_code,
                                label: 'فرمت QR',
                                value: 'شناسه عددی',
                              ),
                              _InfoRow(
                                icon: Icons.fingerprint,
                                label: 'شناسه',
                                value: selectedPlant!.plantId.toString(),
                              ),
                              _InfoRow(
                                icon: Icons.check_circle_outline,
                                label: 'وضعیت',
                                value: 'آماده اسکن',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Instructions
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'این QR کد را چاپ کرده و روی گلدان بچسبانید. هنگام اسکن، مشخصات کامل گیاه نمایش داده می‌شود.',
                                  style: TextStyle(
                                    fontFamily: 'iranSans',
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 120,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'یک گیاه انتخاب کنید',
                        style: TextStyle(
                          fontFamily: 'iranSans',
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'برای ساخت QR کد، ابتدا گیاه مورد نظر را انتخاب کنید',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'iranSans',
                          fontSize: 14,
                          color: Colors.grey.shade500,
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

  Future<void> _saveQRCode() async {
    try {
      // Capture the QR code as image
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to device
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/qr_${selectedPlant!.plantName}_${selectedPlant!.plantId}.png',
      );
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR کد ذخیره شد: ${file.path}'),
            action: SnackBarAction(label: 'باشه', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در ذخیره: $e')));
      }
    }
  }

  Future<void> _shareQRCode() async {
    try {
      // Capture the QR code as image
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save temporarily
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/qr_temp.png');
      await file.writeAsBytes(pngBytes);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'QR کد ${selectedPlant!.plantName} - شناسه: ${selectedPlant!.plantId}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در اشتراک‌گذاری: $e')));
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Constants.primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontFamily: 'iranSans',
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'iranSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
