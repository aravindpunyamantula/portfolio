import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fires the one-shot effects on the hero starfield from anywhere in the
/// hero (warp on "View Projects", meteor shower easter egg, black hole on
/// the availability badge).
class StarfieldController {
  _HeroStarfieldState? _state;

  void warp() => _state?._startWarp();
  void meteorShower() => _state?._startMeteors();
  void blackHole({VoidCallback? onComplete}) =>
      _state?._startBlackHole(onComplete);

  /// Pointer input is forwarded from the hero (which overlays the field),
  /// so the gravity well keeps working over text and buttons.
  void pointerHover(Offset localPosition) => _state?._onHover(localPosition);
  void pointerDown(Offset localPosition) => _state?._onDown(localPosition);
  void pointerExit() => _state?._cursor = null;
}

/// Interactive particle field behind the hero:
/// - stars drift toward the cursor (gravity well) and spring back
/// - faint constellation lines connect the cursor to nearby stars
/// - click/tap sends a ripple shockwave through the field
/// - one-shot modes: hyperspace warp, meteor shower, black hole collapse
///
/// Perf: one ticker + one CustomPainter on a RepaintBoundary. The ticker
/// stops whenever the hero leaves the viewport (VisibilityDetector), and
/// the browser pauses rAF — and therefore all of this — when the tab is
/// hidden.
class HeroStarfield extends StatefulWidget {
  final StarfieldController controller;
  final bool isMobile;

  const HeroStarfield({
    super.key,
    required this.controller,
    required this.isMobile,
  });

  @override
  State<HeroStarfield> createState() => _HeroStarfieldState();
}

enum _FieldMode { idle, warp, blackHole }

class _Star {
  Offset base = Offset.zero;
  Offset pos = Offset.zero;
  Offset vel = Offset.zero;
  double z = 1; // 0 far … 1 near: size, brightness, force multiplier
  double size = 1;
}

class _Ripple {
  final Offset center;
  double age = 0;
  _Ripple(this.center);
}

class _Meteor {
  Offset pos;
  final Offset vel;
  double age = 0;
  final double life;
  _Meteor(this.pos, this.vel, this.life);
}

class _HeroStarfieldState extends State<HeroStarfield>
    with SingleTickerProviderStateMixin {
  static final _rand = Random();

  late final Ticker _ticker = createTicker(_tick);
  Duration _lastTick = Duration.zero;

  final List<_Star> _stars = [];
  final List<_Ripple> _ripples = [];
  final List<_Meteor> _meteors = [];

  Size _size = Size.zero;
  Offset? _cursor;
  bool _visible = false;

  _FieldMode _mode = _FieldMode.idle;
  double _modeT = 0; // 0..1 progress of the active one-shot mode
  VoidCallback? _onModeComplete;
  double _meteorSpawnBudget = 0;
  DateTime _lastInput = DateTime.fromMillisecondsSinceEpoch(0);

  final _repaint = _RepaintSignal();

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _seed(Size size) {
    _size = size;
    _stars.clear();
    final count = widget.isMobile ? 60 : 130;
    for (var i = 0; i < count; i++) {
      final star = _Star()
        ..base = Offset(
          _rand.nextDouble() * size.width,
          _rand.nextDouble() * size.height,
        )
        ..z = 0.25 + _rand.nextDouble() * 0.75;
      star.pos = star.base;
      star.size = 0.5 + star.z * 1.7;
      _stars.add(star);
    }
  }

  // ── one-shot effects ────────────────────────────────────────────────

  void _startWarp() {
    _mode = _FieldMode.warp;
    _modeT = 0;
    final center = _size.center(Offset.zero);
    for (final s in _stars) {
      var dir = s.pos - center;
      dir = dir.distance < 1 ? const Offset(0, 1) : dir / dir.distance;
      s.vel += dir * (500 + s.z * 900);
    }
    _wake();
  }

  void _startMeteors() {
    _meteorSpawnBudget = widget.isMobile ? 6 : 10;
    _wake();
  }

  void _startBlackHole(VoidCallback? onComplete) {
    if (_mode == _FieldMode.blackHole) return;
    _mode = _FieldMode.blackHole;
    _modeT = 0;
    _onModeComplete = onComplete;
    _wake();
  }

  void _wake() {
    if (!_ticker.isActive && mounted) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  // ── input (forwarded from the hero via the controller) ─────────────

  void _onHover(Offset p) {
    _cursor = p;
    _lastInput = DateTime.now();
    _wake();
  }

  void _onDown(Offset p) {
    _cursor = p;
    _lastInput = DateTime.now();
    _ripples.add(_Ripple(p));
    // One-time shockwave impulse away from the tap.
    for (final s in _stars) {
      final d = s.pos - p;
      final dist = d.distance;
      if (dist < 240 && dist > 0.5) {
        s.vel += (d / dist) * (1 - dist / 240) * 260 * s.z;
      }
    }
    _wake();
  }

  // ── simulation ──────────────────────────────────────────────────────

  void _tick(Duration elapsed) {
    var dt = (_lastTick == Duration.zero
            ? 16.0
            : (elapsed - _lastTick).inMicroseconds / 1000.0) /
        1000.0;
    _lastTick = elapsed;
    dt = dt.clamp(0.0, 1 / 20); // cap after jank/tab switches

    final center = _size.center(Offset.zero);
    final inBlackHole = _mode == _FieldMode.blackHole;
    final collapsing = inBlackHole && _modeT < 0.7;

    if (_mode != _FieldMode.idle) {
      _modeT += dt / (_mode == _FieldMode.warp ? 0.8 : 1.7);
      if (inBlackHole && _modeT >= 0.7 && _modeT - dt / 1.7 < 0.7) {
        // Release: fling stars outward, spring brings them home.
        for (final s in _stars) {
          var dir = s.pos - center;
          dir = dir.distance < 1
              ? Offset(_rand.nextDouble() - 0.5, _rand.nextDouble() - 0.5)
              : dir / dir.distance;
          s.vel += dir * (350 + _rand.nextDouble() * 350);
        }
      }
      if (_modeT >= 1) {
        _mode = _FieldMode.idle;
        _modeT = 0;
        final done = _onModeComplete;
        _onModeComplete = null;
        done?.call();
      }
    }

    for (final s in _stars) {
      // Spring back to the star's home position.
      s.vel += (s.base - s.pos) * 7 * dt;

      // Cursor gravity well.
      if (_cursor != null && !collapsing) {
        final d = _cursor! - s.pos;
        final dist = d.distance;
        if (dist < 170 && dist > 1) {
          s.vel += (d / dist) * (1 - dist / 170) * 130 * s.z * dt * 60 * 0.35;
        }
      }

      // Black hole: strong pull to center + tangential swirl.
      if (collapsing) {
        final d = center - s.pos;
        final dist = max(d.distance, 8.0);
        final dir = d / dist;
        final swirl = Offset(-dir.dy, dir.dx);
        final g = Curves.easeIn.transform(min(_modeT / 0.7, 1.0));
        s.vel += (dir * 900 + swirl * 480) * g * dt;
      }

      s.vel *= pow(0.03, dt).toDouble(); // frame-rate independent damping
      s.pos += s.vel * dt;
    }

    for (final r in _ripples) {
      r.age += dt;
    }
    _ripples.removeWhere((r) => r.age > 0.8);

    if (_meteorSpawnBudget > 0) {
      _meteorSpawnBudget -= dt * 8; // ~8 spawns/second
      if (_rand.nextDouble() < dt * 10) {
        final startX = _rand.nextDouble() * _size.width * 0.9;
        final startY = -20 - _rand.nextDouble() * 60;
        _meteors.add(_Meteor(
          Offset(startX, startY),
          Offset(420 + _rand.nextDouble() * 260, 300 + _rand.nextDouble() * 180),
          0.9 + _rand.nextDouble() * 0.5,
        ));
      }
    }
    for (final m in _meteors) {
      m.age += dt;
      m.pos += m.vel * dt;
    }
    _meteors.removeWhere((m) => m.age > m.life);

    _repaint.ping();

    // Sleep whenever the field is settled: no active effect, no recent
    // pointer input, and every star at rest. This keeps the main thread
    // idle when nobody interacts (crucial for perf scores) — any hover,
    // tap, or effect wakes the ticker again instantly.
    final busy = _mode != _FieldMode.idle ||
        _ripples.isNotEmpty ||
        _meteors.isNotEmpty ||
        _meteorSpawnBudget > 0;
    if (busy) return;
    if (!_visible) {
      _ticker.stop();
      return;
    }
    final inputAge = DateTime.now().difference(_lastInput);
    if (inputAge > const Duration(milliseconds: 1500)) {
      var maxVel = 0.0;
      for (final s in _stars) {
        maxVel = max(maxVel, s.vel.distance);
      }
      if (maxVel < 4) _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('hero-starfield'),
      onVisibilityChanged: (info) {
        _visible = info.visibleFraction > 0.05;
        if (_visible) {
          _wake();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if ((size.width - _size.width).abs() > 40 ||
              (size.height - _size.height).abs() > 40) {
            _seed(size);
          }
          return RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _FieldPainter(
                repaint: _repaint,
                stars: _stars,
                ripples: _ripples,
                meteors: _meteors,
                cursor: () => widget.isMobile ? null : _cursor,
                mode: () => _mode,
                modeT: () => _modeT,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RepaintSignal extends ChangeNotifier {
  void ping() => notifyListeners();
}

class _FieldPainter extends CustomPainter {
  final List<_Star> stars;
  final List<_Ripple> ripples;
  final List<_Meteor> meteors;
  final Offset? Function() cursor;
  final _FieldMode Function() mode;
  final double Function() modeT;

  _FieldPainter({
    required Listenable repaint,
    required this.stars,
    required this.ripples,
    required this.meteors,
    required this.cursor,
    required this.mode,
    required this.modeT,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint();
    final center = size.center(Offset.zero);
    final m = mode();
    final t = modeT();

    // Constellation lines from the cursor to nearby stars.
    final c = cursor();
    if (c != null && m == _FieldMode.idle) {
      final linePaint = Paint()..strokeWidth = 1;
      for (final s in stars) {
        final dist = (s.pos - c).distance;
        if (dist < 130) {
          linePaint.color =
              Colors.white.withOpacity((1 - dist / 130) * 0.28 * s.z);
          canvas.drawLine(c, s.pos, linePaint);
        }
      }
    }

    for (final s in stars) {
      var opacity = 0.35 + s.z * 0.6;
      var radius = s.size;

      if (m == _FieldMode.blackHole) {
        // Fade and shrink as stars near the singularity.
        final dist = (s.pos - center).distance;
        final near = (1 - dist / 260).clamp(0.0, 1.0);
        opacity *= (1 - near * 0.75);
        radius *= (1 - near * 0.5);
      }

      if (m == _FieldMode.warp && s.vel.distance > 40) {
        // Hyperspace streak: line trailing behind the motion.
        final dir = s.vel / s.vel.distance;
        final len = (s.vel.distance * 0.09).clamp(4.0, 90.0);
        starPaint
          ..color = Colors.white.withOpacity(opacity * 0.9)
          ..strokeWidth = radius * 0.9
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(s.pos, s.pos - dir * len, starPaint);
      } else {
        starPaint.color = Colors.white.withOpacity(opacity);
        canvas.drawCircle(s.pos, radius, starPaint);
      }
    }

    // Tap ripples: expanding fading ring.
    for (final r in ripples) {
      final p = r.age / 0.8;
      canvas.drawCircle(
        r.center,
        20 + Curves.easeOut.transform(p) * 130,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = AppColors.primary.withOpacity((1 - p) * 0.35),
      );
    }

    // Meteors: gradient trail + bright head.
    for (final me in meteors) {
      final fade = (1 - me.age / me.life).clamp(0.0, 1.0);
      final tail = me.pos - me.vel * 0.16;
      canvas.drawLine(
        me.pos,
        tail,
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95 * fade),
              AppColors.primary.withOpacity(0.0),
            ],
          ).createShader(Rect.fromPoints(me.pos, tail)),
      );
      canvas.drawCircle(
        me.pos,
        2.2,
        Paint()..color = Colors.white.withOpacity(fade),
      );
    }

    // Black hole core + release flash.
    if (m == _FieldMode.blackHole) {
      if (t < 0.7) {
        final g = Curves.easeIn.transform(t / 0.7);
        canvas.drawCircle(
          center,
          6 + g * 10,
          Paint()..color = Colors.black.withOpacity(0.9 * g),
        );
        canvas.drawCircle(
          center,
          10 + g * 14,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF8B5CF6).withOpacity(0.7 * g),
        );
      } else {
        final p = (t - 0.7) / 0.3;
        canvas.drawCircle(
          center,
          20 + Curves.easeOut.transform(p) * 320,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 * (1 - p)
            ..color = Colors.white.withOpacity((1 - p) * 0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FieldPainter oldDelegate) => false;
}
