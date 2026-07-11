import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/core/utils/resposive.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/data/services/urls_launcher_service.dart';
import 'package:portfolio/widgets/glass/glass_button.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';
import 'package:provider/provider.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback tapProject;
  final VoidCallback tapContact;
  const HeroSection({
    super.key,
    required this.tapProject,
    required this.tapContact,
  });

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

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: screenHeight - 140),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hero.showAvailability) ...[
                  _AvailabilityBadge(text: hero.availability)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.4, curve: Curves.easeOutCubic),
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

                ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFB8BCFF), Colors.white],
                        stops: [0.0, 0.55, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        isMobile ? hero.nameShort : hero.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1,
                          color: Colors.white,
                        ),
                      ),
                    )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                SizedBox(height: isMobile ? 16 : 20),

                _RotatingRoles(isMobile: isMobile, roles: hero.roles)
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
                    GlassButton(
                          text: "View Projects",
                          onTap: tapProject,
                          tint: AppColors.primary,
                          width: isMobile ? 150 : 170,
                          fontSize: 14,
                        )
                        .animate(delay: 800.ms)
                        .fadeIn()
                        .scale(begin: const Offset(0.9, 0.9)),
                    GlassButton(
                          text: "Contact Me",
                          onTap: tapContact,
                          width: isMobile ? 150 : 170,
                          fontSize: 14,
                        )
                        .animate(delay: 900.ms)
                        .fadeIn()
                        .scale(begin: const Offset(0.9, 0.9)),
                  ],
                ),
                SizedBox(height: isMobile ? 32 : 40),

                Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SocialIcon(
                          icon: Icons.code_rounded,
                          tooltip: "GitHub",
                          url: links.github,
                        ),
                        const SizedBox(width: 14),
                        _SocialIcon(
                          icon: Icons.business_center_rounded,
                          tooltip: "LinkedIn",
                          url: links.linkedin,
                        ),
                        const SizedBox(width: 14),
                        _SocialIcon(
                          icon: Icons.mail_rounded,
                          tooltip: "Email",
                          url: links.email,
                        ),
                        const SizedBox(width: 14),
                        _SocialIcon(
                          icon: Icons.description_rounded,
                          tooltip: "Resume",
                          url: links.resume,
                        ),
                      ],
                    )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                SizedBox(height: isMobile ? 40 : 56),

                const _ScrollIndicator().animate(delay: 1400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final String text;
  const _AvailabilityBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
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
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatingRoles extends StatefulWidget {
  final bool isMobile;
  final List<String> roles;
  const _RotatingRoles({required this.isMobile, required this.roles});

  @override
  State<_RotatingRoles> createState() => _RotatingRolesState();
}

class _RotatingRolesState extends State<_RotatingRoles> {
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => index = index + 1);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.isMobile ? 18.0 : 24.0;

    return SizedBox(
      height: fontSize * 1.6,
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: Text(
            widget.roles[index % widget.roles.length],
            key: ValueKey(index),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withOpacity(0.95),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
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
              child: Icon(
                icon,
                size: 20,
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
