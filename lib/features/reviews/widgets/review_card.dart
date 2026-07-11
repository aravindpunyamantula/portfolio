import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/data/models/review_model.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final double width;

  const ReviewCard({super.key, required this.review, required this.width});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassHover(
      builder: (context, hovering) {
        return SizedBox(
          width: width,
          child: LiquidGlass(
            borderRadius: 26,
            padding: const EdgeInsets.all(24),
            glow: hovering ? 1 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 30,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                    const Spacer(),
                    if (review.rating > 0)
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: i < review.rating
                                ? const Color(0xFFFBBF24)
                                : Colors.white24,
                          );
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Text(
                    review.message,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 7,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      height: 1.7,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.14),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Avatar(review: review),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (review.subtitle.isNotEmpty)
                            Text(
                              review.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Photo when provided, otherwise gradient initials — so reviews without
/// an avatar image still look finished.
class _Avatar extends StatelessWidget {
  final ReviewModel review;

  const _Avatar({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: review.avatarUrl.isEmpty
          ? Center(
              child: Text(
                review.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Image.network(
              review.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Center(
                child: Text(
                  review.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
    );
  }
}
