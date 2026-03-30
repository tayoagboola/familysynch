import 'package:flutter/material.dart';

import '../../core/utils/member_colors.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.memberId,
    required this.initials,
    this.size = 36,
    this.borderRadius = 12,
    this.avatarUrl,
  });

  final String memberId;
  final String initials;
  final double size;
  final double borderRadius;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = memberGradientColors(memberId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        image: avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null
          ? Center(
              child: Text(
                initials.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
