import 'package:flutter/material.dart';
import 'package:portfolio/widgets/glass/glass_card.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String review;
  const ReviewCard({super.key, required this.name, required this.review});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review),
          const SizedBox(height: 16),
          Text("- $name", style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
