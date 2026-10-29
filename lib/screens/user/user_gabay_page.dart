import 'dart:async';

import 'package:flutter/material.dart';

import '../../brand.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/customer_repository.dart';
import '../../data/catering.dart';
import '../../data/product.dart';
import '../../data/member_preferences.dart';
import '../../data/recommendation_repository.dart';
import '../../data/recommendation.dart';
import '../../data/taste_profile.dart';
import '../../widgets.dart';
import '../detail_sheets.dart';
import '../home_sections.dart';
import 'user_shell.dart';
import '../../data/gabay_knowledge.dart';
import '../../data/catering_repository.dart';
import '../../data/product_repository.dart';

/// Gabay — the member-side AI catering companion ("gabay" = guide).
///
/// Now partially functional: the assistant can hold a grounded conversation
/// (FAQ, package matching by budget + headcount, healthier-menu suggestions,
/// and an honest "why was this recommended?" explanation) from the business's
/// own cleaned content, on-device. The live "Picks just for you" panel still
/// runs from the recommendation stream as before.
///
/// Out of scope for this pass: open-ended chit-chat, changing filed orders, and
/// anything that fabricates a package, price, or inclusion that isn't published.
class UserGabayPage extends StatefulWidget {
  const UserGabayPage({super.key, this.onNavigate});

  /// Switches the member shell to another tab. Null when Gabay is hosted
  /// somewhere that can't navigate — the recommendation panel then simply
  /// doesn't offer to open Packages.
  final void Function(int index)? onNavigate;

  @override
  State<UserGabayPage> createState() => _UserGabayPageState();
}

class _UserGabayPageState extends State<UserGabayPage> {
  final TextEditingController _controller = TextEditingController();
  final _GabayChat _chat = _GabayChat();

  StreamSubscription<RecommendationSet>? _recSub;
  RecommendationSet _recs = RecommendationSet.empty;
  bool _recsLoading = true;

  /// The capabilities Gabay now actually offers. "Picks just for you" is still
  /// absent from this list because it's live and lives in [_RecommendedPanel].
  static const List<(IconData, String, String)> _capabilities = [
    (
      Icons.savings_outlined,
      'Match my budget',
      'Tell me your budget and guest count — I\'ll find the right package.',
    ),
    (
      Icons.eco_outlined,
      'Healthier options',
      'Lighter, more nutritious swaps for any dish on the menu.',
    ),
    (
      Icons.event_seat_outlined,
      'Plan the event',
      'Layout pointers — like why moving the buffet helps the flow.',
    ),
    (
      Icons.help_outline,
      'Why this?',
      'I\'ll explain why a package or setup was recommended to you.',
    ),
    (
      Icons.chat_bubble_outline,
      'Ask anything',
      'Menus, bookings, planning questions — just ask away.',
    ),
  ];

  /// Starter prompts shown as tappable chips — now wired to real replies.
  static const List<String> _starters = [
    'Recommend a package for ₱20,000 · 50 pax',
    'Suggest healthier meal options',
    'Why was this package recommended?',
    'Help me plan my event layout',
    'How do I book catering?',
  ];

  @override
  void initState() {
    super.initState();
    _recSub = RecommendationRepository().watchRecommended().listen(
      (set) {
        if (!mounted) return;
        setState(() {
          _recs = set;
          _recsLoading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _recs = RecommendationSet.empty;
          _recsLoading = false;
        });
      },
    );

    // Open with one grounded welcome reply after the greeting bubble, so the
    // screen doesn't start as a blank chat. Keep it short — the capabilities
    // list and starters below already say what Gabay can do.
    _chat.addAssistant(
      'Kumusta, ${CustomerRepository().displayName?.trim().split(' ').first ?? 'Kaibigan'}! '
      'I\'m Gabay, your catering companion. I can suggest meals and packages, work to '
      'your budget and guest count, and answer your planning questions. Try one of the '
      'suggestions below, or ask me anything about catering.',
    );
  }

  @override
  void dispose() {
    _recSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    _controller.clear();
    _chat.addUser(text);
    _replay(text);
  }

  void _replay(String text) {
    // Keep the helper static from the UI's point of view: schedule a rebuild
    // when the reply lands, and surface errors as a quiet note rather than a
    // broken screen.
    _chat
        .reply(text, prefs: MemberPreferencesScope.value, recs: _recs)
        .then(
          (reply) {
            if (!mounted) return;
            setState(() {
              _chat.addAssistant(reply);
            });
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _chat.addAssistant(
                'Sorry — I dropped your message. Try again in a moment.',
              );
            });
          },
        );
  }

  void _sendStarter(String prompt) {
    FocusScope.of(context).unfocus();
    _controller.text = prompt;
    _send();
  }

  @override
  Widget build(BuildContext context) {
    final name = CustomerRepository().displayName?.trim() ?? '';
    final first = name.isEmpty ? 'Kaibigan' : name.split(' ').first;

    // The recommendation panel answers to the member's own switch over whether
    // Gabay may put suggestions in front of them — watched, not read once, so
    // toggling it in Settings takes the panel away without a tab bounce.
    return ValueListenableBuilder<MemberPreferences>(
      valueListenable: MemberPreferencesScope.notifier,
      builder: (context, prefs, _) => Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              children: [
                FadeSlideIn(child: const _GabayHeader()),
                const SizedBox(height: AppSpacing.xl),

                // Greeting from the assistant.
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: _AssistantBubble(
                    'Kumusta, $first! I\'m Gabay, your catering companion. '
                    'I can suggest meals and packages, work to your budget and '
                    'guest count, and answer your planning questions. How can I '
                    'help today?',
                  ),
                ),
                const SizedBox(height: AppSpacing.section),

                // ── Picks just for you (live) ────────────────────────────────
                SmoothReveal(
                  visible:
                      prefs.gabaySuggestions &&
                      (_recsLoading || _recs.isNotEmpty),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.section),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 110),
                      child: _RecommendedPanel(
                        loading: _recsLoading,
                        set: _recs,
                        onOpenPackages: widget.onNavigate == null
                            ? null
                            : () => widget.onNavigate!(UserShell.tabPackages),
                      ),
                    ),
                  ),
                ),

                // ── Conversation ─────────────────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: _ChatHistory(_chat.messages),
                ),
                const SizedBox(height: AppSpacing.section),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 170),
                  child: Text(
                    'HERE\'S HOW I CAN HELP',
                    style: AppTextStyles.eyebrow,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < _capabilities.length; i++) ...[
                  FadeSlideIn(
                    delay: Duration(milliseconds: 200 + i * 50),
                    child: _CapabilityCard(
                      icon: _capabilities[i].$1,
                      title: _capabilities[i].$2,
                      subtitle: _capabilities[i].$3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                ],
                const SizedBox(height: AppSpacing.lg),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: Text('TRY ASKING', style: AppTextStyles.eyebrow),
                ),
                const SizedBox(height: AppSpacing.md),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final prompt in _starters)
                        _PromptChip(prompt, onTap: () => _sendStarter(prompt)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Composer(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

// ════════════════════════════ Chat history ════════════════════════════
/// The scrolling conversation so far — user messages and assistant replies, both
/// rendered as chat bubbles.
class _ChatHistory extends StatelessWidget {
  const _ChatHistory(this.messages);

  final List<_GabayMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 360),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: messages.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final message = messages[i];
          return message.isFromUser
              ? _UserBubble(message.text)
              : _AssistantBubble(message.text);
        },
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: AppCard(
            radius: AppRadius.lg,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(text, style: AppTextStyles.body),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}

// ════════════════════════════ Recommended panel ════════════════════════════
/// "Picks just for you" — the collaborative-filtering recommendations, in the
/// one place on the member side that can explain itself.
class _RecommendedPanel extends StatelessWidget {
  const _RecommendedPanel({
    required this.loading,
    required this.set,
    required this.onOpenPackages,
  });

  final bool loading;
  final RecommendationSet set;

  /// Opens the Packages tab; null when this Gabay can't navigate.
  final VoidCallback? onOpenPackages;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.recommend_outlined,
                    size: 19,
                    color: AppColors.goldDeep,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    'Picks just for you',
                    style: AppTextStyles.serif(size: 17, height: 1.15),
                  ),
                ),
              ],
            ),
          ),
          SmoothReveal(
            visible: !loading,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: RecommendationSourceBadge(set.source),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 196,
            child: SmoothSwap(
              alignment: Alignment.center,
              child: loading
                  ? const Center(
                      key: ValueKey('picks-loading'),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.goldDeep,
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const ValueKey('picks'),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: set.items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final item = set.items[i];
                        return RecommendedCard(
                          item,
                          onTap: () {
                            if (!item.isPackage) {
                              showProductSheet(context, item.product!);
                            } else {
                              onOpenPackages?.call();
                            }
                          },
                        );
                      },
                    ),
            ),
          ),
          SmoothReveal(
            visible: !loading && onOpenPackages != null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm + 2,
                AppSpacing.md,
                0,
              ),
              child: TextButton(
                onPressed: onOpenPackages,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See the packages',
                      style: AppTextStyles.sans(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.goldDeep,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.goldDeep,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════ Header ════════════════════════════
class _GabayHeader extends StatelessWidget {
  const _GabayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.55),
              width: 1.4,
            ),
          ),
          child: const GabayMark(size: 26, color: AppColors.goldDeep),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Gabay', style: AppTextStyles.serif(size: 26)),
                  const SizedBox(width: AppSpacing.sm),
                  const _PreviewTag(),
                ],
              ),
              const SizedBox(height: 2),
              Text('Your catering companion', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.14),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Text(
        'PREVIEW',
        style: AppTextStyles.engraved(
          size: 8,
          color: AppColors.goldDeep,
          spacing: 1.4,
        ),
      ),
    );
  }
}

// ════════════════════════════ Assistant bubble ════════════════════════════
class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: const GabayMark(size: 15, color: AppColors.goldDeep),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: AppCard(
            radius: AppRadius.lg,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(text, style: AppTextStyles.body),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════ Capability card ════════════════════════════
class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(icon, size: 22, color: AppColors.goldDeep),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.serif(size: 16, height: 1.15)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════ Prompt chip ════════════════════════════
class _PromptChip extends StatelessWidget {
  const _PromptChip(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: AppColors.hairline),
        ),
        child: Text(
          label,
          style: AppTextStyles.sans(
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.brownSoft,
            spacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════ Composer ════════════════════════════
class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller,
                  hint: 'Ask Gabay anything…',
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PressableScale(
                onTap: onSend,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.brown,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: AppColors.cream,
                    size: 22,
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

// ════════════════════════════ Grounded chat controller ════════════════════════════
/// A tiny on-device conversation controller for Gabay.
///
/// Replies are grounded in the business's cleaned content:
///   - FAQ from the existing written FAQ ([GabayFaq.findAnswer])
///   - Packages from the published catalog ([GabayPackageKnowledge])
///   - Menu / healthier options from the published menu ([GabayMenuKnowledge])
///   - "Why this?" from the recommendation evidence ([GabayExplanationKnowledge])
///
/// It stays deliberately bounded: no open-ended chit-chat, no fabricating
/// packages/prices/inclusions, no pretending to change a filed order.
class _GabayChat {
  final List<_GabayMessage> messages = [];

  void addUser(String text) {
    messages.add(_GabayMessage(text, fromUser: true));
  }

  void addAssistant(String text) {
    messages.add(_GabayMessage(text, fromUser: false));
  }

  Future<String> reply(
    String text, {
    required MemberPreferences prefs,
    required RecommendationSet recs,
  }) async {
    final person = GabayPersonalization(
      prefs: prefs,
      groupSize: _activeGroup(prefs),
      occasionTypes: _occasionTypes(prefs),
      dietDirective: _dietDirective(prefs),
      healthierFirst: prefs.gabayHealthierFirst,
    );
    // ── FAQ first ──────────────────────────────────────────────────────────
    final faq = GabayFaq.findAnswer(text);
    if (faq != null) {
      return faq.answer;
    }

    // Explicit FAQ-ish questions the matcher might only partially catch.
    if (_looksLike(text, 'how do i book')) {
      return GabayFaq.groups
          .expand((g) => g.items)
          .firstWhere(
            (item) =>
                item.question.toLowerCase().contains('how do i book catering'),
            orElse: () => GabayFaq.groups[0].items[0],
          )
          .answer;
    }
    if (_looksLike(text, 'food pack') && _looksLike(text, 'order')) {
      return GabayFaq.groups
          .expand((g) => g.items)
          .firstWhere(
            (item) => item.question.toLowerCase().contains(
              'how do i order food packs',
            ),
            orElse: () => GabayFaq.groups[0].items[1],
          )
          .answer;
    }
    if (_looksLike(text, 'status')) {
      return GabayFaq.groups
          .expand((g) => g.items)
          .firstWhere(
            (item) => item.question.toLowerCase().contains(
              'what do the order statuses mean',
            ),
            orElse: () => GabayFaq.groups[0].items[2],
          )
          .answer;
    }
    if (_looksLike(text, 'downpayment') || _looksLike(text, 'pay up front')) {
      return GabayFaq.groups
          .expand((g) => g.items)
          .firstWhere(
            (item) => item.question.toLowerCase().contains(
              'how much do i pay up front',
            ),
            orElse: () => GabayFaq.groups[1].items[0],
          )
          .answer;
    }
    if (_looksLike(text, 'allerg') || _looksLike(text, 'allergy')) {
      return GabayFaq.groups
          .expand((g) => g.items)
          .firstWhere(
            (item) => item.question.toLowerCase().contains(
              'can you cook around an allergy',
            ),
            orElse: () => GabayFaq.groups[2].items[1],
          )
          .answer;
    }
    if (_looksLike(text, 'what is gabay') || _looksLike(text, 'gabay')) {
      return GabayFaq.groups
          .expand((g) => g.items)
          .firstWhere(
            (item) => item.question.toLowerCase().contains('what is gabay'),
            orElse: () => GabayFaq.groups[4].items[0],
          )
          .answer;
    }

    // ── Why was this recommended? ──────────────────────────────────────────
    if (_looksLike(text, 'why was this') ||
        _looksLike(text, 'why this') ||
        _looksLike(text, 'why recommend')) {
      return GabayExplanationKnowledge.explain(recs);
    }

    // ── Package matching by budget + headcount ─────────────────────────────
    final budget = _parseBudget(text);
    final group = _parseGroup(text);
    if (budget != null || group != null) {
      final all = await _packages();
      final fitting = GabayPackageKnowledge.fitting(
        all,
        budget: budget,
        group: group,
      );
      if (fitting.isNotEmpty) {
        return GabayPackagePersonalization.reason(person, fitting);
      }
      // Offer the closest thing when nothing fits exactly.
      final candidates = GabayPackageKnowledge.recommendable(all);
      if (candidates.isNotEmpty) {
        return 'Nothing in our current packages fits ₱${_pesoBand(budget)} a head for '
            '${_groupLabel(group)} exactly, but here\'s what we do have: '
            '${candidates.take(3).map((p) => p.name).join(", ")}. Tap a package to see '
            'the full details and book it.';
      }
      return 'We don\'t have any active packages to show just yet — check back after the '
          'kitchen has published some.';
    }

    // ── Healthier options ───────────────────────────────────────────────────
    if (_looksLike(text, 'healthier') ||
        _looksLike(text, 'lighter') ||
        _looksLike(text, 'nutritious')) {
      final all = await _products();
      final visible = GabayMenuKnowledge.visible(all);
      if (visible.isEmpty) {
        return 'The menu is still loading — try again in a moment.';
      }
      // Fall back to the most obvious "lighter" categories if the member didn't
      // name a dish.
      final suggestions =
          GabayMenuKnowledge.inCategory(all, 'Vegetables') +
          GabayMenuKnowledge.inCategory(all, 'Seafood');
      if (suggestions.isNotEmpty) {
        final names = suggestions.take(4).map((p) => p.name).toList();
        return 'Here are some lighter options from our current menu: '
            '${names.join(", ")}. These are suggestions to ask the kitchen about — '
            'the final call is always with them, especially if you have an allergy.';
      }
      return 'We don\'t have anything that reads as a lighter option on the current menu '
          'just yet. Try asking about a specific dish and I\'ll suggest alternatives.';
    }

    // ── Healthier swap for a named dish ─────────────────────────────────────
    final dish = _findDish(text, all: await _products());
    if (dish != null) {
      final alts = GabayMenuKnowledge.healthierAlternatives(
        await _products(),
        dish.category,
      );
      if (alts.isNotEmpty) {
        final names = alts.take(4).map((p) => p.name).toList();
        return 'For a lighter take on "${dish.name}", you might also look at: '
            '${names.join(", ")}. These are menu suggestions — the kitchen makes '
            'the final call, and remember we cook on shared equipment.';
      }
      return 'I don\'t have a clearer lighter alternative for "${dish.name}" on the '
          'current menu right now. The kitchen can still suggest something when you book.';
    }

    // ── Event planning / layout pointers (complementary role) ───────────────
    if (_looksLike(text, 'plan my event') ||
        _looksLike(text, 'event layout') ||
        _looksLike(text, 'layout')) {
      return 'I can give you a few planning pointers, but the 3D layout planner is the '
          'best place for the actual room setup — I\'m here to explain the "why" behind it. '
          'A good place to start: tell me your occasion, headcount, and budget, and I can '
          'suggest a package and a quick planning checklist for it.';
    }

    // ── Fallback ────────────────────────────────────────────────────────────
    if (prefs.gabaySuggestions && recs.isNotEmpty) {
      return '${GabayExplanationKnowledge.leadIn(recs)} If you\'d rather pick something specific, try asking about a package or the menu.';
    }

    return 'I\'m still learning the parts of catering that matter here. Try asking how to '
        'book, how the downpayment works, what our packages include, or for healthier swaps '
        'on a dish — and if I don\'t know, I\'ll tell you plainly instead of guessing.';
  }

  // ── Small helpers ────────────────────────────────────────────────────────

  bool _looksLike(String text, String fragment) {
    return text.toLowerCase().contains(fragment.toLowerCase());
  }

  GroupSize? _activeGroup(MemberPreferences prefs) {
    final usual = prefs.person?.groupSize;
    if (usual != null) return usual;
    final crowd = prefs.person?.groupSize;
    return crowd;
  }

  Set<OccasionType> _occasionTypes(MemberPreferences prefs) {
    final profile = prefs.person;
    if (profile == null) return const {};
    return profile.occasionTypes
        .map((k) => OccasionType.fromKey(k))
        .whereType<OccasionType>()
        .toSet();
  }

  String? _dietDirective(MemberPreferences prefs) {
    final profile = prefs.person;
    final tasty = profile?.budgetRange;
    if (tasty != null) return tasty.label;
    final avoid = prefs.avoidAllergens;
    final cleaned = avoid.where((a) => a.trim().isNotEmpty).toList();
    if (cleaned.isNotEmpty) {
      return 'avoid ${cleaned.map((a) => a.toLowerCase().trim()).join(" and ")}';
    }
    return null;
  }

  BudgetRange? _parseBudget(String text) {
    if (_looksLike(text, 'budget') ||
        _looksLike(text, 'tipid') ||
        _looksLike(text, 'under')) {
      return BudgetRange.budget;
    }
    if (_looksLike(text, 'sakto') ||
        _looksLike(text, 'mid') ||
        _looksLike(text, '350') ||
        _looksLike(text, '700')) {
      return BudgetRange.mid;
    }
    if (_looksLike(text, 'all-out') ||
        _looksLike(text, 'premium') ||
        _looksLike(text, '700') ||
        _looksLike(text, 'over')) {
      return BudgetRange.premium;
    }
    return null;
  }

  GroupSize? _parseGroup(String text) {
    if (_looksLike(text, 'small') ||
        _looksLike(text, 'intimate') ||
        _looksLike(text, '30')) {
      return GroupSize.small;
    }
    if (_looksLike(text, 'medium') ||
        _looksLike(text, 'crowd') ||
        _looksLike(text, '50') ||
        _looksLike(text, '100')) {
      return GroupSize.medium;
    }
    if (_looksLike(text, 'large') ||
        _looksLike(text, 'barangay') ||
        _looksLike(text, 'more than 100') ||
        _looksLike(text, '150') ||
        _looksLike(text, '200') ||
        _looksLike(text, '500')) {
      return GroupSize.large;
    }
    return null;
  }

  String _pesoBand(BudgetRange? budget) {
    switch (budget) {
      case BudgetRange.budget:
        return '350';
      case BudgetRange.mid:
        return '350–700';
      case BudgetRange.premium:
        return '700';
      case null:
        return 'your budget';
    }
  }

  String _groupLabel(GroupSize? group) {
    switch (group) {
      case GroupSize.small:
        return 'up to 30 guests';
      case GroupSize.medium:
        return '30–100 guests';
      case GroupSize.large:
        return 'more than 100 guests';
      case null:
        return 'your guest count';
    }
  }

  Future<List<CateringPackage>> _packages() async {
    // The repository streams live data; for a reply we just need one snapshot.
    return CateringRepository().watchPackages().first;
  }

  Future<List<Product>> _products() async {
    return ProductRepository().watchVisible().first;
  }

  Product? _findDish(String text, {required List<Product> all}) {
    final lower = text.toLowerCase();
    Product? best;
    int bestScore = 0;
    for (final p in all) {
      final hay = '${p.name} ${p.category}'.toLowerCase();
      var score = 0;
      for (final word in _dishKeywords(lower)) {
        if (hay.contains(word)) score++;
      }
      if (_looksLike(text, p.name.toLowerCase())) score += 2;
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
    return bestScore > 0 ? best : null;
  }

  List<String> _dishKeywords(String text) {
    // Trim the obvious question framing so we match the dish, not the sentence.
    final stopwords = <String>{
      'suggest',
      'healthier',
      'options',
      'for',
      'a',
      'the',
      'can',
      'you',
      'give',
      'me',
      'alternatives',
      'swap',
      'swaps',
      'lighter',
      'meal',
      'meals',
      'dish',
      'dishes',
      'from',
      'menu',
      'i',
      'want',
      'please',
    };
    return text
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !stopwords.contains(w))
        .toList();
  }
}

class _GabayMessage {
  const _GabayMessage(this.text, {required this.fromUser});

  final String text;
  final bool fromUser;

  bool get isFromUser => fromUser;
}
