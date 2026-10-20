import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/providers/auth_provider.dart';
import 'package:uvip/screens/auth/login_screen.dart';
import 'package:uvip/screens/dashboard/main_screen.dart';

/// Route Guard untuk automatic authentication check
/// Auto redirect ke Login jika belum authenticated, atau Dashboard jika sudah
class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.checkAuthentication();

    if (!mounted) return;

    setState(() {
      _isAuthenticated = isAuthenticated;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Jika sudah login dan mencoba akses login screen -> redirect ke dashboard
    if (_isAuthenticated && widget.child is LoginScreen) {
      return const MainScreen();
    }

    // Jika belum login dan mencoba mengakses app -> redirect ke login
    if (!_isAuthenticated && widget.child is! LoginScreen) {
      return const LoginScreen();
    }

    // Normal rendering
    return widget.child;
  }
}
