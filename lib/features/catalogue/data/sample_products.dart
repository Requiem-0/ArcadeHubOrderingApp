// lib/features/catalogue/data/sample_products.dart
import 'product_model.dart';

const List<ProductModel> kSampleProducts = [
  ProductModel(
    id: 'pos-1',
    name: 'Arcade Hub Loaded Nachos',
    emoji: '🧀',
    price: 650,
    originalPrice: 750,
    prepTime: '15 min',
    category: 'Munchies',
    tags: ['Chef Special', 'Popular'],
    description: 'Crispy tortilla chips loaded with melted cheese, jalapenos & sour cream',
    longDescription:
        'Freshly baked corn tortillas topped with house blend aged cheddar, pico de gallo, black olives, guacamole, and signature spicy jalapeno dip.',
    variants: [
      ProductVariant(id: 'v1', label: 'Vegetarian Loaded', price: 650),
      ProductVariant(id: 'v2', label: 'Grilled Chicken Supreme', price: 820),
    ],
    addons: [
      ProductAddon(id: 'a1', name: 'Extra Guacamole', price: 150),
      ProductAddon(id: 'a2', name: 'Extra Melted Cheese', price: 120),
    ],
  ),
  ProductModel(
    id: 'pos-2',
    name: 'Fewa Sunset Mocktail',
    emoji: '🍹',
    price: 380,
    prepTime: '5 min',
    category: 'Drinks',
    tags: ['Refreshing'],
    description: 'Passion fruit, peach syrup, mint & sparkling soda over crushed ice',
    longDescription:
        'Inspired by the sunset colors over Fewa Lake. Layered passion fruit puree, blood orange syrup, fresh lime juice, and a splash of sparkling sprite.',
  ),
  ProductModel(
    id: 'pos-3',
    name: 'Cyberpunk Bacon Cheeseburger',
    emoji: '🍔',
    price: 890,
    originalPrice: 990,
    prepTime: '20 min',
    category: 'Gourmet Burgers',
    tags: ['Must Try'],
    description: 'Juicy beef patty, smoked bacon, caramelized onions & secret hub sauce',
    longDescription:
        '100% prime beef patty, crispy smoked bacon, melted cheddar cheese, caramelized onions, and garlic aioli served in a toasted brioche bun.',
    variants: [
      ProductVariant(id: 'v1', label: 'Single Patty Classic', price: 890),
      ProductVariant(id: 'v2', label: 'Double Patty Beast', price: 1190),
    ],
    addons: [
      ProductAddon(id: 'a1', name: 'Crispy Potato Wedges', price: 200),
    ],
  ),
  ProductModel(
    id: 'pos-4',
    name: 'Rooftop Woodfired Pizza',
    emoji: '🍕',
    price: 1150,
    prepTime: '25 min',
    category: 'Pizza',
    tags: ['Woodfired'],
    description: 'Artisanal thin crust, San Marzano tomato sauce & fresh mozzarella',
    longDescription:
        'Traditional woodfired pizza baked at 450°C. Crispy airy crust topped with rich tomato sauce, buffalo mozzarella, and fresh basil leaves.',
    variants: [
      ProductVariant(id: 'v1', label: 'Margherita Gold', price: 1150),
      ProductVariant(id: 'v2', label: 'Smoked Chicken Supreme', price: 1350),
    ],
  ),
  ProductModel(
    id: 'pos-5',
    name: 'Neon Green Wings (10 pcs)',
    emoji: '🍗',
    price: 720,
    prepTime: '18 min',
    category: 'Munchies',
    tags: ['Spicy'],
    description: 'Jumbo wings tossed in spicy jalapeno cilantro lime glaze',
    longDescription:
        'Crispy fried chicken wings tossed in our signature green jalapeno cilantro glaze, served with cool blue cheese dip.',
  ),
  ProductModel(
    id: 'pos-6',
    name: 'Area 51 Mystery Cocktail',
    emoji: '🧪',
    price: 650,
    prepTime: '8 min',
    category: 'Drinks',
    tags: ['Signature'],
    description: 'Served in a smoking beaker — blue curaçao, vodka & citrus blend',
    longDescription:
        'Top-secret house special presented in a dry-ice smoking beaker. A vibrant blue infusion of premium spirits and exotic citrus fruits.',
  ),
  ProductModel(
    id: 'pos-7',
    name: 'Easy Room Herbal Shisha',
    emoji: '💨',
    price: 1200,
    prepTime: '10 min',
    category: 'Shisha',
    tags: ['Chill'],
    description: 'Nicotine-free herbal shisha — double apple or blueberry mint',
    longDescription:
        'Premium nicotine-free herbal hookah setup designed for relaxed lounging. Smooth flavor clouds and quick coal replenishment included.',
  ),
  ProductModel(
    id: 'pos-8',
    name: 'Party Platter Supreme',
    emoji: '🍱',
    price: 2400,
    originalPrice: 2750,
    prepTime: '30 min',
    category: 'Platters',
    tags: ['Shareable'],
    description: 'Assorted sliders, wings, onion rings, fries & 4 dip sauces',
    longDescription:
        'The ultimate crowd-pleaser for private celebrations! Includes 4 mini beef sliders, 8 spicy wings, golden onion rings, season wedges, and house dips.',
  ),
  ProductModel(
    id: 'pos-9',
    name: 'Play + Bite Combo',
    emoji: '🎮🍔',
    price: 999,
    originalPrice: 1265,
    prepTime: '20 min',
    category: 'Bundle',
    tags: ['Combo', 'SAVE 21%'],
    description: '1 hr Play Room pass + Hub burger + soft drink',
    longDescription:
        'Enjoy 1 hour of unlimited PS5/gaming room access combined with our signature Cyberpunk Burger and cold refreshing beverage.',
  ),
  ProductModel(
    id: 'pos-10',
    name: 'Area 51 Squad Pack',
    emoji: '🔫🌮',
    price: 2999,
    originalPrice: 3860,
    prepTime: '25 min',
    category: 'Bundle',
    tags: ['Squad Pack', 'SAVE 22%'],
    description: 'TT + beer pong for 4 + nacho mountain + 4 mocktails',
    longDescription:
        'Outdoor garden party setup for 4 people with table tennis, beer pong equipment, jumbo nachos, and 4 Fewa Sunset mocktails.',
  ),
];

