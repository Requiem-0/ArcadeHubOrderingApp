import re

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add import if missing
if 'app_theme_colors.dart' not in content:
    content = content.replace(
        "import '../../core/brandkit/app_colors.dart';",
        "import '../../core/brandkit/app_colors.dart';\nimport '../../core/brandkit/app_theme_colors.dart';"
    )

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Import added successfully")
