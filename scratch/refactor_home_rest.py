with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# _SectionHeader
text = text.replace(
    '''class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}''',
    '''class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: colors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}'''
)

# _FeatureGridItemState
text = text.replace(
    '''  @override
  Widget build(BuildContext context) {
    final exp = widget.exp;
    final color = exp.color == const Color(0xFFF8FAFC)
        ? AppColors.textLight
        : exp.color;''',
    '''  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final exp = widget.exp;
    final fgColor = colors.resolveZoneForeground(exp.color);
    final bgColor = colors.resolveZoneBackground(exp.color);
    final borderColor = colors.resolveZoneBorder(exp.color);'''
)

text = text.replace(
    '''              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),''',
    '''              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
                boxShadow: colors.isDark
                    ? [
                        BoxShadow(
                          color: fgColor.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : colors.cardShadow,
              ),'''
)

text = text.replace(
    "color: color.withValues(alpha: 0.05),",
    "color: fgColor.withValues(alpha: colors.isDark ? 0.05 : 0.04),"
)

text = text.replace(
    '''                          ? _buildLargeLayout(exp, color)
                          : _buildSmallLayout(exp, color),''',
    '''                          ? _buildLargeLayout(exp, fgColor, bgColor, colors)
                          : _buildSmallLayout(exp, fgColor, bgColor, colors),'''
)

text = text.replace(
    '''  Widget _buildLargeLayout(ArcadeExperience exp, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10), // Reduced from 12
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(exp.iconData, color: color, size: 36), // Reduced from 48
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exp.name,
              style: GoogleFonts.outfit(
                fontSize: 20, // Reduced from 24
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              exp.subtitle.split('·').first.trim(),
              style: GoogleFonts.dmSans(
                fontSize: 12, // Reduced from 14
                color: AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallLayout(ArcadeExperience exp, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(exp.iconData, color: color, size: 22), // Reduced from 28
        AppSpacing.gapV4,
        Text(
          exp.name,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }''',
    '''  Widget _buildLargeLayout(ArcadeExperience exp, Color fgColor, Color bgColor, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(exp.iconData, color: fgColor, size: 36),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exp.name,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              exp.subtitle.split('·').first.trim(),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallLayout(ArcadeExperience exp, Color fgColor, Color bgColor, AppThemeColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(exp.iconData, color: fgColor, size: 22),
        AppSpacing.gapV4,
        Text(
          exp.name,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: fgColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }'''
)

# PromoTicketCard
text = text.replace(
    '''  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Padding(
          padding: AppSpacing.pagePadding,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.brandColor.withValues(alpha: _glow.value * 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipPath(
              clipper: _TicketClipper(holeRadius: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF1A1A1A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: widget.brandColor.withValues(alpha: 0.3 + (_glow.value * 0.4)),
                    width: 1.5,
                  ),
                ),''',
    '''  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Padding(
          padding: AppSpacing.pagePadding,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: colors.isDark
                  ? [
                      BoxShadow(
                        color: widget.brandColor.withValues(alpha: _glow.value * 0.15),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      )
                    ]
                  : colors.cardShadow,
            ),
            child: ClipPath(
              clipper: _TicketClipper(holeRadius: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors.isDark
                        ? const [
                            Color(0xFF2A2A2A),
                            Color(0xFF1A1A1A),
                          ]
                        : const [
                            Color(0xFFFFFFFF),
                            Color(0xFFF9FAFB),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: widget.brandColor.withValues(alpha: 0.3 + (_glow.value * 0.4)),
                    width: 1.5,
                  ),
                ),'''
)

text = text.replace(
    '''                              Text(
                                widget.subtitle,
                                style: GoogleFonts.dmSans(
                                   fontSize: 13,
                                   color: AppColors.textLight,
                                   height: 1.4,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),''',
    '''                              Text(
                                widget.subtitle,
                                style: GoogleFonts.dmSans(
                                   fontSize: 13,
                                   color: colors.textPrimary,
                                   height: 1.4,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),'''
)

text = text.replace(
    '''                                  Text(
                                     widget.countLabel.toUpperCase(),
                                     style: GoogleFonts.dmSans(
                                       fontSize: 10,
                                       fontWeight: FontWeight.bold,
                                       color: AppColors.textMutedLight,
                                     ),
                                   ),''',
    '''                                  Text(
                                     widget.countLabel.toUpperCase(),
                                     style: GoogleFonts.dmSans(
                                       fontSize: 10,
                                       fontWeight: FontWeight.bold,
                                       color: colors.textMuted,
                                     ),
                                   ),'''
)

text = text.replace(
    '''                                  Text(
                                     _formatDuration(widget.remainingTime),
                                     style: GoogleFonts.outfit(
                                       fontSize: 18,
                                       fontWeight: FontWeight.w900,
                                       color: Colors.white,
                                       letterSpacing: 1,
                                     ),
                                   ),''',
    '''                                  Text(
                                     _formatDuration(widget.remainingTime),
                                     style: GoogleFonts.outfit(
                                       fontSize: 18,
                                       fontWeight: FontWeight.w900,
                                       color: colors.isDark ? Colors.white : colors.textPrimary,
                                       letterSpacing: 1,
                                     ),
                                   ),'''
)

# _BundleCard
text = text.replace(
    '''    final tag = product.tags.isNotEmpty ? product.tags.first : 'Combo';
    final savePillText = product.tags.firstWhere(
      (t) => t.toUpperCase().contains('SAVE') || t.contains('%'),
      orElse: () => product.originalPrice != null
          ? 'SAVE ${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()}%'
          : 'SPECIAL',
    );
    const cardAccentColor = AppColors.primaryRedDark;''',
    '''    final colors = context.appColors;
    final tag = product.tags.isNotEmpty ? product.tags.first : 'Combo';
    final savePillText = product.tags.firstWhere(
      (t) => t.toUpperCase().contains('SAVE') || t.contains('%'),
      orElse: () => product.originalPrice != null
          ? 'SAVE ${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()}%'
          : 'SPECIAL',
    );
    final cardAccentColor = colors.primaryRed;'''
)

text = text.replace(
    '''              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardAccentColor.withValues(alpha: 0.35)),
              ),''',
    '''              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardAccentColor.withValues(alpha: 0.35)),
                boxShadow: colors.cardShadow,
              ),'''
)

text = text.replace(
    '''                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cardAccentColor.withValues(alpha: 0.5)),
                        ),''',
    '''                        decoration: BoxDecoration(
                          color: colors.cardElevated,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cardAccentColor.withValues(alpha: 0.5)),
                        ),'''
)

text = text.replace(
    '''                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),''',
    '''                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),'''
)

text = text.replace(
    '''                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textMutedLight,
                      height: 1.3,
                    ),''',
    '''                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: colors.textMuted,
                      height: 1.3,
                    ),'''
)

text = text.replace(
    '''                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.textMutedLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),''',
    '''                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.normal,
                                    color: colors.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),'''
)

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated home_screen.dart successfully")
