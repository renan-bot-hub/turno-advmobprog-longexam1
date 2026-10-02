import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import 'user_avatar.dart';

/// "What's on your mind?" card. Saves a local post and calls [onPosted].
class PostComposer extends StatefulWidget {
  final User user;
  final VoidCallback onPosted;

  const PostComposer({super.key, required this.user, required this.onPosted});

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final PostService _postService = PostService();
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await _postService.addLocalPost(body: body, userId: widget.user.id);
      _controller.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      setState(() => _isSubmitting = false);
      widget.onPosted();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save post')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPost = _controller.text.trim().isNotEmpty && !_isSubmitting;

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: UserAvatar(user: widget.user, radius: 20),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 14.sp, color: colors.onSurface),
              decoration: InputDecoration(
                hintText: "What's on your mind, ${widget.user.firstName}?",
                isDense: true,
                filled: true,
                fillColor: colors.onSurface.withValues(alpha: 0.05),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          IconButton.filled(
            tooltip: 'Post',
            onPressed: canPost ? _submit : null,
            style: IconButton.styleFrom(
              backgroundColor: FB_PRIMARY,
              disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.08),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: canPost
                        ? Colors.white
                        : colors.onSurface.withValues(alpha: 0.35),
                  ),
          ),
        ],
      ),
    );
  }
}
