import re

with open(r'c:\Users\ACER\Desktop\arcadehuborderingapp\lib\features\home\home_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'class ' in line or 'AppColors.' in line:
        print(f"{i+1}: {line.strip()}")
