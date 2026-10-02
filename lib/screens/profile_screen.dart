import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../widgets/custom_dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_font.dart';
import '../constants.dart';
import '../widgets/post_card.dart';
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
  final TextEditingController _postController = TextEditingController();
  late Future<List<Post>> profilePosts;
  bool _isSubmitting = false;

  final String profileImgUrl =
      'https://media.discordapp.net/attachments/856874434605744142/1443981776560324679/sketch-1688837704405.jpg?ex=697631d3&is=6974e053&hm=f0917d728382d0aacc3c7b9295c8d226c6d59debe534a69663f11a724f678222&=&format=webp&width=648&height=648';

  @override
  void initState() {
    super.initState();
    profilePosts = postService.getPostsByUser(widget.user.id);
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final body = _postController.text.trim();
    if (body.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await postService.addLocalPost(body: body, userId: widget.user.id);
      _postController.clear();
      if (!mounted) return;
      setState(() {
        profilePosts = postService.getPostsByUser(widget.user.id);
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save post')),
      );
    }
  }

  Widget _buildPostComposer() {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 4.h),
      color: colors.surface,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.surfaceContainerHighest,
                  backgroundImage: widget.user.image.isNotEmpty
                      ? NetworkImage(widget.user.image)
                      : null,
                  child: widget.user.image.isEmpty
                      ? Icon(Icons.person, color: colors.onSurfaceVariant)
                      : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 11.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: colors.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _createPost,
                style: FilledButton.styleFrom(backgroundColor: FB_PRIMARY),
                icon: _isSubmitting
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: ListView(
        children: [
          Container(
            color: colors.surfaceContainer,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AspectRatio(
                      aspectRatio: 736 / 414,
                      child: Image.asset(
                        'assets/images/hirin.jpg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: ScreenUtil().setWidth(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.scaffoldBackgroundColor,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                          color: theme.scaffoldBackgroundColor,
                                          value: downloadProgress.progress,
                                        ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setHeight(55)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: widget.user.fullName,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(20),
                        color: colors.onSurface,
                      ),
                      SizedBox(height: ScreenUtil().setHeight(5)),
                      Row(
                        children: [
                          CustomFont(
                            text: '6.7m',
                            fontSize: ScreenUtil().setSp(15),
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: ScreenUtil().setWidth(10)),
                          CustomFont(
                            text: 'followers',
                            fontSize: ScreenUtil().setSp(15),
                            color: Colors.grey,
                            fontWeight: FontWeight.w100,
                          ),
                          SizedBox(width: ScreenUtil().setWidth(5)),
                          Icon(
                            Icons.circle,
                            size: ScreenUtil().setSp(5),
                            color: Colors.grey,
                          ),
                          SizedBox(width: ScreenUtil().setWidth(5)),
                          CustomFont(
                            text: '0',
                            fontSize: ScreenUtil().setSp(15),
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: ScreenUtil().setWidth(10)),
                          CustomFont(
                            text: 'following',
                            fontSize: ScreenUtil().setSp(15),
                            color: Colors.grey,
                            fontWeight: FontWeight.w100,
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(10)),
                      Row(
                        children: [
                          CustomButton(
                            buttonName: 'Follow',
                            onPressed: () {},
                            fontColor: Theme.of(context).colorScheme.onPrimary,
                            buttonType: 'filled',
                          ),
                          SizedBox(width: ScreenUtil().setWidth(10)),
                          CustomButton(
                            buttonName: 'Message',
                            onPressed: () {},
                            fontColor: Theme.of(context).colorScheme.primary,
                            buttonType: 'outlined',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(10)),
                TabBar(
                  dividerColor: colors.onPrimary,
                  indicatorColor: FB_PRIMARY,
                  onTap: (index) {
                    setState(() => selectedTab = index);
                  },
                  tabs: [
                    Tab(
                      child: CustomFont(
                        text: 'Posts',
                        fontSize: ScreenUtil().setSp(15),
                        color: colors.onSurface,
                      ),
                    ),
                    Tab(
                      child: CustomFont(
                        text: 'About',
                        fontSize: ScreenUtil().setSp(15),
                        color: colors.onSurface,
                      ),
                    ),
                    Tab(
                      child: CustomFont(
                        text: 'Photos',
                        fontSize: ScreenUtil().setSp(15),
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  Widget _buildPosts() {
    return FutureBuilder<List<Post>>(
      future: profilePosts,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];

        return Column(
          children: [
            _buildPostComposer(),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              const Center(child: Text('Failed to load posts'))
            else if (posts.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No posts yet'),
              ))
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
    return Container(
      color: colors.surface,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          _buildAboutItem(
            icon: Icons.person_outline,
            value: widget.user.fullName,
            label: 'Name',
          ),
          _aboutDivider(colors),
          _buildAboutItem(
            icon: Icons.alternate_email,
            value: widget.user.username,
            label: 'Username',
          ),
          _aboutDivider(colors),
          _buildAboutItem(
            icon: Icons.mail_outline,
            value: widget.user.email,
            label: 'Email',
          ),
          _aboutDivider(colors),
          _buildAboutItem(
            icon: Icons.people_outline,
            value: widget.user.gender,
            label: 'Gender',
          ),
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
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 36.w,
            child: Icon(icon, size: 23.sp, color: colors.onSurfaceVariant),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFont(
                  text: value,
                  fontSize: 17.sp,
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                CustomFont(
                  text: label,
                  fontSize: 12.sp,
                  color: colors.onSurfaceVariant,
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
      indent: 48.w,
      color: colors.onSurface.withValues(alpha: 0.12),
    );
  }

  Widget _buildPhotos() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GestureDetector(
          child: Image.asset('assets/images/valorant.png', fit: BoxFit.cover),
          onTap: () => customShowImageDialog(
            context,
            image: 'assets/images/valorant.png',
          ),
        ),
        GestureDetector(
          child: Image.asset('assets/images/line.png', fit: BoxFit.cover),
          onTap: () =>
              customShowImageDialog(context, image: 'assets/images/line.png'),
        ),
        GestureDetector(
          child: Image.asset(
            'assets/images/cover_photo.png',
            fit: BoxFit.cover,
          ),
          onTap: () => customShowImageDialog(
            context,
            image: 'assets/images/cover_photo.png',
          ),
        ),
        GestureDetector(
          child: Image.asset(
            'assets/images/user_avatar.png',
            fit: BoxFit.cover,
          ),
          onTap: () => customShowImageDialog(
            context,
            image: 'assets/images/user_avatar.png',
          ),
        ),
        GestureDetector(
          child: Image.asset('assets/images/cat1.png', fit: BoxFit.cover),
          onTap: () =>
              customShowImageDialog(context, image: 'assets/images/cat1.png'),
        ),
        GestureDetector(
          child: Image.asset('assets/images/cat2.png', fit: BoxFit.cover),
          onTap: () =>
              customShowImageDialog(context, image: 'assets/images/cat2.png'),
        ),
        GestureDetector(
          child: Image.asset('assets/images/cat3.png', fit: BoxFit.cover),
          onTap: () =>
              customShowImageDialog(context, image: 'assets/images/cat3.png'),
        ),
        GestureDetector(
          child: Image.asset(
            'assets/images/discord_mod.png',
            fit: BoxFit.cover,
          ),
          onTap: () => customShowImageDialog(
            context,
            image: 'assets/images/discord_mod.png',
          ),
        ),
      ],
    );
  }
}
