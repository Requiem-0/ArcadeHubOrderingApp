// lib/features/services/service_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/brandkit/app_breakpoints.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/constants.dart';
import '../../core/models/booking_request.dart';
import '../../core/models/service.dart';
import '../../core/repositories/booking_repository.dart';
import '../../core/repositories/service_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_button.dart';

/// The booking form: what you are booking, when, and for how many.
class ServiceBookingScreen extends ConsumerStatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  ConsumerState<ServiceBookingScreen> createState() =>
      _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends ConsumerState<ServiceBookingScreen> {
  /// How far ahead the calendar will page. Bookings further out than this
  /// are a phone call.
  static const int _weeksAhead = 8;

  bool _agreed = false;
  bool _loading = false;
  String? _serviceId;
  DateTime? _day;
  TimeOfDay? _time;
  int _people = 2;
  final _noteController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _serviceId = GoRouterState.of(context).uri.queryParameters['serviceId'];
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _ready => _day != null && _time != null && _agreed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final id = _serviceId;

    if (id == null) {
      return Scaffold(
        backgroundColor: colors.scaffold,
        appBar: _bar(context, 'Book'),
        body: Center(
          child: EmptyState(
            iconData: Icons.event_busy_rounded,
            iconColor: colors.primaryRed,
            title: 'Nothing selected',
            subtitle: 'Pick something from the Book tab first.',
          ),
        ),
      );
    }

    final async = ref.watch(serviceByIdProvider(id));

    return async.when(
      loading: () => Scaffold(
        backgroundColor: colors.scaffold,
        appBar: _bar(context, 'Book'),
        body: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: colors.scaffold,
        appBar: _bar(context, 'Book'),
        body: Center(
          child: EmptyState(
            iconData: Icons.wifi_off_rounded,
            iconColor: colors.primaryRed,
            title: 'Could not load this',
            subtitle: 'Check your connection and try again.',
            action: TextButton(
              onPressed: () => ref.invalidate(serviceByIdProvider(id)),
              child: Text(
                'Try again',
                style: TextStyle(color: colors.primaryRed),
              ),
            ),
          ),
        ),
      ),
      data: (found) {
        if (found == null) {
          return Scaffold(
            backgroundColor: colors.scaffold,
            appBar: _bar(context, 'Book'),
            body: Center(
              child: EmptyState(
                iconData: Icons.event_busy_rounded,
                iconColor: colors.primaryRed,
                title: 'No longer available',
                subtitle: 'Ask at the counter and they will sort you out.',
              ),
            ),
          );
        }
        return _form(found);
      },
    );
  }

  PreferredSizeWidget _bar(BuildContext context, String title) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.scaffold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 4,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/book');
          }
        },
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colors.textPrimary,
          size: 20,
        ),
      ),
      title: Text(
        title,
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
    );
  }

  Widget _form(BookableService found) {
    final colors = context.appColors;
    final service = found.service;
    final zone = found.zone;
    final accent = colors.resolveZoneForeground(zone.color);

    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: _bar(context, 'Book'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(context.gutter, 16, context.gutter, 28),
        children: [
          // What is being booked, in the zone's own colour.
          _SummaryCard(service: service, zone: zone, accent: accent),
          const SizedBox(height: 26),

          _Label('Date'),
          const SizedBox(height: 10),
          _WeekCalendar(
            selected: _day,
            accent: accent,
            weeksAhead: _weeksAhead,
            onPick: (day) => setState(() {
              _day = day;
              // A time that has gone by on the newly chosen day has to go.
              if (_time != null && !slotIsBookable(_time!, day)) _time = null;
            }),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _Label('Arriving at')),
              // The hours are the rule, so say them rather than just
              // leaving the other times out.
              Text(
                '${TimeOfDay(hour: AppConstants.bookingOpenHour, minute: 0).format(context)}'
                ' - '
                '${TimeOfDay(hour: AppConstants.bookingLastHour, minute: 0).format(context)}',
                style: GoogleFonts.dmSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TimeSlots(
            day: _day,
            selected: _time,
            accent: accent,
            onPick: (t) => setState(() => _time = t),
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(child: _Label('How many of you')),
              _PeopleStepper(
                value: _people,
                accent: accent,
                onChanged: (v) => setState(() => _people = v),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _Label('Anything we should know?'),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.dmSans(fontSize: 14, color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Birthday, a specific console, anything else',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 13.5,
                color: colors.textMuted,
              ),
              filled: true,
              fillColor: colors.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accent, width: 1.4),
              ),
            ),
          ),

          if (service.rules != null) ...[
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 17, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      service.rules!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          Text(
            'The venue confirms your slot on WhatsApp. Nothing is charged now.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              height: 1.4,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          _TermsRow(
            value: _agreed,
            accent: accent,
            onChanged: (v) => setState(() => _agreed = v),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        service: service,
        day: _day,
        time: _time,
        people: _people,
        ready: _ready,
        loading: _loading,
        onPressed: () => _confirm(found),
      ),
    );
  }

  Future<void> _confirm(BookableService found) async {
    if (!_ready) {
      final what = _day == null
          ? 'Pick a date first.'
          : _time == null
              ? 'Pick a time first.'
              : 'Agree to the terms to continue.';
      AppToast.showWarning(context, what);
      return;
    }

    final request = BookingRequest.create(
      serviceId: found.service.id,
      serviceName: found.service.name,
      zoneId: found.zone.id,
      zoneName: found.zone.name,
      day: _day!,
      time: _time!.format(context),
      people: _people,
      note: _noteController.text,
      price: found.service.price,
    );

    setState(() => _loading = true);
    try {
      await ref.read(bookingRepositoryProvider).submit(request);
      ref.invalidate(myBookingsProvider);
      if (!mounted) return;
      setState(() => _loading = false);
      _showSent(found);
    } on BookingDeliveryException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showError(context, e.message);
    }
  }

  /// WhatsApp is open but the message is still theirs to send, so say so
  /// rather than claiming the booking is confirmed.
  void _showSent(BookableService found) {
    final colors = context.appColors;
    final accent = colors.resolveZoneForeground(found.zone.color);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewPaddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.15),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Icon(Icons.chat_rounded, size: 26, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              'Send it to finish',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your details are typed out in WhatsApp. Send the message and '
              'Arcade Hub will confirm the slot.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1.45,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'See my requests',
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/bookings');
              },
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/book');
                }
              },
              child: Text(
                'Done',
                style: GoogleFonts.dmSans(color: colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section heading above each field.
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: context.appColors.textMuted,
      ),
    );
  }
}

/// What is being booked: zone, name, duration and price.
class _SummaryCard extends StatelessWidget {
  final ServiceModel service;
  final ArcadeExperience zone;
  final Color accent;

  const _SummaryCard({
    required this.service,
    required this.zone,
    required this.accent,
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(zone.iconData, size: 14, color: accent),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            zone.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      service.name,
                      style: GoogleFonts.outfit(
                        fontSize: 21,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (service.durationText != null)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: colors.textMuted,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    service.durationText!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 10),
                        Text(
                          service.price != null
                              ? AppConstants.formatPrice(service.price!)
                              : 'On request',
                          maxLines: 1,
                          style: GoogleFonts.outfit(
                            fontSize: service.price != null ? 18 : 13,
                            fontWeight: FontWeight.w900,
                            color: colors.textPrimary,
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

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// A week at a time, the way a calendar reads: seven columns across the full
/// width, paged with the arrows. Days already gone are not selectable.
class _WeekCalendar extends StatefulWidget {
  final DateTime? selected;
  final Color accent;
  final int weeksAhead;
  final ValueChanged<DateTime> onPick;

  const _WeekCalendar({
    required this.selected,
    required this.accent,
    required this.weeksAhead,
    required this.onPick,
  });

  @override
  State<_WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<_WeekCalendar> {
  // Weeks run Sunday to Saturday.
  static DateTime _weekOf(DateTime day) =>
      _dayOnly(day).subtract(Duration(days: day.weekday % 7));

  late DateTime _week;

  @override
  void initState() {
    super.initState();
    _week = _weekOf(widget.selected ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final today = _dayOnly(DateTime.now());
    final thisWeek = _weekOf(today);
    final lastWeek = thisWeek.add(Duration(days: 7 * widget.weeksAhead));
    final days = [for (var i = 0; i < 7; i++) _week.add(Duration(days: i))];
    final canGoBack = _week.isAfter(thisWeek);
    final canGoOn = _week.isBefore(lastWeek);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Month, plus the two arrows that page the week.
          Row(
            children: [
              _Arrow(
                icon: Icons.chevron_left_rounded,
                enabled: canGoBack,
                onTap: () => _shift(-7),
              ),
              Expanded(
                child: Text(
                  _monthLabel(days.first, days.last),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              _Arrow(
                icon: Icons.chevron_right_rounded,
                enabled: canGoOn,
                onTap: () => _shift(7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final day in days)
                Expanded(
                  child: _DayCell(
                    day: day,
                    selected:
                        widget.selected != null && _sameDay(widget.selected!, day),
                    isToday: _sameDay(day, today),
                    past: day.isBefore(today),
                    accent: widget.accent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onPick(day);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _shift(int days) {
    HapticFeedback.selectionClick();
    setState(() => _week = _week.add(Duration(days: days)));
  }

  /// "October" on its own, or "Oct - Nov" for a week that straddles two.
  String _monthLabel(DateTime first, DateTime last) {
    final year = DateFormat('y').format(first);
    if (first.month == last.month) {
      return '${DateFormat('MMMM').format(first)} $year';
    }
    return '${DateFormat('MMM').format(first)} - '
        '${DateFormat('MMM').format(last)} $year';
  }
}

/// One of the two week arrows.
class _Arrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _Arrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 34,
        height: 30,
        child: Icon(
          icon,
          size: 22,
          color: enabled ? colors.textPrimary : colors.borderSubtle,
        ),
      ),
    );
  }
}

/// Weekday letter over the date. Filled when chosen, ringed when it is today.
class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final bool isToday;
  final bool past;
  final Color accent;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.past,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // The filled cell carries the zone colour, so ink follows the fill.
    final ink = accent.computeLuminance() > 0.45
        ? const Color(0xFF0A0A0A)
        : Colors.white;

    return Column(
      children: [
        Text(
          DateFormat('E').format(day).substring(0, 1),
          style: GoogleFonts.dmSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 5),
        InkResponse(
          onTap: past ? null : onTap,
          radius: 24,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? accent : Colors.transparent,
              border: isToday && !selected
                  ? Border.all(color: accent, width: 1.4)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: selected
                    ? ink
                    : past
                        ? colors.borderSubtle
                        : colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

int _minutesOf(TimeOfDay t) => t.hour * 60 + t.minute;

int get _openMinute => AppConstants.bookingOpenHour * 60;
int get _lastMinute => AppConstants.bookingLastHour * 60;

/// The times the venue offers, every half hour from open to close.
List<TimeOfDay> openingSlots() => [
      for (var m = _openMinute;
          m <= _lastMinute;
          m += AppConstants.bookingSlotMinutes)
        TimeOfDay(hour: m ~/ 60, minute: m % 60),
    ];

/// Whether a time is inside opening hours at all, whatever the day.
bool timeIsWithinHours(TimeOfDay time) {
  final m = _minutesOf(time);
  return m >= _openMinute && m <= _lastMinute;
}

/// Whether a time can still be asked for: inside opening hours, and not
/// already behind us if the day is today.
bool slotIsBookable(TimeOfDay slot, DateTime day, {DateTime? now}) {
  if (!timeIsWithinHours(slot)) return false;
  final clock = now ?? DateTime.now();
  if (!_sameDay(day, clock)) return true;
  return _minutesOf(slot) > _minutesOf(TimeOfDay.fromDateTime(clock));
}

/// The times on offer, plus a way to ask for any other time inside opening
/// hours. Nothing outside the hours can be chosen, by chip or by clock.
class _TimeSlots extends StatelessWidget {
  final DateTime? day;
  final TimeOfDay? selected;
  final Color accent;
  final ValueChanged<TimeOfDay> onPick;

  const _TimeSlots({
    required this.day,
    required this.selected,
    required this.accent,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // A time picked off the clock sits in the strip in its own place, rather
    // than leaving nothing looking selected.
    final all = openingSlots();
    final chosen = selected;
    if (chosen != null && !all.any((s) => _isSameTime(s, chosen))) {
      all.add(chosen);
      all.sort((a, b) => _minutesOf(a).compareTo(_minutesOf(b)));
    }
    final bookable =
        day == null ? all : [for (final s in all) if (slotIsBookable(s, day!)) s];

    if (bookable.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.nightlight_round, size: 16, color: colors.textMuted),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Too late for today. Pick another day.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // One scrolling line rather than a block of chips: half-hourly from open
    // to close is a lot of times, and a wall of them buries the rest of the
    // form. Built all at once so scrolling never lags.
    return SizedBox(
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final slot in all) ...[
              _SlotChip(
                label: slot.format(context),
                selected: chosen != null && _isSameTime(slot, chosen),
                enabled: bookable.contains(slot),
                accent: accent,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPick(slot);
                },
              ),
              const SizedBox(width: 8),
            ],
            _SlotChip(
              label: 'Other',
              icon: Icons.access_time_rounded,
              selected: false,
              enabled: true,
              accent: accent,
              onTap: () => _pickByClock(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Any time at all, so long as the venue is open for it.
  Future<void> _pickByClock(BuildContext context) async {
    HapticFeedback.selectionClick();
    final open = TimeOfDay(hour: AppConstants.bookingOpenHour, minute: 0);
    final close = TimeOfDay(hour: AppConstants.bookingLastHour, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: selected ?? open,
    );
    if (picked == null || !context.mounted) return;

    if (!timeIsWithinHours(picked)) {
      AppToast.showWarning(
        context,
        'Bookings run ${open.format(context)} to ${close.format(context)}.',
      );
      return;
    }
    if (day != null && !slotIsBookable(picked, day!)) {
      AppToast.showWarning(context, 'That time has gone by today.');
      return;
    }
    onPick(picked);
  }
}

bool _isSameTime(TimeOfDay a, TimeOfDay b) =>
    a.hour == b.hour && a.minute == b.minute;

class _SlotChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;
  final IconData? icon;

  const _SlotChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.accent,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ink = accent.computeLuminance() > 0.45
        ? const Color(0xFF0A0A0A)
        : Colors.white;

    return Material(
      color: selected ? accent : colors.card,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected
                  ? accent
                  : enabled
                      ? colors.border
                      : colors.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: colors.textMuted),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? ink
                      : enabled
                          ? colors.textPrimary
                          : colors.borderSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minus / count / plus, sized to sit beside the time field./// Minus / count / plus, sized to sit beside the time field.
class _PeopleStepper extends StatelessWidget {
  final int value;
  final Color accent;
  final ValueChanged<int> onChanged;

  const _PeopleStepper({
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _step(
            context,
            Icons.remove_rounded,
            value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
              ),
            ),
          ),
          _step(
            context,
            Icons.add_rounded,
            value < 30 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _step(BuildContext context, IconData icon, VoidCallback? onTap) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap();
            },
      child: SizedBox(
        width: 40,
        height: 52,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? colors.textMuted : accent,
        ),
      ),
    );
  }
}

/// Tappable terms row with a box that matches the zone colour.
class _TermsRow extends StatelessWidget {
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const _TermsRow({
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ink = accent.computeLuminance() > 0.45
        ? const Color(0xFF0A0A0A)
        : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: value ? accent : colors.border,
                  width: 1.6,
                ),
              ),
              child: value
                  ? Icon(Icons.check_rounded, size: 15, color: ink)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I agree to the venue rules and cancellation terms.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  height: 1.35,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky footer: a recap of the choices, then Confirm.
class _BottomBar extends StatelessWidget {
  final ServiceModel service;
  final DateTime? day;
  final TimeOfDay? time;
  final int people;
  final bool ready;
  final bool loading;
  final VoidCallback onPressed;

  const _BottomBar({
    required this.service,
    required this.day,
    required this.time,
    required this.people,
    required this.ready,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final parts = [
      if (day != null) DateFormat('EEE d MMM').format(day!),
      if (time != null) time!.format(context),
      '$people ${people == 1 ? 'person' : 'people'}',
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.scaffold,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  parts.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              if (service.price != null)
                Text(
                  AppConstants.formatPrice(service.price!),
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Opacity(
            // Stays tappable so the button can say what is missing.
            opacity: ready ? 1 : 0.55,
            child: PrimaryButton(
              label: 'Request on WhatsApp',
              loading: loading,
              icon: const Icon(Icons.chat_rounded,
                  size: 17, color: Colors.white),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
