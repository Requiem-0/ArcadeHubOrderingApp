with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. _HomeScreenState.build
text = text.replace(
    '''  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      drawerScrimColor: Colors.black.withValues(alpha: 0.75),
      drawer: const ArcadeAppDrawer(),
      body: Builder(
        builder: (innerContext) => SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App Bar Header ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                color: AppColors.scaffoldDark,''',
    '''  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.scaffold,
      drawerScrimColor: Colors.black.withValues(alpha: 0.75),
      drawer: const ArcadeAppDrawer(),
      body: Builder(
        builder: (innerContext) => SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App Bar Header ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                color: colors.scaffold,'''
)

# Replace header colors
text = text.replace(
    "colors: [AppColors.primaryRedDark, AppColors.deepRed],",
    "colors: [colors.primaryRed, colors.deepRed],"
)
text = text.replace(
    "color: AppColors.primaryRedDark.withValues(alpha: 0.4),",
    "color: colors.primaryRed.withValues(alpha: 0.4),"
)
text = text.replace(
    "color: AppColors.textLight,\n                              ),",
    "color: colors.textPrimary,\n                              ),"
)
text = text.replace(
    "color: AppColors.textMutedLight,\n                              ),",
    "color: colors.primaryRed,\n                              ),"
)
text = text.replace(
    "color: AppColors.surfaceLight,",
    "color: colors.cardElevated,"
)
text = text.replace(
    "border: Border.all(color: AppColors.borderLight),",
    "border: Border.all(color: colors.border),"
)
text = text.replace(
    "color: AppColors.primaryRedDark,",
    "color: colors.primaryRed,"
)

# Indicator dots
text = text.replace(
    '''                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: active
                              ? AppColors.primaryRedDark
                              : AppColors.borderLight.withValues(alpha: 0.5),
                        ),
                      );''',
    '''                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: active
                              ? colors.primaryRed
                              : colors.border.withValues(alpha: 0.7),
                        ),
                      );'''
)

# Search bar
text = text.replace(
    '''                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/food-menu'),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primaryRedDark,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search food, drinks & combos...',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  Text(
                                    'Burgers, pizzas, platters & drinks',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.tune_rounded,
                              color: AppColors.textMutedLight,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),''',
    '''                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                      boxShadow: colors.cardShadow,
                    ),
                    child: InkWell(
                      onTap: () => context.push('/food-menu'),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.primaryRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.search_rounded,
                                color: colors.primaryRed,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search food, drinks & combos...',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Burgers, pizzas, platters & drinks',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.tune_rounded,
                              color: colors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),'''
)

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated home_screen top parts successfully")
