// lib/features/services/book_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_breakpoints.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/constants.dart';
import '../../core/models/service.dart';
import '../../core/repositories/service_repository.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import 'my_bookings_screen.dart';

/// Book tab: everything bookable, grouped under the zone it belongs to. The
/// tabs narrow it to one zone, but nothing is hidden until asked — the list
/// opens on everything, so a booking never starts with a choice.
class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({super.key});

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  /// null shows every zone.
  String? _zoneId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final async = ref.watch(bookableServicesProvider);
    final gutter = context.gutter;

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${TimeOfDay(hour: AppConstants.bookingOpenHour, minute: 0).format(context)}'
                    ' - '
                    '${TimeOfDay(hour: AppConstants.bookingLastHour, minute: 0).format(context)}'
                    ' · confirmed on WhatsApp',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),

            // Requests already sent, so the tab shows what is outstanding.
            const PendingRequestsStrip(),

            Expanded(
              child: async.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: colors.primaryRed),
                ),
                error: (_, _) => Center(
                  child: EmptyState(
                    iconData: Icons.wifi_off_rounded,
                    iconColor: colors.primaryRed,
                    title: 'Bookings did not load',
                    subtitle: 'Check your connection and try again.',
                    action: TextButton(
                      onPressed: () =>
                          ref.invalidate(bookableServicesProvider),
                      child: Text(
                        'Try again',
                        style: TextStyle(color: colors.primaryRed),
                      ),
                    ),
                  ),
                ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return Center(
                      child: EmptyState(
                        iconData: Icons.event_busy_rounded,
                        iconColor: colors.primaryRed,
                        title: 'Nothing to book right now',
                        subtitle:
                            'Ask at the counter and they will sort you out.',
                      ),
                    );
                  }

                  // A zone that has gone from the data should not leave the
                  // list filtered to nothing.
                  final picked = groups.any((g) => g.zone.id == _zoneId)
                      ? _zoneId
                      : null;
                  final shown = picked == null
                      ? groups
                      : [for (final g in groups) if (g.zone.id == picked) g];

                  return Column(
                    children: [
                      if (groups.length > 1)
                        _ZoneTabs(
                          groups: groups,
                          picked: picked,
                          onPick: (id) => setState(() => _zoneId = id),
                        ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(
                            gutter,
                            16,
                            gutter,
                            AppConstants.bottomNavHeight + 40,
                          ),
                          children: [
                            for (final group in shown) ...[
                              _ZoneHeading(
                                zone: group.zone,
                                count: group.services.length,
                              ),
                              const SizedBox(height: 10),
                              _ServiceList(group: group),
                              const SizedBox(height: 22),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zone tabs: All, then one per zone, underlined in the zone's own colour.
/// Tabs rather than pills so the row reads as a filter over one list, not as
/// a set of buttons.
class _ZoneTabs extends StatelessWidget {
  final List<ZoneServices> groups;
  final String? picked;
  final ValueChanged<String?> onPick;

  const _ZoneTabs({
    required this.groups,
    required this.picked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.gutter - 10),
        child: Row(
          children: [
            _ZoneTab(
              key: const Key('zone-tab-all'),
              label: 'All',
              active: picked == null,
              accent: colors.primaryRed,
              onTap: () => onPick(null),
            ),
            for (final group in groups)
              _ZoneTab(
                key: Key('zone-tab-${group.zone.id}'),
                label: group.zone.name,
                active: picked == group.zone.id,
                accent: colors.resolveZoneForeground(group.zone.color),
                onTap: () => onPick(group.zone.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoneTab extends StatelessWidget {
  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  const _ZoneTab({
    super.key,
    required this.label,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? colors.textPrimary : colors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// The zone a group of cards belongs to, in the zone's own colour.
class _ZoneHeading extends StatelessWidget {
  final ArcadeExperience zone;
  final int count;

  const _ZoneHeading({required this.zone, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = colors.resolveZoneForeground(zone.color);

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Icon(zone.iconData, size: 14, color: accent),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            zone.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          count == 1 ? '1 option' : '$count options',
          style: GoogleFonts.dmSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// One zone's cards: stacked on a phone, two across when there is room.
class _ServiceList extends StatelessWidget {
  final ZoneServices group;

  const _ServiceList({required this.group});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = colors.resolveZoneForeground(group.zone.color);
    final cards = [
      for (final s in group.services)
        _ServiceCard(
          service: s,
          accent: accent,
          zoneIcon: group.zone.iconData,
        ),
    ];

    if (!context.isRoomy) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Floored, so two cards always fit on one line rather than rounding
        // onto two.
        final width = ((constraints.maxWidth - 14) / 2).floorToDouble();
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

/// One bookable thing, read like a product: photo, then what it is and what
/// it costs, then when it runs and the way in.
class _ServiceCard extends StatelessWidget {
  /// Every card is this tall. The text is capped to fit, so a long
  /// description cannot stretch one card past its neighbour.
  static const double _cardHeight = 160;

  final ServiceModel service;
  final Color accent;
  final IconData zoneIcon;

  const _ServiceCard({
    required this.service,
    required this.accent,
    required this.zoneIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ink = accent.computeLuminance() > 0.45
        ? const Color(0xFF0A0A0A)
        : Colors.white;

    return Container(
      key: Key('service-card-${service.id}'),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      // One height for every card, so the photo has a fixed frame to fill and
      // two cards side by side always end level.
      child: SizedBox(
        height: _cardHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A strip of the zone's colour down the edge of the photo.
            ColoredBox(color: accent, child: const SizedBox(width: 3)),
            ColoredBox(
              color: accent.withValues(alpha: 0.12),
              child: SizedBox(
                width: 101,
                height: double.infinity,
                child: AppNetworkImage(
                  url: service.imageUrl,
                  fit: BoxFit.cover,
                  // No photo yet: the zone's own mark rather than a
                  // broken-image box.
                  fallback: Icon(zoneIcon, size: 26, color: accent),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The name gets the full width and two lines. It is the
                    // one thing that must be readable, so the price moved
                    // down to the footer rather than crowding it.
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 15.5,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (service.durationText != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 12, color: colors.textMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              service.durationText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 5),
                    // Takes what is left, so every card's footer sits on the
                    // same line however long the name ran.
                    Expanded(
                      child: Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          height: 1.35,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: colors.borderSubtle),
                    const SizedBox(height: 9),
                    // Price and when it runs, then the way in. The venue's
                    // rules are on the booking screen, where they are read
                    // before committing rather than skimmed here.
                    Row(
                      children: [
                        Expanded(
                          // Scales down rather than trimming: a price with
                          // letters missing is worse than a smaller one.
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              service.price != null
                                  ? AppConstants.formatPrice(service.price!)
                                  : 'On request',
                              maxLines: 1,
                              style: GoogleFonts.outfit(
                                fontSize: service.price != null ? 15 : 12,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                color: service.price != null
                                    ? colors.textPrimary
                                    : colors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sized to its own content, but bounded by what is
                        // left so it can never push the price off a narrow
                        // card.
                        Flexible(
                          child: FilledButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.push(
                                '/service-booking?serviceId=${service.id}',
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Book now',
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 14, color: ink),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
