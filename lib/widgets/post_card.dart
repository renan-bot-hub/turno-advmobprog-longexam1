import 'avatar_image.dart';
import 'custom_inkwell_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import 'custom_font.dart';
import '../screens/detail_screen.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/post_service.dart';

class PostCard extends StatefulWidget {
  final String userName;
  final String postContent;
  final String date;
  final String avatar, image, commentAvatar;
  final int numOfLikes, numOfComments, numOfShares;
  final bool hasImage, hasAvatar, hasCommentAvatar, isAds;
  final String adsMarket;
  final int postId;
  final int commentUserId;
  final String commentUsername, commentFullName;

  const PostCard({
    super.key,
    required this.userName,
    required this.postContent,
    required this.date,
    this.avatar = '',
    required this.hasImage,
    required this.hasAvatar,
    this.image = '',
    this.numOfLikes = 0,
    this.numOfComments = 0,
    this.numOfShares = 0,
    this.adsMarket = '',
    this.isAds = false,
    this.commentAvatar = '',
    this.hasCommentAvatar = false,
    this.commentUsername = 'user',
    this.commentFullName = 'User',
    required this.postId,
    this.commentUserId = 1,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int likes;
  bool liked = false;

  final CommentService commentService = CommentService();
  final PostService postService = PostService();
  late Future<List<Comment>> commentsFuture;

  @override
  void initState() {
    super.initState();

    likes = widget.numOfLikes;
    commentsFuture = commentService.getCommentsByPost(widget.postId);
    _loadLikeState();
  }

  Future<void> _loadLikeState() async {
    final state = await postService.getLikeState(
      postId: widget.postId,
      userId: widget.commentUserId,
      baseCount: widget.numOfLikes,
    );
    if (!mounted) return;
    setState(() {
      likes = state.count;
      liked = state.liked;
    });
  }

  Future<void> _toggleLike() async {
    final state = await postService.toggleLike(
      postId: widget.postId,
      userId: widget.commentUserId,
      baseCount: widget.numOfLikes,
    );
    if (!mounted) return;
    setState(() {
      likes = state.count;
      liked = state.liked;
    });
  }

  Future<void> _openDetail() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          userName: widget.userName,
          postContent: widget.postContent,
          date: widget.date,
          avatar: widget.avatar,
          hasImage: widget.hasImage,
          image: widget.image,
          hasAvatar: widget.hasAvatar,
          numOfLikes: widget.numOfLikes,
          hasLiked: liked,
          postId: widget.postId,
          commentUserId: widget.commentUserId,
          commentAvatar: widget.commentAvatar,
          commentUsername: widget.commentUsername,
          commentFullName: widget.commentFullName,
        ),
      ),
    );
    if (!mounted) return;
    commentsFuture = commentService.getCommentsByPost(widget.postId);
    await _loadLikeState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: _openDetail,
      child: Card(
        color: colors.surface,
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (widget.hasAvatar)
                      ? CircleAvatar(
                          backgroundColor: theme.scaffoldBackgroundColor,
                          radius: 18,
                          backgroundImage: avatarImage(widget.avatar),
                        )
                      : CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          child: Icon(
                            Icons.person,
                            size: ScreenUtil().setSp(22),
                            color: Colors.grey,
                          ),
                        ),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFont(
                          text: widget.userName,
                          fontSize: ScreenUtil().setSp(15),
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: CustomFont(
                                text: widget.date,
                                fontSize: ScreenUtil().setSp(12),
                                color: Colors.grey,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(3)),
                            Icon(
                              Icons.public,
                              color: Colors.grey,
                              size: ScreenUtil().setSp(12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.grey),
                ],
              ),

              SizedBox(height: ScreenUtil().setHeight(10)),

              CustomFont(
                text: widget.postContent,
                fontSize: ScreenUtil().setSp(14),
                color: colors.onSurface,
              ),

              SizedBox(height: ScreenUtil().setHeight(5)),

              widget.hasImage
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: double.infinity,
                        maxHeight: widget.isAds
                            ? ScreenUtil().setHeight(146)
                            : ScreenUtil().setHeight(350),
                      ),
                      child: Image.asset(widget.image, fit: BoxFit.cover),
                    )
                  : SizedBox(height: ScreenUtil().setHeight(1)),

              SizedBox(height: ScreenUtil().setHeight(5)),

              (widget.adsMarket != '')
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: ScreenUtil().setSp(12),
                              color: Colors.grey,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(4)),
                            CustomFont(
                              text: likes.toString(),
                              fontSize: ScreenUtil().setSp(12),
                              color: Colors.grey,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            FutureBuilder<List<Comment>>(
                              future: commentsFuture,
                              builder: (context, snapshot) {
                                final commentCount =
                                    snapshot.data?.length ??
                                    widget.numOfComments;

                                return CustomFont(
                                  text: '$commentCount Comments',
                                  fontSize: ScreenUtil().setSp(12),
                                  color: Colors.grey,
                                );
                              },
                            ),
                            SizedBox(width: ScreenUtil().setWidth(10)),
                            CustomFont(
                              text: '${widget.numOfShares} Shares',
                              fontSize: ScreenUtil().setSp(12),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),

              (widget.adsMarket != '')
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _toggleLike,
                          icon: Icon(
                            liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: liked ? Colors.blue : Colors.grey,
                          ),
                          label: CustomFont(
                            text: 'Like',
                            fontSize: ScreenUtil().setSp(12),
                            color: liked ? Colors.blue : Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openDetail,
                          icon: const Icon(Icons.comment, color: Colors.grey),
                          label: CustomFont(
                            text: 'Comment',
                            fontSize: ScreenUtil().setSp(12),
                            color: Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.redo, color: Colors.grey),
                          label: CustomFont(
                            text: 'Share',
                            fontSize: ScreenUtil().setSp(12),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

              (widget.adsMarket != '')
                  ? Container(
                      padding: EdgeInsets.all(5.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomFont(
                                text: 'MORE DETAILS',
                                fontSize: 17.sp,
                                color: colors.onSurface,
                              ),
                              CustomFont(
                                text: widget.adsMarket,
                                fontSize: 17.sp,
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          CustomInkwellButton(
                            onTap: _openDetail,
                            bgColor: FB_PRIMARY,
                            height: 40.w,
                            width: 90.h,
                            icon: Icon(
                              Icons.arrow_right_alt,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
