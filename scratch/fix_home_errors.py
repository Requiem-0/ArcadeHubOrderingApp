with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix 1: gradient const
text = text.replace(
    '''                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [colors.primaryRed, colors.deepRed],''',
    '''                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [colors.primaryRed, colors.deepRed],'''
)

# Fix 2: _buildNoBundlesPlaceholder
text = text.replace(
    '_buildNoBundlesPlaceholder()',
    '_buildNoBundlesPlaceholder(colors)'
)
text = text.replace(
    'Widget _buildNoBundlesPlaceholder() {',
    'Widget _buildNoBundlesPlaceholder(AppThemeColors colors) {'
)
text = text.replace(
    '''              child: const Icon(
                Icons.card_giftcard_rounded,
                color: colors.primaryRed,
                size: 30,
              ),''',
    '''              child: Icon(
                Icons.card_giftcard_rounded,
                color: colors.primaryRed,
                size: 30,
              ),'''
)

# Fix 3: _BundleSkeleton colors
text = text.replace(
    '''  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pagePadding,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, __) => Container(
            width: 310,
            decoration: BoxDecoration(
              color: (context.findAncestorWidgetOfExactType<HomeScreen>() != null ? Theme.of(context).cardColor : const Color(0xFF212121)).withValues(alpha: _anim.value),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
          ),
        ),
      ),
    );
  }''',
    '''  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pagePadding,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, __) => Container(
            width: 310,
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: _anim.value),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
          ),
        ),
      ),
    );
  }'''
)

# Fix 4: _BundleCard gradient const
text = text.replace(
    '''                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [const Color(0xFFFFD700), colors.primaryRed],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),''',
    '''                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFFFD700), colors.primaryRed],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),'''
)

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Applied fixes to home_screen.dart")
