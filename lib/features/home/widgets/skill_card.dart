import 'package:flutter/material.dart';
import 'package:portfolio/widgets/glass/glass_card.dart';

class SkillCard extends StatelessWidget {
  final String skill;
  const SkillCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.code, size: 32),
          const SizedBox(height: 10),
          Text(skill),
        ],
      ),
    );
  }
}
