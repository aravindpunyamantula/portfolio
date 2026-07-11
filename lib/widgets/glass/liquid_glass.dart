import 'dart:ui';

import 'package:flutter/material.dart';

/// Core iOS-style "Liquid Glass" surface.
///
/// Combines background blur with a saturation boost so colors behind the
/// glass stay vivid, a gradient rim that reads as light refracting on the
/// edge, an inner top highlight for the curved-surface sheen, and squircle
/// (continuous) corners. No glows.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? tint;
  final double baseOpacity;

  /// 0..1 — brightens the rim and fill (used by hover states).
  final double glow;
  final bool shadow;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.blur = 24,
    this.tint,
    this.baseOpacity = 0.07,
    this.glow = 0,
    this.shadow = true,
  });

  static ImageFilter blurAndSaturate(double sigma) {
    // Saturation boost (~1.6x) composed with the blur — the key ingredient
    // that makes backdrop colors pop through the glass like iOS vibrancy.
    const s = 1.6;
    const sr = (1 - s) * 0.2126;
    const sg = (1 - s) * 0.7152;
    const sb = (1 - s) * 0.0722;
    return ImageFilter.compose(
      outer: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      inner: const ColorFilter.matrix([
        sr + s, sg, sb, 0, 0, //
        sr, sg + s, sb, 0, 0, //
        sr, sg, sb + s, 0, 0, //
        0, 0, 0, 1, 0,
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius * 1.6),
    );
    // blur: 0 skips the BackdropFilter entirely. Use it for small chips
    // that sit over dark backgrounds (blur is invisible there) and for
    // anything that animates continuously — every live BackdropFilter
    // re-filters its backdrop on every frame of any animation.
    final noBlur = blur <= 0;
    final fill = tint == null
        ? Colors.white.withOpacity(baseOpacity + glow * 0.05 + (noBlur ? 0.03 : 0))
        : tint!.withOpacity(0.22 + glow * 0.10);

    return Container(
      decoration: shadow
          ? ShapeDecoration(
              shape: shape,
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            )
          : null,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: _maybeBlur(
          noBlur,
          CustomPaint(
            foregroundPainter: _RimPainter(shape: shape, glow: glow),
            child: Container(
              padding: padding,
              decoration: ShapeDecoration(shape: shape, color: fill),
              foregroundDecoration: ShapeDecoration(
                shape: shape,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.white.withOpacity(0.10 + glow * 0.06),
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _maybeBlur(bool noBlur, Widget child) {
    if (noBlur) return child;
    return BackdropFilter(filter: blurAndSaturate(blur), child: child);
  }
}

/// Rim light: a gradient stroke, bright where light "catches" the top-left
/// edge and nearly invisible at the bottom-right — the refractive edge look.
class _RimPainter extends CustomPainter {
  final ShapeBorder shape;
  final double glow;

  _RimPainter({required this.shape, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect.deflate(0.75));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.55 + glow * 0.25),
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.03),
          Colors.white.withOpacity(0.22 + glow * 0.15),
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RimPainter oldDelegate) =>
      oldDelegate.glow != glow || oldDelegate.shape != shape;
}

/// Adds hover tracking + a specular sheen sweep to any LiquidGlass surface.
class LiquidGlassHover extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovering) builder;
  final double liftOnHover;
  final MouseCursor cursor;

  const LiquidGlassHover({
    super.key,
    required this.builder,
    this.liftOnHover = 0,
    this.cursor = MouseCursor.defer,
  });

  @override
  State<LiquidGlassHover> createState() => _LiquidGlassHoverState();
}

class _LiquidGlassHoverState extends State<LiquidGlassHover> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        offset: hovering && widget.liftOnHover != 0
            ? Offset(0, -widget.liftOnHover)
            : Offset.zero,
        child: widget.builder(context, hovering),
      ),
    );
  }
}

/// A one-shot specular streak that sweeps across when [trigger] flips true.
class SpecularSweep extends StatefulWidget {
  final bool trigger;
  final double borderRadius;

  const SpecularSweep({
    super.key,
    required this.trigger,
    this.borderRadius = 24,
  });

  @override
  State<SpecularSweep> createState() => _SpecularSweepState();
}

class _SpecularSweepState extends State<SpecularSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didUpdateWidget(SpecularSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          if (_ctrl.value == 0 || _ctrl.isCompleted) {
            return const SizedBox.expand();
          }
          return ClipPath(
            clipper: ShapeBorderClipper(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius * 1.6),
              ),
            ),
            child: Align(
              alignment: Alignment(lerpDouble(-2.5, 2.5, _ctrl.value)!, 0),
              child: FractionallySizedBox(
                widthFactor: 0.45,
                heightFactor: 1,
                child: Transform.rotate(
                  angle: 0.35,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
