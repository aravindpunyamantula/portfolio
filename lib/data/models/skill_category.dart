import 'package:flutter/material.dart';

class SkillCategory {
  final String title;
  final List<String> skills;
  final Color color;

  SkillCategory({
    required this.title,
    required this.skills,
    required this.color,
  });

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      title: json['title'] as String? ?? '',
      skills: (json['skills'] as List?)?.whereType<String>().toList() ?? [],
      color: _parseHex(json['color'] as String?) ?? const Color(0xFF6366F1),
    );
  }

  /// Parses "#RRGGBB" (or "RRGGBB") to an opaque [Color].
  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return null;
    final value = int.tryParse(cleaned, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }
}

final sampleSkills = [
  SkillCategory(
    title: "Languages",
    color: const Color(0xFF6366F1), // indigo
    skills: ["Dart", "JavaScript", "Java", "C", "Python"],
  ),
  SkillCategory(
    title: "Frontend",
    color: const Color(0xFF06B6D4), // cyan
    skills: ["Flutter", "React", "HTML", "CSS", "Tailwind CSS", "JavaScript"],
  ),
  SkillCategory(
    title: "Backend",
    color: const Color(0xFF8B5CF6), // violet
    skills: [
      "Java",
      "Node.js",
      "Express",
      "Redis",
      "RabbitMQ",
      "Microservices",
      "REST APIs",
      "Firebase",
    ],
  ),
  SkillCategory(
    title: "Database",
    color: const Color(0xFF10B981), // emerald
    skills: [
      "MongoDB",
      "MySQL",
      "OracleDB",
      "NoSQL",
      "SQL",
      "Firestore",
      "PostgreSQL",
    ],
  ),
  SkillCategory(
    title: "Tools",
    color: const Color(0xFFF59E0B), // amber
    skills: [
      "Git",
      "GitHub",
      "Postman",
      "Docker",
      "Vercel",
      "Render",
      "Cloudflare",
    ],
  ),
];
