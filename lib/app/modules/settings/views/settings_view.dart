import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';
import 'package:swypher_flutter/shared/widgets/modals/delete_account_modal.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      mainController: controller.mainController,
      showBackButton: true,
      showNavBar: false,
      showBottomListenMusic: false,
      showSettingsButton: false,
      body: Obx(() {
        final isLoggedIn = controller.isLoggedIn;
        final localPath  = controller.memory.localAvatarPath;

        Widget defaultAvatar() => Container(
          color: AppColors.primaryLinearGradientStart.withValues(alpha: 0.3),
          child: Icon(Icons.person_sharp, size: 50.sp, color: AppColors.secondaryColor),
        );

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.h),
          children: [

            // ── Bloc Profil (connecté uniquement) ────────────────────────────
            if (isLoggedIn) ...[
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLinearGradientStart,
                            AppColors.primaryLinearGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipOval(
                        child: localPath != null
                            ? Image.file(File(localPath), fit: BoxFit.cover,
                                errorBuilder: (_, e, s) => defaultAvatar())
                            : defaultAvatar(),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.memory.currentUser?.stageName ?? '',
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          controller.memory.currentUser?.pseudo ?? '',
                          style: TextStyle(
                            color: AppColors.secondaryTextColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              _SectionLabel(tkSettingsSectionAccount.tr),
              SizedBox(height: 8.h),
              _SettingsCard(children: [
                _SettingsRow(
                  icon: Icons.lock_outline_sharp,
                  label: tkSettingsChangePassword.tr,
                  trailing: Icon(Icons.arrow_forward_ios, color: AppColors.secondaryTextColor, size: 16.sp),
                  onTap: () => controller.goToUpdatePassword(),
                ),
              ]),
              SizedBox(height: 20.h),
            ],

            _SectionLabel(tkSettingsSectionPreferences.tr),
            SizedBox(height: 8.h),
            _SettingsCard(children: [
              // Notifications
              Obx(() => _SettingsRow(
                icon: Icons.notifications_none_sharp,
                label: tkSettingsNotifications.tr,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.notificationsEnabled.value ? tkOn.tr : tkOff.tr,
                      style: TextStyle(
                        color: AppColors.secondaryTextColor,
                        fontSize: 14.sp,
                        fontFamily: AppFonts.montserrat,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      controller.notificationsEnabled.value
                          ? Icons.toggle_on_sharp
                          : Icons.toggle_off_sharp,
                      color: controller.notificationsEnabled.value
                          ? AppColors.primaryColor
                          : AppColors.secondaryTextColor,
                      size: 28.sp,
                    ),
                  ],
                ),
                onTap: controller.toggleNotifications,
              )),

              _Divider(),

              Obx(() {
                final expanded = controller.languageExpanded.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SettingsRow(
                      icon: Icons.language_sharp,
                      label: controller.currentLanguageName,
                      trailing: Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_sharp
                            : Icons.keyboard_arrow_down_sharp,
                        color: AppColors.secondaryTextColor,
                        size: 24.sp,
                      ),
                      onTap: controller.toggleLanguageExpanded,
                    ),
                    if (expanded) ...[
                      _Divider(),
                      _LanguageOption(
                        label: tkLangFrench.tr,
                        selected: (controller.memory.languageCode ?? 'fr') == 'fr',
                        onTap: () => controller.setLanguage('fr'),
                      ),
                      _Divider(),
                      _LanguageOption(
                        label: tkLangEnglish.tr,
                        selected: controller.memory.languageCode == 'en',
                        onTap: () => controller.setLanguage('en'),
                      ),
                    ],
                  ],
                );
              }),
            ]),
            SizedBox(height: 20.h),

            _SectionLabel(tkSettingsSectionPrivacy.tr),
            SizedBox(height: 8.h),
            _SettingsCard(children: [
              _SettingsRow(
                icon: Icons.privacy_tip_sharp,
                label: tkSettingsPrivacyPolicy.tr,
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.secondaryTextColor, size: 16.sp),
                onTap: () => controller.goToPrivacyPolicy(),
              ),
              _Divider(),
              _SettingsRow(
                icon: Icons.security_sharp,
                label: tkSettingsCgu.tr,
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.secondaryTextColor, size: 16.sp),
                onTap: () => controller.goToCgu(),
              ),
            ]),
            SizedBox(height: 20.h),

            _SectionLabel(tkSettingsSectionSupport.tr),
            SizedBox(height: 8.h),
            _SettingsCard(children: [
              _SettingsRow(
                icon: Icons.help_outline_sharp,
                label: tkSettingsHelpCenter.tr,
                trailing: Icon(Icons.launch_sharp, color: AppColors.secondaryTextColor, size: 20.sp),
                onTap: controller.openHelpEmail,
              ),
              _Divider(),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_sharp, color: AppColors.primaryColor, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(tkVersion.tr, style: TextStyle(
                          color: AppColors.primaryTextColor,
                          fontSize: 16.sp,
                          fontFamily: AppFonts.montserrat,
                        )),
                      ],
                    ),
                    Text('1.0.0', style: TextStyle(
                      color: AppColors.secondaryTextColor,
                      fontSize: 14.sp,
                      fontFamily: AppFonts.montserrat,
                    )),
                  ],
                ),
              ),
            ]),

            if (isLoggedIn) ...[
              SizedBox(height: 20.h),
              Obx(() => CustomTextButton(
                text: tkBtnLogout.tr,
                onPressed: controller.logout,
                isLoading: controller.isLoading.value,
                icon: Icons.logout,
                haveBorder: true,
                showShadow: false,
                height: 70.h,
                iconColor: AppColors.tertiaryColor,
                textColor: AppColors.tertiaryColor,
                primaryGradientColor: AppColors.quinaryColor.withValues(alpha: 0.2),
                secondaryGradientColor: AppColors.quinaryColor.withValues(alpha: 0.2),
              )),
              SizedBox(height: 20.h),
              CustomTextButton(
                text: tkBtnDeleteAccount.tr,
                onPressed: () => DeleteAccountModal.show(
                  onConfirm: controller.deleteAccount,
                ),
                icon: Icons.delete_forever_sharp,
                haveBorder: true,
                showShadow: false,
                height: 70.h,
                iconColor: AppColors.tertiaryColor,
                textColor: AppColors.tertiaryColor,
                primaryGradientColor: AppColors.quinaryColor.withValues(alpha: 0.2),
                secondaryGradientColor: AppColors.quinaryColor.withValues(alpha: 0.2),
              ),
            ],

            SizedBox(height: 20.h),
          ],
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: 8.w),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.primaryTextColor,
        fontSize: 14.sp,
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.whiteColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.1)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(label, style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 16.sp,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.normal,
              )),
            ],
          ),
          trailing,
        ],
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    height: 1,
    color: AppColors.whiteColor.withValues(alpha: 0.1),
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: selected ? AppColors.primaryColor : AppColors.primaryTextColor,
            fontSize: 15.sp,
            fontFamily: AppFonts.montserrat,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          )),
          if (selected)
            Icon(Icons.check_sharp, color: AppColors.primaryColor, size: 18.sp),
        ],
      ),
    ),
  );
}
