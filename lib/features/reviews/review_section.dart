import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/core/utils/resposive.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/features/reviews/widgets/review_card.dart';
import 'package:portfolio/widgets/common/section_container.dart';
import 'package:portfolio/widgets/common/section_header.dart';
import 'package:portfolio/widgets/glass/glass_arrow_button.dart';
import 'package:provider/provider.dart';

/// Client / peer testimonials, fed entirely from data.json — the whole
/// section stays hidden until at least one review exists.
class ReviewSection extends StatefulWidget {
  const ReviewSection({super.key});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      (_scrollCtrl.offset + delta).clamp(
        0.0,
        _scrollCtrl.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentService>().content;
    final reviews = content.reviews;
    if (reviews.isEmpty) return const SizedBox.shrink();

    final header = content.section('reviews');
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = isMobile
        ? (screenWidth - 72).clamp(240.0, 340.0)
        : 380.0;
    final step = cardWidth + 20;

    return SectionContainer(
      child: Column(
        children: [
          SectionHeader(
            eyebrow: header.eyebrow,
            title: header.title,
            subtitle: header.subtitle,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 290,
            child: ListView.builder(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ReviewCard(review: reviews[index], width: cardWidth)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: (index * 150).ms)
                      .moveY(
                        begin: 40,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),
                );
              },
            ),
          ),
          if (reviews.length > (isMobile ? 1 : 3)) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassArrowButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => _scrollBy(-step),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Scroll",
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 16),
                GlassArrowButton(
                  icon: Icons.arrow_forward_rounded,
                  onTap: () => _scrollBy(step),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
