import re

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

matches = re.findall(r'AppColors\.[a-zA-Z0-9]+', content)
print("Unique AppColors in home_screen.dart:", set(matches))
print("Total count:", len(matches))
