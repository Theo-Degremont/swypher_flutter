import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/widgets/music_card_widget.dart';
import '../controllers/single_music_controller.dart';

class SingleMusicView extends GetView<SingleMusicController> {
  const SingleMusicView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      mainController: controller.mainController,
      showBackButton: true,
      showBottomListenMusic: false,
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final queue = AudioService.to.currentQueueObs;
              if (queue.isEmpty) return const SizedBox.shrink();
              return PageView.builder(
                controller: controller.pageController,
                scrollDirection: Axis.vertical,
                itemCount: queue.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (_, index) => MusicCardWidget(music: queue[index], topMargin: 30),
              );
            }),
          ),
        ],
      ),
    );
  }
}
