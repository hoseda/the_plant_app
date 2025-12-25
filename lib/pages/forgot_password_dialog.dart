import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/providers/database_providers.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  ConsumerState<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _showPasswordFields = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String? _emailError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'ایمیل الزامی است';
      } else {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          _emailError = 'فرمت ایمیل نامعتبر است';
        } else {
          _emailError = null;
        }
      }
    });
  }

  void _validateNewPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _newPasswordError = 'رمز عبور جدید الزامی است';
      } else if (value.length < 6) {
        _newPasswordError = 'رمز عبور حداقل ۶ کاراکتر باید باشد';
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

  Future<void> _verifyEmail() async {
    _validateEmail(_emailController.text);

    if (_emailError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(appDatabaseProvider);
      final user = await db.getUserByEmail(_emailController.text.trim());

      setState(() => _isLoading = false);

      if (user == null) {
        setState(() {
          _emailError = 'کاربری با این ایمیل یافت نشد';
        });
      } else {
        setState(() {
          _showPasswordFields = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ایمیل تأیید شد. رمز عبور جدید را وارد کنید'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    }
  }

  Future<void> _resetPassword() async {
    _validateNewPassword(_newPasswordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    if (_newPasswordError != null || _confirmPasswordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(appDatabaseProvider);
      final user = await db.getUserByEmail(_emailController.text.trim());

      if (user != null) {
        final success = await db.updateUser(
          id: user.id,
          password: _newPasswordController.text,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رمز عبور با موفقیت بازنشانی شد'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطا در بازنشانی رمز عبور'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_reset,
                      color: Constants.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'فراموشی رمز عبور',
                      style: TextStyle(
                        fontFamily: 'iranSans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _showPasswordFields
                      ? 'رمز عبور جدید خود را وارد کنید'
                      : 'ایمیل خود را وارد کنید',
                  style: const TextStyle(
                    fontFamily: 'iranSans',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Email Field
                TextField(
                  controller: _emailController,
                  enabled: !_showPasswordFields,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'ایمیل',
                    errorText: _emailError,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Constants.primaryColor,
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

                if (_showPasswordFields) ...[
                  const SizedBox(height: 16),

                  // New Password Field
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
                        onPressed: () => setState(
                          () => _showNewPassword = !_showNewPassword,
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

                  // Confirm Password Field
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
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'انصراف',
                          style: TextStyle(
                            fontFamily: 'iranSans',
                            color: Constants.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_showPasswordFields
                                  ? _resetPassword
                                  : _verifyEmail),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                            : Text(
                                _showPasswordFields ? 'بازنشانی' : 'ادامه',
                                style: const TextStyle(
                                  fontFamily: 'iranSans',
                                  color: Colors.white,
                                  fontSize: 16,
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
