/// Gabay's grounded knowledge layer — the business's own cleaned content, exposed
/// as the things the assistant can actually answer from.
///
/// This is what "trained on the cleaned datasets" means here: Gabay answers from
/// the business's published content and the member's own context, on-device, with
/// no separate model. The FAQ is the existing written FAQ in the app; packages and
/// menu come from the live Firestore catalog; recommendation explanations come from
/// the same evidence the recommendation engine already produces.
///
/// Everything here is a read-only helper over the app's existing repositories, so
/// Gabay stays grounded in what the business has actually published right now.
library;

import 'package:flutter/foundation.dart';

import 'catering.dart';
import 'member_preferences.dart';
import 'product.dart';
import 'recommendation.dart';

/// The FAQ content Gabay answers from — the business's existing written FAQ, lifted
/// out of the Help & FAQ settings screen so the assistant can search it instead of
/// only the settings UI exposing it.
///
/// Groups and items are the same content the settings screen shows; the difference
/// is that this is now a real knowledge source the assistant can match questions to.
class GabayFaq {
  /// All FAQ content, grouped as the business wrote it.
  static const List<GabayFaqGroup> groups = [
    GabayFaqGroup(
      label: 'BOOKING & ORDERS',
      items: [
        GabayFaqItem(
          question: 'How do I book catering?',
          answer:
              'Open the Packages tab, choose the package you like and tap "Book Us '
              'Now". The wizard walks you through the date, the venue, your headcount '
              'and a dish for each course, then files the order. It reaches us as '
              'Pending right away, and we call your contact number to go through the '
              'details.',
        ),
        GabayFaqItem(
          question: 'How do I order food packs or party trays?',
          answer:
              'Also from the Packages tab — "Book Us Now" for food packs. It\'s a '
              'shorter form built around our written quotation: the occasion, when and '
              'where it\'s going, and a menu list with a pax count on every dish.',
        ),
        GabayFaqItem(
          question: 'What do the order statuses mean?',
          answer:
              'Pending — we have your order and are going through it.\n'
              'Confirmed — your date is locked in and the kitchen is planning for it.\n'
              'Completed — the event is done, and maraming salamat.\n'
              'Declined — we couldn\'t take that one on. Message us and we\'ll see what '
              'else we can arrange.',
        ),
        GabayFaqItem(
          question: 'Where do I see the orders I\'ve sent?',
          answer:
              'Settings → Order tracking. Every order you\'ve filed is there, newest '
              'first, with the open ones on top. It updates itself as we move an order '
              'along, so there\'s nothing to refresh.',
        ),
        GabayFaqItem(
          question: 'Can I change or cancel an order I\'ve already sent?',
          answer:
              'Not from the app. Once an order is filed, its details are ours to change '
              '— that\'s what stops an event being edited out from under the kitchen '
              'halfway through the planning. Call or message us and we\'ll adjust it with '
              'you.',
        ),
      ],
    ),
    GabayFaqGroup(
      label: 'PAYING',
      items: [
        GabayFaqItem(
          question: 'How much do I pay up front?',
          answer:
              'Half the order total holds your date. The balance is settled with the '
              'team on the day of the event.',
        ),
        GabayFaqItem(
          question: 'How can I pay the downpayment?',
          answer:
              'With GCash, Maya, GrabPay or a Visa / Mastercard, on PayMongo\'s secure '
              'checkout page. Your card details never pass through this app — we only '
              'ever see that the payment cleared.',
        ),
        GabayFaqItem(
          question: 'I closed the payment page before finishing. Is my order lost?',
          answer:
              'No. Your order is filed before the payment, precisely so an interrupted '
              'checkout can\'t lose the form you filled in. Open Order tracking, tap the '
              'order and choose Pay — it hands you back the same checkout page, rather '
              'than starting a second one.',
        ),
        GabayFaqItem(
          question: 'My order says you\'ll send a quotation. What does that mean?',
          answer:
              'Some orders are priced by hand — a small delivery, or a spread that needs '
              'costing first. Those file without an online downpayment: we\'ll send you '
              'the quotation, then arrange the downpayment with you directly.',
        ),
        GabayFaqItem(
          question: 'When is my booking actually confirmed?',
          answer:
              'When we\'ve been through the details and the downpayment has landed. The '
              'status in Order tracking turns to Confirmed the moment it does — you don\'t '
              'have to chase us for it.',
        ),
      ],
    ),
    GabayFaqGroup(
      label: 'THE MENU & ALLERGENS',
      items: [
        GabayFaqItem(
          question: 'Where do the allergen tags come from?',
          answer:
              'Our own kitchen tags every dish. On the Menu, the allergen map shows how '
              'those tags run across the dishes you\'re looking at — warmer means both '
              'more common and higher-risk, so a peanut tag reads hotter than a soy one.',
        ),
        GabayFaqItem(
          question: 'Can you cook around an allergy?',
          answer:
              'Set the allergens in Settings → Dietary preference and we\'ll flag any dish '
              'on the Menu that carries one. Please also tell us in your booking notes and '
              'give us a call: we cook everything in one kitchen on shared equipment, so we '
              'can warn you, but we can\'t promise a dish is free of traces.',
        ),
        GabayFaqItem(
          question: 'A dish I liked has disappeared from the Menu.',
          answer:
              'The kitchen decides what\'s on show, so a dish comes off when it\'s out of '
              'season or resting for a while. It stays on your past orders, and you can '
              'always ask us about it.',
        ),
      ],
    ),
    GabayFaqGroup(
      label: 'YOUR ACCOUNT',
      items: [
        GabayFaqItem(
          question: 'How do I change my profile photo?',
          answer:
              'Open the Account tab and tap your picture. You can choose one from your '
              'gallery, or remove the one that\'s there.',
        ),
        GabayFaqItem(
          question: 'I\'ve forgotten my password.',
          answer:
              'On the log-in screen, tap "Forgot password?" and give us your email address '
              '— a reset link is on its way within a minute or two. Check your spam folder '
              'if it seems slow.',
        ),
        GabayFaqItem(
          question: 'Can I change my email address or phone number?',
          answer:
              'Not in the app yet. Your number is also how we keep two accounts from sharing '
              'one contact, so it\'s moved by hand — message us and we\'ll take care of it.',
        ),
        GabayFaqItem(
          question: 'I can\'t sign in even though my password is right.',
          answer:
              'An account can be suspended if something has gone wrong with it. Get in touch '
              'and we\'ll go through it with you.',
        ),
        GabayFaqItem(
          question: 'What do you do with my information?',
          answer:
              'Only what we need to cook for you and keep your account working. Settings → '
              'Privacy Policy lists exactly what we hold, who sees it, and how to have it '
              'changed or removed.',
        ),
      ],
    ),
    GabayFaqGroup(
      label: 'GABAY',
      items: [
        GabayFaqItem(
          question: 'What is Gabay?',
          answer:
              '"Gabay" means guide — it\'s your catering companion, in the middle of the '
              'bottom bar. It\'s still in preview: the plan is meal and package ideas drawn '
              'from your past orders, matching a package to your budget and headcount, '
              'lighter swaps for a dish, and pointers on your event layout. Your two Settings '
              'switches — "Gabay suggestions" and "Healthier suggestions first" — are what it '
              'will follow when it opens up.',
        ),
      ],
    ),
  ];

  /// Best-matching FAQ item for a member's question, or null when nothing fits well.
  ///
  /// Matching is intentionally simple and on-device: we look for the item whose
  /// question shares the most meaningful words with what the member typed. This is
  /// enough for a bounded FAQ assistant, and it keeps the answers grounded in the
  /// business's own copy rather than rephrasing it into something it might get wrong.
  static GabayFaqItem? findAnswer(String query) {
    final needle = query.toLowerCase().trim();
    if (needle.isEmpty) return null;

    // A small stopword set so a generic "how do I" doesn't match everything.
    final stopwords = <String>{
      'how', 'do', 'i', 'can', 'i', 'what', 'is', 'are', 'the', 'my',
      'a', 'an', 'and', 'or', 'to', 'for', 'in', 'on', 'of', 'with',
      'does', 'it', 'have', 'has', 'been', 'will', 'when', 'where',
    };

    final terms = needle.split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty && !stopwords.contains(t))
        .toSet();

    if (terms.isEmpty) return null;

    GabayFaqItem? best;
    int bestScore = 0;

    for (final group in groups) {
      for (final item in group.items) {
        final hay = '${item.question} ${item.answer}'.toLowerCase();
        var score = 0;
        for (final term in terms) {
          if (hay.contains(term)) score++;
        }
        // Prefer a match on the question itself over the same word in the answer.
        if (item.question.toLowerCase().contains(needle)) {
          score += 2;
        }
        if (score > bestScore) {
          bestScore = score;
          best = item;
        }
      }
    }

    // Require at least one meaningful term to match — otherwise we'd be guessing.
    return bestScore > 0 ? best : null;
  }
}

/// One FAQ group, as the business authored it.
class GabayFaqGroup {
  const GabayFaqGroup({
    required this.label,
    required this.items,
  });

  final String label;
  final List<GabayFaqItem> items;
}

/// One FAQ item — a question and its business-authored answer.
class GabayFaqItem {
  const GabayFaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

/// Package knowledge for Gabay — what the assistant needs to match and explain
/// catering packages from the business's published catalog.
///
/// This stays grounded in [CateringPackage] exactly as the Content Moderator
/// publishes it: name, type, price per head, minimum pax, inclusions (the courses),
/// standard services, and the institutional-only flag.
class GabayPackageKnowledge {
  /// Packages the assistant may recommend — active, non-institutional catering
  /// packages, because the institutional package is offered strictly to church,
  /// government and school functions and shouldn't be surfaced as a general pick.
  ///
  /// Food pack packages are included too — they're a real published family the
  /// assistant can talk about and match to a member's needs.
  static List<CateringPackage> recommendable(List<CateringPackage> all) {
    return all.where((p) => p.active && !p.isInstitutional).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
  }

  /// Packages that plausibly fit a member's stated budget and guest count.
  ///
  /// Budget matching uses the same band logic the recommendation engine already
  /// uses: under ₱350/head is budget, ₱350–₱700 is sakto, over ₱700 is all-out.
  /// Guest-count matching respects the package's minimum — a package whose minimum
  /// is above the member's crowd is out of reach.
  static List<CateringPackage> fitting(
    List<CateringPackage> all, {
    required BudgetRange? budget,
    required GroupSize? group,
  }) {
    final candidates = recommendable(all);

    return candidates.where((p) {
      if (budget != null && _bandFor(p.price) != budget) return false;
      if (group != null && !_fitsGroup(p, group)) return false;
      return true;
    }).toList();
  }

  /// Plain-language explanation of what a package includes, in the business's own
  /// words where it has them.
  ///
  /// [standardServices] is the newline-separated list of standard services every
  /// package in this family carries; [inclusions] is the package's own menu /
  /// course lines. The assistant uses this to say what the package actually buys,
  /// not to invent a description.
  static String describe(CateringPackage pkg) {
    final parts = <String>[];

    if (pkg.standardServices.isNotEmpty) {
      parts.add('Standard: ${pkg.standardServices.join(", ")}.');
    }

    if (pkg.inclusions.isNotEmpty) {
      parts.add('Includes: ${pkg.inclusions.join(", ")}.');
    }

    if (pkg.minPax > 0) {
      parts.add(
        pkg.isFoodPack
            ? 'Minimum ${pkg.minPax} orders.'
            : 'Minimum ${pkg.minPax} guests.',
      );
    }

    if (parts.isEmpty) {
      return 'A ${pkg.type.toLowerCase()} package from HapagPamana.';
    }

    return parts.join(' ');
  }

  /// Which budget band a per-head price falls into.
  static BudgetRange _bandFor(num pricePerHead) {
    if (pricePerHead < 350) return BudgetRange.budget;
    if (pricePerHead <= 700) return BudgetRange.mid;
    return BudgetRange.premium;
  }

  /// Whether a package's minimum headcount suits a member's usual crowd.
  static bool _fitsGroup(CateringPackage pkg, GroupSize group) {
    switch (group) {
      case GroupSize.small:
        return pkg.minPax <= 30;
      case GroupSize.medium:
        return pkg.minPax <= 100;
      case GroupSize.large:
        return true;
    }
  }
}

/// Menu knowledge for Gabay — what the assistant needs to talk about dishes and to
/// suggest healthier alternatives from the business's published menu.
///
/// This stays grounded in [Product] exactly as the Content Moderator publishes it:
/// name, category, type, allergens, featured flag. There are no invented dish
/// descriptions here.
class GabayMenuKnowledge {
  /// Dishes that are visible in the app right now.
  static List<Product> visible(List<Product> all) =>
      all.where((p) => p.available).toList();

  /// Dishes in a given category — the pool healthier-swaps and "dishes like this"
  /// suggestions draw from.
  static List<Product> inCategory(List<Product> all, String category) =>
      visible(all).where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();

  /// Whether a dish carries any allergen the member has asked us to avoid.
  static bool crossoversAvoided(Product dish, Set<String> avoided) {
    if (avoided.isEmpty) return false;
    for (final tag in dish.allergens) {
      if (avoided.contains(tag)) return true;
    }
    return false;
  }

  /// Healthier alternatives to a dish, drawn from the same published menu.
  ///
  /// "Healthier" here is a menu-grounded heuristic, not a medical claim: dishes in
  /// lighter-leaning categories (vegetables, seafood, grilled protein) are treated as
  /// lighter options than heavy fried/riche courses. The assistant should present these
  /// as suggestions the member can ask the kitchen about, not as guaranteed nutritional
  /// facts.
  ///
  /// The member's own preferences ([MemberPreferences.healthierFirst],
  /// [MemberPreferences.diet], [MemberPreferences.avoidAllergens]) are the business's
  /// settings the assistant should respect; this helper returns candidates, and the
  /// caller filters by those preferences before showing them.
  static List<Product> healthierAlternatives(
    List<Product> all,
    String currentCategory,
  ) {
    final candidates = visible(all);

    // Exclude the dish's own category first — we want alternatives, not the same thing.
    final others = candidates
        .where((p) => p.category.toLowerCase() != currentCategory.toLowerCase())
        .toList();

    // Score by how "light" a category reads on a Filipino catering menu.
    return others.map((p) => (_lighterScore(p.category), p)).toList()
      ..sort((a, b) => b.$1.compareTo(a.$1));

    // Return the best-scoring alternatives, capped so the assistant doesn't swamp
    // the member with options.
  }

  /// A menu-grounded "lightness" score for a category, 0–1.
  ///
  /// Higher means the category reads as a lighter option on this kitchen's menu.
  static double _lighterScore(String category) {
    final key = category.toLowerCase();
    if (key.contains('vegetable') || key.contains('gulay')) return 0.9;
    if (key.contains('seafood') || key.contains('fish') || key.contains('isda')) return 0.8;
    if (key.contains('grill') || key.contains('inihaw') || key.contains('chicken')) return 0.6;
    if (key.contains('soup') || key.contains('ensalada')) return 0.7;
    if (key.contains('pork') || key.contains('beef')) return 0.4;
    if (key.contains('dessert') || key.contains('sweet') || key.contains('leche')) return 0.3;
    return 0.5;
  }

  /// Whether a dish carries any allergen the member has asked us to avoid.
  static bool crossesAvoided(Product dish, Set<String> avoided) {
    if (avoided.isEmpty) return false;
    for (final tag in dish.allergens) {
      if (avoided.contains(tag)) return true;
    }
    return false;
  }
}

/// Recommendation explanations for Gabay — plain-language reasons grounded in the
/// business's own recommendation evidence, not invented.
///
/// The assistant uses this to answer "why was this recommended?" honestly. Each
/// explanation names the real source ([RecommendationSource]) and only claims what
/// that source can support.
class GabayExplanationKnowledge {
  /// Plain-language explanation of a recommendation set — what produced it and what
  /// that means.
  ///
  /// This is the "why this?" capability. It is grounded in [RecommendationSource] and
  /// the evidence the engine already computes; it never invents a reason.
  static String explain(RecommendationSet set) {
    if (set.isEmpty) {
      return 'Nothing to recommend right now — the kitchen may not have published '
          'anything yet.';
    }

    final source = set.source;
    final count = set.items.length;

    switch (source) {
      case RecommendationSource.crowd:
        return 'These ${count} pick${count == 1 ? '' : 's'} are from customers who '
            'ordered the same things you do — what they enjoyed alongside your favourites. '
            'It\'s the app\'s way of surfacing dishes you might not have found on your own.';
      case RecommendationSource.cf:
        return 'These ${count} pick${count == 1 ? '' : 's'} are based on your past orders — '
            'dishes and packages like the ones you\'ve gone for before.';
      case RecommendationSource.tasteProfile:
        return 'These ${count} pick${count == 1 ? '' : 's'} match your taste profile — what '
            'you told us you like, before you\'ve ordered with us yet.';
      case RecommendationSource.featured:
        return 'These ${count} pick${count == 1 ? '' : 's'} are featured by the kitchen — '
            'the team\'s own picks, since we don\'t have your orders or profile to go on yet.';
    }
  }

  /// A short, honest opening line for when Gabay shows the member their current picks.
  static String leadIn(RecommendationSet set) {
    if (set.isEmpty) {
      return 'I don\'t have any picks for you just yet — try asking me about packages or '
          'the menu.';
    }
    return explain(set);
  }
}

/// A single place the chat can ask for the business's cleaned content.
///
/// This aggregates the four knowledge pieces above so the assistant's intent router
/// can query one entry point instead of wiring each capability to a different helper.
class GabayKnowledge {
  /// The FAQ content and matcher.
  static const faq = GabayFaq();

  /// Package knowledge helpers.
  static const packages = GabayPackageKnowledge();

  /// Menu knowledge helpers.
  static const menu = GabayMenuKnowledge();

  /// Recommendation explanation helpers.
  static const explanations = GabayExplanationKnowledge();
}
