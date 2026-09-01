// lib/features/profile/contact_us_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme.dart';
import '../../shared/widgets/primary_button.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/9779805855494?text=Hi%20Arcade%20Hub!%20I%20have%20an%20inquiry.');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+9779805855494');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:support@arcadehub.com.np');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _sending = false);
      _msgCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Message sent successfully! We will contact you shortly.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textLight, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Contact Us',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryRed.withOpacity(0.18),
                      AppColors.surfaceLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: AppColors.primaryRed,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'We are here to help!',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Have a question about food delivery or station bookings?',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Direct Channels (Compact 2-Column + 1 Full Width Grid)
              Text(
                'Direct Channels',
                style: GoogleFonts.outfit(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.phone_rounded,
                      label: 'Call Us',
                      subtext: '+977 9805855494',
                      onTap: _launchPhone,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      subtext: 'Instant Chat',
                      onTap: _launchWhatsApp,
                      color: const Color(0xFF25D366),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ContactCard(
                icon: Icons.email_rounded,
                label: 'Email Support',
                subtext: 'support@arcadehub.com.np',
                onTap: _launchEmail,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 20),

              // Venue Info Box (Combined Card)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.primaryRed, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arcade Hub Venue',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                              Text(
                                'Lakeside, Pokhara 33700, Nepal',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderLight, height: 20),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppColors.primaryRed, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Operating Hours',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                              Text(
                                'Daily: 11:00 AM – 11:00 PM',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Send Message Form
              Text(
                'Send a Message',
                style: GoogleFonts.outfit(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _nameCtrl,
                style: GoogleFonts.dmSans(color: AppColors.textLight),
                decoration: const InputDecoration(
                  hintText: 'Your Name',
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: AppColors.textMutedLight, size: 18),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.dmSans(color: AppColors.textLight),
                decoration: const InputDecoration(
                  hintText: 'Email or Phone Number',
                  prefixIcon: Icon(Icons.alternate_email_rounded,
                      color: AppColors.textMutedLight, size: 18),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _msgCtrl,
                maxLines: 3,
                style: GoogleFonts.dmSans(color: AppColors.textLight),
                decoration: const InputDecoration(
                  hintText: 'How can we help you?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                label: 'SUBMIT INQUIRY →',
                loading: _sending,
                onPressed: _sendMessage,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtext;
  final VoidCallback onTap;
  final Color color;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.subtext,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtext,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
