import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/data/models/project_model.dart';
import 'package:portfolio/data/services/urls_launcher_service.dart';
import 'package:portfolio/features/projects/widgets/project_preview.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final bool isMobile;
  const ProjectCard({super.key, required this.project, this.isMobile = false});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool isHovering = false;

  String get _addressText {
    final link = widget.project.projectLink;
    if (link != null && link.isNotEmpty) {
      return Uri.parse(link).host;
    }
    final github = widget.project.githubLink;
    if (github != null && github.isNotEmpty) {
      return github.replaceAll('https://', '');
    }
    return widget.project.projectTitle.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final hasLive = project.projectLink?.isNotEmpty ?? false;
    final hasGithub = project.githubLink?.isNotEmpty ?? false;

    return MouseRegion(
      onEnter: widget.isMobile
          ? null
          : (event) => setState(() => isHovering = true),
      onExit: widget.isMobile
          ? null
          : (event) => setState(() => isHovering = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        offset: isHovering ? const Offset(0, -0.012) : Offset.zero,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: LiquidGlass(
            borderRadius: 26,
            glow: isHovering ? 1 : 0,
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrowserChrome(address: _addressText),

                    // Preview inside an inset hairline frame
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        height: widget.isMobile ? 170 : 290,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ProjectPreview(project: project),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.projectTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: widget.isMobile ? 17 : 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.projectDescription,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: widget.isMobile ? 13 : 14,
                              color: Colors.white60,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              if (hasLive)
                                _ActionPill(
                                  label: "Live",
                                  icon: Icons.north_east_rounded,
                                  tint: AppColors.primary,
                                  onTap: () => openLink(project.projectLink!),
                                ),
                              if (hasLive && hasGithub)
                                const SizedBox(width: 10),
                              if (hasGithub)
                                _ActionPill(
                                  label: "GitHub",
                                  icon: Icons.code_rounded,
                                  onTap: () => openLink(project.githubLink!),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Specular streak sweeps once per hover — no glow.
                Positioned.fill(
                  child: SpecularSweep(trigger: isHovering, borderRadius: 26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Browser-style chrome: window dots + address pill.
class _BrowserChrome extends StatelessWidget {
  final String address;
  const _BrowserChrome({required this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 6),
          _dot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 6),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 11,
                    color: Colors.white.withOpacity(0.35),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.85),
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color? tint;
  final VoidCallback onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tint,
  });

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final tint = widget.tint;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: tint != null
                ? tint.withOpacity(hovering ? 0.38 : 0.25)
                : Colors.white.withOpacity(hovering ? 0.14 : 0.07),
            border: Border.all(
              color: tint != null
                  ? tint.withOpacity(hovering ? 0.7 : 0.4)
                  : Colors.white.withOpacity(hovering ? 0.3 : 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(widget.icon, size: 14, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
