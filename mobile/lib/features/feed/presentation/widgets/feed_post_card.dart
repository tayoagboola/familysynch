import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme.dart';
import '../../../../../core/extensions/color_extension.dart';
import '../../../../../features/household/domain/entities/household_member.dart';
import '../../domain/entities/feed_post.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    required this.membersMap,
    required this.currentUserId,
    required this.onDelete,
  });

  final FeedPost post;
  final Map<String, HouseholdMember> membersMap;
  final String currentUserId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = membersMap[post.authorId];
    final isOwn = post.authorId == currentUserId;
    final avatarColor = author != null
        ? HexColor.fromHex(author.color)
        : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: avatarColor,
                backgroundImage: author?.avatarUrl != null
                    ? NetworkImage(author!.avatarUrl!)
                    : null,
                child: author?.avatarUrl == null
                    ? Text(
                        author != null && author.displayName.isNotEmpty
                            ? author.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author?.displayName ?? 'Unknown',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _formatTime(post.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (isOwn)
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () => _showOptions(context),
                ),
            ]),

            const SizedBox(height: AppSpacing.sm),

            // Content
            Text(post.content, style: theme.textTheme.bodyLarge),

            // Image
            if (post.imageUrl != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.broken_image_outlined,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListTile(
          leading: Icon(Icons.delete_outline,
              color: Theme.of(context).colorScheme.error),
          title: Text('Delete post',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error)),
          onTap: () {
            Navigator.pop(context);
            onDelete();
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
