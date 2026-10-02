import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/post_card.dart';
import '../widgets/post_composer.dart';

class NewsFeedScreen extends StatefulWidget {
  final User user;

  const NewsFeedScreen({super.key, required this.user});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final PostService postService = PostService();
  late Future<List<({Post post, User author})>> posts;

  @override
  void initState() {
    super.initState();
    posts = postService.getPostsWithAuthors();
  }

  Future<void> _refresh() async {
    final future = postService.getPostsWithAuthors();
    setState(() => posts = future);
    await future.catchError((_) => <({Post post, User author})>[]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<({Post post, User author})>>(
        future: posts,
        builder: (context, snapshot) {
          final postsWithUsers = snapshot.data ?? [];

          return ListView(
            padding: EdgeInsets.only(bottom: 16.h),
            children: [
              PostComposer(user: widget.user, onPosted: _refresh),
              if (snapshot.connectionState == ConnectionState.waiting)
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Padding(
                  padding: EdgeInsets.only(top: 60.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 48,
                        color: colors.onSurface.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Could not load your feed',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else
                ...postsWithUsers.map((item) {
                  final (:post, author: user) = item;

                  return PostCard(
                    key: ValueKey(post.id),
                    postId: post.id,
                    commentUserId: widget.user.id,
                    userName: user.fullName,
                    avatar: user.image,
                    hasAvatar: user.image.isNotEmpty,
                    commentAvatar: widget.user.image,
                    hasCommentAvatar: widget.user.image.isNotEmpty,
                    commentUsername: widget.user.username,
                    commentFullName: widget.user.fullName,
                    postContent: post.body,
                    hasImage: false,
                    numOfLikes: post.likes,
                    numOfComments: 0,
                    numOfShares: 0,
                    date: post.createdAt,
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
