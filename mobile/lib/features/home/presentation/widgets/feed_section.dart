import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/home_providers.dart';

class FeedSection extends ConsumerWidget {
  const FeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(recentFeedPostsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Family Feed',
          linkText: 'See all →',
          onLinkTap: () => context.go(Routes.feed),
        ),
        const SizedBox(height: 12),
        postsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeSpacing.screenPadding),
                child: Text(
                  'No messages yet — say hi! 👋',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                ),
              );
            }
            return Column(
              children: posts.map((p) => _FeedBubble(post: p)).toList(),
            );
          },
          loading: () => const LoadingSkeletonList(itemCount: 2, itemHeight: 72),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HomeSpacing.screenPadding),
            child: Text(
              'Could not load feed',
              style: AppTypography.body
                  .copyWith(color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedBubble extends ConsumerWidget {
  const _FeedBubble({required this.post});
  final Map<String, dynamic> post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersMap = ref.watch(householdMembersMapProvider);
    final authorId = post['author_id'] as String? ?? '';
    final author = membersMap[authorId];
    final content = post['content'] as String? ?? '';
    final createdAt = post['created_at'] != null
        ? DateTime.tryParse(post['created_at'] as String)
        : null;

    final name = author?.displayName ?? 'Family';
    final initials = _initials(name);
    final timeLabel = createdAt != null
        ? DateFormat('h:mm a').format(createdAt)
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(HomeSpacing.screenPadding, 0,
          HomeSpacing.screenPadding, HomeSpacing.itemGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MemberAvatar(
            memberId: author?.id ?? authorId,
            initials: initials,
            size: 36,
            borderRadius: 12,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: const [HomeShadow.card],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name.split(' ').first,
                        style: AppTypography.label.copyWith(
                            color: AppColors.textPrimary, fontSize: 12),
                      ),
                      Text(
                        timeLabel,
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}
