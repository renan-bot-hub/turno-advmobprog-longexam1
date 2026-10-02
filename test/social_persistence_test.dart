import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turno_advmobprog_longexam/models/comment.dart';
import 'package:turno_advmobprog_longexam/services/comment_service.dart';
import 'package:turno_advmobprog_longexam/services/post_service.dart';
import 'package:turno_advmobprog_longexam/services/user_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('posts, likes, and comments persist through logout', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('registered_users', ['saved-account']);
    await prefs.setInt('id', 42);

    final postService = PostService();
    final post = await postService.addLocalPost(
      body: 'Persistent post',
      userId: 42,
    );
    final likeState = await postService.toggleLike(
      postId: post.id,
      userId: 42,
      baseCount: 0,
    );
    final commentService = CommentService();
    await commentService.addComment(
      body: 'Persistent comment',
      postId: post.id,
      userId: 42,
      username: 'turno',
      fullName: 'Turno User',
    );

    await UserService().logout();

    expect(prefs.getInt('id'), isNull);
    expect(prefs.getStringList('registered_users'), ['saved-account']);
    expect((await postService.getLocalPosts()).single.body, 'Persistent post');
    expect(
      (await postService.getLikeState(
        postId: post.id,
        userId: 42,
        baseCount: 0,
      )).liked,
      isTrue,
    );
    expect(likeState.count, 1);

    final comments = await commentService.getCommentsByPost(post.id);
    expect(comments, hasLength(1));
    expect(comments.single, isA<Comment>());
    expect(comments.single.body, 'Persistent comment');
  });
}
