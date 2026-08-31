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
  ),
  ArcadeExperience(
    id: 'area51',
    indexNumber: '05',
    name: 'Area 51',
    icon: '🛸',
    iconData: Icons.wb_twilight_rounded,
    color: Color(0xFFA855F7),
    subtitle: 'Outdoor chill · TT · Beer pong',
    tagline: 'Outdoor chill · TT · Beer pong',
    description:
        'A private outdoor space for groups to chill, play table tennis, beer pong, and have fun together under neon garden lights.',
    shortDesc: 'Outdoor chill · TT · Beer pong',
    featureTag: 'Outdoor Chill',
    type: ExperienceType.gaming,
  ),
  ArcadeExperience(
    id: 'easyroom',
    indexNumber: '06',
    name: 'Easy Room',
    icon: '🔵',
    iconData: Icons.weekend_rounded,
    color: Color(0xFF3B82F6),
    subtitle: 'Cozy private · PS5 · Karaoke',
    tagline: 'Cozy private · PS5 · Karaoke',
    description:
        'A cozy private room to play PS5, sing karaoke, watch movies or sports with food and drinks served right to your seat.',
    shortDesc: 'Cozy private · PS5 · Karaoke',
    featureTag: 'Private Lounge',
    type: ExperienceType.lounge,
  ),
];
