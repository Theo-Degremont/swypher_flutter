import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/settings/controllers/settings_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';

class PrivacyPolicyView extends GetView<SettingsController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      mainController: controller.mainController,
      showBackButton: true,
      showNavBar: false,
      showBottomListenMusic: false,
      showSettingsButton: false,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
        children: [
          Text(
            'Politique de confidentialité',
            style: TextStyle(
              fontSize: 22.sp,
              color: AppColors.primaryTextColor,
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Dernière mise à jour : juillet 2025',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.secondaryTextColor,
              fontFamily: AppFonts.montserrat,
            ),
          ),
          SizedBox(height: 28.h),

          const _Section(
            title: '1. Introduction',
            body:
                'La présente Politique de confidentialité décrit la manière dont Swypher collecte, '
                'utilise et protège les données personnelles des utilisateurs de l\'application. '
                'En utilisant Swypher, vous acceptez les pratiques décrites ci-dessous.',
          ),

          const _Section(
            title: '2. Données collectées',
            body:
                'Lors de la création de votre compte et de l\'utilisation de l\'application, '
                'nous collectons les données suivantes :\n'
                '• Informations de compte : adresse e-mail, pseudo, nom de scène (stage name) '
                'et description de profil ;\n'
                '• Contenus publiés : fichiers audio, titres et visuels des musiques mises en ligne ;\n'
                '• Données d\'interaction : musiques aimées (likes), musiques repostées et '
                'historique d\'écoute ;\n'
                '• Données techniques : identifiants de session (access token, refresh token) '
                'nécessaires à l\'authentification.',
          ),

          const _Section(
            title: '3. Utilisation des données',
            body:
                'Les données collectées sont utilisées exclusivement pour :\n'
                '• Fournir et améliorer les fonctionnalités de l\'application ;\n'
                '• Personnaliser votre expérience (recommandations, bibliothèque personnelle) ;\n'
                '• Assurer la sécurité de votre compte et prévenir les usages frauduleux ;\n'
                '• Vous permettre de partager vos créations musicales avec la communauté Swypher.',
          ),

          const _Section(
            title: '4. Partage des données',
            body:
                'Swypher ne vend, ne loue et ne cède en aucun cas vos données personnelles à '
                'des tiers à des fins commerciales. Vos données peuvent être partagées uniquement '
                'dans les cas suivants :\n'
                '• Avec les prestataires techniques qui assurent l\'hébergement et le bon '
                'fonctionnement de la plateforme, dans le strict respect de la confidentialité ;\n'
                '• Si la loi l\'exige ou dans le cadre d\'une procédure judiciaire.',
          ),

          const _Section(
            title: '5. Conservation des données',
            body:
                'Vos données personnelles sont conservées aussi longtemps que votre compte est '
                'actif. En cas de suppression de votre compte, l\'ensemble de vos données '
                '(profil, musiques, interactions) est définitivement supprimé de nos serveurs '
                'dans un délai maximum de 30 jours.',
          ),

          const _Section(
            title: '6. Sécurité des données',
            body:
                'Nous mettons en œuvre des mesures techniques et organisationnelles adaptées '
                'pour protéger vos données contre tout accès non autorisé, toute divulgation ou '
                'toute altération. L\'accès à votre compte est sécurisé par un système '
                'd\'authentification par tokens (access token / refresh token).',
          ),

          const _Section(
            title: '7. Vos droits',
            body:
                'Conformément à la réglementation applicable, vous disposez des droits suivants '
                'sur vos données personnelles :\n'
                '• Droit d\'accès : vous pouvez consulter les données associées à votre compte '
                'depuis votre profil ;\n'
                '• Droit de rectification : vous pouvez modifier votre pseudo, votre nom de '
                'scène et votre description à tout moment ;\n'
                '• Droit à l\'effacement : vous pouvez supprimer définitivement votre compte '
                'et toutes vos données depuis les paramètres de l\'application.\n\n'
                'Pour exercer ces droits ou pour toute question, contactez-nous à l\'adresse '
                'ci-dessous.',
          ),

          const _Section(
            title: '8. Cookies et traceurs',
            body:
                'Swypher n\'utilise pas de cookies de traçage publicitaire. Les seules données '
                'stockées localement sur votre appareil sont celles nécessaires au fonctionnement '
                'de l\'application (session d\'authentification, préférences de langue).',
          ),

          const _Section(
            title: '9. Modifications de la politique',
            body:
                'Swypher se réserve le droit de mettre à jour la présente politique à tout '
                'moment. Toute modification significative vous sera notifiée via l\'application. '
                'La date de dernière mise à jour est indiquée en haut de ce document.',
          ),

          const _Section(
            title: '10. Contact',
            body:
                'Pour toute question relative à la présente politique ou à vos données '
                'personnelles, vous pouvez nous contacter à l\'adresse suivante :\n'
                'theodegremontdev@gmail.com',
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.primaryColor,
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primaryTextColor,
              fontFamily: AppFonts.montserrat,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
