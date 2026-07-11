import 'package:flutter/material.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/data/services/content_service.dart';
import 'package:portfolio/data/services/email_service.dart';
import 'package:portfolio/features/home/intro_page.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmailService()),
        // Remote content starts loading during the intro splash, so it's
        // usually in place before the home page appears.
        ChangeNotifierProvider(create: (_) => ContentService()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: IntroPage(),
      ),
    );
  }
}
