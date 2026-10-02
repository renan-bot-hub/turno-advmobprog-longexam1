import '../widgets/avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_font.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../models/user.dart';

//ignore: must_be_immutable
class DetailScreen extends StatefulWidget {
  final String userName;
  final String postContent;
  final String date;
  final String avatar, image;
  int numOfLikes;
  final bool hasImage, hasAvatar;
  bool hasLiked;
  final int postId;
  final int commentUserId;
  final String commentAvatar;
  final String commentUsername;
  final String commentFullName;

  DetailScreen({
    super.key,
    required this.userName,
    required this.postContent,
    required this.date,
    required this.avatar,
    required this.hasImage,
    required this.hasAvatar,
    this.image = '',
    this.numOfLikes = 0,
    this.hasLiked = false,
    required this.postId,
    required this.commentUserId,
    this.commentAvatar = '',
    this.commentUsername = 'user',
    this.commentFullName = 'User',
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CommentService commentService = CommentService();
  final TextEditingController commentController = TextEditingController();

  late Future<List<Comment>> commentsFuture;
  List<Comment> comments = [];
  late int numOfLikes;
  bool liked = false;

  final UserService userService = UserService();
  final PostService postService = PostService();
  final Map<int, Future<User>> commentUsers = {};
  final FocusNode commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    numOfLikes = widget.numOfLikes;
    liked = widget.hasLiked;
    commentsFuture = commentService.getCommentsByPost(widget.postId);
    _loadLikeState();
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  Future<User> getCommentUser(int userId) {
    return commentUsers.putIfAbsent(
      userId,
      () => userService.getUserById(userId),
    );
  }

  Future<void> submitComment() async {
    final text = commentController.text.trim();

    if (text.isEmpty) return;

    try {
      final newComment = await commentService.addComment(
        body: text,
        postId: widget.postId,
        userId: widget.commentUserId,
        username: widget.commentUsername,
        fullName: widget.commentFullName,
      );

      if (!mounted) return;

      setState(() {
        comments.add(newComment);
        commentController.clear();
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to post comment')));
    }
  }

  Future<void> _loadLikeState() async {
    final state = await postService.getLikeState(
      postId: widget.postId,
      userId: widget.commentUserId,
      baseCount: widget.numOfLikes,
    );
    if (!mounted) return;
    setState(() {
      numOfLikes = state.count;
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
      numOfLikes = state.count;
      liked = state.liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomFont(
          text: widget.userName,
          fontSize: ScreenUtil().setSp(20),
          color: colors.onSurface,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Colors.grey),
      ),
      body: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          child: Column(
            children: [
              (widget.hasImage)
                  ? ConstrainedBox(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      child: Image.asset(widget.image, fit: BoxFit.cover),
                    )
                  : SizedBox(height: ScreenUtil().setHeight(0)),
              SizedBox(height: ScreenUtil().setHeight(20)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    (widget.hasAvatar)
                        ? CircleAvatar(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            radius: ScreenUtil().setSp(25),
                            backgroundImage: avatarImage(widget.avatar),
                          )
                        : CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            child: Icon(
                              Icons.person,
                              size: ScreenUtil().setSp(36),
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
                                size: ScreenUtil().setSp(12),
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_horiz, color: Colors.grey),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                ),
                alignment: Alignment.centerLeft,
                child: CustomFont(
                  text: widget.postContent,
                  fontSize: ScreenUtil().setSp(18),
                  color: colors.onSurface,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(30)),
              Divider(color: Theme.of(context).colorScheme.onPrimary),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _toggleLike,
                      icon: Icon(
                        liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: liked ? Colors.blue : Colors.grey,
                      ),
                      label: CustomFont(
                        text: liked || numOfLikes > 0
                            ? numOfLikes.toString()
                            : 'Like',
                        fontSize: ScreenUtil().setSp(12),
                        color: liked ? Colors.blue : colors.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(commentFocusNode);
                      },
                      icon: const Icon(Icons.comment, color: Colors.grey),
                      label: CustomFont(
                        text: 'Comment',
                        fontSize: ScreenUtil().setSp(12),
                        color: colors.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.redo, color: Colors.grey),
                      label: CustomFont(
                        text: 'Share',
                        fontSize: ScreenUtil().setSp(12),
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Comment>>(
                future: commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Failed to load comments'),
                    );
                  }

                  if (comments.isEmpty) {
                    comments = snapshot.data ?? [];
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: Theme.of(context).colorScheme.onPrimary),

                      ...comments.map(
                        (comment) => FutureBuilder<User>(
                          future: getCommentUser(comment.userId),
                          builder: (context, snapshot) {
                            final imageUrl = snapshot.data?.image ?? '';
                            final authorName =
                                snapshot.data?.fullName.isNotEmpty == true
                                ? snapshot.data!.fullName
                                : comment.fullName.isEmpty
                                ? comment.username
                                : comment.fullName;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: imageUrl.isNotEmpty
                                    ? avatarImage(imageUrl)
                                    : null,
                                backgroundColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                child: imageUrl.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      )
                                    : null,
                              ),
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 2.h,
                              ),
                              title: Text(
                                authorName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                comment.body,
                                style: TextStyle(color: colors.onSurface),
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10),
                          vertical: ScreenUtil().setHeight(10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              backgroundImage: widget.commentAvatar.isNotEmpty
                                  ? avatarImage(widget.commentAvatar)
                                  : null,
                              child: widget.commentAvatar.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(8)),
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: TextField(
                                  focusNode: commentFocusNode,
                                  controller: commentController,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(12),
                                    color: colors.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Write a comment...',
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(11),
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: theme.scaffoldBackgroundColor,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil().setSp(14),
                                      vertical: ScreenUtil().setSp(6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: submitComment,
                              icon: Icon(Icons.send, color: colors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
