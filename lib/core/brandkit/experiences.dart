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
  final String capacity;
  final String operatingHours;
  final String setupDetail;

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
    this.capacity = 'Up to 20 Guests',
    this.operatingHours = '10:00 AM – 2:00 AM',
    this.setupDetail = 'Arcade & Gaming Setup',
  });
}

const List<ArcadeExperience> kArcadeExperiences = [
  ArcadeExperience(
    id: 'playroom',
    indexNumber: '01',
    name: 'Play Room',
    icon: '🎮',
    iconData: Icons.sports_esports_rounded,
    color: Color(0xFFFACC15),
    subtitle: 'PS5 · Racing · Foosball · Darts',
    tagline: 'PS5 · Racing · Foosball · Darts',
    description:
        'Play PS5, racing, foosball, table tennis, darts and more exciting games. Walk in solo or bring the whole crew.',
    shortDesc: 'PS5 · Racing · Foosball',
    featureTag: 'Gaming Zone',
    type: ExperienceType.gaming,
    capacity: '25 Players',
    operatingHours: '10:00 AM – 2:00 AM',
    setupDetail: '4x PS5 Pro • 4K HDR • Darts',
  ),
  ArcadeExperience(
    id: 'partyroom',
    indexNumber: '02',
    name: 'Party Room',
    icon: '🎉',
    iconData: Icons.celebration_rounded,
    color: Color(0xFFEF4444),
    subtitle: 'Parties · Karaoke · Movies',
    tagline: 'Parties · Karaoke · Movies',
    description:
        'Perfect for private parties, karaoke, movies, birthdays, meetings and celebrations with your group.',
    shortDesc: 'Parties · Karaoke · Movies',
    featureTag: 'Private VIP',
    type: ExperienceType.lounge,
    capacity: '40 Guests',
    operatingHours: '11:00 AM – 3:00 AM',
    setupDetail: '4K Projector • Pro Sound System',
  ),
  ArcadeExperience(
    id: 'sportsbar',
    indexNumber: '03',
    name: 'Sports Bar',
    icon: '🏟️',
    iconData: Icons.sports_soccer_rounded,
    color: Color(0xFF4ADE80),
    subtitle: 'Live sports · Big screens · Drinks',
    tagline: 'Live sports · Big screens · Drinks',
    description:
        'Watch live sports on big screens everywhere — never miss a match. Football, cricket, cool drinks & great food.',
    shortDesc: 'Live sports · Big screens',
    featureTag: 'Live HD',
    type: ExperienceType.dining,
    capacity: '60 Seated',
    operatingHours: '12:00 PM – 2:00 AM',
    setupDetail: '10x 4K HD Displays • Full Bar',
  ),
  ArcadeExperience(
    id: 'rooftop',
    indexNumber: '04',
    name: 'Rooftop Restro',
    icon: '🏙️',
    iconData: Icons.deck_rounded,
    color: Color(0xFFF8FAFC),
    subtitle: 'City views · Relaxed dining',
    tagline: 'City views · Relaxed dining',
    description:
        'Enjoy delicious food with beautiful city and nature views in a relaxing rooftop setting with warm sky views.',
    shortDesc: 'City views · Relaxed dining',
    featureTag: 'Sky Lounge',
    type: ExperienceType.dining,
    capacity: '50 Seated',
    operatingHours: '4:00 PM – 1:00 AM',
    setupDetail: 'Open-Air Sky Deck & Lounge',
  ),
  ArcadeExperience(
    id: 'area51',
    indexNumber: '05',
    name: 'Area 51',
    icon: '🛸',
    iconData: Icons.wb_twilight_rounded,
    color: Color(0xFFA855F7),
    // Unconfirmed: the outdoor space, the table tennis, the beer pong and the
    // neon garden were all ours.
    subtitle: 'Area 51',
    tagline: 'Area 51',
    description: 'Ask at the counter.',
    shortDesc: 'Area 51',
    featureTag: 'Zone',
    type: ExperienceType.gaming,
    capacity: '20 Guests',
    operatingHours: '5:00 PM – 2:00 AM',
    setupDetail: 'Neon Outdoor Garden & TT',
  ),
  ArcadeExperience(
    id: 'easyroom',
    indexNumber: '06',
    name: 'Easy Room',
    icon: '🔵',
    iconData: Icons.weekend_rounded,
    color: Color(0xFF3B82F6),
    // Karaoke is in the Party Room, confirmed by the client. What the Easy
    // Room actually offers is still unknown, so it says only what its name
    // does.
    subtitle: 'Private room',
    tagline: 'Private room',
    description: 'A private room for your group.',
    shortDesc: 'Private room',
    featureTag: 'Zone',
    type: ExperienceType.lounge,
    capacity: '12 Guests',
    operatingHours: '10:00 AM – 2:00 AM',
    setupDetail: 'Luxury Sofa Lounge & PS5',
  ),
];
