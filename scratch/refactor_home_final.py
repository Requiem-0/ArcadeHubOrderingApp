with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# _FeaturedZoneCard
text = text.replace(
    '''  @override
  Widget build(BuildContext context) {
    final color = exp.color == const Color(0xFFF8FAFC)
        ? AppColors.textLight
        : exp.color;''',
    '''  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = exp.color == const Color(0xFFF8FAFC)
        ? colors.textPrimary
        : exp.color;'''
)

# Line 345: Empty bundles state
text = text.replace(
    "color: AppColors.cardLight,\n          borderRadius: BorderRadius.circular(20),",
    "color: colors.card,\n          borderRadius: BorderRadius.circular(20),\n          boxShadow: colors.cardShadow,"
)
text = text.replace(
    "color: AppColors.primaryRed.withValues(alpha: 0.12),",
    "color: colors.primaryRed.withValues(alpha: 0.12),"
)
text = text.replace(
    "color: AppColors.textLight,\n              ),",
    "color: colors.textPrimary,\n              ),"
)
text = text.replace(
    "color: AppColors.textMutedLight,\n              ),",
    "color: colors.textMuted,\n              ),"
)

# _BundleSkeleton
text = text.replace(
    "color: AppColors.cardLight.withValues(alpha: _anim.value),",
    "color: (context.findAncestorWidgetOfExactType<HomeScreen>() != null ? Theme.of(context).cardColor : const Color(0xFF212121)).withValues(alpha: _anim.value),"
)

# _BundleCard remaining
text = text.replace(
    "colors: [Color(0xFFFFD700), AppColors.primaryRedDark],",
    "colors: [const Color(0xFFFFD700), colors.primaryRed],"
)
text = text.replace(
    "backgroundColor: AppColors.primaryRed,",
    "backgroundColor: colors.primaryRed,"
)

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Finished clean up of home_screen.dart")
