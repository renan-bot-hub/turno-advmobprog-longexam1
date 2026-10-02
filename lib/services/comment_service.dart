import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  // Remote comments never change, so each post's list is fetched once.
  static final Map<int, Future<List<Comment>>> _remoteCache = {};

  Future<List<Comment>> getCommentsByPost(int postId) async {
    final localComments = await _getLocalComments(postId);
    if (postId < 0) return localComments;

    final remote = _remoteCache.putIfAbsent(
      postId,
      () => _fetchRemoteComments(postId),
    );

    try {
      return [...await remote, ...localComments];
    } catch (_) {
      _remoteCache.remove(postId);
      rethrow;
    }
  }

  Future<List<Comment>> _fetchRemoteComments(int postId) async {
    final response = await http.get(Uri.parse('$host/comments/post/$postId'));

    if (response.statusCode == 404) return [];

    if (response.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final comments = data['comments'] as List? ?? [];
    return comments.map((comment) => Comment.fromJson(comment)).toList();
  }

  Future<Comment> addComment({
    required String body,
    required int postId,
    required int userId,
    String username = 'user',
    String fullName = 'User',
  }) async {
    final comment = Comment(
      id: -DateTime.now().microsecondsSinceEpoch,
      body: body.trim(),
      postId: postId,
      userId: userId,
      likes: 0,
      username: username,
      fullName: fullName,
    );
    final prefs = await SharedPreferences.getInstance();
    final storedComments = prefs.getStringList('local_comments') ?? [];
    storedComments.add(
      jsonEncode({
        'id': comment.id,
        'body': comment.body,
        'postId': comment.postId,
        'likes': comment.likes,
        'user': {
          'id': comment.userId,
          'username': comment.username,
          'fullName': comment.fullName,
        },
      }),
    );
    await prefs.setStringList('local_comments', storedComments);

    return comment;
  }

  Future<List<Comment>> _getLocalComments(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedComments = prefs.getStringList('local_comments') ?? [];

    return storedComments
        .map(
          (value) =>
              Comment.fromJson(jsonDecode(value) as Map<String, dynamic>),
        )
        .where((comment) => comment.postId == postId)
        .toList();
  }
}
