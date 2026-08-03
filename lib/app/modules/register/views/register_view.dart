import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/register/controllers/register_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_field.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: CustomPage(
        showNavBar: false,
        mainController: controller.mainController,
        showBackButton: true,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: AppColors.primaryTextColor,
                    letterSpacing: -0.5,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16.w, right: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.whiteColor.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppColors.whiteColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(
                      () => CustomField(
                        focusNode: controller.usernameFocusNode,
                        isFocused: controller.usernameIsFocused,
                        controller: controller.usernameController,
                        labelText: 'Nom d\'utilisateur',
                        hintText: 'Entrez votre nom d\'utilisateur',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        errorText: controller.usernameError.value,
                        onSubmitted: () => FocusScope.of(
                          context,
                        ).requestFocus(controller.emailFocusNode),
                      ),
                    ),
                    Obx(
                      () => CustomField(
                        focusNode: controller.emailFocusNode,
                        isFocused: controller.emailIsFocused,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        labelText: 'Email',
                        hintText: 'Entrez votre adresse email',
                        prefixIcon: Icons.email_outlined,
                        textInputAction: TextInputAction.next,
                        errorText: controller.emailError.value,
                        onSubmitted: () => FocusScope.of(
                          context,
                        ).requestFocus(controller.passwordFocusNode),
                      ),
                    ),
                    Obx(
                      () => CustomField(
                        focusNode: controller.passwordFocusNode,
                        isFocused: controller.passwordIsFocused,
                        controller: controller.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        height: 130,
                        labelText: 'Mot de passe',
                        hintText: 'Entrez votre mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !controller.isPasswordVisible.value,
                        showEyeIcon: true,
                        onTapEye: controller.togglePasswordVisibility,
                        textInputAction: TextInputAction.done,
                        errorText: controller.passwordError.value,
                        onSubmitted: () => FocusScope.of(context).unfocus(),
                      ),
                    ),
                    Obx(
                      () => CustomTextButton(
                        onPressed: controller.register,
                        text: 'Créer mon compte',
                        isLoading: controller.isLoading.value,
                        isEnabled: controller.isButtonEnabled.value,
                      ),

                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà un compte ?',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.secondaryTextColor,
                            letterSpacing: 0.5,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Connectez-vous',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primaryColor,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
