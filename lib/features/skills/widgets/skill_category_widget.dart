import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/core/utils/animation_gate.dart';
import 'package:portfolio/data/models/skill_category.dart';
import 'package:portfolio/features/skills/widgets/skill_planet.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A planet with its skills orbiting on a tilted elliptical (3D) path.
///
/// Depth model: for a chip at angle θ, x = cosθ·rx, y = sinθ·ry and
/// z = sinθ. Chips shrink, fade and pass BEHIND the planet when z < 0
/// (upper half of the ellipse), giving a true 3D orbit. The orbit angle
/// is driven by scroll position plus a slow idle spin, so scrolling the
/// page visibly rotates the system.
class SkillCategoryWidget extends StatefulWidget {
  final SkillCategory category;
  final ValueListenable<double> scrollOffset;
  final Alignment alignment;

  const SkillCategoryWidget({
    super.key,
    required this.category,
    required this.scrollOffset,
    this.alignment = Alignment.center,
  });

  @override
  State<SkillCategoryWidget> createState() => _SkillCategoryWidgetState();
}

class _SkillCategoryWidgetState extends State<SkillCategoryWidget>
    with SingleTickerProviderStateMixin {
  bool isVisible = false;
  late final AnimationController idleSpin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );

  @override
  void initState() {
    super.initState();
    _maybeSpin();
    AnimationGate.open.addListener(_maybeSpin);
  }

  void _maybeSpin() {
    if (AnimationGate.open.value && !idleSpin.isAnimating && mounted) {
      idleSpin.repeat();
    }
  }

  @override
  void dispose() {
    AnimationGate.open.removeListener(_maybeSpin);
    idleSpin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.category.title),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15 && !isVisible && mounted) {
          setState(() => isVisible = true);
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: isVisible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 700),
          offset: isVisible ? Offset.zero : const Offset(0, 0.15),
          curve: Curves.easeOutCubic,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isNarrow = width < 700;

              final planetSize = isNarrow ? 120.0 : 170.0;
              // Keep the widest chip (~55px half-width at full scale) inside
              // the section on small screens.
              final rx = max(
                70.0,
                min(width / 2 - 95, isNarrow ? 140.0 : 280.0),
              );
              final ry = rx * 0.34;
              final systemHeight = planetSize + ry * 2 + 110;

              final orbitSystem = SizedBox(
                width: rx * 2 + 140,
                height: systemHeight,
                child: AnimatedBuilder(
                  animation: Listenable.merge([idleSpin, widget.scrollOffset]),
                  builder: (context, _) {
                    final offset = widget.scrollOffset.value;
                    // Scroll spins the orbit fast enough to watch chips ride
                    // the curve...
                    final angle = idleSpin.value * 2 * pi + offset * 0.008;
                    // ...while the whole orbital plane gently pitches with
                    // scroll (real perspective), selling the 3D curvature.
                    final tilt = 0.22 * sin(offset * 0.0016);
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(tilt),
                      child: _OrbitSystem(
                        category: widget.category,
                        baseAngle: angle,
                        rx: rx,
                        ry: ry,
                        planetSize: planetSize,
                      ),
                    );
                  },
                ),
              );

              if (isNarrow) return Center(child: orbitSystem);
              return Align(alignment: widget.alignment, child: orbitSystem);
            },
          ),
        ),
      ),
    );
  }
}

class _OrbitSystem extends StatelessWidget {
  final SkillCategory category;
  final double baseAngle;
  final double rx;
  final double ry;
  final double planetSize;

  const _OrbitSystem({
    required this.category,
    required this.baseAngle,
    required this.rx,
    required this.ry,
    required this.planetSize,
  });

  @override
  Widget build(BuildContext context) {
    final n = category.skills.length;
    final positioned = <_OrbitingChip>[];

    for (int i = 0; i < n; i++) {
      final theta = baseAngle + (2 * pi / n) * i;
      final z = sin(theta); // -1 far … +1 near
      positioned.add(
        _OrbitingChip(
          label: category.skills[i],
          color: category.color,
          offset: Offset(cos(theta) * rx, sin(theta) * ry),
          z: z,
        ),
      );
    }

    final back = positioned.where((c) => c.z < 0).toList()
      ..sort((a, b) => a.z.compareTo(b.z));
    final front = positioned.where((c) => c.z >= 0).toList()
      ..sort((a, b) => a.z.compareTo(b.z));

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Back half of the orbit path
        CustomPaint(
          size: Size(rx * 2, ry * 2),
          painter: _OrbitPathPainter(color: category.color, front: false),
        ),
        ...back,
        SkillPlanet(
          title: category.title,
          color: category.color,
          size: planetSize,
        ),
        // Front half of the orbit path
        CustomPaint(
          size: Size(rx * 2, ry * 2),
          painter: _OrbitPathPainter(color: category.color, front: true),
        ),
        ...front,
      ],
    );
  }
}

class _OrbitingChip extends StatelessWidget {
  final String label;
  final Color color;
  final Offset offset;
  final double z;

  const _OrbitingChip({
    required this.label,
    required this.color,
    required this.offset,
    required this.z,
  });

  @override
  Widget build(BuildContext context) {
    final depth = (z + 1) / 2; // 0 far … 1 near
    final scale = 0.62 + depth * 0.48;
    final opacity = 0.30 + depth * 0.70;

    // Lightweight faux-glass — dozens of chips animate every frame, so no
    // BackdropFilter here; over the dark backdrop the difference is invisible.
    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color.lerp(
                const Color(0xFF10141F),
                color,
                0.12 + depth * 0.08,
              )!.withOpacity(0.85),
              border: Border.all(
                color: Colors.white.withOpacity(0.10 + depth * 0.15),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75 + depth * 0.25),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Half of the elliptical orbit line — the front (lower) arc is brighter
/// than the back arc, reinforcing the perspective.
class _OrbitPathPainter extends CustomPainter {
  final Color color;
  final bool front;

  _OrbitPathPainter({required this.color, required this.front});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withOpacity(front ? 0.30 : 0.10);
    // Front = lower half (0..π), back = upper half (π..2π).
    canvas.drawArc(rect, front ? 0 : pi, pi, false, paint);
  }

  @override
  bool shouldRepaint(_OrbitPathPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.front != front;
}
