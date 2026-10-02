import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  Future<List<Comment>> getCommentsByPost(int postId) async {
    final localComments = await _getLocalComments(postId);
    if (postId < 0) return localComments;

    final response = await http.get(Uri.parse('$host/comments/post/$postId'));

    if (response.statusCode == 404) return localComments;

    if (response.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final comments = data['comments'] as List? ?? [];

    return [
      ...comments.map((comment) => Comment.fromJson(comment)),
      ...localComments,
    ];
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
