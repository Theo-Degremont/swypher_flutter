import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/record_music_controller.dart';

class RecordMusicView extends GetView<RecordMusicController> {
  const RecordMusicView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RecordMusicView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'RecordMusicView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
