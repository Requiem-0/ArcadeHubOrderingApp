// lib/core/brandkit/experiences.dart
import 'package:flutter/material.dart';

enum ExperienceType {
  gaming, // Playroom, Area 51
  dining, // Rooftop, Sports Bar
  lounge, // Party Room, Easy Room
}

class ArcadeExperience {
  final String id;
  final String indexNumber;
  final String name;
  final String icon;
  final IconData iconData;
  final Color color;
  final String subtitle;
  final String tagline;
  final String description;
  final String shortDesc;
  final String featureTag;
  final ExperienceType type;

  const ArcadeExperience({
    required this.id,
    required this.indexNumber,
    required this.name,
    required this.icon,
    required this.iconData,
    required this.color,
    required this.subtitle,
    required this.tagline,
    required this.description,
    required this.shortDesc,
    required this.featureTag,
    required this.type,
  });
}

const List<ArcadeExperience> kArcadeExperiences = [
  ArcadeExperience(
    id: 'playroom',
    indexNumber: '01',
    name: 'Playroom',
    icon: '🎮',
    iconData: Icons.sports_esports_rounded,
    color: Color(0xFFFFD700), // Sunny Yellow
    subtitle: 'Arcade Games, VR & Gaming Zone',
    tagline: 'Immerse in retro classics, modern consoles & VR battles',
    description:
        'State-of-the-art gaming experience with racing simulators, fighting cabinets, and private console stations.',
    shortDesc: 'VR battles and racing sims',
    featureTag: 'VR & arcade',
    type: ExperienceType.gaming,
  ),
  ArcadeExperience(
    id: 'partyroom',
    indexNumber: '02',
    name: 'Party Room',
    icon: '🎉',
    iconData: Icons.shield_outlined,
    color: Color(0xFFFF355E), // Signal Red
    subtitle: 'Private Celebrations & Events',
    tagline: 'Host unforgettable birthdays, victory bashes & reunions',
    description:
        'Soundproofed party hub equipped with surround sound, customizable ambient lighting, and dedicated service.',
    shortDesc: 'Soundproofed space for events',
    featureTag: 'Private VIP',
    type: ExperienceType.lounge,
  ),
  ArcadeExperience(
    id: 'rooftop',
    indexNumber: '03',
    name: 'Rooftop Restro',
    icon: '🏙️',
    iconData: Icons.home_outlined,
    color: Color(0xFFFFFFFF), // White
    subtitle: 'Scenic Dining & Sky Lounge',
    tagline: 'Panoramic Fewa Lake views, gourmet dining & chill beats',
    description:
        'Open-air restro experience combining chef-crafted dishes, signature cocktails, and vibrant Pokhara sunsets.',
    shortDesc: 'Sky dining over Fewa Lake',
    featureTag: 'Sunset views',
    type: ExperienceType.dining,
  ),
  ArcadeExperience(
    id: 'sportsbar',
    indexNumber: '04',
    name: 'Sports Bar',
    icon: '🏟️',
    iconData: Icons.tv_rounded,
    color: Color(0xFF00E676), // Neon Green
    subtitle: 'Live Matches, Drinks & Bites',
    tagline: 'Cheer your team on giant HD projectors with icy craft drinks',
    description:
        'High-energy sports venue serving cold draft beer, wings, sliders, and live match screenings on big screens.',
    shortDesc: 'Big screens and craft beer',
    featureTag: 'Live match HD',
    type: ExperienceType.dining,
  ),
  ArcadeExperience(
    id: 'area51',
    indexNumber: '05',
    name: 'Area 51',
    icon: '🛸',
    iconData: Icons.language_rounded,
    color: Color(0xFFD500F9), // Purple
    subtitle: 'Mystery Experience Room',
    tagline: 'Top-secret futuristic hangout & immersive lounge zone',
    description:
        'Exclusive secret-theme chamber featuring laser visuals, futuristic chill pods, and mystery house specials.',
    shortDesc: 'Mystery room and laser pods',
    featureTag: 'Sci-fi room',
    type: ExperienceType.gaming,
  ),
  ArcadeExperience(
    id: 'easyroom',
    indexNumber: '06',
    name: 'Easy Room',
    icon: '🔵',
    iconData: Icons.headphones_rounded,
    color: Color(0xFF00E5FF), // Blue
    subtitle: 'Lounge & Chill Space',
    tagline: 'Relaxed sofa lounge, board games & smooth refreshers',
    description:
        'Ultra-comfortable relaxed space designed for casual conversations, board gaming sessions, and light snacks.',
    shortDesc: 'Sofa lounge and hot drinks',
    featureTag: 'Board games',
    type: ExperienceType.lounge,
  ),
];
