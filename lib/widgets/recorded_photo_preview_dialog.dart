import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/project_provider.dart';

class RecordedPhotoPreviewDialog extends StatefulWidget {
  final XFile photoFile;
  final Future<void> Function(String projectId) onConfirmUpload;
  final VoidCallback? onCancel;

  const RecordedPhotoPreviewDialog({
    super.key,
    required this.photoFile,
    required this.onConfirmUpload,
    this.onCancel,
  });

  @override
  State<RecordedPhotoPreviewDialog> createState() =>
      _RecordedPhotoPreviewDialogState();
}

class _RecordedPhotoPreviewDialogState
    extends State<RecordedPhotoPreviewDialog> {
  bool _isUploading = false;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
    });
  }

  Future<void> _handleConfirm() async {
    if (_isUploading) return;
    
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih project terlebih dahulu'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await widget.onConfirmUpload(_selectedProjectId!);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint("Error confirming upload: $e");
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _handleCancel() {
    if (_isUploading) return;
    widget.onCancel?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxDialogHeight = screenSize.height * 0.88;
    final maxDialogWidth =
        screenSize.width > 640 ? 600.0 : screenSize.width * 0.94;

    return PopScope(
      canPop: !_isUploading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDialogWidth,
              maxHeight: maxDialogHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.black87,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Hasil Tangkapan Foto',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!_isUploading)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _handleCancel,
                            ),
                        ],
                      ),
                    ),

                    // Photo Content Body (Flexible)
                    Flexible(
                      child: Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: kIsWeb
                            ? Image.network(
                                widget.photoFile.path,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                File(widget.photoFile.path),
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),

                    // Project Selection Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: const Color(0xFF1E1E1E),
                      child: Consumer<ProjectProvider>(
                        builder: (context, projectProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedProjectId,
                            decoration: InputDecoration(
                              labelText: 'Pilih Project *',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black45,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                            dropdownColor: const Color(0xFF2E2E2E),
                            style: const TextStyle(color: Colors.white),
                            items: projectProvider.projects.map((project) {
                              return DropdownMenuItem<String>(
                                value: project.id,
                                child: Text(project.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProjectId = value;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    // Action Buttons (Ulangi & Upload)
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      color: const Color(0xFF1E1E1E),
                      child: Row(
                        children: [
                          // Button Ulangi / Batal
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: _isUploading ? null : _handleCancel,
                              icon: const Icon(
                                Icons.replay_rounded,
                                size: 18,
                                color: Colors.white70,
                              ),
                              label: const Text(
                                'Ulangi',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Button Simpan & Upload
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _handleConfirm,
                              icon: _isUploading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                _isUploading ? 'Menyimpan...' : 'Upload Foto',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
