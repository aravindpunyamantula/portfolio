import 'package:flutter/material.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class GlassArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const GlassArrowButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassHover(
      cursor: SystemMouseCursors.click,
      builder: (context, hovering) {
        return GestureDetector(
          onTap: onTap,
          child: LiquidGlass(
            borderRadius: 16,
            blur: 14,
            shadow: false,
            glow: hovering ? 1 : 0,
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 18,
              color: hovering ? Colors.white : Colors.white60,
            ),
          ),
        );
      },
    );
  }
}
