import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/features/skills/widgets/skill_category_widget.dart';
import 'package:portfolio/widgets/common/section_container.dart';
import 'package:portfolio/widgets/common/section_header.dart';
import 'package:provider/provider.dart';

class SkillSection extends StatelessWidget {
  /// Page scroll offset — drives the 3D orbit rotation of each planet.
  final ValueListenable<double> scrollOffset;

  const SkillSection({super.key, required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentService>().content;
    final categories = content.skillCategories;
    final header = content.section('skills');

    return SectionContainer(
      child: Column(
        children: [
          SectionHeader(
            eyebrow: header.eyebrow,
            title: header.title,
            subtitle: header.subtitle,
          ),
          const SizedBox(height: 24),
          ...List.generate(categories.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SkillCategoryWidget(
                category: categories[index],
                scrollOffset: scrollOffset,
                alignment: index.isEven
                    ? const Alignment(-0.6, 0)
                    : const Alignment(0.6, 0),
              ),
            );
          }),
        ],
      ),
    );
  }
}
