import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchPageController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Search', style: TextStyle(color: AppColors.primaryTextColor)),
    );
  }
}
