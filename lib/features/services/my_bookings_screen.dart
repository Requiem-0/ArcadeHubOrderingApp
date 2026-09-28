// lib/features/services/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/brandkit/app_breakpoints.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/models/booking_request.dart';
import '../../core/repositories/booking_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../shared/widgets/empty_state.dart';

/// What the customer has asked the venue for. Requests, not reservations: the
/// venue confirms in the chat, so nothing here says a slot is held.
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final async = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(
        backgroundColor: colors.scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/book');
            }
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.textPrimary, size: 20),
        ),
        title: Text(
          'Your requests',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: colors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colors.borderSubtle),
        ),
      ),
      body: async.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.primaryRed)),
        error: (_, _) => Center(
          child: EmptyState(
            iconData: Icons.event_busy_rounded,
            iconColor: colors.primaryRed,
            title: 'Could not load your requests',
            subtitle: 'Try again in a moment.',
            action: TextButton(
              onPressed: () => ref.invalidate(myBookingsProvider),
              child:
                  Text('Try again', style: TextStyle(color: colors.primaryRed)),
            ),
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: EmptyState(
                iconData: Icons.event_available_rounded,
                iconColor: colors.primaryRed,
                title: 'No requests yet',
                subtitle: 'Anything you ask to book will show up here.',
                action: TextButton(
                  onPressed: () => context.go('/book'),
                  child: Text('Book something',
                      style: TextStyle(color: colors.primaryRed)),
                ),
              ),
            );
          }

          return ListView.separated(
            padding:
                EdgeInsets.fromLTRB(context.gutter, 16, context.gutter, 40),
            itemCount: requests.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'The venue confirms on WhatsApp. These are what you asked '
                    'for, not held slots.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      height: 1.45,
                      color: colors.textMuted,
                    ),
                  ),
                );
              }
              return _RequestCard(request: requests[i - 1]);
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final BookingRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final zone = kArcadeExperiences.where((e) => e.id == request.zoneId);
    final accent = zone.isEmpty
        ? colors.primaryRed
        : colors.resolveZoneForeground(zone.first.color);
    final off = request.status == BookingStatus.cancelled ||
        request.status == BookingStatus.declined;

    return Opacity(
      opacity: off ? 0.6 : 1,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
          boxShadow: colors.cardShadow,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: off ? colors.borderSubtle : accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              request.serviceName,
                              style: GoogleFonts.outfit(
                                fontSize: 16.5,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StatusPill(status: request.status),
                        ],
                      ),
                      const SizedBox(height: 7),
                      _line(
                        context,
                        Icons.event_rounded,
                        '${DateFormat('EEE d MMM').format(request.day)} · '
                        '${request.time}',
                      ),
                      const SizedBox(height: 4),
                      _line(
                        context,
                        Icons.group_rounded,
                        '${request.people} '
                        '${request.people == 1 ? 'person' : 'people'}'
                        '${request.zoneName.isEmpty ? '' : ' · ${request.zoneName}'}',
                      ),
                      if (request.note != null) ...[
                        const SizedBox(height: 4),
                        _line(context, Icons.sticky_note_2_rounded,
                            request.note!),
                      ],
                      if (!off) ...[
                        const SizedBox(height: 10),
                        Divider(height: 1, color: colors.borderSubtle),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _resend(context, ref),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Message again',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _cancel(context, ref),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(BuildContext context, IconData icon, String text) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Icon(icon, size: 13, color: colors.textMuted),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              height: 1.35,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    try {
      await ref.read(bookingRepositoryProvider).submit(request);
      ref.invalidate(myBookingsProvider);
    } on BookingDeliveryException catch (e) {
      if (context.mounted) AppToast.showError(context, e.message);
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final colors = context.appColors;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        title: Text(
          'Cancel this request?',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800, color: colors.textPrimary),
        ),
        content: Text(
          'Tell the venue in the chat too, so they know to drop it.',
          style: GoogleFonts.dmSans(fontSize: 13.5, color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep it',
                style: GoogleFonts.dmSans(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel it',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700, color: colors.primaryRed)),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await ref.read(bookingRepositoryProvider).cancel(request.id);
    ref.invalidate(myBookingsProvider);
  }
}

/// Where the request stands. Only the venue moves it past "Requested".
class _StatusPill extends StatelessWidget {
  final BookingStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (label, fill) = switch (status) {
      BookingStatus.requested => ('Requested', const Color(0xFFF59E0B)),
      BookingStatus.confirmed => ('Confirmed', const Color(0xFF22C55E)),
      BookingStatus.declined => ('Declined', colors.primaryRed),
      BookingStatus.cancelled => ('Cancelled', colors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: fill.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fill.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: fill,
        ),
      ),
    );
  }
}

/// A line on the Book tab: how many requests are waiting on the venue.
class PendingRequestsStrip extends ConsumerWidget {
  const PendingRequestsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final waiting = ref.watch(myBookingsProvider).valueOrNull?.where(
              (r) => r.status == BookingStatus.requested,
            ) ??
        const <BookingRequest>[];
    if (waiting.isEmpty) return const SizedBox.shrink();

    final count = waiting.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/bookings'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 17, color: colors.primaryRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    count == 1
                        ? '1 request waiting on the venue'
                        : '$count requests waiting on the venue',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: colors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
