import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_icon_button.dart';

// ─── Equalizer bars animées ──────────────────────────────────────────────────

/// Trois barres verticales qui ondulent en déphasage quand [isPlaying] est true.
class EqualizerBarsWidget extends StatefulWidget {
  const EqualizerBarsWidget({
    super.key,
    required this.isPlaying,
    this.barColor,
    this.barWidth,
    this.maxHeight,
  });

  final bool isPlaying;
  final Color? barColor;
  final double? barWidth;
  final double? maxHeight;

  @override
  State<EqualizerBarsWidget> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBarsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isPlaying) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(EqualizerBarsWidget old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color     = widget.barColor  ?? AppColors.primaryColor;
    final barW      = widget.barWidth  ?? 3.w;
    final maxH      = widget.maxHeight ?? 16.w;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value * 2 * math.pi;
        // 3 barres déphasées de 2π/3 (~120°) chacune.
        final heights = [
          (math.sin(t)                       * 0.4 + 0.6).clamp(0.15, 1.0),
          (math.sin(t + 2 * math.pi / 3)     * 0.4 + 0.6).clamp(0.15, 1.0),
          (math.sin(t + 4 * math.pi / 3)     * 0.4 + 0.6).clamp(0.15, 1.0),
        ];

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) => Padding(
            padding: EdgeInsets.only(right: i < 2 ? 2.w : 0),
            child: Container(
              width: barW,
              height: maxH * heights[i],
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        );
      },
    );
  }
}

// ─── Mini-player bas ─────────────────────────────────────────────────────────

class BottomListenMusicWidget extends StatelessWidget {
  const BottomListenMusicWidget({
    super.key,
    required this.music,
    required this.coverUrl,
    required this.onTogglePlay,
    required this.formatDuration,
  });

  final MusicModel music;
  final String? coverUrl;
  final VoidCallback onTogglePlay;
  final String Function(int?) formatDuration;

  @override
  Widget build(BuildContext context) {
    final audio = AudioService.to;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 85.h,
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiaryColor.withValues(alpha: 0.1),
              blurRadius: 20.0,
              offset: const Offset(0, 0),
            ),
          ],
          color: const Color(0xFF251A31),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.whiteColor.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // ── Equalizer animé ────────────────────────────────────────
            Obx(() => EqualizerBarsWidget(
              isPlaying: audio.isPlayingRx(AudioType.music).value,
            )),

            SizedBox(width: 10.w),

            // ── Bouton pause/play ──────────────────────────────────────
            Obx(() => CustomIconButton(
              icon: audio.isPlayingRx(AudioType.music).value
                  ? Icons.pause_sharp
                  : Icons.play_arrow_sharp,
              iconSize: 30.w,
              onPressed: onTogglePlay,
            )),

            SizedBox(width: 10.w),

            // ── Infos ──────────────────────────────────────────────────
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    music.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: AppFonts.montserrat,
                      letterSpacing: 0,
                      fontWeight: FontWeight.normal,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      if ((music.beatmakerName ?? '').isNotEmpty)
                        Text(
                          music.beatmakerName!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppFonts.montserrat,
                            letterSpacing: 1,
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      if ((music.beatmakerName ?? '').isNotEmpty &&
                          formatDuration(music.duration).isNotEmpty) ...[
                        SizedBox(width: 5.w),
                        Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryTextColor
                                .withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                      ],
                      if (formatDuration(music.duration).isNotEmpty)
                        Obx(() {
                          final pos = audio.positionRx(AudioType.music).value;
                          return Text(
                            '${_fmt(pos)} / ${formatDuration(music.duration)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppFonts.montserrat,
                              letterSpacing: 1,
                              fontWeight: FontWeight.normal,
                              color: AppColors.secondaryTextColor,
                            ),
                          );
                        }),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 10.w),

            // ── Pochette ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: coverUrl != null
                  ? Image.network(
                      coverUrl!,
                      width: 45.w,
                      height: 45.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverFallback(),
                    )
                  : _coverFallback(),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _coverFallback() => Container(
    width: 45.w,
    height: 45.w,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryLinearGradientStart,
          AppColors.primaryLinearGradientEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Icon(
      Icons.music_note_sharp,
      color: AppColors.secondaryColor,
      size: 22.w,
    ),
  );
}
