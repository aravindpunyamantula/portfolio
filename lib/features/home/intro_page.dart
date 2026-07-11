import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/core/utils/resposive.dart';
import 'package:portfolio/features/home/home_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, _, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(opacity: curved, child: child);
          },
          pageBuilder: (_, _, _) => const HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const IntroAnimation();
  }
}

class IntroAnimation extends StatelessWidget {
  const IntroAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);

    final letters = "P D S ARAVIND KUMAR".split("");

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Hero(
          tag: "logo",
          child: Material(
            color: Colors.transparent,
            child:
                Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(letters.length, (i) {
                        return Text(
                              letters[i],
                              style: TextStyle(
                                fontSize: isMobile ? 24 : 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                color: AppColors.textPrimary,
                              ),
                            )
                            .animate(delay: (50 * i).ms)
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.6, curve: Curves.easeOutCubic);
                      }),
                    )
                    .animate(delay: 1100.ms)
                    .scale(
                      begin: const Offset(0.97, 0.97),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
          ),
        ),
      ),
    );
  }
}
