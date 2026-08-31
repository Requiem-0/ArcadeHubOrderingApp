// lib/features/catalogue/data/product_model.dart

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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Category',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
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

  const ProductAddon({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductAddon.fromJson(Map<String, dynamic> json) {
    return ProductAddon(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };
}

class ProductModel {
  final String id;
  final String name;
  final String emoji;
  final double price;
  final double? originalPrice;
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
    final rawCategory = json['category'];
    String categoryName = 'All';
    if (rawCategory is Map) {
      categoryName = rawCategory['name']?.toString() ?? 'All';
    } else if (rawCategory != null) {
      categoryName = rawCategory.toString();
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
    }

    final rawAddons = json['addons'];
    List<ProductAddon> parsedAddons = [];
    if (rawAddons is List) {
      parsedAddons = rawAddons
          .map((a) => ProductAddon.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Product',
      emoji: json['emoji']?.toString() ?? '🍕',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      prepTime: json['prepTime']?.toString(),
      category: categoryName,
      tags: parsedTags,
      description: json['description']?.toString() ?? '',
      longDescription: json['longDescription']?.toString(),
      image: json['image']?.toString(),
      variants: parsedVariants,
      addons: parsedAddons,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'price': price,
        'originalPrice': originalPrice,
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
