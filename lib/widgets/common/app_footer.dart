import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/data/services/urls_launcher_service.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';
import 'package:provider/provider.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentService>().content;
    final links = content.links;
    final year = DateTime.now().year;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Gradient hairline — light catches the center of the edge.
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 36 : 48,
            horizontal: 24,
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFB8BCFF)],
                ).createShader(bounds),
                child: const Text(
                  "P D S ARAVIND KUMAR",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                content.hero.footerTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _FooterIcon(
                    icon: Icons.code_rounded,
                    tooltip: "GitHub",
                    url: links.github,
                  ),
                  _FooterIcon(
                    icon: Icons.business_center_rounded,
                    tooltip: "LinkedIn",
                    url: links.linkedin,
                  ),
                  _FooterIcon(
                    icon: Icons.camera_alt_rounded,
                    tooltip: "Instagram",
                    url: links.instagram,
                  ),
                  _FooterIcon(
                    icon: Icons.mail_rounded,
                    tooltip: "Email",
                    url: links.email,
                  ),
                  _FooterIcon(
                    icon: Icons.description_rounded,
                    tooltip: "Resume",
                    url: links.resume,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "© $year P D S Aravind Kumar",
                    style: const TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Crafted with ",
                        style: TextStyle(color: Colors.white30, fontSize: 12),
                      ),
                      Icon(
                        Icons.favorite_rounded,
                        size: 12,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                      const Text(
                        " in Flutter",
                        style: TextStyle(color: Colors.white30, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String url;

  const _FooterIcon({
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
              borderRadius: 15,
              blur: 12,
              shadow: false,
              glow: hovering ? 1 : 0,
              padding: const EdgeInsets.all(11),
              child: Icon(
                icon,
                size: 18,
                color: hovering ? Colors.white : Colors.white60,
              ),
            ),
          );
        },
      ),
    );
  }
}
