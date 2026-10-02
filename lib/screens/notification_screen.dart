import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../screens/detail_screen.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with AutomaticKeepAliveClientMixin {
  static const int _newCount = 5;

  final PostService postService = PostService();
  final UserService userService = UserService();

  late Future<List<({Post post, User author})>> posts;
  User? _signedInUser;
  final Set<int> _readPostIds = {};
  int _userId = 0;

  // Keep read state when switching tabs in the home PageView.
  @override
  bool get wantKeepAlive => true;

  String get _readKey => 'read_notifications_$_userId';

  @override
  void initState() {
    super.initState();
    posts = _load();
  }

  Future<List<({Post post, User author})>> _load() async {
    final signedInUser = await userService.getUser();
    _signedInUser = signedInUser;
    _userId = signedInUser.id;
    final prefs = await SharedPreferences.getInstance();
    _readPostIds.addAll((prefs.getStringList(_readKey) ?? []).map(int.parse));
    return postService.getPostsWithAuthors();
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => posts = future);
    await future.catchError((_) => <({Post post, User author})>[]);
  }

  Future<void> _markRead(Iterable<int> postIds) async {
    setState(() => _readPostIds.addAll(postIds));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _readKey,
      _readPostIds.map((id) => id.toString()).toList(),
    );
  }

  void _open(Post post, User author, User signedInUser) {
    _markRead([post.id]);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          userName: author.fullName,
          postContent: post.body,
          date: post.createdAt,
          avatar: author.image,
          hasImage: false,
          image: '',
          hasAvatar: author.image.isNotEmpty,
          numOfLikes: post.likes,
          postId: post.id,
          commentUserId: signedInUser.id,
          commentAvatar: signedInUser.image,
          commentUsername: signedInUser.username,
          commentFullName: signedInUser.fullName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<({Post post, User author})>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _message(
              colors,
              icon: Icons.cloud_off_outlined,
              title: 'Could not load notifications',
              action: TextButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _message(
              colors,
              icon: Icons.notifications_none_rounded,
              title: "You're all caught up",
            );
          }

          final newItems = items.take(_newCount).toList();
          final earlierItems = items.skip(_newCount).toList();
          final unread = newItems
              .where((i) => !_readPostIds.contains(i.post.id))
              .length;

          return ListView(
            padding: EdgeInsets.only(bottom: 16.h),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 8.w, 4.h),
                child: Row(
                  children: [
                    Text(
                      'New',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    if (unread > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: FB_PRIMARY,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unread',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (unread > 0)
                      TextButton(
                        onPressed: () =>
                            _markRead(newItems.map((i) => i.post.id)),
                        child: const Text('Mark all as read'),
                      ),
                  ],
                ),
              ),
              ...newItems.map((item) => _tile(item, canBeUnread: true)),
              if (earlierItems.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 6.h),
                  child: Text(
                    'Earlier',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ...earlierItems.map((item) => _tile(item, canBeUnread: false)),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(({Post post, User author}) item, {required bool canBeUnread}) {
    final colors = Theme.of(context).colorScheme;
    final (:post, :author) = item;
    final signedInUser = _signedInUser!;
    final isOwnPost = author.id == signedInUser.id;
    final unread = canBeUnread && !_readPostIds.contains(post.id);
    final time = _relativeTime(post.createdAt);

    return Material(
      color: unread ? FB_PRIMARY.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: () => _open(post, author, signedInUser),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(user: author, radius: 26),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: post.likes > 0 && isOwnPost
                            ? const Color(0xFFEF4444)
                            : FB_PRIMARY,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        post.likes > 0 && isOwnPost
                            ? Icons.favorite
                            : Icons.article_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isOwnPost ? 'You' : author.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: isOwnPost
                                ? ' shared a new post.'
                                : ' posted a new status.',
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '"${post.body}"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colors.onSurface.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (time.isNotEmpty) ...[
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: unread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: unread
                                  ? FB_PRIMARY
                                  : colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          SizedBox(width: 10.w),
                        ],
                        Icon(
                          Icons.favorite_border,
                          size: 13,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '${post.likes}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (unread)
                Padding(
                  padding: EdgeInsets.only(left: 8.w, top: 20.h),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: FB_PRIMARY,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(
    ColorScheme colors, {
    required IconData icon,
    required String title,
    Widget? action,
  }) {
    // ListView keeps pull-to-refresh working on empty/error states.
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Icon(icon, size: 56, color: colors.onSurface.withValues(alpha: 0.3)),
        SizedBox(height: 12.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        if (action != null) Center(child: action),
      ],
    );
  }

  String _relativeTime(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.month}/${date.day}/${date.year}';
  }
}
