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
import '../../shared/widgets/empty_state.dart';
import 'my_bookings_screen.dart';

/// Book tab: pick a zone, then a bookable service in it. The same booking
/// form the zone pages push, reachable without digging into a zone first.
class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({super.key});

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  String? _zoneId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final zonesAsync = ref.watch(bookableZonesProvider);

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        bottom: false,
        child: zonesAsync.when(
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
                onPressed: () => ref.invalidate(bookableZonesProvider),
                child: Text(
                  'Try again',
                  style: TextStyle(color: colors.primaryRed),
                ),
              ),
            ),
          ),
          data: (zones) {
            if (zones.isEmpty) {
              return Center(
                child: EmptyState(
                  iconData: Icons.event_busy_rounded,
                  iconColor: colors.primaryRed,
                  title: 'Nothing to book right now',
                  subtitle: 'Ask at the counter and they will sort you out.',
                ),
              );
            }
            // Zones come and go with the data, so fall back to the first one.
            final zone = zones.firstWhere(
              (z) => z.id == _zoneId,
              orElse: () => zones.first,
            );
            return _ZoneBooking(
              zones: zones,
              zone: zone,
              onPick: (id) => setState(() => _zoneId = id),
            );
          },
        ),
      ),
    );
  }
}

/// The header, the zone picker, and the chosen zone's services.
class _ZoneBooking extends ConsumerWidget {
  final List<ArcadeExperience> zones;
  final ArcadeExperience zone;
  final ValueChanged<String> onPick;

  const _ZoneBooking({
    required this.zones,
    required this.zone,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final accent = colors.resolveZoneForeground(zone.color);
    final servicesAsync = ref.watch(servicesProvider(zone.id));
    final gutter = context.gutter;

    return Column(
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
              // The rules every booking runs by, as one line of prose. The
              // zone pills below are the only pills the header needs.
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

        // Zone selector, only for zones that have something to book
        if (zones.length > 1) ...[
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: gutter),
              itemCount: zones.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _ZonePill(
                exp: zones[i],
                active: zones[i].id == zone.id,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPick(zones[i].id);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        Expanded(
          child: servicesAsync.when(
            loading: () =>
                Center(child: CircularProgressIndicator(color: accent)),
            error: (_, _) => Center(
              child: EmptyState(
                iconData: Icons.wifi_off_rounded,
                iconColor: colors.primaryRed,
                title: 'Bookings did not load',
                subtitle: 'Check your connection and try again.',
                action: TextButton(
                  onPressed: () => ref.invalidate(servicesProvider(zone.id)),
                  child: Text(
                    'Try again',
                    style: TextStyle(color: colors.primaryRed),
                  ),
                ),
              ),
            ),
            data: (services) {
              final bookable = services.where((s) => s.isBookable).toList();
              if (bookable.isEmpty) {
                return Center(
                  child: EmptyState(
                    iconData: Icons.event_busy_rounded,
                    iconColor: accent,
                    title: 'Nothing to book in ${zone.name}',
                    subtitle: 'Try another zone, or ask at the counter.',
                  ),
                );
              }

              final label = Padding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 12),
                child: Text(
                  '${zone.name.toUpperCase()} · ${bookable.length} TO BOOK',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: colors.textMuted,
                  ),
                ),
              );

              // Two across once the window is wider than a phone.
              final columns = context.isRoomy ? 2 : 1;
              return ListView(
                padding: EdgeInsets.only(
                  bottom: AppConstants.bottomNavHeight + 40,
                ),
                children: [
                  label,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    child: columns == 1
                        ? Column(
                            children: [
                              for (final s in bookable) ...[
                                _ServiceCard(
                                  service: s,
                                  accent: accent,
                                  zoneIcon: zone.iconData,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final width =
                                  ((constraints.maxWidth - 16) / 2)
                                      .floorToDouble();
                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  for (final s in bookable)
                                    SizedBox(
                                      width: width,
                                      child: _ServiceCard(
                                        service: s,
                                        accent: accent,
                                        zoneIcon: zone.iconData,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A small fact about every booking, in the header.
class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Fact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One zone in the picker: a pill that fills with the zone's own colour.
class _ZonePill extends StatelessWidget {
  final ArcadeExperience exp;
  final bool active;
  final VoidCallback onTap;

  const _ZonePill({
    required this.exp,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fill = colors.resolveZoneForeground(exp.color);
    // A pale zone colour needs dark ink on it.
    final ink = fill.computeLuminance() > 0.45
        ? const Color(0xFF0A0A0A)
        : Colors.white;

    return Material(
      color: active ? fill : colors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? fill : colors.border,
              width: active ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                exp.iconData,
                size: 15,
                color: active ? ink : colors.textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                exp.name,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? ink : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One bookable thing. Led by its price, because that is the first question.
class _ServiceCard extends StatelessWidget {
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
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A band in the zone's colour, so a card is placed at a glance.
          Container(height: 3, color: accent),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(13),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Icon(zoneIcon, size: 21, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: GoogleFonts.outfit(
                              fontSize: 17.5,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            service.price != null
                                ? AppConstants.formatPrice(service.price!)
                                : 'Price on request',
                            style: GoogleFonts.outfit(
                              fontSize: service.price != null ? 18 : 13,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              color: service.price != null
                                  ? accent
                                  : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(
                  service.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
                if (service.durationText != null) ...[
                  const SizedBox(height: 11),
                  _Fact(
                    icon: Icons.schedule_rounded,
                    label: service.durationText!,
                  ),
                ],
                if (service.rules != null) ...[
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            service.rules!,
                            style: GoogleFonts.dmSans(
                              fontSize: 11.5,
                              height: 1.4,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(
                        '/service-booking?serviceId=${service.id}',
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'Pick a time',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
