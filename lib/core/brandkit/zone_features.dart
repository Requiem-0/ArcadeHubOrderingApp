// lib/core/brandkit/zone_features.dart
import 'package:flutter/material.dart';
import 'experiences.dart';

/// Something to do at Arcade Hub, shown in the home carousel. Tapping a
/// feature opens the zone it belongs to.
///
/// Features come from the zone copy in [kArcadeExperiences] and from the real
/// 4th-floor layout. Which zone Mini Golf belongs to is not confirmed by the
/// client yet, and every photo is a stock placeholder.
class ZoneFeature {
  final String title;
  final String line;
  final IconData iconData;
  final String zoneId;

  /// Stock photo without people, until the venue supplies real ones.
  final String imageUrl;

  const ZoneFeature({
    required this.title,
    required this.imageUrl,
    required this.line,
    required this.iconData,
    required this.zoneId,
  });

  ArcadeExperience get zone =>
      kArcadeExperiences.firstWhere((e) => e.id == zoneId);
}

String _unsplash(String id) =>
    'https://images.unsplash.com/photo-$id?q=80&w=1200&auto=format&fit=crop';

final List<ZoneFeature> kZoneFeatures = [
  ZoneFeature(
    title: 'PS5 Gaming',
    imageUrl: _unsplash('1766051666522-9cfa12675f5b'),
    line: 'Solo or with the crew.',
    iconData: Icons.sports_esports_rounded,
    zoneId: 'playroom',
  ),
  ZoneFeature(
    title: 'Live Sports',
    imageUrl: _unsplash('1706583698532-05506e06728c'),
    line: 'Every match, big screens.',
    iconData: Icons.live_tv_rounded,
    zoneId: 'sportsbar',
  ),
  ZoneFeature(
    title: 'Karaoke',
    imageUrl: _unsplash('1511671782779-c97d3d27a1d4'),
    line: 'Your song, your room.',
    iconData: Icons.mic_external_on_rounded,
    zoneId: 'partyroom',
  ),
  ZoneFeature(
    title: 'Mini Golf',
    imageUrl: _unsplash('1743730135766-c892848072db'),
    line: 'Putting, indoors.',
    iconData: Icons.golf_course_rounded,
    zoneId: 'playroom',
  ),
  ZoneFeature(
    title: 'Rooftop Dining',
    imageUrl: _unsplash('1563138216-8ff2e182ccbd'),
    line: 'Eat out on the terrace.',
    iconData: Icons.deck_rounded,
    zoneId: 'rooftop',
  ),
  ZoneFeature(
    title: 'Table Tennis',
    imageUrl: _unsplash('1511067007398-7e4b90cfa4bc'),
    line: 'Grab a paddle.',
    iconData: Icons.sports_tennis_rounded,
    zoneId: 'playroom',
  ),
  ZoneFeature(
    title: 'Private Parties',
    imageUrl: _unsplash('1613235058916-e51862f2964b'),
    line: 'Birthdays and celebrations.',
    iconData: Icons.cake_rounded,
    zoneId: 'partyroom',
  ),
  ZoneFeature(
    title: 'Racing',
    imageUrl: _unsplash('1743649978995-c76212449e15'),
    line: 'Foosball and darts too.',
    iconData: Icons.sports_motorsports_rounded,
    zoneId: 'playroom',
  ),
];
