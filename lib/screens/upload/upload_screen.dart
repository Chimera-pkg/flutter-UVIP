import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/widgets/uploaded_item_tile.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Upload Foto Kota',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Consumer<UploadProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dotted Dropzone
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    color: AppTheme.primaryColor,
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    radius: const Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(
                        alpha: 0.15,
                      ), // Light teal background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.upload_rounded,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload your photo here',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.lightGray),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Uploaded Section
                if (provider.uploadedFiles.isNotEmpty) ...[
                  Text(
                    'Uploaded',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.uploadedFiles.length,
                    itemBuilder: (context, index) {
                      final file = provider.uploadedFiles[index];
                      return UploadedItemTile(
                        fileName: file.name,
                        fileSize: file.size,
                        onDelete: () => provider.removeUploadedFile(index),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Uploading Section
                if (provider.uploadingFiles.isNotEmpty) ...[
                  Text(
                    'Uploading ${provider.uploadingFiles.length} images',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Horizontal list of teal boxes for uploading images
                  Row(
                    children: provider.uploadingFiles.map((file) {
                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar & Cancel
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: provider.uploadProgress,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.secondaryColor, // Navy blue progress
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => provider.cancelUpload(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time remaining: ${provider.timeRemaining}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],

                const SizedBox(height: 48),

                // Analisa Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action for Analisa
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Analisa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
