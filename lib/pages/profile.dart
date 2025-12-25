import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:the_plant_app/const/constants.dart';
import 'package:the_plant_app/main.dart';
import 'package:the_plant_app/pages/auth/auth_page.dart';
import 'package:the_plant_app/providers/auth_providers.dart';
import 'package:the_plant_app/providers/user_providers.dart';
import 'package:the_plant_app/pages/edit_profile_page.dart';
import 'package:the_plant_app/pages/orders_page.dart';
import 'package:the_plant_app/pages/reset_password_dialog.dart';
import 'package:the_plant_app/pages/qr_generator_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final storedUserAsync = ref.watch(currentUserProvider);
    final user =
        authState.user ??
        storedUserAsync.maybeWhen(data: (u) => u, orElse: () => null);

    final avatarPath = ref.watch(avatarPathProvider);
    final avatarFile = (avatarPath != null && avatarPath.isNotEmpty)
        ? File(avatarPath)
        : null;

    final displayName = (user?.name.isNotEmpty ?? false) ? user!.name : 'کاربر';
    final email = user?.email ?? '---';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 145,
                        width: 145,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: avatarFile != null
                              ? FileImage(avatarFile)
                              : null,
                          child: avatarFile == null
                              ? Text(
                                  displayName.isNotEmpty
                                      ? displayName.characters.first
                                      : '?',
                                  style: const TextStyle(
                                    fontFamily: 'iranSans',
                                    fontSize: 42,
                                    color: Colors.black87,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: 8,
                        child: InkWell(
                          onTap: () async {
                            await _showAvatarSheet(
                              context,
                              ref,
                              hasAvatar: avatarFile != null,
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Constants.primaryColor,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 27,
                      child: Image.asset('assets/images/verified.png'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontFamily: 'iranSans',
                        fontSize: 20,
                        color: Constants.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                email,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast,
                    ),
                    children: [
                      _ProfileTile(
                        icon: Icons.person,
                        title: 'پروفایل‌من',
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: EditProfilePage(
                                currentName: user?.name ?? '',
                                currentEmail: user?.email ?? '',
                              ),
                              type: PageTransitionType.fade,
                            ),
                          );
                        },
                      ),
                      _ProfileTile(
                        icon: Icons.lock_reset,
                        title: 'تغییر رمز عبور',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const ResetPasswordDialog(),
                          );
                        },
                      ),
                      _ProfileTile(
                        icon: Icons.qr_code_2,
                        title: 'ساخت QR کد گیاهان',
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const QRGeneratorPage(),
                              type: PageTransitionType.fade,
                            ),
                          );
                        },
                      ),
                      _ProfileTile(
                        icon: Icons.receipt_long,
                        title: 'سفارش‌ها',
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const OrdersPage(),
                              type: PageTransitionType.fade,
                            ),
                          );
                        },
                      ),
                      _ProfileTile(
                        icon: Icons.exit_to_app_rounded,
                        title: 'خروج',
                        onTap: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
                          await saveAuthStatus(false);
                          isAuthenticated = false;
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                child: const AuthPage(),
                                type: PageTransitionType.fade,
                              ),
                              (route) => false,
                            );
                          }
                        },
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showAvatarSheet(
  BuildContext context,
  WidgetRef ref, {
  required bool hasAvatar,
}) async {
  final picker = ImagePicker();

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text(
                  'انتخاب از گالری',
                  style: TextStyle(fontFamily: 'iranSans'),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    await ref
                        .read(avatarPathProvider.notifier)
                        .setAvatar(picked.path);
                  }
                },
              ),
              ListTile(
                enabled: hasAvatar,
                leading: Icon(
                  Icons.delete_forever,
                  color: hasAvatar ? Colors.red : Colors.grey,
                ),
                title: Text(
                  'حذف تصویر پروفایل',
                  style: TextStyle(
                    fontFamily: 'iranSans',
                    color: hasAvatar ? null : Colors.grey,
                  ),
                ),
                onTap: !hasAvatar
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(avatarPathProvider.notifier)
                            .setAvatar(null);
                      },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.black87),
        minLeadingWidth: 10,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'iranSans',
            fontSize: 20,
            color: color ?? Constants.blackColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded),
        onTap: onTap,
      ),
    );
  }
}
