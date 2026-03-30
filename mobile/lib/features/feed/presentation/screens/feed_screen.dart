import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../../household/domain/entities/household_member.dart';
import '../../../../shared/widgets/ai_fab.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../domain/entities/feed_post.dart';
import '../controllers/feed_providers.dart';
import '../providers/feed_extra_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _composeController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _composeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _composeController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _composeController.clear();
    _focusNode.unfocus();
    final success =
        await ref.read(feedActionsProvider.notifier).createPost(content: text);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post',
              style: AppTypography.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    if (mounted) setState(() => _isSending = false);
  }

  void _prefill(String text) {
    _composeController.text = text;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      floatingActionButton: const AIFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const _FeedHeader(),
          const _OnlineStrip(),
          Expanded(child: _FeedList()),
          _ComposeBar(
            controller: _composeController,
            focusNode: _focusNode,
            isFocused: _isFocused,
            isSending: _isSending,
            onSend: _sendMessage,
            onPrefill: _prefill,
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _FeedHeader extends ConsumerWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.h1.copyWith(fontSize: 22),
                        children: [
                          TextSpan(
                            text: 'Family ',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text: 'Feed',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Search button
                  Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.search_rounded,
                        size: 17, color: AppColors.textSecondary),
                  ),
                  // Post button
                  GestureDetector(
                    onTap: () => _showNewPostSheet(context, ref),
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: const [HomeShadow.card],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            'Post',
                            style: AppTypography.label.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const _FeedFilterRow(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showNewPostSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewPostSheet(),
    );
  }
}

// ── Filter Row ────────────────────────────────────────────────────────────────

class _FeedFilterRow extends ConsumerWidget {
  const _FeedFilterRow();

  static const _filters = [
    (FeedFilter.all, '🏠 All'),
    (FeedFilter.announcements, '📢 Announcements'),
    (FeedFilter.celebrations, '🎉 Celebrations'),
    (FeedFilter.updates, '📋 Updates'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(feedFilterProvider);

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: HomeSpacing.screenPadding),
        children: _filters.map((f) {
          final isActive = selected == f.$1;
          return GestureDetector(
            onTap: () =>
                ref.read(feedFilterProvider.notifier).state = f.$1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface2,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(72),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                f.$2,
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Online Strip ──────────────────────────────────────────────────────────────

class _OnlineStrip extends ConsumerWidget {
  const _OnlineStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineAsync = ref.watch(onlineMembersProvider);
    final membersMap = ref.watch(householdMembersMapProvider);
    final onlineIds = onlineAsync.valueOrNull ?? [];
    final onlineMembers =
        onlineIds.map((id) => membersMap[id]).whereType<HouseholdMember>().toList();

    if (onlineMembers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface2,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            'NOW ACTIVE',
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 12),
          ...onlineMembers.take(6).map((member) {
            final initials = _initials(member.displayName);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  MemberAvatar(
                    memberId: member.id,
                    initials: initials,
                    size: 28,
                    borderRadius: 9,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

// ── Feed List ─────────────────────────────────────────────────────────────────

class _FeedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(feedPostsProvider);
    final posts = ref.watch(filteredFeedPostsProvider);
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';

    return postsAsync.when(
      loading: () => const LoadingSkeletonList(
          itemCount: 4,
          itemHeight: 80,
          padding: EdgeInsets.fromLTRB(22, 16, 22, 0)),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text('Could not load feed',
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => ref.invalidate(feedPostsProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Retry',
                    style: AppTypography.label
                        .copyWith(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
      data: (_) {
        if (posts.isEmpty) {
          return _EmptyState();
        }

        // Build list with date separators
        final items = <_FeedListItem>[];
        DateTime? lastDate;
        for (final post in posts) {
          final postDate = DateTime(post.createdAt.year,
              post.createdAt.month, post.createdAt.day);
          if (lastDate == null || lastDate != postDate) {
            items.add(_FeedListItem.separator(postDate));
            lastDate = postDate;
          }
          items.add(_FeedListItem.post(post));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            if (item.isSeparator) {
              return _DateSeparator(date: item.date!);
            }
            return _TextFeedItem(
              post: item.post!,
              isSelf: item.post!.authorId == currentUserId,
              // Group: hide avatar if prev post is from same author within 5min
              showAvatar: _shouldShowAvatar(items, i),
            );
          },
        );
      },
    );
  }

  bool _shouldShowAvatar(List<_FeedListItem> items, int i) {
    final current = items[i];
    if (current.post == null) return true;
    if (i == 0) return true;
    final prev = items[i - 1];
    if (prev.isSeparator || prev.post == null) return true;
    if (prev.post!.authorId != current.post!.authorId) return true;
    final diff = current.post!.createdAt
        .difference(prev.post!.createdAt)
        .inMinutes
        .abs();
    return diff >= 5;
  }
}

class _FeedListItem {
  final FeedPost? post;
  final DateTime? date;

  const _FeedListItem._({this.post, this.date});
  factory _FeedListItem.post(FeedPost p) => _FeedListItem._(post: p);
  factory _FeedListItem.separator(DateTime d) => _FeedListItem._(date: d);

  bool get isSeparator => date != null;
}

// ── Date Separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    String label;
    if (d == today) {
      label = 'TODAY · ${DateFormat('MMMM d').format(date).toUpperCase()}';
    } else if (d == yesterday) {
      label = 'YESTERDAY · ${DateFormat('MMMM d').format(date).toUpperCase()}';
    } else {
      label = DateFormat('EEEE, MMMM d').format(date).toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
      child: Center(
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ── Text Feed Item ────────────────────────────────────────────────────────────

class _TextFeedItem extends ConsumerWidget {
  const _TextFeedItem({
    required this.post,
    required this.isSelf,
    required this.showAvatar,
  });

  final FeedPost post;
  final bool isSelf;
  final bool showAvatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersMap = ref.watch(householdMembersMapProvider);
    final author = membersMap[post.authorId];
    final initials = author != null ? _initials(author.displayName) : '?';
    final name = author?.displayName.split(' ').first ?? 'Member';

    final avatarWidget = showAvatar
        ? MemberAvatar(
            memberId: post.authorId,
            initials: initials,
            size: 36,
            borderRadius: 12,
          )
        : const SizedBox(width: 36);

    final bubble = _Bubble(post: post, isSelf: isSelf);
    final timestamp = Padding(
      padding: EdgeInsets.only(
          top: 4, left: isSelf ? 0 : 48, right: isSelf ? 0 : 0),
      child: Text(
        _formatTime(post.createdAt),
        style: AppTypography.labelSmall.copyWith(
          fontSize: 10,
          color: AppColors.textTertiary,
        ),
        textAlign: isSelf ? TextAlign.right : TextAlign.left,
      ),
    );

    final content = Column(
      crossAxisAlignment:
          isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showAvatar && !isSelf)
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 4),
            child: Text(
              name,
              style: AppTypography.label.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        Row(
          mainAxisAlignment:
              isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: isSelf
              ? [bubble, const SizedBox(width: 8), avatarWidget]
              : [avatarWidget, const SizedBox(width: 8), bubble],
        ),
        _ReactionsRow(postId: post.id),
        timestamp,
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: content,
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day) {
      return DateFormat('h:mm a').format(dt);
    }
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.post, required this.isSelf});
  final FeedPost post;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final selfDecoration = BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, Color(0xFFFF9A6C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      ),
    );

    final otherDecoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      ),
      boxShadow: const [HomeShadow.card],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.68,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isSelf ? selfDecoration : otherDecoration,
        child: Text(
          post.content,
          style: AppTypography.body.copyWith(
            fontSize: 13,
            height: 1.5,
            color: isSelf ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Reactions Row ─────────────────────────────────────────────────────────────

class _ReactionsRow extends ConsumerWidget {
  const _ReactionsRow({required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reactionsAsync = ref.watch(postReactionsProvider(postId));
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';

    return reactionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (reactions) {
        if (reactions.isEmpty) return const SizedBox(height: 4);

        // Group by emoji
        final grouped = <String, List<Reaction>>{};
        for (final r in reactions) {
          (grouped[r.emoji] ??= []).add(r);
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: grouped.entries.map((entry) {
              final isActive =
                  entry.value.any((r) => r.memberId == currentUserId);
              return _ReactionPill(
                emoji: entry.key,
                count: entry.value.length,
                isActive: isActive,
                onTap: () async {
                  await ref
                      .read(reactionActionsProvider)
                      .toggleReaction(postId, currentUserId, entry.key);
                  ref.invalidate(postReactionsProvider(postId));
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ReactionPill extends StatefulWidget {
  const _ReactionPill({
    required this.emoji,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_ReactionPill> createState() => _ReactionPillState();
}

class _ReactionPillState extends State<_ReactionPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.primaryLight
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isActive
                    ? AppColors.primary
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.emoji,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '${widget.count}',
                  style: AppTypography.label.copyWith(
                    fontSize: 11,
                    color: widget.isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Compose Bar ───────────────────────────────────────────────────────────────

class _ComposeBar extends StatelessWidget {
  const _ComposeBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.isSending,
    required this.onSend,
    required this.onPrefill,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isSending;
  final VoidCallback onSend;
  final void Function(String) onPrefill;

  static const _quickReplies = [
    '📅 Share event',
    '✅ Task done!',
    '🛒 Grocery item',
    '📸 Photo',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 10, 22, 10 + bottomInset),
          decoration: const BoxDecoration(
            color: Color(0xF5F7F4EF), // bg at 96% opacity
            border: Border(
                top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input row
              Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isFocused
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                        boxShadow: const [HomeShadow.card],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {}, // TODO: open emoji picker
                            child: const Text('😊',
                                style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onSubmitted: (_) => onSend(),
                              style: AppTypography.body
                                  .copyWith(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText:
                                    'Share something with the family...',
                                hintStyle: AppTypography.body.copyWith(
                                    color: AppColors.textTertiary),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 10),
                              ),
                              textCapitalization:
                                  TextCapitalization.sentences,
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  GestureDetector(
                    onTap: onSend,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSending
                            ? AppColors.textTertiary
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: const [HomeShadow.card],
                      ),
                      child: isSending
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              // Quick replies row
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: SizedBox(
                  height: isFocused ? null : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _quickReplies.map((label) {
                          return GestureDetector(
                            onTap: () => onPrefill(label),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.border, width: 1.5),
                              ),
                              child: Text(
                                label,
                                style: AppTypography.label.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text('💬', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Share updates with your family',
            style: AppTypography.body
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── New Post Sheet (stub) ─────────────────────────────────────────────────────

class _NewPostSheet extends ConsumerStatefulWidget {
  const _NewPostSheet();

  @override
  ConsumerState<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends ConsumerState<_NewPostSheet> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    final success =
        await ref.read(feedActionsProvider.notifier).createPost(content: text);
    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post',
                style: AppTypography.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          22,
          20,
          22,
          20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('New Post',
              style: AppTypography.h2
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            style: AppTypography.body
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'What\'s happening in the family?',
              hintStyle: AppTypography.body
                  .copyWith(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isSending ? null : _post,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color: _isSending
                      ? AppColors.textTertiary
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(HomeRadius.button),
                  boxShadow: const [HomeShadow.card],
                ),
                child: Center(
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Post to Family',
                          style: AppTypography.label
                              .copyWith(color: Colors.white, fontSize: 14),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
