import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/main.dart';
import 'package:the_plant_app/pages/root.dart';
import 'package:the_plant_app/providers/auth_providers.dart';
import 'package:the_plant_app/pages/forgot_password_dialog.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _autoValidate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
      _autoValidate = false;
    });
    _formKey.currentState?.reset();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    setState(() {
      _autoValidate = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final controller = ref.read(authControllerProvider.notifier);

    bool ok;
    if (_isLogin) {
      ok = await controller.login(email: email, password: password);
    } else {
      ok = await controller.register(
        name: name,
        email: email,
        password: password,
      );
    }

    if (!ok) return;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        _showSnack(next.errorMessage!);
      }

      if (next.isAuthenticated) {
        saveAuthStatus(true);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageTransition(
              child: const RootPage(),
              type: PageTransitionType.fade,
            ),
          );
        }
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'به گیاه شاپ خوش آمدید',
                    style: TextStyle(
                      fontFamily: 'iranSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Constants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'برای دیدن محصولات وارد شوید'
                        : 'ایجاد حساب جدید برای شروع خرید',
                    style: const TextStyle(
                      fontFamily: 'iranSans',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff7f7f7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Constants.primaryColor,
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _toggleMode(false),
                            style: TextButton.styleFrom(
                              backgroundColor: !_isLogin
                                  ? Constants.primaryColor
                                  : Colors.transparent,
                              foregroundColor: !_isLogin
                                  ? Colors.white
                                  : Constants.primaryColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'ثبت نام',
                                style: TextStyle(
                                  fontFamily: 'iranSans',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => _toggleMode(true),
                            style: TextButton.styleFrom(
                              backgroundColor: _isLogin
                                  ? Constants.primaryColor
                                  : Colors.transparent,
                              foregroundColor: _isLogin
                                  ? Colors.white
                                  : Constants.primaryColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'ورود',
                                style: TextStyle(
                                  fontFamily: 'iranSans',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: Constants.primaryColor),
                      decoration: InputDecoration(
                        labelText: 'نام و نام خانوادگی',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Constants.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Constants.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'نام الزامی است';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Constants.primaryColor),
                    decoration: InputDecoration(
                      labelText: 'ایمیل',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Constants.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Constants.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      return ref
                          .read(authControllerProvider.notifier)
                          .validateEmail(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Constants.primaryColor),
                    decoration: InputDecoration(
                      labelText: 'رمز عبور',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Constants.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Constants.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      return ref
                          .read(authControllerProvider.notifier)
                          .validatePassword(value ?? '');
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? 'ورود به حساب' : 'ایجاد حساب',
                              style: const TextStyle(
                                fontFamily: 'iranSans',
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),

                  // Forgot Password Link (only show in login mode)
                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const ForgotPasswordDialog(),
                          );
                        },
                        child: Text(
                          'رمز عبور را فراموش کرده‌اید؟',
                          style: TextStyle(
                            fontFamily: 'iranSans',
                            fontSize: 14,
                            color: Constants.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'ورود به معنای پذیرش قوانین و حریم خصوصی است',
                          style: TextStyle(
                            fontFamily: 'iranSans',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _toggleMode(!_isLogin),
                          child: Text(
                            _isLogin
                                ? 'حساب کاربری نداری؟ ثبت نام'
                                : 'حساب داری؟ ورود',
                            style: TextStyle(
                              fontFamily: 'iranSans',
                              fontSize: 15,
                              color: Constants.primaryColor,
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
      ),
    );
  }
}
