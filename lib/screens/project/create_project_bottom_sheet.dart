import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/models/project_model.dart';
import 'package:uvip/providers/project_provider.dart';

/// Modal bottom sheet untuk membuat proyek baru sesuai desain terkini.
Future<ProjectModel?> showCreateProjectBottomSheet(BuildContext context) {
  return showModalBottomSheet<ProjectModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateProjectBottomSheet(),
  );
}

class CreateProjectBottomSheet extends StatefulWidget {
  const CreateProjectBottomSheet({super.key});

  @override
  State<CreateProjectBottomSheet> createState() =>
      _CreateProjectBottomSheetState();
}

class _CreateProjectBottomSheetState extends State<CreateProjectBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _locationController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );

    final newProject = await projectProvider.createProject(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (newProject != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, newProject);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            projectProvider.errorMessage ?? 'Gagal membuat project',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEnabled = _isValid && !_isSubmitting;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Judul & Tombol Tutup (X)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Buat Proyek Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF0F172A),
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Field 1: Nama Proyek
              _buildFieldLabel(
                icon: Icons.folder_outlined,
                label: 'Nama Proyek *',
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'Masukkan nama proyek',
              ),
              const SizedBox(height: 18),

              // Field 2: Lokasi
              _buildFieldLabel(
                icon: Icons.location_on_outlined,
                label: 'Lokasi *',
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _locationController,
                hintText: 'Masukkan lokasi proyek',
              ),
              const SizedBox(height: 18),

              // Field 3: Deskripsi
              _buildFieldLabel(
                icon: Icons.article_outlined,
                label: 'Deskripsi *',
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Masukkan deskripsi proyek',
                minLines: 4,
                maxLines: 5,
              ),
              const SizedBox(height: 28),

              // Tombol Submit
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isEnabled ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled
                        ? AppTheme.primaryColor
                        : const Color(0xFFF1F5F9),
                    foregroundColor: isEnabled
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                    disabledBackgroundColor: const Color(0xFFF1F5F9),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Buat Proyek Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isEnabled
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F172A)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
