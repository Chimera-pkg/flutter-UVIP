import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';

import 'package:uvip/providers/profile_provider.dart';
import 'package:uvip/providers/result_provider.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/providers/home_provider.dart';
import 'package:uvip/providers/map_provider.dart';
import 'package:uvip/providers/aicam_provider.dart';
import 'package:uvip/providers/auth_provider.dart';
import 'package:uvip/screens/auth/login_screen.dart';
import 'package:uvip/screens/dashboard/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasToken = prefs.getString('access_token') != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => AiCamProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ResultProvider()),
      ],
      child: MyApp(isLoggedIn: hasToken),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UVIP App',
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
