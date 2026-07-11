import 'dart:math';

import 'package:flutter/material.dart';
import 'package:portfolio/core/constants/app_colors.dart';
import 'package:portfolio/widgets/glass/liquid_glass.dart';

/// Floating liquid-glass snackbar — same recipe as the cards: backdrop
/// blur + saturation, tinted rim, dark translucent fill. Use everywhere
/// instead of the default Material snackbar.
void showGlassSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Color accent = AppColors.primary,
}) {
  final width = MediaQuery.of(context).size.width;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      width: min(440, width - 32),
      duration: const Duration(seconds: 4),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: LiquidGlass.blurAndSaturate(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withOpacity(0.4)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 19),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
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
