import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/data/models/skill_category.dart';
import 'package:portfolio/features/skills/widgets/skill_category_widget.dart';
import 'package:portfolio/widgets/common/section_container.dart';
import 'package:portfolio/widgets/common/section_header.dart';

class SkillSection extends StatelessWidget {
  /// Page scroll offset — drives the 3D orbit rotation of each planet.
  final ValueListenable<double> scrollOffset;

  const SkillSection({super.key, required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: "EXPERTISE",
            title: "Tech Universe",
            subtitle:
                "Technologies powering scalable systems, immersive interfaces, and modern digital products — each one in orbit.",
          ),
          const SizedBox(height: 24),
          ...List.generate(sampleSkills.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SkillCategoryWidget(
                category: sampleSkills[index],
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
