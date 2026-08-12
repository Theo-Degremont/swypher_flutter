import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/data/models/comment_model.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/utils/auth_guard.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_field.dart';

class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({
    super.key,
    required this.musicId,
    required this.musicTitle,
  });

  final String musicId;
  final String musicTitle;

  static void show({required String musicId, required String musicTitle}) {
    Get.bottomSheet(
      CommentsBottomSheet(musicId: musicId, musicTitle: musicTitle),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorText;

  final _controller  = TextEditingController();
  final _focusNode   = FocusNode();
  late final ValueNotifier<bool> _isFocused;

  @override
  void initState() {
    super.initState();
    _isFocused = ValueNotifier(false);
    _focusNode.addListener(() => _isFocused.value = _focusNode.hasFocus);
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _isFocused.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final response = await Get.find<MusicApi>().getComments(widget.musicId);
    if (mounted) {
      setState(() {
        _comments = response.data ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    if (!requireAuth()) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (text.length > 500) {
      setState(() => _errorText = 'Maximum 500 caractères');
      return;
    }

    setState(() {
      _isSending = true;
      _errorText = null;
    });

    final response = await Get.find<MusicApi>().postComment(widget.musicId, text);

    if (!mounted) return;
    if (response.isSuccess && response.data != null) {
      _controller.clear();
      _focusNode.unfocus();
      setState(() {
        _comments.insert(0, response.data!);
        _isSending = false;
      });
    } else {
      setState(() {
        _errorText = response.errorMessage ?? 'Une erreur est survenue';
        _isSending = false;
      });
    }
  }

  String _formatDate(String iso) {
    try {
      final dt   = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'À l\'instant';
      if (diff.inHours   < 1) return 'Il y a ${diff.inMinutes} min';
      if (diff.inDays    < 1) return 'Il y a ${diff.inHours} h';
      if (diff.inDays   < 30) return 'Il y a ${diff.inDays} j';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight   = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Container(
          height: screenHeight * 0.70,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border(
              top: BorderSide(
                color: AppColors.whiteColor.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // ─── Handle ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // ─── Header ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commentaires',
                            style: TextStyle(
                              color: AppColors.primaryTextColor,
                              fontSize: 16.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.musicTitle,
                            style: TextStyle(
                              color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                              fontSize: 12.sp,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                        size: 22.w,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: AppColors.whiteColor.withValues(alpha: 0.07), height: 1),

              // ─── Liste ──────────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                            itemCount: _comments.length,
                            itemBuilder: (_, i) => _CommentTile(
                              comment: _comments[i],
                              date: _formatDate(_comments[i].createdAt),
                            ),
                          ),
              ),

              Divider(color: AppColors.whiteColor.withValues(alpha: 0.07), height: 1),

              // ─── Champ de saisie ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomField(
                        focusNode:   _focusNode,
                        isFocused:   _isFocused,
                        controller:  _controller,
                        labelText:   '',
                        hintText:    'Écrire un commentaire…',
                        isExpandable: true,
                        marginBottom: 0,
                        errorText:   _errorText,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendComment,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // ── Bouton envoyer ─────────────────────────────────────
                    GestureDetector(
                      onTap: _isSending ? null : _sendComment,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _isSending
                              ? null
                              : LinearGradient(
                                  colors: [
                                    AppColors.primaryLinearGradientStart,
                                    AppColors.primaryLinearGradientEnd,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: _isSending
                              ? AppColors.whiteColor.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: _isSending
                            ? Padding(
                                padding: EdgeInsets.all(12.w),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                color: AppColors.secondaryColor,
                                size: 20.w,
                              ),
                      ),
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primaryLinearGradientStart,
                AppColors.primaryLinearGradientEnd,
              ],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(Icons.chat_bubble_outline_rounded, size: 48.w, color: Colors.white),
          ),
          SizedBox(height: 16.h),
          Text(
            'Aucun commentaire pour le moment',
            style: TextStyle(
              color: AppColors.secondaryTextColor.withValues(alpha: 0.7),
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Sois le premier à réagir !',
            style: TextStyle(
              color: AppColors.secondaryTextColor.withValues(alpha: 0.4),
              fontSize: 12.sp,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile commentaire ───────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.date});

  final CommentModel comment;
  final String date;

  @override
  Widget build(BuildContext context) {
    final initials = comment.user.pseudo.isNotEmpty
        ? comment.user.pseudo[0].toUpperCase()
        : '?';

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Avatar ───────────────────────────────────────────────────
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLinearGradientStart.withValues(alpha: 0.6),
                  AppColors.primaryLinearGradientEnd.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: comment.user.profilePicture != null
                ? ClipOval(
                    child: Image.network(
                      comment.user.profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _initial(initials),
                    ),
                  )
                : _initial(initials),
          ),

          SizedBox(width: 12.w),

          // ─── Contenu ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.user.pseudo,
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: 13.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppColors.secondaryTextColor.withValues(alpha: 0.4),
                        fontSize: 11.sp,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: AppColors.secondaryTextColor.withValues(alpha: 0.85),
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initial(String letter) {
    return Center(
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
