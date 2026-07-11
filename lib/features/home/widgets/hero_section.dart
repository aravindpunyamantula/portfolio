import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/core/utils/resposive.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/data/services/github_stats_service.dart';
import 'package:portfolio/data/services/urls_launcher_service.dart';
import 'package:portfolio/features/home/widgets/hero_starfield.dart';
import 'package:portfolio/widgets/glass/glass_button.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';
import 'package:provider/provider.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback tapProject;
  final VoidCallback tapContact;
  const HeroSection({
    super.key,
    required this.tapProject,
    required this.tapContact,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final StarfieldController _field = StarfieldController();

  // Easter egg: typing "aravind" anywhere summons a meteor shower.
  String _typed = '';
  Future<GithubStats?>? _statsFuture;
  String _statsUser = '';

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final char = event.character;
    if (char == null || char.length != 1) return false;
    // Never react while someone is typing in the contact form.
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused != null &&
        focused.findAncestorWidgetOfExactType<EditableText>() != null) {
      return false;
    }
    _typed = (_typed + char.toLowerCase());
    if (_typed.length > 16) _typed = _typed.substring(_typed.length - 16);
    if (_typed.endsWith('aravind')) {
      _typed = '';
      _field.meteorShower();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentService>().content;
    final hero = content.hero;
    final links = content.links;
    final isMobile = Responsive.isMobile(context);
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    // Scale the headline with viewport width so it never wraps awkwardly
    // on tablets or small phones.
    final nameSize = isMobile
        ? min(40.0, screenSize.width * 0.105)
        : min(68.0, screenSize.width * 0.062);

    // Live GitHub chips — username comes from the (possibly remote) link.
    final username = links.github
        .split('/')
        .where((p) => p.isNotEmpty)
        .toList()
        .reversed
        .first;
    if (username != _statsUser) {
      _statsUser = username;
      _statsFuture = fetchGithubStats(username);
    }

    final heroContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hero.showAvailability) ...[
          _AvailabilityBadge(
            text: hero.availability,
            // Easter egg: double-tap collapses the starfield into a
            // black hole, then warps down to the contact section.
            onDoubleTap: () =>
                _field.blackHole(onComplete: widget.tapContact),
          ).animate().fadeIn(duration: 500.ms).slideY(
              begin: 0.4, curve: Curves.easeOutCubic),
          SizedBox(height: isMobile ? 28 : 36),
        ],

        Text(
          hero.greeting,
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        )
            .animate(delay: 150.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.4, curve: Curves.easeOutCubic),
        const SizedBox(height: 12),

        _HeroName(
          key: ValueKey(isMobile ? hero.nameShort : hero.name),
          text: isMobile ? hero.nameShort : hero.name,
          fontSize: nameSize,
          interactive: !isMobile,
        ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
        SizedBox(height: isMobile ? 16 : 20),

        _TypingRole(roles: hero.roles, isMobile: isMobile)
            .animate(delay: 500.ms)
            .fadeIn(duration: 500.ms),
        SizedBox(height: isMobile ? 20 : 24),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            hero.tagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 15 : 17,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        )
            .animate(delay: 650.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.3, curve: Curves.easeOutCubic),
        SizedBox(height: isMobile ? 32 : 40),

        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _Magnetic(
              enabled: !isMobile,
              child: GlassButton(
                text: "View Projects",
                onTap: () {
                  _field.warp();
                  widget.tapProject();
                },
                tint: AppColors.primary,
                width: isMobile ? 150 : 170,
                fontSize: 14,
              ),
            ).animate(delay: 800.ms).fadeIn().scale(
                begin: const Offset(0.9, 0.9)),
            _Magnetic(
              enabled: !isMobile,
              child: GlassButton(
                text: "Contact Me",
                onTap: widget.tapContact,
                width: isMobile ? 150 : 170,
                fontSize: 14,
              ),
            ).animate(delay: 900.ms).fadeIn().scale(
                begin: const Offset(0.9, 0.9)),
          ],
        ),
        SizedBox(height: isMobile ? 32 : 40),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SocialIcon(
              icon: FontAwesomeIcons.github,
              tooltip: "GitHub",
              url: links.github,
            ),
            const SizedBox(width: 14),
            _SocialIcon(
              icon: FontAwesomeIcons.linkedinIn,
              tooltip: "LinkedIn",
              url: links.linkedin,
            ),
            const SizedBox(width: 14),
            _SocialIcon(
              icon: FontAwesomeIcons.solidEnvelope,
              tooltip: "Email",
              url: links.email,
            ),
            const SizedBox(width: 14),
            _SocialIcon(
              icon: FontAwesomeIcons.solidFileLines,
              tooltip: "Resume",
              url: links.resume,
            ),
          ],
        )
            .animate(delay: 1000.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.3, curve: Curves.easeOutCubic),
        const SizedBox(height: 22),

        // Live proof-of-work: GitHub stats + "currently building" ticker.
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _GithubChips(future: _statsFuture),
            if (hero.currentlyBuilding.isNotEmpty)
              _InfoChip(
                dotColor: const Color(0xFFF59E0B),
                pulse: true,
                text: "Building: ${hero.currentlyBuilding}",
              ),
          ],
        ).animate(delay: 1150.ms).fadeIn(duration: 500.ms),
        SizedBox(height: isMobile ? 34 : 44),

        const _ScrollIndicator().animate(delay: 1400.ms).fadeIn(),
      ],
    );

    // Forward pointer activity from the whole hero (including over text
    // and buttons) into the starfield so the gravity well never "dies"
    // in the middle of the screen. Listener local coords == stack coords.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerHover: (e) => _field.pointerHover(e.localPosition),
      onPointerMove: (e) => _field.pointerHover(e.localPosition),
      onPointerDown: (e) => _field.pointerDown(e.localPosition),
      child: MouseRegion(
        opaque: false,
        onExit: (_) => _field.pointerExit(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight - 140),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: HeroStarfield(controller: _field, isMobile: isMobile),
              ),
              // Non-positioned child defines the stack's size.
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: isMobile
                        ? heroContent
                        : _TiltRegion(child: heroContent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Act 2: decrypt name + gravity-warp letters (Act 3) ─────────────────

class _HeroName extends StatefulWidget {
  final String text;
  final double fontSize;
  final bool interactive;

  const _HeroName({
    super.key,
    required this.text,
    required this.fontSize,
    required this.interactive,
  });

  @override
  State<_HeroName> createState() => _HeroNameState();
}

class _HeroNameState extends State<_HeroName> {
  static const _glyphs = r'ABCDEFGHIJKMNPQRSTUVWXYZ023456789#%&$@*+=<>';
  static final _rand = Random();

  late List<String> _display;
  int _revealed = 0;
  Timer? _timer;
  Offset? _cursor;
  List<double> _centers = const [];
  double _measuredFor = -1;

  TextStyle get _style => TextStyle(
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1,
        color: Colors.white,
      );

  @override
  void initState() {
    super.initState();
    _display = widget.text.split('');
    _scrambleFrom(0);
    // Decrypt: reveal one character every tick, churning the rest.
    _timer = Timer.periodic(const Duration(milliseconds: 45), (_) {
      if (!mounted) return;
      setState(() {
        _revealed++;
        _scrambleFrom(_revealed);
        if (_revealed >= widget.text.length) {
          _timer?.cancel();
        }
      });
    });
  }

  void _scrambleFrom(int start) {
    for (var i = start; i < widget.text.length; i++) {
      final c = widget.text[i];
      // Keep spaces and punctuation stable so the shape reads through.
      _display[i] = RegExp(r'[A-Za-z]').hasMatch(c)
          ? _glyphs[_rand.nextInt(_glyphs.length)]
          : c;
    }
    for (var i = 0; i < min(start, widget.text.length); i++) {
      _display[i] = widget.text[i];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _measure() {
    if (_measuredFor == widget.fontSize) return;
    _measuredFor = widget.fontSize;
    final centers = <double>[];
    var x = 0.0;
    for (final c in widget.text.split('')) {
      final painter = TextPainter(
        text: TextSpan(text: c, style: _style),
        textDirection: TextDirection.ltr,
      )..layout();
      centers.add(x + painter.width / 2);
      x += painter.width;
    }
    _centers = centers;
  }

  @override
  Widget build(BuildContext context) {
    _measure();
    final done = _revealed >= widget.text.length;

    Widget letters = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_display.length, (i) {
        Offset shift = Offset.zero;
        if (done && widget.interactive && _cursor != null) {
          // Gravity warp: letters near the cursor ease away, like mass
          // bending spacetime. Deliberately subtle (max ~6 px).
          final d = _centers.length > i ? _cursor!.dx - _centers[i] : 0.0;
          final falloff = exp(-(d * d) / (2 * 70 * 70));
          shift = Offset(
            (d.abs() < 1 ? 0 : -d.sign) * falloff * 6,
            -falloff * 5,
          );
        }
        return TweenAnimationBuilder<Offset>(
          tween: Tween(end: shift),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, value, child) =>
              Transform.translate(offset: value, child: child),
          child: Text(_display[i], style: _style),
        );
      }),
    );

    if (widget.interactive) {
      letters = MouseRegion(
        opaque: false,
        onHover: (e) => setState(() => _cursor = e.localPosition),
        onExit: (_) => setState(() => _cursor = null),
        child: letters,
      );
    }

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFB8BCFF), Colors.white],
        stops: [0.0, 0.55, 1.0],
      ).createShader(bounds),
      child: FittedBox(fit: BoxFit.scaleDown, child: letters),
    );
  }
}

// ── Act 2: typewriter role line ────────────────────────────────────────

class _TypingRole extends StatefulWidget {
  final List<String> roles;
  final bool isMobile;
  const _TypingRole({required this.roles, required this.isMobile});

  @override
  State<_TypingRole> createState() => _TypingRoleState();
}

class _TypingRoleState extends State<_TypingRole> {
  int _role = 0;
  int _chars = 0;
  bool _deleting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule(600);
  }

  void _schedule(int ms) {
    _timer = Timer(Duration(milliseconds: ms), _step);
  }

  void _step() {
    if (!mounted) return;
    final word = widget.roles[_role % widget.roles.length];
    setState(() {
      if (_deleting) {
        _chars--;
        if (_chars <= 0) {
          _deleting = false;
          _role++;
        }
      } else {
        _chars++;
      }
    });
    if (!_deleting && _chars >= word.length) {
      _deleting = true;
      _schedule(1700); // hold the finished word
    } else {
      _schedule(_deleting ? 32 : 62);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.isMobile ? 18.0 : 24.0;
    final word = widget.roles[_role % widget.roles.length];
    final shown = word.substring(0, _chars.clamp(0, word.length));

    return SizedBox(
      height: fontSize * 1.6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            shown,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withOpacity(0.95),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            "|",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.primary.withOpacity(0.9),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: 500.ms)
              .then()
              .fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}

// ── Act 3: magnetic CTA + tilt parallax ────────────────────────────────

class _Magnetic extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const _Magnetic({required this.child, required this.enabled});

  @override
  State<_Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<_Magnetic> {
  Offset _shift = Offset.zero;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return MouseRegion(
      opaque: false,
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final delta = e.localPosition - box.size.center(Offset.zero);
        setState(() {
          _shift = Offset(
            delta.dx.clamp(-40, 40) * 0.22,
            delta.dy.clamp(-24, 24) * 0.22,
          );
        });
      },
      onExit: (_) => setState(() => _shift = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: _shift),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) =>
            Transform.translate(offset: value, child: child),
        child: widget.child,
      ),
    );
  }
}

class _TiltRegion extends StatefulWidget {
  final Widget child;
  const _TiltRegion({required this.child});

  @override
  State<_TiltRegion> createState() => _TiltRegionState();
}

class _TiltRegionState extends State<_TiltRegion> {
  Offset _tilt = Offset.zero; // x = rotateY, y = rotateX

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final c = box.size.center(Offset.zero);
        setState(() {
          _tilt = Offset(
            ((e.localPosition.dx - c.dx) / c.dx).clamp(-1, 1) * 0.035,
            -((e.localPosition.dy - c.dy) / c.dy).clamp(-1, 1) * 0.03,
          );
        });
      },
      onExit: (_) => setState(() => _tilt = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: _tilt),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, value, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0008)
            ..rotateY(value.dx)
            ..rotateX(value.dy),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ── Act 5: live GitHub chips + info chip ───────────────────────────────

class _GithubChips extends StatelessWidget {
  final Future<GithubStats?>? future;
  const _GithubChips({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GithubStats?>(
      future: future,
      builder: (context, snap) {
        final stats = snap.data;
        if (stats == null) return const SizedBox.shrink();
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoChip(
              icon: Icons.folder_rounded,
              text: "${stats.repos} repos",
            ),
            if (stats.stars > 0)
              _InfoChip(
                icon: Icons.star_rounded,
                text: "${stats.stars} stars",
              ),
          ],
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData? icon;
  final Color? dotColor;
  final bool pulse;
  final String text;

  const _InfoChip({
    this.icon,
    this.dotColor,
    this.pulse = false,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Widget leading;
    if (dotColor != null) {
      Widget dot = Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
      );
      if (pulse) {
        dot = dot
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(duration: 800.ms)
            .then()
            .fadeOut(duration: 800.ms);
      }
      leading = dot;
    } else {
      leading = Icon(icon, size: 13, color: Colors.white54);
    }

    return LiquidGlass(
      borderRadius: 30,
      blur: 10,
      shadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── shared pieces ──────────────────────────────────────────────────────

class _AvailabilityBadge extends StatefulWidget {
  final String text;
  final VoidCallback onDoubleTap;
  const _AvailabilityBadge({required this.text, required this.onDoubleTap});

  @override
  State<_AvailabilityBadge> createState() => _AvailabilityBadgeState();
}

class _AvailabilityBadgeState extends State<_AvailabilityBadge> {
  int _taps = 0;
  Timer? _reset;

  void _onTap() {
    _taps++;
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1200), () => _taps = 0);
    if (_taps >= 2) {
      _taps = 0;
      widget.onDoubleTap();
    }
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: LiquidGlass(
        borderRadius: 30,
        blur: 14,
        shadow: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 900.ms)
                .then()
                .fadeOut(duration: 900.ms),
            const SizedBox(width: 10),
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final FaIconData icon;
  final String tooltip;
  final String url;

  const _SocialIcon({
    required this.icon,
    required this.tooltip,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: LiquidGlassHover(
        cursor: SystemMouseCursors.click,
        builder: (context, hovering) {
          return GestureDetector(
            onTap: () => openLink(url),
            child: LiquidGlass(
              borderRadius: 16,
              blur: 14,
              shadow: false,
              glow: hovering ? 1 : 0,
              padding: const EdgeInsets.all(12),
              child: FaIcon(
                icon,
                size: 18,
                color: hovering ? Colors.white : Colors.white70,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  const _ScrollIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "SCROLL",
          style: TextStyle(
            color: Colors.white30,
            fontSize: 10,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38)
            .animate(onPlay: (c) => c.repeat())
            .moveY(begin: -2, end: 6, duration: 900.ms, curve: Curves.easeInOut)
            .then()
            .moveY(begin: 6, end: -2, duration: 900.ms, curve: Curves.easeInOut),
      ],
    );
  }
}
