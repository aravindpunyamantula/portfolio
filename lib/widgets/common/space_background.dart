import 'dart:math';

import 'package:flutter/material.dart';
import 'package:portfolio/core/utils/animation_gate.dart';

class Star {
  double x;
  double y;
  double radius;
  double speed;
  double twinkleSpeed;
  double depth;
  double opacity;

  Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.twinkleSpeed,
    required this.depth,
  });
}

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final List<Star> stars = [];
  final random = Random();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    // Stars render one static frame until the calm-start gate opens.
    _maybeStart();
    AnimationGate.open.addListener(_maybeStart);
  }

  void _maybeStart() {
    if (AnimationGate.open.value && !controller.isAnimating && mounted) {
      controller.repeat();
    }
  }

  bool _starsGenerated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_starsGenerated) {
      _starsGenerated = true;
      // Fewer stars on small screens — less per-frame paint work.
      generateStars(MediaQuery.of(context).size.width < 600 ? 80 : 150);
    }
  }

  @override
  void dispose() {
    AnimationGate.open.removeListener(_maybeStart);
    controller.dispose();
    super.dispose();
  }

  void generateStars(int count) {
    for (int i = 0; i < count; i++) {
      final depth = random.nextDouble();

      stars.add(
        Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 1.5,
          speed: random.nextDouble() * 0.3 + 0.05,
          opacity: random.nextDouble() * 0.8 + 0.2,
          twinkleSpeed: random.nextDouble() * 2 + 1,
          depth: depth,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary keeps the per-frame star repaint from invalidating
    // the rest of the page.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, _) {
          return CustomPaint(
            painter: StarPainter(stars, controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  final Random random = Random();

  StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      final y =
          ((star.y * size.height) + (animationValue * star.speed * 50)) %
          size.height;

      final x = star.x * size.width;
      final twinkle =
          (sin(animationValue * 2 * pi * star.twinkleSpeed) + 1) / 2;
      final opacity = star.opacity * (0.5 + twinkle * 0.5);

      paint.color = Colors.white.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Slow-drifting aurora blobs — gives the hero a living backdrop for a
/// few gradient fills per frame (no per-pixel painter).
class NebulaBackground extends StatefulWidget {
  const NebulaBackground({super.key});

  @override
  State<NebulaBackground> createState() => _NebulaBackgroundState();
}

class _NebulaBackgroundState extends State<NebulaBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  );

  @override
  void initState() {
    super.initState();
    _maybeStart();
    AnimationGate.open.addListener(_maybeStart);
  }

  void _maybeStart() {
    if (AnimationGate.open.value && !controller.isAnimating && mounted) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    AnimationGate.open.removeListener(_maybeStart);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value * 2 * pi;
          return Stack(
            children: [
              _blob(
                alignment: Alignment(-0.9 + sin(t) * 0.25, -0.8 + cos(t) * 0.2),
                color: Colors.blueAccent,
                size: 460,
              ),
              _blob(
                alignment: Alignment(0.95 + cos(t * 0.7) * 0.2, 0.9),
                color: Colors.purpleAccent,
                size: 420,
              ),
              _blob(
                alignment: Alignment(sin(t * 0.5) * 0.6, -0.2 + cos(t * 0.8) * 0.3),
                color: const Color(0xFF6366F1),
                size: 380,
                opacity: 0.10,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blob({
    required Alignment alignment,
    required Color color,
    required double size,
    double opacity = 0.20,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class ShootingStar extends StatefulWidget {
  const ShootingStar({super.key});

  @override
  State<ShootingStar> createState() => _ShootingStarState();
}

class _ShootingStarState extends State<ShootingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fire once, shortly after the calm-start gate opens.
    AnimationGate.open.addListener(_onGate);
    _onGate();
  }

  void _onGate() {
    if (!AnimationGate.open.value) return;
    AnimationGate.open.removeListener(_onGate);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    AnimationGate.open.removeListener(_onGate);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return Positioned(
          top: 120,
          left: 200,
          child: Transform.rotate(
            angle: -0.7,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: 140,
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),

                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
