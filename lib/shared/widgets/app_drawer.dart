// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/constants.dart';

class ArcadeAppDrawer extends StatelessWidget {
  const ArcadeAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            // ── Drawer Header ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryRedDark, AppColors.deepRed],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.sports_esports_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          AppConstants.appLocation,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMutedLight),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Scrollable Menu ──────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  Text(
                    'VENUE EXPERIENCES',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 6 Core Experience Badges with Vector Icons
                  ...kArcadeExperiences.map((exp) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: exp.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push('/experience/${exp.id}');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    exp.iconData,
                                    color: exp.color == const Color(0xFFFFFFFF)
                                        ? AppColors.textLight
                                        : exp.color,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      exp.name,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: exp.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      exp.featureTag,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: exp.color == const Color(0xFFFFFFFF)
                                            ? AppColors.textLight
                                            : exp.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),

                  const SizedBox(height: 16),
                  Text(
                    'SPECIAL SERVICES',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // PS5 Rental Quick Link
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    tileColor: AppColors.primaryRed.withOpacity(0.15),
                    leading: const Icon(Icons.sports_esports_rounded, color: AppColors.primaryRedDark, size: 22),
                    title: Text(
                      'PS5 Rental (9PM-9AM)',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRedDark,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/service-booking');
                    },
                  ),
                  const SizedBox(height: 8),

                  // App Discount Quick Link
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    tileColor: AppColors.success.withOpacity(0.15),
                    leading: const Icon(Icons.bolt_rounded, color: AppColors.success, size: 22),
                    title: Text(
                      'App 10% Discount Info',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/discounts');
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderLight),

                  ListTile(
                    leading: const Icon(Icons.receipt_long,
                        color: AppColors.textMutedLight),
                    title: const Text('Recent Orders'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/orders');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppColors.textMutedLight),
                    title: const Text('Saved Addresses'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/addresses');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: AppColors.textMutedLight),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/settings');
                    },
                  ),
                ],
              ),
            ),

            // ── WhatsApp Contact Footer ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Direct WhatsApp contact action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(
                  'WhatsApp: ${AppConstants.whatsappFormatted}',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
