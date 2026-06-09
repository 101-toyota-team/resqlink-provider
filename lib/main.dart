import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'screens/provider_home_screen.dart';

void main() {
  runApp(const ResQLinkProviderApp());
}

class ResQLinkProviderApp extends StatelessWidget {
  const ResQLinkProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQLink Provider',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ProviderHomeScreen(),
    );
  }
}
