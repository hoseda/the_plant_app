import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/const/constants.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات', style: TextStyle(fontFamily: 'iranSans')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.light_mode_rounded,
                size: 56,
                color: Constants.primaryColor,
              ),
              SizedBox(height: 12),
              Text(
                'حالت تیره از برنامه حذف شد. برنامه فقط حالت روشن را پشتیبانی می‌کند.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'iranSans', fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
