import '../widgets/custom_info.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final PostService postService = PostService();
  final UserService userService = UserService();

  late Future<List<Map<String, dynamic>>> posts;

  @override
  void initState() {
    super.initState();
    posts = loadPostsWithUsers();
  }

  Future<List<Map<String, dynamic>>> loadPostsWithUsers() async {
    final signedInUser = await userService.getUser();
    final posts = await postService.getPosts();

    return Future.wait(
      posts.map((post) async {
        final user = await userService.getUserById(post.userId);

        return {'post': post, 'user': user, 'signedInUser': signedInUser};
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load posts'));
        }

        final postsWithUsers = snapshot.data ?? [];

        return Container(
          color: Theme.of(context).colorScheme.surface,
          width: ScreenUtil().screenWidth,
          child: ListView(
            children: postsWithUsers.map((item) {
              final post = item['post'] as Post;
              final user = item['user'] as User;
              final signedInUser = item['signedInUser'] as User;

              return CustomInfo(
                name: user.fullName,
                description: 'posted a new status.',
                hasSubDescription: true,
                subDescription: post.body,
                avatar: user.image,
                hasAvatar: user.image.isNotEmpty,
                date: post.createdAt,
                hasImage: false,
                numOfLikes: post.likes,
                postId: post.id,
                commentUserId: signedInUser.id,
                commentAvatar: signedInUser.image,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
