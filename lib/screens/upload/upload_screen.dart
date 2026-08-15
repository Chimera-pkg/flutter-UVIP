import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/widgets/uploaded_item_tile.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UploadProvider>(context, listen: false).fetchStreetPhotos();
    });
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (context.mounted) {
        final provider = Provider.of<UploadProvider>(context, listen: false);
        await provider.uploadPhoto(image);
      }
    }
  }

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
          if (provider.isLoading && provider.uploadedPhotos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dotted Dropzone
                GestureDetector(
                  onTap: provider.isUploading
                      ? null
                      : () => _pickAndUpload(context),
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: provider.isUploading
                          ? Colors.grey
                          : AppTheme.primaryColor,
                      strokeWidth: 2,
                      dashPattern: const [8, 4],
                      radius: const Radius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      decoration: BoxDecoration(
                        color: provider.isUploading
                            ? Colors.grey.withValues(alpha: 0.1)
                            : AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_rounded,
                            size: 64,
                            color: provider.isUploading
                                ? Colors.grey
                                : AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.isUploading
                                ? 'Uploading...'
                                : 'Upload your photo here',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.lightGray),
                          ),
                          if (!provider.isUploading) ...[
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
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Error Message
                if (provider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => provider.clearError(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Uploading Section
                if (provider.isUploading) ...[
                  Text(
                    'Uploading 1 image',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                  const SizedBox(height: 32),
                ],

                // Uploaded Section
                if (provider.uploadedPhotos.isNotEmpty) ...[
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
                    itemCount: provider.uploadedPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = provider.uploadedPhotos[index];
                      return UploadedItemTile(
                        fileName: photo.originalFilename,
                        fileSize: '${photo.fileSizeKb} KB',
                        imageUrl: photo.filePath,
                        isSelected: provider.selectedPhoto?.id == photo.id,
                        onSelect: (value) =>
                            provider.togglePhotoSelection(photo),
                        onDelete: () => provider.removeUploadedFile(index),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 48),

                // Analisa Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.selectedPhoto != null
                        ? () {
                            // Action for Analisa
                          }
                        : null,
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
