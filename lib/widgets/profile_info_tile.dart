import 'package:flutter/material.dart';
import 'package:uvip/core/theme/app_theme.dart';

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            // Left Icon
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 36, // Using larger size based on the image
            ),
            const SizedBox(width: 20),
            // Middle Content (Label & Value)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            // Right Arrow
            const Icon(
              Icons.chevron_right,
              color: AppTheme.unselectedIconColor,
            ),
          ],
        ),
      ),
    );
  }
}
