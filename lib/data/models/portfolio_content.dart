import 'package:portfolio/core/constants/app_links.dart';
import 'package:portfolio/data/models/certificate_model.dart';
import 'package:portfolio/data/models/project_model.dart';
import 'package:portfolio/data/models/review_model.dart';
import 'package:portfolio/data/models/skill_category.dart';

/// Everything on the site that can be edited from `portfolio-data/data.json`
/// without redeploying. Every field falls back to the values compiled into
/// the app, so a missing key or a bad edit can never break the site.
class PortfolioContent {
  final HeroContent hero;
  final LinksContent links;
  final List<ProjectModel> projects;
  final List<CertificateModel> certificates;
  final List<SkillCategory> skillCategories;
  final List<ReviewModel> reviews;
  final Map<String, SectionHeaderContent> sections;

  PortfolioContent({
    required this.hero,
    required this.links,
    required this.projects,
    required this.certificates,
    required this.skillCategories,
    required this.reviews,
    required this.sections,
  });

  factory PortfolioContent.fallback() {
    return PortfolioContent(
      hero: HeroContent.fallback(),
      links: LinksContent.fallback(),
      projects: sampleProjects,
      certificates: sampleCertificates,
      skillCategories: sampleSkills,
      reviews: const [],
      sections: _defaultSections,
    );
  }

  factory PortfolioContent.fromJson(Map<String, dynamic> json) {
    final fallback = PortfolioContent.fallback();

    List<T> parseList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
      List<T> orElse, {
      bool allowEmpty = false,
    }) {
      final raw = json[key];
      if (raw is! List) return orElse;
      final parsed = raw
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      // An empty projects/skills list would leave whole sections blank —
      // treat it as "not provided". Reviews may legitimately be empty.
      if (parsed.isEmpty && !allowEmpty) return orElse;
      return parsed;
    }

    final sections = Map<String, SectionHeaderContent>.from(_defaultSections);
    final rawSections = json['sections'];
    if (rawSections is Map) {
      for (final entry in rawSections.entries) {
        final def = sections[entry.key];
        if (def != null && entry.value is Map) {
          sections[entry.key] = SectionHeaderContent.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
            def,
          );
        }
      }
    }

    // Stable sort on the `order` field — ties keep their data.json order
    // (List.sort alone isn't stable).
    List<T> sortByOrder<T>(List<T> list, int Function(T) orderOf) {
      final indexed = list.asMap().entries.toList()
        ..sort((a, b) {
          final byOrder = orderOf(a.value).compareTo(orderOf(b.value));
          return byOrder != 0 ? byOrder : a.key.compareTo(b.key);
        });
      return indexed.map((e) => e.value).toList();
    }

    return PortfolioContent(
      hero: json['hero'] is Map
          ? HeroContent.fromJson(
              Map<String, dynamic>.from(json['hero'] as Map), fallback.hero)
          : fallback.hero,
      links: json['links'] is Map
          ? LinksContent.fromJson(
              Map<String, dynamic>.from(json['links'] as Map), fallback.links)
          : fallback.links,
      projects: sortByOrder(
          parseList('projects', ProjectModel.fromJson, fallback.projects),
          (p) => p.order),
      certificates: sortByOrder(
          parseList(
              'certificates', CertificateModel.fromJson, fallback.certificates),
          (c) => c.order),
      skillCategories: parseList(
          'skillCategories', SkillCategory.fromJson, fallback.skillCategories),
      reviews: parseList('reviews', ReviewModel.fromJson, fallback.reviews,
          allowEmpty: true),
      sections: sections,
    );
  }

  SectionHeaderContent section(String key) =>
      sections[key] ?? _defaultSections[key]!;

  static final _defaultSections = <String, SectionHeaderContent>{
    'projects': SectionHeaderContent(
      eyebrow: 'WORK',
      title: 'Featured Projects',
      subtitle:
          'Products and experiments — from live platforms to open-source builds.',
    ),
    'skills': SectionHeaderContent(
      eyebrow: 'EXPERTISE',
      title: 'Tech Universe',
      subtitle:
          'Technologies powering scalable systems, immersive interfaces, and modern digital products — each one in orbit.',
    ),
    'certificates': SectionHeaderContent(
      eyebrow: 'CREDENTIALS',
      title: 'Certification Vault',
      subtitle:
          'Credentials that validate expertise — a commitment to excellence and continuous learning.',
    ),
    'reviews': SectionHeaderContent(
      eyebrow: 'TESTIMONIALS',
      title: 'What People Say',
      subtitle:
          'Feedback from clients and peers I have built products with.',
    ),
    'contact': SectionHeaderContent(
      eyebrow: 'CONTACT',
      title: "Let's Build Something Exceptional",
      subtitle:
          'Open to collaborations, internships, and ambitious digital experiences.',
    ),
  };
}

class HeroContent {
  final String greeting;
  final String name;
  final String nameShort;
  final List<String> roles;
  final String tagline;
  final String availability;
  final bool showAvailability;
  final String footerTagline;

  HeroContent({
    required this.greeting,
    required this.name,
    required this.nameShort,
    required this.roles,
    required this.tagline,
    required this.availability,
    required this.showAvailability,
    required this.footerTagline,
  });

  factory HeroContent.fallback() {
    return HeroContent(
      greeting: "Hi, I'm",
      name: 'P. D. S. Aravind Kumar',
      nameShort: 'Aravind Kumar',
      roles: const [
        'Full Stack Developer',
        'Flutter Developer',
        'Backend Engineer',
        'UI Craftsman',
      ],
      tagline:
          'I design and build scalable, high-performance applications with interfaces people love to use.',
      availability: 'Open to opportunities',
      showAvailability: true,
      footerTagline: 'Building scalable products with beautiful interfaces.',
    );
  }

  factory HeroContent.fromJson(Map<String, dynamic> json, HeroContent def) {
    final roles =
        (json['roles'] as List?)?.whereType<String>().toList() ?? def.roles;
    return HeroContent(
      greeting: json['greeting'] as String? ?? def.greeting,
      name: json['name'] as String? ?? def.name,
      nameShort: json['nameShort'] as String? ?? def.nameShort,
      roles: roles.isEmpty ? def.roles : roles,
      tagline: json['tagline'] as String? ?? def.tagline,
      availability: json['availability'] as String? ?? def.availability,
      showAvailability: json['showAvailability'] as bool? ?? def.showAvailability,
      footerTagline: json['footerTagline'] as String? ?? def.footerTagline,
    );
  }
}

class LinksContent {
  final String github;
  final String linkedin;
  final String instagram;
  final String email;
  final String resume;

  LinksContent({
    required this.github,
    required this.linkedin,
    required this.instagram,
    required this.email,
    required this.resume,
  });

  factory LinksContent.fallback() {
    return LinksContent(
      github: AppLinks.github,
      linkedin: AppLinks.linkedin,
      instagram: AppLinks.instagram,
      email: AppLinks.email,
      resume: AppLinks.resume,
    );
  }

  factory LinksContent.fromJson(Map<String, dynamic> json, LinksContent def) {
    return LinksContent(
      github: json['github'] as String? ?? def.github,
      linkedin: json['linkedin'] as String? ?? def.linkedin,
      instagram: json['instagram'] as String? ?? def.instagram,
      email: json['email'] as String? ?? def.email,
      resume: json['resume'] as String? ?? def.resume,
    );
  }
}

class SectionHeaderContent {
  final String eyebrow;
  final String title;
  final String subtitle;

  SectionHeaderContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  factory SectionHeaderContent.fromJson(
      Map<String, dynamic> json, SectionHeaderContent def) {
    return SectionHeaderContent(
      eyebrow: json['eyebrow'] as String? ?? def.eyebrow,
      title: json['title'] as String? ?? def.title,
      subtitle: json['subtitle'] as String? ?? def.subtitle,
    );
  }
}
