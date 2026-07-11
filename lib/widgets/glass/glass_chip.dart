import 'package:flutter/material.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class SkillChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final double size;

  const SkillChip({super.key, required this.label, this.icon, this.size = 1});

  @override
  State<SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<SkillChip> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: hovering ? 1.08 : 1,
        child: LiquidGlass(
          borderRadius: 40,
          blur: 14,
          shadow: false,
          glow: hovering ? 1 : 0,
          padding: EdgeInsets.symmetric(
            horizontal: 18 * widget.size,
            vertical: 10 * widget.size,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: Colors.white70,
                  size: 16 * widget.size,
                ),
                SizedBox(width: 8 * widget.size),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * widget.size,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
