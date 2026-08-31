// lib/features/favourites/favourites_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favourites state: Set of product IDs
class FavouritesNotifier extends StateNotifier<Set<String>> {
  FavouritesNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool isFav(String id) => state.contains(id);
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, Set<String>>((ref) {
  return FavouritesNotifier();
});
