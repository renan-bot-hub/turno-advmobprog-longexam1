class Comment {
  final int id;
  final int userId;
  final int postId;
  final String body;
  final int likes;
  final String username;
  final String fullName;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.body,
    required this.likes,
    required this.username,
    required this.fullName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};

    return Comment(
      id: json['id'] ?? 0,
      userId: user['id'] ?? json['userId'] ?? 0,
      postId: json['postId'] ?? 0,
      body: json['body'] ?? '',
      likes: json['likes'] ?? 0,
      username: user['username'] ?? '',
      fullName: user['fullName'] ?? '',
    );
  }
}