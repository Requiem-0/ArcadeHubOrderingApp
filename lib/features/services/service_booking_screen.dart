import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../shared/widgets/primary_button.dart';
import '../../core/repositories/auth_repository.dart';

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
    if (serviceId == null) {
      return const Scaffold(body: Center(child: Text('No service specified')));
    }

    // A hack to find the service from our provider since we don't have a direct getServiceById in our mock
    // In a real app we'd fetch it via id. For now we can fetch all services for 'playroom' and others, 
    // but a better way is to just find it from a global state.
    // Given our mock structure, let's pretend we pass the service data or just show a loading screen while we fetch.
    // For simplicity, let's just make a generic UI.

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.scaffoldLight,
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Confirm Booking',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
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
                      color: AppColors.primaryRed.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryRedDark.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('🎮', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'Service Booking',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Base Price', style: GoogleFonts.dmSans(color: AppColors.textMutedLight)),
                                  Text(
                                    'Standard Rate',
                                    style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Duration', style: GoogleFonts.dmSans(color: AppColors.textMutedLight)),
                                  Text(
                                    'Standard Duration',
                                    style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
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
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.textMutedLight, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please review the terms and conditions for this booking, including cancellation and late return policies provided by the venue.',
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMutedLight, height: 1.4),
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
                          activeColor: AppColors.primaryRedDark,
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the service rules and venue terms of service.',
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textLight),
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
        decoration: const BoxDecoration(
          color: AppColors.scaffoldLight,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
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
                        backgroundColor: AppColors.scaffoldLight,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎮', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 12),
                              Text(
                                'Sign in to Book PS5 Rental',
                                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please sign in or register to reserve PS5 console rental slots.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMutedLight),
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
                                child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textMutedLight)),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please agree to the terms to proceed.')),
                    );
                  },
          ),
        ),
      ),
    );
  }
}
