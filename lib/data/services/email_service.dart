import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailService extends ChangeNotifier {
  bool sent = false;
  bool get isSending => sent;

  void sendEmail(
    BuildContext context,
    String name,
    String email,
    String message,
  ) async {
    print("Sending email from $name <$email>: $message");
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message Sent Successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to send message")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message ${e.toString()}")),
      );
    } finally {
      sent = false;
      notifyListeners();
    }
  }
}
