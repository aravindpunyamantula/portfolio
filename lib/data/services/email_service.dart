import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:portfolio/data/services/sound_service.dart';
import 'package:portfolio/widgets/glass/glass_snackbar.dart';

class EmailService extends ChangeNotifier {
  bool sent = false;
  bool get isSending => sent;

  void sendEmail(
    BuildContext context,
    String name,
    String email,
    String message,
  ) async {
    sent = true;
    notifyListeners();

    const serviceId = 'service_vhgrmso';
    const templateId = 'template_gwnxpve';
    const publicKey = '21uNgzXVuKbRypUha';

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,

          'template_id': templateId,

          'user_id': publicKey,

          'template_params': {
            'name': name,

            'email': email,

            'message': message,

            'time': DateTime.now().toString(),
          },
        }),
      );

      if (!context.mounted) return;
      if (response.statusCode == 200) {
        SoundService.play(Sfx.sent);
        showGlassSnackBar(
          context,
          message: "Message sent — I'll get back to you soon!",
          icon: Icons.mark_email_read_rounded,
          accent: const Color(0xFF34D399),
        );
      } else {
        showGlassSnackBar(
          context,
          message: "Failed to send — please try again or email me directly.",
          icon: Icons.error_outline_rounded,
          accent: Colors.redAccent,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showGlassSnackBar(
          context,
          message: "Failed to send — please try again or email me directly.",
          icon: Icons.error_outline_rounded,
          accent: Colors.redAccent,
        );
      }
    } finally {
      sent = false;
      notifyListeners();
    }
  }
}
