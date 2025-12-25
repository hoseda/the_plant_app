import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/providers/auth_providers.dart';

class ResetPasswordDialog extends ConsumerStatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  ConsumerState<ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<ResetPasswordDialog> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateCurrentPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _currentPasswordError = 'رمز عبور فعلی الزامی است';
      } else {
        _currentPasswordError = null;
      }
    });
  }

  void _validateNewPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _newPasswordError = 'رمز عبور جدید الزامی است';
      } else if (value.length < 6) {
        _newPasswordError = 'رمز عبور حداقل 6 کاراکتر باید باشد';
      } else {
        _newPasswordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'تأیید رمز عبور الزامی است';
      } else if (value != _newPasswordController.text) {
        _confirmPasswordError = 'رمز عبور‌ها مطابقت ندارند';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _submit() async {
    _validateCurrentPassword(_currentPasswordController.text);
    _validateNewPassword(_newPasswordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    if (_currentPasswordError != null ||
        _newPasswordError != null ||
        _confirmPasswordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً تمام فیلدها را صحیح پر کنید')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ok = await ref
        .read(authControllerProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز عبور با موفقیت تغییر کرد')),
      );
      Navigator.pop(context);
    } else {
      final error = ref.read(authControllerProvider).errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'خطا در تغییر رمز عبور')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تغییر رمز عبور',
                  style: TextStyle(
                    fontFamily: 'iranSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _currentPasswordController,
                  onChanged: _validateCurrentPassword,
                  obscureText: !_showCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور فعلی',
                    errorText: _currentPasswordError,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Constants.primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Constants.primaryColor,
                      ),
                      onPressed: () => setState(
                        () => _showCurrentPassword = !_showCurrentPassword,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Constants.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  onChanged: (value) {
                    _validateNewPassword(value);
                    _validateConfirmPassword(_confirmPasswordController.text);
                  },
                  obscureText: !_showNewPassword,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور جدید',
                    errorText: _newPasswordError,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Constants.primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Constants.primaryColor,
                      ),
                      onPressed: () =>
                          setState(() => _showNewPassword = !_showNewPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Constants.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  onChanged: _validateConfirmPassword,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'تأیید رمز عبور',
                    errorText: _confirmPasswordError,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Constants.primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Constants.primaryColor,
                      ),
                      onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Constants.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'انصراف',
                          style: TextStyle(color: Constants.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'ذخیره',
                                style: TextStyle(
                                  fontFamily: 'iranSans',
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
