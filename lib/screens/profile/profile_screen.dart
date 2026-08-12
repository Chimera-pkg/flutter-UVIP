import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/profile_provider.dart';
import 'package:uvip/providers/auth_provider.dart';
import 'package:uvip/screens/auth/login_screen.dart';
import 'package:uvip/widgets/profile_info_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Consumer2<ProfileProvider, AuthProvider>(
        builder: (context, provider, authProvider, child) {
          final user = authProvider.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Circular Avatar Placeholder
                const CircleAvatar(
                  radius: 70,
                  backgroundColor: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Role
                Text(
                  user?.role ?? 'User',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightGray),
                ),
                const SizedBox(height: 40),
                // List Items
                ProfileInfoTile(
                  icon: Icons.phone_outlined, // Teal icon on the left
                  label: 'No. Telepon',
                  value: provider.phone,
                ),
                ProfileInfoTile(
                  icon: Icons.mail_outline, // Teal icon on the left
                  label: 'Email',
                  value: user?.email ?? '-',
                ),
                ProfileInfoTile(
                  icon: Icons
                      .map_outlined, // You can use a more precise icon if needed
                  label: 'Alamat',
                  value: provider.address,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // padding for the bottom nav bar
              ],
            ),
          );
        },
      ),
    );
  }
}
