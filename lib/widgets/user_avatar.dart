import 'package:flutter/material.dart';
import '../models/user.dart';
import 'avatar_image.dart';

/// Picks a stable color pair for a user so generated avatars/covers differ
/// between accounts but stay the same for one account.
List<Color> userPalette(User user) {
  const palettes = [
    [Color(0xFF5865F2), Color(0xFF8B5CF6)],
    [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    [Color(0xFF10B981), Color(0xFF0EA5E9)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    [Color(0xFF14B8A6), Color(0xFF22C55E)],
    [Color(0xFFF97316), Color(0xFFDB2777)],
    [Color(0xFF6366F1), Color(0xFF06B6D4)],
  ];
  final seed = user.username.isNotEmpty ? user.username : '${user.id}';
  final hash = seed.codeUnits.fold<int>(
    user.id,
    (a, b) => (a * 31 + b) & 0x7fffffff,
  );
  return palettes[hash % palettes.length];
}

/// Circular avatar that shows the user's photo, or their initials on a
/// colored background when they have no photo.
class UserAvatar extends StatelessWidget {
  final User user;
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 20,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final palette = userPalette(user);
    final hasImage = user.image.isNotEmpty;

    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
        image: hasImage
            ? DecorationImage(
                image: ResizeImage.resizeIfNeeded(
                  (radius * 2 * MediaQuery.devicePixelRatioOf(context)).ceil(),
                  null,
                  avatarImage(user.image),
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Text(
              user.initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.75,
              ),
            ),
    );

    if (borderWidth <= 0) return avatar;

    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: borderColor ?? Theme.of(context).colorScheme.surface,
      ),
      child: avatar,
    );
  }
}

/// Cover banner: the user's own cover photo if they have one, otherwise a
/// gradient unique to their account.
class ProfileCover extends StatelessWidget {
  final User user;
  final double aspectRatio;

  const ProfileCover({
    super.key,
    required this.user,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    if (user.coverImage.isNotEmpty) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Image(
          image: avatarImage(user.coverImage),
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    final palette = userPalette(user);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: _Bubble(size: 180, opacity: 0.12),
            ),
            Positioned(
              left: -30,
              bottom: -50,
              child: _Bubble(size: 150, opacity: 0.10),
            ),
            Positioned(
              right: 60,
              bottom: 20,
              child: _Bubble(size: 50, opacity: 0.14),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
