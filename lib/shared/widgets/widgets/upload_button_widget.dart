import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class UploadButtonWidget extends StatefulWidget {
  const UploadButtonWidget({
    super.key,
    required this.fileName,
    required this.onTap,
    required this.onRemove,
  });

  final String? fileName;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<UploadButtonWidget> createState() => _UploadButtonWidgetState();
}

class _UploadButtonWidgetState extends State<UploadButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.fileName != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!hasFile) widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.whiteColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.quinaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFile ? Icons.audio_file_outlined : Icons.file_upload_outlined,
                  color: AppColors.tertiaryColor,
                  size: 30.w,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: hasFile
                    ? Text(
                        widget.fileName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.primaryTextColor,
                          letterSpacing: 0.5,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajouter un fichier audio',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primaryTextColor,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'MP3, WAV, OGG, FLAC, M4A, AAC, WebM',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.secondaryTextColor,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
              ),
              if (hasFile)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: Icon(
                      Icons.close,
                      color: AppColors.secondaryTextColor,
                      size: 20.w,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
