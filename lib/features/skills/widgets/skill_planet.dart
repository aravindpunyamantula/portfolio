import 'dart:math';

import 'package:flutter/material.dart';

/// A 3D-shaded planet: offset radial light source, dark limb on the far
/// side, thin atmosphere rim on the lit edge, and faint surface bands.
/// No glow shadows — depth comes entirely from shading.
class SkillPlanet extends StatelessWidget {
  final String title;
  final Color color;
  final double size;

  const SkillPlanet({
    super.key,
    required this.title,
    required this.color,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlanetPainter(color: color),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: size * 0.105,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  final Color color;

  _PlanetPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final circle = Rect.fromCircle(center: center, radius: radius);

    final hsl = HSLColor.fromColor(color);
    final lit = hsl
        .withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
        .toColor();
    final base = hsl.withLightness((hsl.lightness * 0.75)).toColor();
    final dark = hsl
        .withLightness((hsl.lightness * 0.22).clamp(0.0, 1.0))
        .toColor();

    // Body: light source at upper-left.
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.5),
        radius: 1.15,
        colors: [lit, base, dark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(circle);
    canvas.drawCircle(center, radius, bodyPaint);

    // Surface bands (clipped to the sphere).
    canvas.save();
    canvas.clipPath(Path()..addOval(circle));
    final bandPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final y = size.height * (0.3 + i * 0.22);
      bandPaint.strokeWidth = radius * (0.10 + i * 0.04);
      final band = Path()
        ..moveTo(-radius * 0.2, y + radius * 0.12)
        ..quadraticBezierTo(
          size.width / 2,
          y - radius * 0.15,
          size.width + radius * 0.2,
          y + radius * 0.10,
        );
      canvas.drawPath(band, bandPaint);
    }

    // Terminator: night side creeping in from bottom-right.
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.85, 0.9),
        radius: 1.3,
        colors: [
          Colors.black.withOpacity(0.55),
          Colors.black.withOpacity(0.0),
        ],
        stops: const [0.0, 0.75],
      ).createShader(circle);
    canvas.drawCircle(center, radius, shadowPaint);
    canvas.restore();

    // Atmosphere rim: thin bright arc hugging the lit edge only.
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        transform: const GradientRotation(pi * 0.75),
        colors: [
          lit.withOpacity(0.9),
          lit.withOpacity(0.0),
          Colors.transparent,
          lit.withOpacity(0.0),
          lit.withOpacity(0.9),
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(circle);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - radius * 0.02),
      pi * 0.7,
      pi * 1.1,
      false,
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(_PlanetPainter oldDelegate) =>
      oldDelegate.color != color;
}
