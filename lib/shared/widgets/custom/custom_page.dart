import 'package:flutter/material.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_app_bar.dart';

class CustomPage extends StatelessWidget {
  const CustomPage({
    super.key,
    this.showBackButton = false,
    });

  final bool showBackButton;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        Expanded(
          flex: 12,
          child: CustomAppBar(
            showBackButton: showBackButton,
          ),
        ),
        Expanded(
          flex: 78,
          child: Container(
            child: const Center(
              child: Text('Custom Page'),
            ),
          ),
        ),
      Expanded(
          flex: 10,
          child: Container(
            color: Colors.white,
            child: const Center(
              child: Text('Custom Page'),
            ),
          ),
        ),
      ],)
    );
  }
}