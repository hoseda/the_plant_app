import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/model/model.dart';

/// وضعیت اسکن QR
class ScanState {
  final Plant? plant;
  final String? errorMessage;
  final bool isProcessing;

  const ScanState({this.plant, this.errorMessage, this.isProcessing = false});

  ScanState copyWith({Plant? plant, String? errorMessage, bool? isProcessing}) {
    return ScanState(
      plant: plant ?? this.plant,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  static const ScanState initial = ScanState();
}

/// کنترلر اسکن QR
class ScanController extends StateNotifier<ScanState> {
  ScanController() : super(ScanState.initial);

  /// پردازش QR کد اسکن شده
  void handleScan(String qrCode) {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);

    Plant? plant = _findPlantFromQR(qrCode);

    if (plant != null) {
      state = ScanState(plant: plant, isProcessing: false);
    } else {
      state = ScanState(
        errorMessage: 'گیاه با شناسه "$qrCode" یافت نشد',
        isProcessing: false,
      );
    }
  }

  /// پیدا کردن گیاه از QR کد
  Plant? _findPlantFromQR(String qrCode) {
    try {
      // فرمت 1: فقط شناسه عددی گیاه (مثلاً "0", "1", "2")
      final plantId = int.tryParse(qrCode.trim());
      if (plantId != null) {
        try {
          return Plant.plantList.firstWhere((p) => p.plantId == plantId);
        } catch (e) {
          return null;
        }
      }

      // فرمت 2: فرمت URL (مثلاً "plantshop://plant/1")
      if (qrCode.startsWith('plantshop://plant/')) {
        final id = int.tryParse(qrCode.replaceFirst('plantshop://plant/', ''));
        if (id != null) {
          try {
            return Plant.plantList.firstWhere((p) => p.plantId == id);
          } catch (e) {
            return null;
          }
        }
      }

      // فرمت 3: URL وب (مثلاً "https://plantshop.com/plant/1")
      if (qrCode.contains('/plant/')) {
        final parts = qrCode.split('/plant/');
        if (parts.length > 1) {
          final id = int.tryParse(parts.last.split('?').first);
          if (id != null) {
            try {
              return Plant.plantList.firstWhere((p) => p.plantId == id);
            } catch (e) {
              return null;
            }
          }
        }
      }

      // فرمت 4: نام گیاه (مثلاً "سانسوریا")
      try {
        return Plant.plantList.firstWhere(
          (p) => p.plantName.trim() == qrCode.trim(),
        );
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// پاک کردن وضعیت
  void clear() {
    state = ScanState.initial;
  }
}

/// Provider اصلی برای کنترلر اسکن
final scanControllerProvider = StateNotifierProvider<ScanController, ScanState>(
  (ref) {
    return ScanController();
  },
);
