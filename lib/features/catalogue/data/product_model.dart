// lib/features/catalogue/data/product_model.dart
import '../../../core/constants.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? image;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  String? get imageUrl => AppConstants.resolveImageUrl(image);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawImg = json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        json['photo']?.toString();
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Category',
      description: json['description']?.toString(),
      image: AppConstants.resolveImageUrl(rawImg),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
      };
}

class ProductVariant {
  final String id;
  final String label;
  final double price;

  const ProductVariant({
    required this.id,
    required this.label,
    required this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'price': price,
      };
}

class ProductAddon {
  final String id;
  final String name;
  final double price;
  final int maxAvailable;

  const ProductAddon({
    required this.id,
    required this.name,
    required this.price,
    this.maxAvailable = 5,
  });

  factory ProductAddon.fromJson(Map<String, dynamic> json) {
    final rawMax = json['maxAvailable'] ?? json['maxQuantity'] ?? json['limit'];
    return ProductAddon(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      maxAvailable: (rawMax as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'maxAvailable': maxAvailable,
      };
}

class ProductDiscount {
  final String id;
  final String name;
  final double rate;
  final bool isEnabled;
  final String type; // 'percentage' or 'fixed'

  const ProductDiscount({
    required this.id,
    required this.name,
    required this.rate,
    this.isEnabled = true,
    this.type = 'percentage',
  });

  factory ProductDiscount.fromJson(Map<String, dynamic> json) {
    return ProductDiscount(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Discount',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      isEnabled: json['isEnabled'] as bool? ?? true,
      type: json['type']?.toString() ?? 'percentage',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rate': rate,
        'isEnabled': isEnabled,
        'type': type,
      };
}

class ProductModel {
  final String id;
  final String name;
  final String emoji;
  final double price;
  final double? originalPrice;
  final bool usesOfferPrice;
  final double? offerPrice;
  final List<ProductDiscount> discounts;
  final String? prepTime;
  final String category;
  final List<String> tags;
  final String description;
  final String? longDescription;
  final String? image;
  final List<ProductVariant> variants;
  final List<ProductAddon> addons;

  const ProductModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    this.originalPrice,
    this.usesOfferPrice = false,
    this.offerPrice,
    this.discounts = const [],
    this.prepTime,
    required this.category,
    this.tags = const [],
    required this.description,
    this.longDescription,
    this.image,
    this.variants = const [],
    this.addons = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'] ?? json['categories'];
    String categoryName = 'All';
    if (rawCategory is Map) {
      categoryName = rawCategory['name']?.toString() ?? 'All';
    } else if (rawCategory is String && rawCategory.isNotEmpty) {
      categoryName = rawCategory;
    }

    final rawTags = json['tags'];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((t) => t.toString()).toList();
    }

    final rawVariants = json['variants'];
    List<ProductVariant> parsedVariants = [];
    if (rawVariants is List) {
      parsedVariants = rawVariants
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList();
    } else if (rawVariants is Map && rawVariants['variantItems'] is List) {
      final items = rawVariants['variantItems'] as List;
      parsedVariants = items.map((v) {
        final optValues = v['optionValues'] as List?;
        final label = (optValues != null && optValues.isNotEmpty)
            ? optValues.join(' / ')
            : (v['name']?.toString() ?? 'Standard');
        return ProductVariant(
          id: v['_id']?.toString() ?? '',
          label: label,
          price: (v['price'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    }

    final rawAddons = json['addons'];
    List<ProductAddon> parsedAddons = [];
    if (rawAddons is List) {
      parsedAddons = rawAddons
          .map((a) => ProductAddon.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    final rawDiscounts = json['discounts'];
    List<ProductDiscount> parsedDiscounts = [];
    if (rawDiscounts is List) {
      parsedDiscounts = rawDiscounts
          .whereType<Map<String, dynamic>>()
          .map((d) => ProductDiscount.fromJson(d))
          .toList();
    }

    final rawImg = json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        json['photo']?.toString() ??
        json['coverImage']?.toString() ??
        (json['images'] is List && (json['images'] as List).isNotEmpty
            ? (json['images'] as List).first.toString()
            : null);

    double parsedPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    if (parsedPrice == 0.0 && parsedVariants.isNotEmpty) {
      final positiveVariant = parsedVariants.firstWhere(
        (v) => v.price > 0,
        orElse: () => parsedVariants.first,
      );
      parsedPrice = positiveVariant.price;
    }

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Product',
      emoji: json['emoji']?.toString() ?? '🍕',
      price: parsedPrice,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      usesOfferPrice: json['usesOfferPrice'] as bool? ?? false,
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      discounts: parsedDiscounts,
      prepTime: json['prepTime']?.toString(),
      category: categoryName,
      tags: parsedTags,
      description: json['description']?.toString() ?? '',
      longDescription: json['longDescription']?.toString(),
      image: AppConstants.resolveImageUrl(rawImg),
      variants: parsedVariants,
      addons: parsedAddons,
    );
  }

  String? get imageUrl => AppConstants.resolveImageUrl(image);

  /// Effective price to charge after applying offer price or item discounts
  double get effectivePrice {
    double base = price;
    if (base == 0.0 && variants.isNotEmpty) {
      final positiveVariant = variants.firstWhere(
        (v) => v.price > 0,
        orElse: () => variants.first,
      );
      base = positiveVariant.price;
    }
    if (usesOfferPrice && offerPrice != null && offerPrice! > 0) {
      return offerPrice!;
    }
    // Check item-level discounts
    final activeDiscs = discounts.where((d) => d.rate > 0).toList();
    if (activeDiscs.isNotEmpty && base > 0) {
      double current = base;
      for (final d in activeDiscs) {
        if (d.type == 'percentage') {
          current -= (base * (d.rate / 100));
        } else {
          current -= d.rate;
        }
      }
      return current < 0 ? 0.0 : current;
    }
    return base;
  }

  /// Original regular price before discount (if discounted)
  double? get displayOriginalPrice {
    if (originalPrice != null && originalPrice! > effectivePrice) {
      return originalPrice;
    }
    if (usesOfferPrice && offerPrice != null && price > offerPrice!) {
      return price;
    }
    final activeDiscs = discounts.where((d) => d.rate > 0).toList();
    if (activeDiscs.isNotEmpty && price > effectivePrice) {
      return price;
    }
    return null;
  }

  bool get hasDiscount =>
      displayOriginalPrice != null && displayOriginalPrice! > effectivePrice;

  /// Human-readable discount badge (e.g. "15% OFF" or "Rs 100 OFF")
  String? get discountTag {
    if (!hasDiscount) return null;
    final orig = displayOriginalPrice!;
    final eff = effectivePrice;
    final diff = orig - eff;
    if (orig > 0) {
      final pct = ((diff / orig) * 100).round();
      if (pct > 0) return '$pct% OFF';
    }
    return 'Rs ${diff.toStringAsFixed(0)} OFF';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'price': price,
        'originalPrice': originalPrice,
        'usesOfferPrice': usesOfferPrice,
        'offerPrice': offerPrice,
        'discounts': discounts.map((d) => d.toJson()).toList(),
        'prepTime': prepTime,
        'category': category,
        'tags': tags,
        'description': description,
        'longDescription': longDescription,
        'image': image,
        'variants': variants.map((v) => v.toJson()).toList(),
        'addons': addons.map((a) => a.toJson()).toList(),
      };
}
