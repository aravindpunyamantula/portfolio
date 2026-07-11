import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/core/constants/app_links.dart';
import 'package:portfolio/core/utils/resposive.dart';
import 'package:portfolio/data/services/email_service.dart';
import 'package:portfolio/data/services/urls_launcher_service.dart';
import 'package:portfolio/widgets/common/section_container.dart';
import 'package:portfolio/widgets/common/section_header.dart';
import 'package:portfolio/widgets/glass/glass_button.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';
import 'package:provider/provider.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  bool nameError = false;
  bool emailError = false;
  bool messageError = false;

  static final _emailRegex = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _send(EmailService emailService) {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    setState(() {
      nameError = name.isEmpty;
      emailError = email.isEmpty || !_emailRegex.hasMatch(email);
      messageError = message.isEmpty;
    });

    if (nameError || emailError || messageError) {
      final what = emailError && email.isNotEmpty
          ? "Please enter a valid email address"
          : "Please fill in all fields before sending";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1A1F2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  what,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    nameController.clear();
    emailController.clear();
    messageController.clear();

    emailService.sendEmail(context, name, email, message);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Consumer<EmailService>(
      builder: (context, emailService, child) {
        return SectionContainer(
          child: Column(
            children: [
              const SectionHeader(
                eyebrow: "CONTACT",
                title: "Let's Build Something Exceptional",
                subtitle:
                    "Open to collaborations, internships, and ambitious digital experiences.",
              ),
              const SizedBox(height: 28),

              LiquidGlass(
                borderRadius: 28,
                padding: EdgeInsets.all(isMobile ? 22 : 36),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _leftSection(),
                          const SizedBox(height: 36),
                          _rightSection(emailService),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _leftSection()),
                          const SizedBox(width: 40),
                          Expanded(child: _rightSection(emailService)),
                        ],
                      ),
              ),

              const SizedBox(height: 28),

              Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: const [
                  _SocialPill(
                    icon: Icons.code_rounded,
                    label: "GitHub",
                    url: AppLinks.github,
                  ),
                  _SocialPill(
                    icon: Icons.business_center_rounded,
                    label: "LinkedIn",
                    url: AppLinks.linkedin,
                  ),
                  _SocialPill(
                    icon: Icons.camera_alt_rounded,
                    label: "Instagram",
                    url: AppLinks.instagram,
                  ),
                  _SocialPill(
                    icon: Icons.mail_rounded,
                    label: "Email",
                    url: AppLinks.email,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _leftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Have an idea?\nLet's talk.",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Whether it's a product, a platform, or an experiment — I reply fast and love a good challenge.",
          style: TextStyle(color: Colors.white60, height: 1.8, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Availability pill — same treatment as the hero badge.
        LiquidGlass(
          borderRadius: 30,
          blur: 12,
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
              ),
              const SizedBox(width: 10),
              const Text(
                "Available for opportunities",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _QuickActionPill(title: "Email", url: AppLinks.email),
            _QuickActionPill(title: "Resume", url: AppLinks.resume),
            _QuickActionPill(title: "GitHub", url: AppLinks.github),
            _QuickActionPill(title: "LinkedIn", url: AppLinks.linkedin),
          ],
        ),
      ],
    );
  }

  Widget _rightSection(EmailService emailService) {
    return Column(
      children: [
        _GlassInput(
          hint: "Your Name",
          controller: nameController,
          error: nameError,
          onChanged: () {
            if (nameError) setState(() => nameError = false);
          },
        ),
        const SizedBox(height: 16),
        _GlassInput(
          hint: "Your Email",
          controller: emailController,
          error: emailError,
          onChanged: () {
            if (emailError) setState(() => emailError = false);
          },
        ),
        const SizedBox(height: 16),
        _GlassInput(
          hint: "Your Message",
          maxLines: 6,
          controller: messageController,
          error: messageError,
          onChanged: () {
            if (messageError) setState(() => messageError = false);
          },
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: emailService.isSending
              ? LiquidGlass(
                  borderRadius: 40,
                  tint: AppColors.primary,
                  shadow: false,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : GlassButton(
                  text: "Send Message",
                  icon: Icons.send_rounded,
                  tint: AppColors.primary,
                  width: double.infinity,
                  fontSize: 14,
                  onTap: () => _send(emailService),
                ),
        ),
      ],
    );
  }
}

class _GlassInput extends StatefulWidget {
  final String hint;
  final int maxLines;
  final TextEditingController controller;
  final bool error;
  final VoidCallback? onChanged;

  const _GlassInput({
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.error = false,
    this.onChanged,
  });

  @override
  State<_GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<_GlassInput> {
  final focusNode = FocusNode();
  bool focused = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() => focused = focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(focused ? 0.07 : 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.error
              ? Colors.redAccent.withOpacity(0.65)
              : focused
              ? AppColors.primary.withOpacity(0.6)
              : Colors.white.withOpacity(0.10),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: focusNode,
        maxLines: widget.maxLines,
        onChanged: (_) => widget.onChanged?.call(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _QuickActionPill extends StatefulWidget {
  final String title;
  final String url;

  const _QuickActionPill({required this.title, required this.url});

  @override
  State<_QuickActionPill> createState() => _QuickActionPillState();
}

class _QuickActionPillState extends State<_QuickActionPill> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: () => openLink(widget.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(hovering ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(hovering ? 0.28 : 0.12),
            ),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: hovering ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;

  const _SocialPill({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  State<_SocialPill> createState() => _SocialPillState();
}

class _SocialPillState extends State<_SocialPill> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: () => openLink(widget.url),
        child: LiquidGlass(
          borderRadius: 18,
          blur: 12,
          shadow: false,
          glow: hovering ? 1 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: hovering ? Colors.white : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: hovering ? Colors.white : Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
