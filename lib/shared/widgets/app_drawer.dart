// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/experiences.dart';

class ArcadeAppDrawer extends StatelessWidget {
  const ArcadeAppDrawer({super.key});

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/9779805855494?text=Hi%20Arcade%20Hub!%20I%20have%20an%20inquiry.');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E0808),
              Color(0xFF121212),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            right: BorderSide(
              color: AppColors.primaryRedDark.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drawer Header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Red Gradient Brand Logo Box
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryRedDark, AppColors.deepRed],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRedDark.withOpacity(0.4),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sports_esports_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arcade Hub',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'GAME HOUSE · RESTRO',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.borderLight, height: 1),

              // ── Scrollable Navigation ──────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  children: [
                    // 6 Zone Links
                    ...kArcadeExperiences.map((exp) => _DrawerZoneLink(exp: exp)),

                    const SizedBox(height: 10),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 10),

                    // Secondary Nav Links
                    _DrawerSmallLink(
                      iconData: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/settings');
                      },
                    ),
                    _DrawerSmallLink(
                      iconData: Icons.person_outline_rounded,
                      label: 'My Profile',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/profile');
                      },
                    ),
                    _DrawerSmallLink(
                      iconData: Icons.location_on_outlined,
                      label: 'Saved Addresses',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/addresses');
                      },
                    ),
                    _DrawerSmallLink(
                      iconData: Icons.favorite_outline_rounded,
                      label: 'Favourites',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/favourites');
                      },
                    ),
                    _DrawerSmallLink(
                      iconData: Icons.receipt_long_outlined,
                      label: 'Recent Orders',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/orders');
                      },
                    ),
                    _DrawerSmallLink(
                      iconData: Icons.chat_bubble_outline_rounded,
                      label: 'Contact Us',
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchWhatsApp();
                      },
                    ),
                  ],
                ),
              ),

              // ── Drawer Footer ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderLight, width: 1),
                  ),
                ),
                child: Text(
                  'Pokhara, Nepal',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMutedLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drawer Zone Navigation Link
class _DrawerZoneLink extends StatelessWidget {
  final ArcadeExperience exp;

  const _DrawerZoneLink({required this.exp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            context.push('/experience/${exp.id}');
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: exp.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: exp.color.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      exp.iconData,
                      color: exp.color == const Color(0xFFF8FAFC)
                          ? AppColors.textLight
                          : exp.color,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    exp.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMutedLight,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer Small Action Link
class _DrawerSmallLink extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onTap;

  const _DrawerSmallLink({
    required this.iconData,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(iconData, color: AppColors.textMutedLight, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
