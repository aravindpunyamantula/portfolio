import 'package:flutter/material.dart';
import 'package:portfolio/core/utils/resposive.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/features/projects/widgets/project_card.dart';
import 'package:portfolio/widgets/common/section_container.dart';
import 'package:portfolio/widgets/common/section_header.dart';
import 'package:portfolio/widgets/glass/glass_arrow_button.dart';
import 'package:provider/provider.dart';

class ProjectSection extends StatefulWidget {
  const ProjectSection({super.key});

  @override
  State<ProjectSection> createState() => _ProjectSectionState();
}

class _ProjectSectionState extends State<ProjectSection> {
  PageController? _pageCtrl;
  double _fraction = 0;

  bool get isMobile => Responsive.isMobile(context);

  // Wider viewport share on tablets so cards never feel cramped.
  double get _targetFraction {
    final width = MediaQuery.of(context).size.width;
    if (width < 870) return 0.96;
    if (width < 1150) return 0.85;
    return 0.72;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pageCtrl == null || _fraction != _targetFraction) {
      _fraction = _targetFraction;
      final old = _pageCtrl;
      _pageCtrl = PageController(viewportFraction: _fraction);
      // The old controller is still attached to the PageView until this
      // build pass swaps it in — disposing it now would trip debug asserts.
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
  }

  @override
  void dispose() {
    _pageCtrl?.dispose();
    super.dispose();
  }

  void _goTo(int delta) {
    final count = context.read<ContentService>().content.projects.length;
    final page = (_pageCtrl!.page ?? 0).round() + delta;
    _pageCtrl!.animateToPage(
      page.clamp(0, count - 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _pageCtrl!;
    final content = context.watch<ContentService>().content;
    final projects = content.projects;
    final header = content.section('projects');

    return SectionContainer(
      child: Column(
        children: [
          SectionHeader(
            eyebrow: header.eyebrow,
            title: header.title,
            subtitle: header.subtitle,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: isMobile ? 400 : 540,
            // The controller listeners must live BELOW the PageView: when a
            // breakpoint change swaps in a new controller, its attach fires
            // a notification mid-build, and notifying an ancestor throws
            // "setState() called during build". Descendants are fine.
            child: PageView.builder(
              padEnds: false,
              controller: ctrl,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return AnimatedBuilder(
                  animation: ctrl,
                  child: Padding(
                    padding: EdgeInsets.only(right: isMobile ? 8 : 24),
                    child: ProjectCard(project: project, isMobile: isMobile),
                  ),
                  builder: (context, child) {
                    final currentPage =
                        ctrl.hasClients && ctrl.position.haveDimensions
                            ? (ctrl.page ?? 0)
                            : 0.0;
                    final scale = isMobile
                        ? 1.0
                        : (1 - (currentPage - index).abs() * 0.15).clamp(
                            0.85,
                            1.0,
                          );
                    return Transform.scale(scale: scale, child: child);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassArrowButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => _goTo(-1),
              ),
              const SizedBox(width: 20),
              AnimatedBuilder(
                animation: ctrl,
                builder: (context, _) {
                  final current =
                      ctrl.hasClients && ctrl.position.haveDimensions
                          ? (ctrl.page ?? 0)
                          : 0.0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(projects.length, (index) {
                      final isActive = current.round() == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(width: 20),
              GlassArrowButton(
                icon: Icons.arrow_forward_rounded,
                onTap: () => _goTo(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
