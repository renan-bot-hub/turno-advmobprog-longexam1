import 'package:flutter/material.dart';
import '../constants.dart';

/// NansuX brand mark: a gradient "N" badge with the wordmark beside or below it.
class NansuXLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final bool vertical;

  const NansuXLogo({
    super.key,
    this.size = 64,
    this.showWordmark = true,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FB_PRIMARY, Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: FB_PRIMARY.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'N',
        style: TextStyle(
          fontFamily: 'Klavika',
          fontSize: size * 0.62,
          height: 1,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (!showWordmark) return badge;

    final wordmark = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Nansu',
            style: TextStyle(color: onSurface),
          ),
          const TextSpan(
            text: 'X',
            style: TextStyle(color: FB_PRIMARY),
          ),
        ],
      ),
      style: TextStyle(
        fontFamily: 'Klavika',
        fontSize: size * (vertical ? 0.55 : 0.5),
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );

    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              badge,
              SizedBox(height: size * 0.25),
              wordmark,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              badge,
              SizedBox(width: size * 0.22),
              wordmark,
            ],
          );
  }
}
