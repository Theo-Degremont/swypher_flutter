import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/settings/controllers/settings_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_field.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';

class UpdatePasswordView extends GetView<SettingsController> {
  const UpdatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      mainController: controller.mainController,
      showBackButton: true,
      showNavBar: false,
      showBottomListenMusic: false,
      showSettingsButton: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 30.h,
                  bottom: 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      tkTitleUpdatePassword.tr,
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: AppColors.primaryTextColor,
                        letterSpacing: -0.5,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    Obx(() => CustomField(
                      focusNode: controller.currentPasswordFocus,
                      isFocused: controller.currentPasswordFocused,
                      controller: controller.currentPasswordCtrl,
                      labelText: tkLabelCurrentPassword.tr,
                      hintText: '••••••••',
                      obscureText: controller.obscureCurrentPassword.value,
                      showEyeIcon: true,
                      onTapEye: () => controller.obscureCurrentPassword.toggle(),
                      errorText: controller.currentPasswordError.value,
                      textInputAction: TextInputAction.next,
                      onSubmitted: () => controller.newPasswordFocus.requestFocus(),
                    )),

                    // ── Nouveau mot de passe ────────────────────────────────
                    Obx(() => CustomField(
                      focusNode: controller.newPasswordFocus,
                      isFocused: controller.newPasswordFocused,
                      controller: controller.newPasswordCtrl,
                      labelText: tkLabelNewPassword.tr,
                      hintText: '••••••••',
                      obscureText: controller.obscureNewPassword.value,
                      showEyeIcon: true,
                      onTapEye: () => controller.obscureNewPassword.toggle(),
                      errorText: controller.newPasswordError.value,
                      textInputAction: TextInputAction.next,
                      onSubmitted: () => controller.confirmPasswordFocus.requestFocus(),
                    )),

                    // ── Confirmation mot de passe ───────────────────────────
                    Obx(() => CustomField(
                      focusNode: controller.confirmPasswordFocus,
                      isFocused: controller.confirmPasswordFocused,
                      controller: controller.confirmPasswordCtrl,
                      labelText: tkLabelConfirmPassword.tr,
                      hintText: '••••••••',
                      obscureText: controller.obscureConfirmPassword.value,
                      showEyeIcon: true,
                      onTapEye: () => controller.obscureConfirmPassword.toggle(),
                      errorText: controller.confirmPasswordError.value,
                      textInputAction: TextInputAction.done,
                      onSubmitted: controller.updatePassword,
                    )),
                  ],
                ),
              ),
            ),

            // ── Bouton (toujours visible en bas) ─────────────────────────────
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Obx(() => CustomTextButton(
                onPressed: controller.updatePassword,
                isLoading: controller.isUpdatingPassword.value,
                text: tkBtnUpdatePassword.tr,
                borderRadius: 50,
              )),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

