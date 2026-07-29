import 'package:flutter/material.dart';
import 'package:uvip/core/theme/app_theme.dart';

class UploadedItemTile extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final VoidCallback? onDelete;

  const UploadedItemTile({
    super.key,
    required this.fileName,
    required this.fileSize,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Teal Box (Thumbnail placeholder)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          // File Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  fileSize,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          // Trash Icon
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.unselectedIconColor, // Gray color for trash
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
