import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'storage.dart';
import 'pages/onboarding.dart';
import 'pages/home_shell.dart';

void main() {
  runApp(const NonicApp());
}

class NonicApp extends StatefulWidget {
  const NonicApp({super.key});
  @override
  State<NonicApp> createState() => _NonicAppState();
}

class _NonicAppState extends State<NonicApp> {
  final StorageService storage = StorageService();
  UserProfile? profile;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final loaded = await storage.getProfile();
    setState(() => profile = loaded);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nonic',
      debugShowCheckedModeBanner: false,
      theme: buildNonicTheme(),
      home: profile == null
          ? OnboardingScreen(
              onComplete: (p) async {
                await storage.saveProfile(p);
                setState(() => profile = p);
              },
            )
          : HomeShell(profile: profile!, storage: storage),
    );
  }
}


