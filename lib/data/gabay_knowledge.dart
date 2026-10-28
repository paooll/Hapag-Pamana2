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

import 'dart:math';

import 'catering.dart';
import 'member_preferences.dart';
import 'product.dart';
import 'recommendation.dart';
import 'recommendation_engine.dart';
import 'booking.dart';
import 'taste_profile.dart';

class GabayFaq {
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

  static GabayFaqItem? findAnswer(String query) {
    final needle = query.toLowerCase().trim();
    if (needle.isEmpty) return null;

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
        if (item.question.toLowerCase().contains(needle)) {
          score += 2;
        }
        if (score > bestScore) {
          bestScore = score;
          best = item;
        }
      }
    }

    return bestScore > 0 ? best : null;
  }
}

class GabayFaqGroup {
  const GabayFaqGroup({
    required this.label,
    required this.items,
  });

  final String label;
  final List<GabayFaqItem> items;
}

class GabayFaqItem {
  const GabayFaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class GabayPackageKnowledge {
  static List<CateringPackage> recommendable(List<CateringPackage> all) {
    return all.where((p) => p.active && !p.isInstitutional).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
  }

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

  static BudgetRange _bandFor(num pricePerHead) {
    if (pricePerHead < 350) return BudgetRange.budget;
    if (pricePerHead <= 700) return BudgetRange.mid;
    return BudgetRange.premium;
  }

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

class GabayMenuKnowledge {
  static List<Product> visible(List<Product> all) =>
      all.where((p) => p.available).toList();

  static List<Product> inCategory(List<Product> all, String category) =>
      visible(all).where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();

  static bool crossoversAvoided(Product dish, Set<String> avoided) {
    if (avoided.isEmpty) return false;
    for (final tag in dish.allergens) {
      if (avoided.contains(tag)) return true;
    }
    return false;
  }

  static List<Product> healthierFor(
    List<Product> all,
    MemberPreferences prefs, {
    int take = 6,
  }) {
    final visible = visible(all);
    if (visible.isEmpty) return const [];

    final allowed = <Product>[];
    for (final p in visible) {
      if (crossoversAvoided(p, prefs.avoidAllergens)) continue;
      if (!dietAllows(p, prefs.diet)) continue;
      allowed.add(p);
    }
    if (allowed.isEmpty) return const [];

    allowed.sort((a, b) =>
        (_lighterScoreRank(b.category)).compareTo(_lighterScoreRank(a.category)));

    if (!prefs.healthierFirst) {
      allowed.shuffle(const Random());
    }

    return allowed.take(take).toList();
  }

  static bool dietAllows(Product dish, DietStyle diet) {
    final hay = '${dish.category} ${dish.name}'.toLowerCase();
    switch (diet) {
      case DietStyle.none:
        return true;
      case DietStyle.vegetarian:
        return !_hasMeat(hay);
      case DietStyle.vegan:
        return !_hasAnimalProduct(hay);
      case DietStyle.pescatarian:
        return !_hasMeat(hay);
      case DietStyle.noPork:
        return !hay.contains('pork') && !hay.contains('baboy');
      case DietStyle.halal:
        return !hay.contains('pork') && !hay.contains('baboy');
    }
  }

  static bool _hasMeat(String hay) {
    return _hasAny(hay, [
      'pork', 'baboy', 'beef', 'carne', 'chicken', 'manok',
      'meat', 'liempo', 'lechon', 'sisig', 'crispy', 'pritu', 'fried',
    ]);
  }

  static bool _hasAnimalProduct(String hay) {
    return _hasMeat(hay) ||
        hay.contains('milk') ||
        hay.contains('cheese') ||
        hay.contains('cream') ||
        hay.contains('egg') ||
        hay.contains('mayo') ||
        hay.contains('butter');
  }

  static int _lighterScoreRank(String category) {
    return (_lighterScore(category) * 100).round();
  }

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

  static bool _hasAny(String hay, List<String> terms) {
    for (final t in terms) {
      if (hay.contains(t)) return true;
    }
    return false;
  }

  static List<Product> healthierAlternatives(
    List<Product> all,
    String currentCategory,
  ) {
    final candidates = visible(all);
    final others = candidates
        .where((p) => p.category.toLowerCase() != currentCategory.toLowerCase())
        .toList();
    final scored = others.map((p) => (_lighterScore(p.category), p)).toList();
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.map((e) => e.$2).toList();
  }
}

class GabayExplanationKnowledge {
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

  static String leadIn(RecommendationSet set) {
    if (set.isEmpty) {
      return 'I don\'t have any picks for you just yet — try asking me about packages or '
          'the menu.';
    }
    return explain(set);
  }
}

class GabayPackagePersonalization {
  /// A trimmed package list for a member who is looking for something by budget
  /// and/or headcount. It uses [GabayPersonalization] as its member-aware input,
  /// and keeps to the same public helpers the chat page already imports.
  static List<CateringPackage> fitting(
    List<CateringPackage> all,
    GabayPersonalization person, {
    int take = 5,
  }) {
    final candidates = GabayPackageKnowledge.recommendable(all);
    final budget = person.budget;
    final group = person.group;

    final fitting = candidates.where((p) {
      if (budget != null && GabayPackageKnowledge._bandFor(p.price) != budget)
          return false;
      if (group != null && !GabayPackageKnowledge._fitsGroup(p, group))
          return false;
      return true;
    }).toList();

    if (fitting.isEmpty) return fitting;

    if (person.hasProfile) {
      fitting.sort((a, b) {
        final aEvent = _eventFit(a, person.occasions);
        final bEvent = _eventFit(b, person.occasions);
        if (aEvent != bEvent) return bEvent.compareTo(aEvent);
        return a.price.compareTo(b.price);
      });
    } else {
      fitting.sort((a, b) => a.price.compareTo(b.price));
    }

    final booked = _bookedPackageIds(person);
    fitting.removeWhere((p) => booked.contains(p.id));

    return fitting.take(take).toList();
  }

  static String reason(GabayPersonalization person, List<CateringPackage> picks) {
    if (picks.isEmpty) {
      return 'Nothing in our current packages fits what we know about your event right now.';
    }
    final parts = <String>[];
    if (person.budget != null) {
      parts.add(_budgetPhrase(person.budget!));
    } else {
      parts.add('for your budget');
    }
    if (person.group != null) {
      parts.add('for ${_groupPhrase(person.group!)}');
    } else {
      parts.add('for your guest count');
    }
    if (person.occasions.isNotEmpty) {
      final first = person.occasions.first;
      final label = GabayPersonalization.occasionLabel(first);
      parts.add('for a ${label.toLowerCase()}');
    }
    return 'Here are a few packages I picked that fit ${parts.join(" ")}. Tap one to see '
        'what it includes and the minimum guest count, then book it if it suits your event.';
  }

  static List<String> _bookedPackageIds(GabayPersonalization person) {
    final ids = <String>{};
    for (final booking in person.completedOrders) {
      final id = booking.value('packageId');
      if (id.isNotEmpty) ids.add(id);
    }
    return ids.toList();
  }

  static int _eventFit(CateringPackage pkg, Set<String> occasions) {
    if (occasions.isEmpty) return 0;
    if (pkg.isFoodPack) return -1;
    if (pkg.isInstitutional || pkg.name.toLowerCase().contains('serbisyo')) {
      final institutionalOccasions = ['religious', 'wedding', 'corporate', 'fiesta'];
      for (final o in occasions) {
        if (institutionalOccasions.contains(o)) return 1;
      }
      return 0;
    }
    return 0;
  }

  static String _budgetPhrase(BudgetRange budget) {
    switch (budget) {
      case BudgetRange.budget:
        return 'your budget-friendly range';
      case BudgetRange.mid:
        return 'your mid-range budget';
      case BudgetRange.premium:
        return 'your premium budget';
    }
  }

  static String _groupPhrase(GroupSize group) {
    switch (group) {
      case GroupSize.small:
        return 'your small crowd';
      case GroupSize.medium:
        return 'your medium crowd';
      case GroupSize.large:
        return 'your large crowd';
    }
  }
}

class GabayExplanationPersonalization {
  /// A personalized "why am I seeing this?" explanation that mirrors the chat
  /// page's expectation: it reads from a [GabayPersonalization] built by the chat
  /// layer, and falls back to the same honest, non-personal phrasing the plain
  /// explanation class uses when there's no member context to work with.
  static String explain(GabayPersonalization person) {
    if (person.recs.isEmpty) {
      return 'Nothing to recommend right now — the kitchen may not have published anything yet.';
    }
    final source = person.recs.source;
    final count = person.recs.items.length;
    switch (source) {
      case RecommendationSource.crowd:
        return 'These ${count} pick${count == 1 ? '' : 's'} are from customers who ordered the '
            'same things you do — what they enjoyed alongside your favourites. It\'s the app\'s '
            'way of surfacing dishes or packages you might not have found on your own.';
      case RecommendationSource.cf:
        if (person.hasHistory) {
          final categories = _categorySummary(person.completedOrders);
          return 'These ${count} pick${count == 1 ? '' : 's'} are based on your past orders — '
              'dishes and packages like the ones you\'ve gone for before (${categories}).';
        }
        return 'These ${count} pick${count == 1 ? '' : 's'} are based on your past orders — '
            'dishes and packages like the ones you\'ve gone for before.';
      case RecommendationSource.tasteProfile:
        if (person.hasProfile) {
          final flavors = _flavorSummary(person.flavorProfile);
          final budget = person.budget;
          final group = person.group;
          final parts = <String>[];
          if (flavors.isNotEmpty) parts.add(flavors);
          if (budget != null) parts.add(_budgetPhrase(budget));
          if (group != null) parts.add(_groupPhrase(group));
          final lead = parts.isEmpty
              ? 'what you told us you like'
              : parts.join(', ');
          return 'These ${count} pick${count == 1 ? '' : 's'} match your taste profile — ${lead} '
              '— before you\'ve ordered with us yet.';
        }
        return 'These ${count} pick${count == 1 ? '' : 's'} match your taste profile — what you '
            'told us you like, before you\'ve ordered with us yet.';
      case RecommendationSource.featured:
        return 'These ${count} pick${count == 1 ? '' : 's'} are featured by the kitchen — '
            'the team\'s own picks, since we don\'t have your orders or profile to go on yet.';
    }
  }

  static String _categorySummary(List<Booking> completed) {
    if (completed.isEmpty) return 'your past orders';
    final counts = <String, int>{};
    for (final booking in completed) {
      for (final line in [
            ...booking.lines('menu'),
            ...booking.lines('menuAddOns'),
          ]) {
        final key = _roughCategory(line);
        if (key.isNotEmpty) counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return 'your past orders';
    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(2).map((e) => e.key).toList();
    if (top.length == 1) return top.first;
    return '${top[0]} and ${top[1]}';
  }

  static String _roughCategory(String line) {
    final hay = line.toLowerCase();
    if (hay.contains('seafood') || hay.contains('isda') || hay.contains('shrimp') ||
        hay.contains('hipon') || hay.contains('squid') || hay.contains('bangus')) return 'seafood';
    if (hay.contains('chicken') || hay.contains('manok') || hay.contains('bbq') || hay.contains('inihaw')) return 'chicken and grilled';
    if (hay.contains('pork') || hay.contains('baboy') || hay.contains('liempo') || hay.contains('lechon')) return 'pork';
    if (hay.contains('beef') || hay.contains('baka') || hay.contains('bulalo') || hay.contains('caldereta') || hay.contains('menudo')) return 'beef';
    if (hay.contains('pasta') || hay.contains('noodle') || hay.contains('canton') || hay.contains('bihon') || hay.contains('palabok')) return 'pasta and noodles';
    if (hay.contains('soup') || hay.contains('sinigang') || hay.contains('sabaw')) return 'soup';
    if (hay.contains('vegetable') || hay.contains('gulay')) return 'vegetables';
    if (hay.contains('dessert') || hay.contains('sweet') || hay.contains('leche') || hay.contains('cake') || hay.contains('buko') || hay.contains('halo')) return 'desserts';
    return '';
  }

  static String _flavorSummary(Set<String> flavors) {
    if (flavors.isEmpty) return '';
    final labels = flavors.map((k) {
      final note = FlavorNote.fromKey(k);
      return note?.label ?? k;
    }).toList();
    if (labels.length == 1) return labels.first;
    if (labels.length == 2) return '${labels[0]} and ${labels[1]}';
    return '${labels.sublist(0, labels.length - 1).join(", ")} and ${labels.last}';
  }

  static String _budgetPhrase(BudgetRange budget) {
    switch (budget) {
      case BudgetRange.budget:
        return 'a budget-friendly range';
      case BudgetRange.mid:
        return 'a mid-range budget';
      case BudgetRange.premium:
        return 'a premium budget';
    }
  }

  static String _groupPhrase(GroupSize group) {
    switch (group) {
      case GroupSize.small:
        return 'a small crowd';
      case GroupSize.medium:
        return 'a medium crowd';
      case GroupSize.large:
        return 'a large crowd';
    }
  }
}

class GabayKnowledge {
  static const faq = GabayFaq();
  static const packages = GabayPackageKnowledge();
  static const menu = GabayMenuKnowledge();
  static const explanations = GabayExplanationKnowledge();
  static const packagePersonalization = GabayPackagePersonalization();
  static const explanationPersonalization = GabayExplanationPersonalization();
}
