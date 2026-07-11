import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/core/utils/resposive.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class GlassNavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onProjectsTap;
  final VoidCallback onSkillsTap;
  final VoidCallback onCertificatesTap;
  final VoidCallback onContactTap;

  /// Index of the section currently in view
  /// (0 Home, 1 Projects, 2 Skills, 3 Certs, 4 Contact).
  final ValueListenable<int> activeSection;

  const GlassNavBar({
    super.key,
    required this.onHomeTap,
    required this.onProjectsTap,
    required this.onSkillsTap,
    required this.onCertificatesTap,
    required this.onContactTap,
    required this.activeSection,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Positioned(
      top: 20,
      left: 10,
      right: 10,
      child: Center(
        child: LiquidGlass(
          borderRadius: 40,
          blur: 22,
          shadow: false,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 5 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'logo',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    isMobile ? 'ARAVIND KUMAR' : 'P D S ARAVIND KUMAR',
                    style: TextStyle(
                      letterSpacing: isMobile ? 1.5 : 2,
                      fontSize: isMobile ? 13 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (!isMobile)
                ValueListenableBuilder<int>(
                  valueListenable: activeSection,
                  builder: (context, active, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 40),
                        _NavItem(
                          title: "Home",
                          onTap: onHomeTap,
                          isActive: active == 0,
                        ),
                        const SizedBox(width: 8),
                        _NavItem(
                          title: "Projects",
                          onTap: onProjectsTap,
                          isActive: active == 1,
                        ),
                        const SizedBox(width: 8),
                        _NavItem(
                          title: "Skills",
                          onTap: onSkillsTap,
                          isActive: active == 2,
                        ),
                        const SizedBox(width: 8),
                        _NavItem(
                          title: "Certs",
                          onTap: onCertificatesTap,
                          isActive: active == 3,
                        ),
                        const SizedBox(width: 8),
                        _NavItem(
                          title: "Contact",
                          onTap: onContactTap,
                          isActive: active == 4,
                        ),
                      ],
                    );
                  },
                ),

              if (isMobile) ...[
                const SizedBox(width: 10),
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isActive;
  const _NavItem({required this.title, this.onTap, this.isActive = false});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = hovering || widget.isActive;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.isActive
                ? Colors.white.withOpacity(0.12)
                : hovering
                ? Colors.white.withOpacity(0.06)
                : Colors.transparent,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: highlighted ? Colors.white : Colors.white60,
              fontSize: 15,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }
}
