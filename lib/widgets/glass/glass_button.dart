import 'package:flutter/material.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double fontSize;

  /// Filled accent variant (primary CTA). Null = clear glass.
  final Color? tint;

  const GlassButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 40,
    this.fontSize = 16,
    this.tint,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    final horizontalPadding = isMobile ? 22.0 : 32.0;
    final verticalPadding = isMobile ? 12.0 : 15.0;

    return LiquidGlassHover(
      cursor: SystemMouseCursors.click,
      builder: (context, hovering) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.width ?? (isMobile ? 220 : 280),
            minWidth: 120,
          ),
          child: GestureDetector(
            onTapDown: (_) => setState(() => isPressed = true),
            onTapUp: (_) {
              setState(() => isPressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => isPressed = false),
            child: AnimatedScale(
              scale: isPressed ? 0.96 : (hovering ? 1.03 : 1.0),
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: LiquidGlass(
                borderRadius: widget.borderRadius,
                blur: 20,
                tint: widget.tint,
                glow: hovering ? 1 : 0,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  padding:
                      widget.padding ??
                      EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: widget.fontSize + 2,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
