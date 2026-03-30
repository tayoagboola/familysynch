import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../providers/ai_providers.dart';

// ── Panel Colors ──────────────────────────────────────────────────────────────

const _panelBg    = Color(0xFF0F0F23);
const _aiPurple   = Color(0xFF6C63FF);
const _aiPurple2  = Color(0xFFA78BFA);
const _white07    = Color(0x12FFFFFF);
const _white10    = Color(0x1AFFFFFF);
const _white25    = Color(0x40FFFFFF);
const _white60    = Color(0x99FFFFFF);
const _white80    = Color(0xCCFFFFFF);
const _white85    = Color(0xD9FFFFFF);

// ── AI Panel ──────────────────────────────────────────────────────────────────

class AIPanel extends ConsumerStatefulWidget {
  const AIPanel({super.key});

  @override
  ConsumerState<AIPanel> createState() => _AIPanelState();
}

class _AIPanelState extends ConsumerState<AIPanel> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    // Mark nudges read when panel opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId != null) {
        ref.read(nudgeActionsProvider).markAllRead(userId);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? text]) async {
    final msg = (text ?? _controller.text).trim();
    if (msg.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();
    await sendAIMessage(ref, msg);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(isAITypingProvider);

    // Scroll when messages update
    ref.listen(chatMessagesProvider, (_, __) => _scrollToBottom());

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: const BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _white25,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Header
          _AIPanelHeader(onClose: () => Navigator.pop(context)),
          // Context pills
          const _ContextPillRow(),
          // Chat list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (isTyping && i == messages.length) {
                  return const _TypingIndicator();
                }
                final msg = messages[i];
                if (msg.role == 'user') {
                  return _UserMessage(message: msg);
                }
                return _AIMessage(
                  message: msg,
                  showAvatar: i == 0 ||
                      messages[i - 1].role != 'assistant',
                );
              },
            ),
          ),
          // Quick prompts
          _QuickPromptsRow(onTap: _send),
          // Input bar
          _AIInputBar(
            controller: _controller,
            focusNode: _focusNode,
            isFocused: _isFocused,
            onSend: _send,
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _AIPanelHeader extends StatefulWidget {
  const _AIPanelHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_AIPanelHeader> createState() => _AIPanelHeaderState();
}

class _AIPanelHeaderState extends State<_AIPanelHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;
  late final Animation<double> _dotOpacity;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _dotOpacity = Tween<double>(begin: 1.0, end: 0.3).animate(
        CurvedAnimation(parent: _dotController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF), width: 1)),
      ),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_aiPurple, _aiPurple2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _aiPurple.withAlpha(102),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FamilyAI',
                  style: AppTypography.h3.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _dotOpacity,
                      builder: (_, __) => Opacity(
                        opacity: _dotOpacity.value,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Connected to your family's data",
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _white07,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: _white60),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Context Pill Row ──────────────────────────────────────────────────────────

class _ContextPillRow extends ConsumerWidget {
  const _ContextPillRow();

  static const _pills = [
    ('calendar', '📅 Calendar'),
    ('tasks', '✅ Tasks'),
    ('grocery', '🛒 Grocery'),
    ('members', '👨‍👩‍👧 Members'),
    ('feed', '💬 Feed'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeContextProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _pills.map((p) {
          final isActive = active.contains(p.$1);
          return GestureDetector(
            onTap: () {
              final notifier = ref.read(activeContextProvider.notifier);
              final current = Set<String>.from(active);
              if (isActive) {
                current.remove(p.$1);
              } else {
                current.add(p.$1);
              }
              notifier.state = current;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0x336C63FF)
                    : _white07,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0x806C63FF)
                      : _white10,
                  width: 1,
                ),
              ),
              child: Text(
                p.$2,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: isActive ? _aiPurple2 : _white60,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── AI Message ────────────────────────────────────────────────────────────────

class _AIMessage extends StatefulWidget {
  const _AIMessage({required this.message, required this.showAvatar});
  final ChatMessage message;
  final bool showAvatar;

  @override
  State<_AIMessage> createState() => _AIMessageState();
}

class _AIMessageState extends State<_AIMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar
              widget.showAvatar
                  ? Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_aiPurple, _aiPurple2],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Center(
                          child: Text('🤖',
                              style: TextStyle(fontSize: 14))),
                    )
                  : const SizedBox(width: 36),
              // Bubble
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: _white07,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(18),
                        ),
                        border: Border.all(
                            color: const Color(0x14FFFFFF), width: 1),
                      ),
                      child: Text(
                        widget.message.content,
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: _white85,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fmt(widget.message.timestamp),
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: _white25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) => DateFormat('h:mm a').format(dt);
}

// ── User Message ──────────────────────────────────────────────────────────────

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 40),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_aiPurple, _aiPurple2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _aiPurple.withAlpha(89),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: _white25,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _anims = _controllers
        .map((c) => Tween<double>(begin: 0, end: -5).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();

    // Stagger starts
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_aiPurple, _aiPurple2]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 14))),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _white07,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border:
                  Border.all(color: const Color(0x14FFFFFF), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _anims[i].value),
                    child: Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: const BoxDecoration(
                        color: _white25,
                        shape: BoxShape.circle,
                      ),
                    ),
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

// ── Quick Prompts Row ─────────────────────────────────────────────────────────

class _QuickPromptsRow extends StatefulWidget {
  const _QuickPromptsRow({required this.onTap});
  final void Function(String) onTap;

  @override
  State<_QuickPromptsRow> createState() => _QuickPromptsRowState();
}

class _QuickPromptsRowState extends State<_QuickPromptsRow> {
  int? _activeIndex;

  static const _prompts = [
    "What does our week look like?",
    "Who's free this weekend?",
    "What's overdue?",
    "Add milk to grocery",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try asking',
            style: AppTypography.labelSmall.copyWith(
              fontSize: 11,
              color: _white25,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(_prompts.length, (i) {
                final isActive = _activeIndex == i;
                return GestureDetector(
                  onTap: () async {
                    setState(() => _activeIndex = i);
                    widget.onTap(_prompts[i]);
                    await Future.delayed(
                        const Duration(milliseconds: 300));
                    if (mounted) setState(() => _activeIndex = null);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0x336C63FF)
                          : _white07,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0x806C63FF)
                            : _white10,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _prompts[i],
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 12,
                        color: isActive ? _aiPurple2 : _white60,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class _AIInputBar extends StatefulWidget {
  const _AIInputBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final Future<void> Function([String?]) onSend;

  @override
  State<_AIInputBar> createState() => _AIInputBarState();
}

class _AIInputBarState extends State<_AIInputBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sendController;
  late final Animation<Offset> _sendSlide;

  @override
  void initState() {
    super.initState();
    _sendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sendSlide = TweenSequence([
      TweenSequenceItem(
          tween: Tween<Offset>(
              begin: Offset.zero, end: const Offset(0.3, -0.3)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween<Offset>(
              begin: const Offset(-0.3, 0.3), end: Offset.zero),
          weight: 50),
    ]).animate(
        CurvedAnimation(parent: _sendController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _sendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _white07,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isFocused
                ? const Color(0x806C63FF)
                : _white10,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Mic
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Voice coming soon 🎙️',
                      style: AppTypography.body
                          .copyWith(color: Colors.white)),
                  backgroundColor: const Color(0xFF2D2D5E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child: const Opacity(
                opacity: 0.5,
                child: Text('🎙️', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            // Input
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                onSubmitted: (_) => widget.onSend(),
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: _white80,
                ),
                cursorColor: _aiPurple2,
                decoration: InputDecoration(
                  hintText: 'Ask about your family...',
                  hintStyle: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: _white25,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            GestureDetector(
              onTap: () async {
                _sendController.forward(from: 0);
                await widget.onSend();
              },
              child: SlideTransition(
                position: _sendSlide,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_aiPurple, _aiPurple2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: _aiPurple.withAlpha(102),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
