import 'avatar_image.dart';
import '../screens/detail_screen.dart';

import '../widgets/custom_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomInfo extends StatelessWidget {
  const CustomInfo({
    super.key,
    this.avatar = '',
    required this.name,
    required this.description,
    required this.hasSubDescription,
    required this.hasAvatar,
    required this.hasImage,
    this.numOfLikes = 0,
    this.subDescription = '',
    this.atProfile = false,
    this.date = '',
    this.image = '',
    required this.postId,
    this.commentUserId = 1,
    this.commentAvatar = '',
  });

  final String avatar, name, description, subDescription, date, image;
  final bool hasSubDescription, hasImage, hasAvatar, atProfile;
  final int postId;
  final int commentUserId;
  final int numOfLikes;
  final String commentAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: colors.surface,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          (atProfile)
              ? () {}
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      userName: name,
                      postContent: subDescription,
                      date: date,
                      avatar: avatar,
                      hasImage: hasImage,
                      image: image,
                      hasAvatar: hasAvatar,
                      numOfLikes: numOfLikes,
                      postId: postId,
                      commentUserId: commentUserId,
                      commentAvatar: commentAvatar,
                    ),
                  ),
                );
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              (hasAvatar)
                  ? CircleAvatar(
                      radius: 22,
                      backgroundImage: avatarImage(avatar),
                      backgroundColor: colors.surface,
                    )
                  : CircleAvatar(
                      radius: 22,
                      backgroundColor: colors.surface,
                      child: const Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),

              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFont(
                      text: name,
                      fontSize: 15.sp,
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    CustomFont(
                      text: description,
                      fontSize: 12.sp,
                      color: colors.onSurfaceVariant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasSubDescription) ...[
                      SizedBox(height: 4.h),
                      CustomFont(
                        text: '"$subDescription"',
                        fontSize: 13.sp,
                        color: colors.onSurface,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.more_horiz, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomInfoModified extends CustomInfo {
  const CustomInfoModified({
    super.key,
    super.avatar,
    required super.name,
    required super.description,
    required super.hasSubDescription,
    required super.hasAvatar,
    required this.changeLeading,
    required this.nullifyTrailing,
    required super.hasImage,
    super.numOfLikes,
    this.iconLeading,
    super.subDescription,
    super.atProfile,
    super.date,
    super.image,
    required super.postId,
    super.commentUserId,
    super.commentAvatar,
  });

  final bool changeLeading, nullifyTrailing;
  final IconData? iconLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setSp(10)),
      child: Row(
        children: [
          (hasAvatar)
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: avatarImage(avatar),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(iconLeading, color: Colors.grey),
                ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            flex: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFont(
                  text: name,
                  fontSize: ScreenUtil().setSp(20),
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                CustomFont(
                  text: description,
                  fontSize: ScreenUtil().setSp(13),
                  color: colors.onSurface,
                ),
                hasSubDescription
                    ? CustomFont(
                        text: subDescription,
                        fontSize: ScreenUtil().setSp(13),
                        color: colors.onSurface,
                      )
                    : SizedBox(height: ScreenUtil().setHeight(0)),
              ],
            ),
          ),
          const Spacer(),
          Icon(nullifyTrailing ? null : Icons.more_horiz, color: Colors.grey),
        ],
      ),
    );
  }
}
