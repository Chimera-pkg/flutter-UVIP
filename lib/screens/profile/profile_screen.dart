import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/profile_provider.dart';
import 'package:uvip/providers/auth_provider.dart';
import 'package:uvip/screens/auth/login_screen.dart';
import 'package:uvip/widgets/profile_info_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).fetchMe();
      }
    });
  }

  String _resolveUrl(String path) {
    String fullUrl = path.replaceAll('\\', '/');
    if (!fullUrl.startsWith('http')) {
      const baseUrl = 'http://80.241.214.39';
      fullUrl =
          '$baseUrl/${fullUrl.startsWith('/') ? fullUrl.substring(1) : fullUrl}';
    }
    return fullUrl;
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Ubah Foto Profil',
                  style: Theme.of(
                    bottomSheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto langsung dari kamera'),
                onTap: () =>
                    Navigator.pop(bottomSheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih foto dari galeri HP'),
                onTap: () =>
                    Navigator.pop(bottomSheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return;
      if (!context.mounted) return;

      final success = await authProvider.updateAvatar(pickedFile.path);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Gagal memperbarui foto profil',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAvatar(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    final profilePath = user?.profileFilePath;
    final hasAvatar = profilePath != null && profilePath.trim().isNotEmpty;
    final avatarUrl = hasAvatar ? _resolveUrl(profilePath) : '';

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: authProvider.isUpdatingAvatar
                ? null
                : () => _pickAndUploadImage(context, authProvider),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: AppTheme.darkGray,
                child: hasAvatar
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          key: ValueKey(avatarUrl),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              ),
                        ),
                      )
                    : const Icon(Icons.person, size: 70, color: Colors.white),
              ),
            ),
          ),
          if (authProvider.isUpdatingAvatar)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 2,
            right: 4,
            child: GestureDetector(
              onTap: authProvider.isUpdatingAvatar
                  ? null
                  : () => _pickAndUploadImage(context, authProvider),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

          return RefreshIndicator(
            onRefresh: () => authProvider.fetchMe(),
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Circular Avatar with edit button and user icon fallback
                  _buildAvatar(context, authProvider),
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
                    icon: Icons.person_outline, // Teal icon on the left
                    label: 'Username',
                    value: user?.name ?? '-',
                  ),
                  ProfileInfoTile(
                    icon: Icons.mail_outline, // Teal icon on the left
                    label: 'Email',
                    value: user?.email ?? '-',
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Apakah Anda yakin ingin logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
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
                  const SizedBox(height: 20), // padding for the bottom nav bar
                  //version in bottom
                  Text(
                    'Versi 1.0.0',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.darkGray),
                  ),
                  const SizedBox(height: 100), // padding for the bottom nav bar
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
