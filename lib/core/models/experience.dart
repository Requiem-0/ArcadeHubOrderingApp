import 'package:flutter/material.dart';

enum ExperienceType { gaming, dining, lounge }

class ExperienceModel {
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

  const ExperienceModel({
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
