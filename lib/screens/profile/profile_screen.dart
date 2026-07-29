import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/profile_provider.dart';
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
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
                  provider.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                // Role
                Text(
                  provider.role,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightGray,
                      ),
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
                  value: provider.email,
                ),
                ProfileInfoTile(
                  icon: Icons.map_outlined, // You can use a more precise icon if needed
                  label: 'Alamat',
                  value: provider.address,
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
