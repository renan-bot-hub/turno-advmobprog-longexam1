import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import 'package:flutter/material.dart';
import '../widgets/post_card.dart';

class NewsFeedScreen extends StatefulWidget {
  final User user;

  const NewsFeedScreen({super.key, required this.user});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final PostService postService = PostService();
  late Future<List<Map<String, dynamic>>> posts;
  final UserService userService = UserService();

  Future<List<Map<String, dynamic>>> loadPostsWithUsers() async {
    final posts = await postService.getPosts();

    return Future.wait(
      posts.map((post) async {
        final user = await userService.getUserById(post.userId);

        return {'post': post, 'user': user};
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    posts = loadPostsWithUsers();
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

        return ListView(
          children: postsWithUsers.map((item) {
              final post = item['post'] as Post;
              final user = item['user'] as User;

              return PostCard(
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
            }).toList(),
        );
      },
    );
  }
}
