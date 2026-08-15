import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/settings/controllers/settings_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';

class CguView extends GetView<SettingsController> {
  const CguView({super.key});

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
            'Conditions Générales d\'Utilisation',
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
            title: '1. Objet',
            body:
                'Les présentes Conditions Générales d\'Utilisation (CGU) régissent l\'accès et '
                'l\'utilisation de l\'application Swypher, plateforme de création, partage et '
                'découverte de musique originale. En utilisant Swypher, vous acceptez sans réserve '
                'les présentes CGU.',
          ),

          const _Section(
            title: '2. Accès à l\'application',
            body:
                'L\'utilisation de Swypher est réservée aux personnes âgées d\'au moins 13 ans. '
                'En créant un compte, vous confirmez avoir atteint cet âge minimum. L\'accès à '
                'certaines fonctionnalités est conditionné à la création d\'un compte utilisateur.',
          ),

          const _Section(
            title: '3. Contenu original — Obligation absolue',
            body:
                'Swypher est une plateforme dédiée exclusivement aux créations musicales originales.\n\n'
                'Il est strictement interdit de :\n'
                '• Publier des productions (beats, instrumentales, samples) ou des extraits issus '
                'de musiques existantes protégées par le droit d\'auteur, qu\'elles soient '
                'commerciales ou non ;\n'
                '• Réutiliser des boucles, des sons ou des mélodies provenant d\'œuvres tierces '
                'sans avoir obtenu au préalable les droits nécessaires ;\n'
                '• Déposer du contenu audio dont vous ne détenez pas tous les droits de propriété '
                'intellectuelle.\n\n'
                'Tout contenu portant atteinte aux droits d\'auteur sera supprimé sans préavis et '
                'pourra entraîner la suspension ou la suppression définitive du compte concerné.',
          ),

          const _Section(
            title: '4. Responsabilité de l\'utilisateur',
            body:
                'Vous êtes seul responsable du contenu que vous publiez sur Swypher. '
                'Vous garantissez que :\n'
                '• Vous êtes l\'auteur ou le titulaire des droits sur chaque production mise en ligne ;\n'
                '• Votre contenu ne porte atteinte à aucun droit de tiers (droit d\'auteur, '
                'droit à l\'image, marques, etc.) ;\n'
                '• Votre contenu ne contient aucun élément illicite, diffamatoire, haineux ou '
                'à caractère violent.',
          ),

          const _Section(
            title: '5. Comportement des utilisateurs',
            body:
                'Sur Swypher, il est interdit de :\n'
                '• Harceler, menacer ou intimider d\'autres utilisateurs ;\n'
                '• Publier du contenu discriminatoire fondé sur l\'origine, le genre, la religion, '
                'l\'orientation sexuelle ou tout autre critère protégé par la loi ;\n'
                '• Utiliser l\'application à des fins commerciales non autorisées ou pour envoyer '
                'des communications non sollicitées (spam) ;\n'
                '• Tenter de contourner les mécanismes de sécurité de la plateforme ou d\'y '
                'accéder de manière non autorisée.',
          ),

          const _Section(
            title: '6. Modération et sanctions',
            body:
                'Swypher se réserve le droit de supprimer tout contenu qui ne respecterait pas '
                'les présentes CGU, sans préavis et sans obligation de justification. En cas de '
                'manquement grave ou répété, le compte de l\'utilisateur pourra être suspendu ou '
                'définitivement supprimé.',
          ),

          const _Section(
            title: '7. Propriété intellectuelle',
            body:
                'Les éléments constitutifs de l\'application Swypher (logo, interface, '
                'fonctionnalités, code source) sont la propriété exclusive de leurs auteurs et '
                'sont protégés par le droit de la propriété intellectuelle. Toute reproduction '
                'ou exploitation non autorisée est interdite.',
          ),

          const _Section(
            title: '8. Modification des CGU',
            body:
                'Swypher se réserve le droit de modifier les présentes CGU à tout moment. '
                'Les utilisateurs seront informés des changements importants via une notification '
                'dans l\'application. La poursuite de l\'utilisation de l\'application vaut '
                'acceptation des nouvelles conditions.',
          ),

          const _Section(
            title: '9. Contact',
            body:
                'Pour toute question relative aux présentes CGU, vous pouvez nous contacter à '
                'l\'adresse suivante : theodegremontdev@gmail.com',
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
