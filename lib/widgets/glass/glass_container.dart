import 'package:flutter/material.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: borderRadius,
      padding: padding,
      shadow: false,
      child: child,
    );
  }
}
