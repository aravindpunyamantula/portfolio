import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_spacing.dart';
import 'package:portfolio/core/utils/resposive.dart';

class SectionContainer extends StatelessWidget {
  final Widget child;

  const SectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? AppSpacing.md : AppSpacing.lg,
        horizontal: isMobile ? AppSpacing.sm : AppSpacing.md,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }
}
