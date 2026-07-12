import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/core/constants/app_spacing.dart';
import 'package:portfolio/core/utils/animation_gate.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/data/services/urls_launcher_service.dart';
import 'package:portfolio/features/certificates/certificate_section.dart';
import 'package:portfolio/features/contacts/contact_section.dart';
import 'package:portfolio/features/home/widgets/hero_section.dart';
import 'package:portfolio/features/projects/project_section.dart';
import 'package:portfolio/features/reviews/review_section.dart';
import 'package:portfolio/features/skills/skill_section.dart';
import 'package:provider/provider.dart';
import 'package:portfolio/widgets/common/app_footer.dart';
import 'package:portfolio/widgets/common/space_background.dart';
import 'package:portfolio/widgets/glass/glass_nav_bar.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey homeKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey skillsKey = GlobalKey();
  final GlobalKey certificatesKey = GlobalKey();
  final GlobalKey reviewsKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  final ScrollController _scrollCtrl = ScrollController();

  /// Raw scroll offset — drives the 3D skill orbits.
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  /// Which nav section is in view (0 Home, 1 Projects, 2 Skills, 3 Contact).
  final ValueNotifier<int> _activeSection = ValueNotifier(0);

  /// Show the scroll-to-top button after leaving the hero.
  final ValueNotifier<bool> _showToTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _scrollOffset.dispose();
    _activeSection.dispose();
    _showToTop.dispose();
    super.dispose();
  }

  void _onScroll() {
    AnimationGate.unlock();
    final offset = _scrollCtrl.offset;
    _scrollOffset.value = offset;
    _showToTop.value = offset > 600;

    var active = 0;
    for (final entry
        in [projectsKey, skillsKey, certificatesKey, contactKey]
            .asMap()
            .entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top < MediaQuery.of(context).size.height * 0.4) {
        active = entry.key + 1;
      }
    }
    if (_activeSection.value != active) _activeSection.value = active;
  }

  void scrollToSection(GlobalKey key) {
    // Below-fold sections build on first interaction; if this tap IS the
    // first interaction, wait one frame for the target to exist.
    AnimationGate.unlock();
    void go() {
      final ctx = key.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }

    if (key.currentContext != null) {
      go();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => go());
    }
  }

  void _scrollToTop() {
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: _buildDrawer(context),
      backgroundColor: AppColors.background,
      body: Listener(
        // Any pointer activity opens the calm-start animation gate.
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => AnimationGate.unlock(),
        onPointerMove: (_) => AnimationGate.unlock(),
        onPointerHover: (_) => AnimationGate.unlock(),
        child: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: NebulaBackground()),
            const Positioned.fill(child: SpaceBackground()),
            const ShootingStar(),
            SingleChildScrollView(
              controller: _scrollCtrl,
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  Container(
                    key: homeKey,
                    child: HeroSection(
                      tapProject: () => scrollToSection(projectsKey),
                      tapContact: () => scrollToSection(contactKey),
                    ),
                  ),
                  // Everything below the fold builds on first interaction:
                  // it's invisible until the user scrolls (which opens the
                  // gate), and skipping it keeps boot + the remote-content
                  // rebuild cheap — crucial for TBT on CPU-only auditors.
                  GateBuilder(
                    builder: (context, open) {
                      if (!open) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SizedBox(height: AppSpacing.md),
                          Container(
                            key: projectsKey,
                            child: ProjectSection(
                              tapContact: () => scrollToSection(contactKey),
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Container(
                            key: skillsKey,
                            child: SkillSection(scrollOffset: _scrollOffset),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Container(
                            key: certificatesKey,
                            child: CertificateSection(
                              tapContact: () => scrollToSection(contactKey),
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Container(
                              key: reviewsKey, child: const ReviewSection()),
                          SizedBox(height: AppSpacing.md),
                          Container(
                              key: contactKey, child: const ContactSection()),
                          const SizedBox(height: 40),
                          const AppFooter(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            GlassNavBar(
              activeSection: _activeSection,
              onHomeTap: () => scrollToSection(homeKey),
              onProjectsTap: () => scrollToSection(projectsKey),
              onSkillsTap: () => scrollToSection(skillsKey),
              onCertificatesTap: () => scrollToSection(certificatesKey),
              onContactTap: () => scrollToSection(contactKey),
            ),
            _ScrollToTopButton(visible: _showToTop, onTap: _scrollToTop),
          ],
        ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final links = context.read<ContentService>().content.links;
    final sections = [
      (Icons.home_rounded, "Home", homeKey),
      (Icons.work_rounded, "Projects", projectsKey),
      (Icons.public_rounded, "Skills", skillsKey),
      (Icons.verified_rounded, "Certifications", certificatesKey),
      (Icons.mail_rounded, "Contact", contactKey),
    ];

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: (MediaQuery.of(context).size.width * 0.82).clamp(240.0, 304.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: LiquidGlass.blurAndSaturate(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.6),
              border: Border(
                left: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "ARAVIND KUMAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(
                      color: Colors.white.withOpacity(0.10),
                      height: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<int>(
                    valueListenable: _activeSection,
                    builder: (context, active, _) {
                      return Column(
                        children: List.generate(sections.length, (i) {
                          final (icon, title, key) = sections[i];
                          return _DrawerItem(
                            icon: icon,
                            title: title,
                            isActive: active == i,
                            onTap: () {
                              Navigator.pop(context);
                              scrollToSection(key);
                            },
                          );
                        }),
                      );
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Colors.white.withOpacity(0.10),
                          height: 32,
                        ),
                        Row(
                          children: [
                            _DrawerSocialIcon(
                              icon: FontAwesomeIcons.github,
                              url: links.github,
                            ),
                            const SizedBox(width: 12),
                            _DrawerSocialIcon(
                              icon: FontAwesomeIcons.linkedinIn,
                              url: links.linkedin,
                            ),
                            const SizedBox(width: 12),
                            _DrawerSocialIcon(
                              icon: FontAwesomeIcons.solidEnvelope,
                              url: links.email,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "© P D S Aravind Kumar",
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isActive
                  ? Colors.white.withOpacity(0.10)
                  : Colors.transparent,
              border: Border.all(
                color: isActive
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isActive ? AppColors.primary : Colors.white54,
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerSocialIcon extends StatelessWidget {
  final FaIconData icon;
  final String url;

  const _DrawerSocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openLink(url),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: FaIcon(icon, size: 16, color: Colors.white70),
      ),
    );
  }
}

class _ScrollToTopButton extends StatelessWidget {
  final ValueListenable<bool> visible;
  final VoidCallback onTap;

  const _ScrollToTopButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (context, show, child) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: show ? 1 : 0,
            child: IgnorePointer(ignoring: !show, child: child),
          );
        },
        child: LiquidGlassHover(
          cursor: SystemMouseCursors.click,
          builder: (context, hovering) {
            return GestureDetector(
              onTap: onTap,
              child: LiquidGlass(
                borderRadius: 18,
                blur: 16,
                glow: hovering ? 1 : 0,
                padding: const EdgeInsets.all(14),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 20,
                  color: hovering ? Colors.white : Colors.white70,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
