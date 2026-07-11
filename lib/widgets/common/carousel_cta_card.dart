import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/widgets/glass/glass_button.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

/// Closing card at the end of the projects / certificates carousels:
/// if someone scrolled this far they're interested — hand them a
/// one-tap path to the contact section.
class CarouselCtaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onContact;
  final double? width;

  const CarouselCtaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onContact,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: 24,
      blur: 14,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.14),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.35),
                ),
              ),
              child: const Icon(
                Icons.waving_hand_rounded,
                color: Color(0xFFF5C86B),
                size: 30,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            GlassButton(
              text: "Contact Me",
              onTap: onContact,
              tint: AppColors.primary,
              width: 160,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}
