import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/avatar_image.dart';
import '../widgets/custom_font.dart';
import '../constants.dart';
import '../widgets/post_card.dart';
import '../widgets/post_composer.dart';
import '../widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0;
  final PostService postService = PostService();
  late Future<List<Post>> profilePosts;

  @override
  void initState() {
    super.initState();
    profilePosts = postService.getPostsByUser(widget.user.id);
  }

  Future<void> _refresh() async {
    final future = postService.getPostsByUser(widget.user.id);
    setState(() => profilePosts = future);
    await future.catchError((_) => <Post>[]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          _buildHeader(theme),
          SizedBox(height: 8.h),
          if (selectedTab == 0)
            _buildPosts()
          else if (selectedTab == 1)
            _buildAbout()
          else
            _buildPhotos(),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final colors = theme.colorScheme;
    const avatarRadius = 52.0;
    final muted = colors.onSurface.withValues(alpha: 0.6);

    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: widget.user.coverImage.isEmpty
                    ? null
                    : () => customShowImageDialog(
                        context,
                        image: widget.user.coverImage,
                        isNetwork: !isAssetImage(widget.user.coverImage),
                      ),
                child: ProfileCover(user: widget.user, aspectRatio: 16 / 8),
              ),
              Positioned(
                left: 20.w,
                bottom: -avatarRadius,
                child: GestureDetector(
                  onTap: widget.user.image.isEmpty
                      ? null
                      : () => customShowImageDialog(
                          context,
                          image: widget.user.image,
                          isNetwork: !isAssetImage(widget.user.image),
                        ),
                  child: UserAvatar(
                    user: widget.user,
                    radius: avatarRadius,
                    borderWidth: 4,
                    borderColor: colors.surface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: avatarRadius + 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFont(
                  text: widget.user.fullName,
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                  color: colors.onSurface,
                ),
                SizedBox(height: 2.h),
                CustomFont(
                  text: '@${widget.user.username}',
                  fontSize: 14.sp,
                  color: muted,
                ),
                SizedBox(height: 14.h),
                FutureBuilder<List<Post>>(
                  future: profilePosts,
                  builder: (context, snapshot) => Row(
                    children: [
                      _stat('${snapshot.data?.length ?? 0}', 'Posts'),
                      _statDivider(colors),
                      _stat('${widget.user.photos.length}', 'Photos'),
                      if (widget.user.age > 0) ...[
                        _statDivider(colors),
                        _stat('${widget.user.age}', 'Age'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
            child: _buildTabs(colors),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider(ColorScheme colors) => Padding(
    padding: EdgeInsets.only(right: 16.w),
    child: Icon(
      Icons.circle,
      size: 4,
      color: colors.onSurface.withValues(alpha: 0.3),
    ),
  );

  Widget _buildTabs(ColorScheme colors) {
    const tabs = [
      (Icons.dynamic_feed_outlined, 'Posts'),
      (Icons.info_outline, 'About'),
      (Icons.photo_library_outlined, 'Photos'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selectedTab == i ? FB_PRIMARY : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[i].$1,
                        size: 17.sp,
                        color: selectedTab == i
                            ? Colors.white
                            : colors.onSurface.withValues(alpha: 0.7),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        tabs[i].$2,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: selectedTab == i
                              ? Colors.white
                              : colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPosts() {
    return FutureBuilder<List<Post>>(
      future: profilePosts,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];

        return Column(
          children: [
            PostComposer(user: widget.user, onPosted: _refresh),
            if (snapshot.connectionState == ConnectionState.waiting)
              Padding(
                padding: EdgeInsets.all(24.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              _emptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load posts',
                subtitle: 'Pull down to try again.',
              )
            else if (posts.isEmpty)
              _emptyState(
                icon: Icons.edit_note_outlined,
                title: 'No posts yet',
                subtitle: 'Share your first thought above.',
              )
            else
              ...posts.map(
                (post) => PostCard(
                  postId: post.id,
                  commentUserId: widget.user.id,
                  userName: widget.user.fullName,
                  avatar: widget.user.image,
                  hasAvatar: widget.user.image.isNotEmpty,
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
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAbout() {
    final colors = Theme.of(context).colorScheme;
    final items = [
      (Icons.person_outline, 'Name', widget.user.fullName),
      (Icons.alternate_email, 'Username', widget.user.username),
      (Icons.mail_outline, 'Email', widget.user.email),
      (Icons.wc_outlined, 'Gender', widget.user.gender),
      if (widget.user.age > 0)
        (Icons.cake_outlined, 'Age', '${widget.user.age} years old'),
      if (widget.user.mobile.isNotEmpty)
        (Icons.phone_outlined, 'Mobile', widget.user.mobile),
    ].where((item) => item.$3.isNotEmpty).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) _aboutDivider(colors),
            _buildAboutItem(
              icon: items[i].$1,
              label: items[i].$2,
              value: items[i].$3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FB_PRIMARY.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: FB_PRIMARY),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFont(
                  text: label,
                  fontSize: 12.sp,
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(height: 2.h),
                CustomFont(
                  text: value,
                  fontSize: 15.sp,
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutDivider(ColorScheme colors) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 52,
      color: colors.onSurface.withValues(alpha: 0.12),
    );
  }

  Widget _buildPhotos() {
    final photos = widget.user.photos;
    if (photos.isEmpty) {
      return _emptyState(
        icon: Icons.photo_library_outlined,
        title: 'No photos yet',
        subtitle: 'Photos you share will show up here.',
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final photo in photos)
            GestureDetector(
              onTap: () => customShowImageDialog(context, image: photo),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(photo, fit: BoxFit.cover, cacheWidth: 360),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      child: Column(
        children: [
          Icon(icon, size: 44, color: colors.onSurface.withValues(alpha: 0.3)),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
