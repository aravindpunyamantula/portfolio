import 'package:flutter/material.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final double glow;
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.glow = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: borderRadius,
      padding: padding,
      glow: glow,
      child: child,
    );
  }
}
