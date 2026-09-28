// lib/features/services/book_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_spacing.dart';
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

/// The picker plus the chosen zone's services.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Reserve a room or a console.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),

        // Zone selector, only for zones that have something to book
        if (zones.length > 1)
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.pagePadding,
              itemCount: zones.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _ZoneTile(
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

        // Requests already sent, so the tab shows what is outstanding.
        const PendingRequestsStrip(),

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
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                itemCount: bookable.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 20),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'IN ${zone.name.toUpperCase()} · ${bookable.length}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: colors.textMuted,
                        ),
                      ),
                    );
                  }
                  return _ServiceCard(
                    service: bookable[i - 1],
                    accent: accent,
                    zoneIcon: zone.iconData,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// One zone in the picker. Fills with the zone's own colour when chosen.
class _ZoneTile extends StatelessWidget {
  final ArcadeExperience exp;
  final bool active;
  final VoidCallback onTap;

  const _ZoneTile({
    required this.exp,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = colors.resolveZoneForeground(exp.color);

    return Material(
      color: active ? colors.resolveZoneBackground(exp.color) : colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 96,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? fg : colors.border,
              width: active ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                exp.iconData,
                size: 20,
                color: active ? fg : colors.textMuted,
              ),
              Text(
                exp.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: active ? colors.textPrimary : colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      // IntrinsicHeight so the colour rail can stretch to the card's height,
      // which the surrounding list leaves unbounded.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zone colour rail, so a card reads as belonging to its zone
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(zoneIcon, size: 19, color: accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                              if (service.durationText != null) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 13,
                                      color: colors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        service.durationText!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: colors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (service.rules != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              service.rules!,
                              style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                height: 1.35,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Divider(height: 1, color: colors.borderSubtle),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: service.price != null
                              ? Text(
                                  AppConstants.formatPrice(service.price!),
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textPrimary,
                                  ),
                                )
                              : Text(
                                  'Price on request',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textMuted,
                                  ),
                                ),
                        ),
                        FilledButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push(
                              '/service-booking?serviceId=${service.id}',
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            'Book',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              // A pale zone colour needs dark ink on it.
                              color: accent.computeLuminance() > 0.45
                                  ? const Color(0xFF0A0A0A)
                                  : Colors.white,
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
