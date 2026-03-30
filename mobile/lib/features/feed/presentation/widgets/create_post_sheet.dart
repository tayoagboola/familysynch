import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme.dart';
import '../controllers/feed_providers.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final ok = await ref
        .read(feedActionsProvider.notifier)
        .createPost(content: text);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not post. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(feedActionsProvider).isLoading;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(children: [
            Text('New announcement',
                style: theme.textTheme.titleLarge),
            const Spacer(),
            TextButton(
              onPressed: isLoading ? null : _post,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Post'),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),

          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: "What's happening with the family?",
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppRadius.md)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ]),
      ),
    );
  }
}
