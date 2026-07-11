import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/data/models/certificate_model.dart';
import 'package:portfolio/data/services/urls_launcher_service.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

class CertificateCard extends StatefulWidget {
  final CertificateModel certificate;
  final double width;
  const CertificateCard({
    super.key,
    required this.certificate,
    this.width = 380,
  });

  @override
  State<CertificateCard> createState() => _CertificateCardState();
}

class _CertificateCardState extends State<CertificateCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;
    final hasLink = cert.link.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        offset: isHovering ? const Offset(0, -0.015) : Offset.zero,
        child: SizedBox(
          width: widget.width,
          child: LiquidGlass(
            borderRadius: 26,
            glow: isHovering ? 1 : 0,
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image in the same inset hairline frame as project cards
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AnimatedScale(
                          scale: isHovering ? 1.04 : 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          child: Image.network(
                            cert.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stacktrace) {
                              return const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 44,
                                      color: Colors.white24,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Preview unavailable",
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${cert.organisation} · ${cert.date}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: cert.skills.map((skill) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                            0.10,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        skill,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              if (hasLink) ...[
                                const SizedBox(width: 10),
                                _VerifyPill(onTap: () => openLink(cert.link)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

class _VerifyPill extends StatefulWidget {
  final VoidCallback onTap;
  const _VerifyPill({required this.onTap});

  @override
  State<_VerifyPill> createState() => _VerifyPillState();
}

class _VerifyPillState extends State<_VerifyPill> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.primary.withOpacity(hovering ? 0.38 : 0.25),
            border: Border.all(
              color: AppColors.primary.withOpacity(hovering ? 0.7 : 0.4),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Verify",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 5),
              Icon(Icons.north_east_rounded, size: 12, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
