import 'package:flutter/material.dart';
import 'package:uvip/core/theme/app_theme.dart';

class UploadedItemTile extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String? imageUrl;
  final VoidCallback? onDelete;
  final bool isSelected;
  final ValueChanged<bool?>? onSelect;

  const UploadedItemTile({
    super.key,
    required this.fileName,
    required this.fileSize,
    this.imageUrl,
    this.onDelete,
    this.isSelected = false,
    this.onSelect,
  });

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle relative paths
    String? fullImageUrl = imageUrl;
    if (fullImageUrl != null && !fullImageUrl.startsWith('http')) {
      // Assuming base URL is http://103.92.214.110:8001
      final baseUrl = 'http://103.92.214.110:8001';
      fullImageUrl =
          '$baseUrl/${fullImageUrl.startsWith('/') ? fullImageUrl.substring(1) : fullImageUrl}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: fullImageUrl != null
            ? () => _showImagePreview(context, fullImageUrl!)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Checkbox
            if (onSelect != null)
              Checkbox(
                value: isSelected,
                onChanged: onSelect,
                activeColor: AppTheme.primaryColor,
              ),
            // Thumbnail
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
                image: fullImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(fullImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: fullImageUrl == null
                  ? const Icon(Icons.image, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            // File Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileSize,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 12),
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
      ),
    );
  }
}
