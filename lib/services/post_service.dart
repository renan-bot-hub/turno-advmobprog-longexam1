import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import 'user_service.dart';

class PostLikeState {
  final int count;
  final bool liked;

  const PostLikeState({required this.count, required this.liked});
}

class PostService {
  static const _localPostsKey = 'local_posts';
  static const _localLikesKeyPrefix = 'local_likes_';

  /// Feed posts paired with their authors, used by the feed and notifications.
  Future<List<({Post post, User author})>> getPostsWithAuthors() async {
    final posts = await getPosts();
    final userService = UserService();
    final authors = await Future.wait(
      posts.map((post) => userService.getUserById(post.userId)),
    );
    return [
      for (var i = 0; i < posts.length; i++)
        (post: posts[i], author: authors[i]),
    ];
  }

  Future<List<Post>> getPosts({int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');
    final response = await get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List postsJson = data['posts'] ?? [];
      final localPosts = await getLocalPosts();
      return [
        ...localPosts.reversed,
        ...postsJson.map((p) => Post.fromJson(p)),
      ];
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    final uri = Uri.parse('$host/posts/user/$userId');
    final response = await get(uri);

    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Failed to load user posts: ${response.statusCode}');
    }

    final remotePosts = response.statusCode == 200
        ? ((jsonDecode(response.body) as Map<String, dynamic>)['posts']
                      as List? ??
                  [])
              .map((post) => Post.fromJson(post as Map<String, dynamic>))
              .toList()
        : <Post>[];
    final localPosts = await getLocalPosts();

    return [
      ...localPosts.where((post) => post.userId == userId).toList().reversed,
      ...remotePosts,
    ];
  }

  Future<List<Post>> getLocalPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPosts = prefs.getStringList(_localPostsKey) ?? [];

    return storedPosts
        .map(
          (value) => Post.fromJson(jsonDecode(value) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Post> addLocalPost({required String body, required int userId}) async {
    final now = DateTime.now();
    final post = Post(
      id: -now.microsecondsSinceEpoch,
      postId: 0,
      userId: userId,
      body: body.trim(),
      likes: 0,
      dislikes: 0,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
    final prefs = await SharedPreferences.getInstance();
    final storedPosts = prefs.getStringList(_localPostsKey) ?? [];
    storedPosts.add(jsonEncode(post.toJson()));
    await prefs.setStringList(_localPostsKey, storedPosts);

    return post;
  }

  Future<PostLikeState> getLikeState({
    required int postId,
    required int userId,
    required int baseCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userIds = prefs.getStringList('$_localLikesKeyPrefix$postId') ?? [];

    return PostLikeState(
      count: baseCount + userIds.length,
      liked: userIds.contains(userId.toString()),
    );
  }

  Future<PostLikeState> toggleLike({
    required int postId,
    required int userId,
    required int baseCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_localLikesKeyPrefix$postId';
    final userIds = (prefs.getStringList(key) ?? []).toSet();
    final userKey = userId.toString();

    if (!userIds.add(userKey)) {
      userIds.remove(userKey);
    }

    await prefs.setStringList(key, userIds.toList());
    return PostLikeState(
      count: baseCount + userIds.length,
      liked: userIds.contains(userKey),
    );
  }
}
