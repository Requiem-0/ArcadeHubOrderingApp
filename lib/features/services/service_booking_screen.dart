// lib/features/services/service_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../shared/widgets/primary_button.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/utils/app_toast.dart';

class ServiceBookingScreen extends ConsumerStatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  ConsumerState<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends ConsumerState<ServiceBookingScreen> {
  bool _agreedToTerms = false;
  bool _loading = false;
  String? serviceId;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    serviceId = uri.queryParameters['serviceId'];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (serviceId == null) {
      return Scaffold(
        backgroundColor: colors.scaffold,
        body: Center(child: Text('No service specified', style: TextStyle(color: colors.textPrimary))),
      );
    }

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.scaffold,
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: colors.textPrimary, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Confirm Booking',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.primaryRed.withValues(alpha: 0.3)),
                      boxShadow: colors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primaryRed.withValues(alpha: 0.15),
                            border: Border.all(
                              color: colors.primaryRed.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.sports_esports_rounded,
                            size: 34,
                            color: colors.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Service Booking',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.cardElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Base Price', style: GoogleFonts.dmSans(color: colors.textMuted)),
                                  Text(
                                    'Standard Rate',
                                    style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                              Divider(color: colors.border, height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Duration', style: GoogleFonts.dmSans(color: colors.textMuted)),
                                  Text(
                                    'Standard Duration',
                                    style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Terms Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                      boxShadow: colors.cardShadow,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: colors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please review the terms and conditions for this booking, including cancellation and late return policies provided by the venue.',
                            style: GoogleFonts.dmSans(fontSize: 13, color: colors.textMuted, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Agreement Checkbox
                  InkWell(
                    onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (v) {
                            if (v != null) setState(() => _agreedToTerms = v);
                          },
                          activeColor: colors.primaryRed,
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the service rules and venue terms of service.',
                            style: GoogleFonts.dmSans(fontSize: 13, color: colors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.scaffold,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Confirm Booking',
            loading: _loading,
            onPressed: _agreedToTerms
                ? () async {
                    final isLoggedIn = await ref.read(authRepositoryProvider).isLoggedIn();
                    if (!isLoggedIn) {
                      if (!mounted) return;
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: colors.scaffold,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primaryRed.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: colors.primaryRed.withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.sports_esports_rounded,
                                  size: 28,
                                  color: colors.primaryRed,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sign in to Book PS5 Rental',
                                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please sign in or register to reserve PS5 console rental slots.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(fontSize: 13, color: colors.textMuted),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Sign In / Register',
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.push('/login');
                                },
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancel', style: GoogleFonts.dmSans(color: colors.textMuted)),
                              ),
                            ],
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() => _loading = true);
                    await Future.delayed(const Duration(milliseconds: 1000));
                    if (!mounted) return;
                    context.go('/order-success');
                  }
                : () {
                    AppToast.showWarning(context, 'Please agree to the terms to proceed.');
                  },
          ),
        ),
      ),
    );
  }
}
