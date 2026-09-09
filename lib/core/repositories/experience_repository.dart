import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experience.dart';

class ExperienceRepository {
  Future<List<ExperienceModel>> getExperiences() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const [
      ExperienceModel(
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
        capacity: '25 Players',
        operatingHours: '10:00 AM – 2:00 AM',
        setupDetail: '4x PS5 Pro • 4K HDR • Darts',
        imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=2071&auto=format&fit=crop',
      ),
      ExperienceModel(
        id: 'partyroom',
        indexNumber: '02',
        name: 'Party Room',
        icon: '🎉',
        iconData: Icons.celebration_rounded,
        color: Color(0xFFFF355E), // Signal Red
        subtitle: 'Private Celebrations & Events',
        tagline: 'Host unforgettable birthdays, victory bashes & reunions',
        description:
            'Soundproofed party hub equipped with surround sound, customizable ambient lighting, and dedicated service.',
        shortDesc: 'Soundproofed space for events',
        featureTag: 'Private VIP',
        type: ExperienceType.lounge,
        capacity: '40 Guests',
        operatingHours: '11:00 AM – 3:00 AM',
        setupDetail: '4K Projector • Pro Sound System',
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1974&auto=format&fit=crop',
      ),
      ExperienceModel(
        id: 'rooftop',
        indexNumber: '03',
        name: 'Rooftop Restro',
        icon: '🏙️',
        iconData: Icons.deck_rounded,
        color: Color(0xFFFFFFFF), // White
        subtitle: 'Scenic Dining & Sky Lounge',
        tagline: 'Panoramic Fewa Lake views, gourmet dining & chill beats',
        description:
            'Open-air restro experience combining chef-crafted dishes, signature cocktails, and vibrant Pokhara sunsets.',
        shortDesc: 'Sky dining over Fewa Lake',
        featureTag: 'Sunset views',
        type: ExperienceType.dining,
        capacity: '50 Seated',
        operatingHours: '4:00 PM – 1:00 AM',
        setupDetail: 'Open-Air Sky Deck & Lounge',
        imageUrl: 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?q=80&w=1974&auto=format&fit=crop',
      ),
      ExperienceModel(
        id: 'sportsbar',
        indexNumber: '04',
        name: 'Sports Bar',
        icon: '🏟️',
        iconData: Icons.sports_soccer_rounded,
        color: Color(0xFF00E676), // Neon Green
        subtitle: 'Live Matches, Drinks & Bites',
        tagline: 'Cheer your team on giant HD projectors with icy craft drinks',
        description:
            'High-energy sports venue serving cold draft beer, wings, sliders, and live match screenings on big screens.',
        shortDesc: 'Big screens and craft beer',
        featureTag: 'Live match HD',
        type: ExperienceType.dining,
        capacity: '60 Seated',
        operatingHours: '12:00 PM – 2:00 AM',
        setupDetail: '10x 4K HD Displays • Full Bar',
        imageUrl: 'https://images.unsplash.com/photo-1575444758702-4a6b9222336e?q=80&w=2070&auto=format&fit=crop',
      ),
      ExperienceModel(
        id: 'area51',
        indexNumber: '05',
        name: 'Area 51',
        icon: '🛸',
        iconData: Icons.wb_twilight_rounded,
        color: Color(0xFFD500F9), // Purple
        subtitle: 'Mystery Experience Room',
        tagline: 'Top-secret futuristic hangout & immersive lounge zone',
        description:
            'Exclusive secret-theme chamber featuring laser visuals, futuristic chill pods, and mystery house specials.',
        shortDesc: 'Mystery room and laser pods',
        featureTag: 'Sci-fi room',
        type: ExperienceType.gaming,
        capacity: '20 Guests',
        operatingHours: '5:00 PM – 2:00 AM',
        setupDetail: 'Neon Outdoor Garden & TT',
        imageUrl: 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?q=80&w=2070&auto=format&fit=crop',
      ),
      ExperienceModel(
        id: 'easyroom',
        indexNumber: '06',
        name: 'Easy Room',
        icon: '🔵',
        iconData: Icons.weekend_rounded,
        color: Color(0xFF00E5FF), // Blue
        subtitle: 'Lounge & Chill Space',
        tagline: 'Relaxed sofa lounge, board games & smooth refreshers',
        description:
            'Ultra-comfortable relaxed space designed for casual conversations, board gaming sessions, and light snacks.',
        shortDesc: 'Sofa lounge and hot drinks',
        featureTag: 'Board games',
        type: ExperienceType.lounge,
        capacity: '12 Guests',
        operatingHours: '10:00 AM – 2:00 AM',
        setupDetail: 'Luxury Sofa Lounge & PS5',
        imageUrl: 'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?q=80&w=2070&auto=format&fit=crop',
      ),
    ];
  }

  Future<ExperienceModel?> getExperienceById(String id) async {
    final list = await getExperiences();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final experienceRepositoryProvider = Provider<ExperienceRepository>((ref) {
  return ExperienceRepository();
});

final experiencesProvider = FutureProvider<List<ExperienceModel>>((ref) async {
  return ref.read(experienceRepositoryProvider).getExperiences();
});
