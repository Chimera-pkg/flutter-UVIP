import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/auth_provider.dart';
import 'package:uvip/screens/aicam/aicam_screen.dart';
import 'package:uvip/screens/dashboard/home_screen.dart';
import 'package:uvip/screens/map/map_analysis_screen.dart';
import 'package:uvip/screens/profile/profile_screen.dart';
import 'package:uvip/screens/upload/upload_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // Track tab yang pernah dikunjungi — screen berat hanya dibuild saat pernah dipilih
  final Set<int> _visitedTabs = {0}; // Tab 0 (Home) langsung aktif

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        authProvider.fetchMe();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _visitedTabs.add(index);
      _selectedIndex = index;
    });
  }

  /// Membungkus child dalam IndexedStack: hanya build jika tab pernah dikunjungi.
  /// Ini mencegah screen berat (GoogleMap, Camera) langsung di-mount saat MainScreen dibuka.
  Widget _buildTabChild(int tabIndex, Widget child) {
    if (_visitedTabs.contains(tabIndex)) {
      return child;
    }
    // Placeholder ringan sebelum tab dikunjungi
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Stack(
      children: [
        Scaffold(
          // IndexedStack menjaga semua screen tetap hidup (tidak di-dispose),
          // tapi screen berat hanya di-build setelah tab pernah dikunjungi
          // untuk menghindari crash saat pertama kali masuk MainScreen.
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildTabChild(0, const HomeScreen(key: PageStorageKey('HomeScreen'))),
              _buildTabChild(1, const MapAnalysisScreen(key: PageStorageKey('MapAnalysisScreen'))),
              _buildTabChild(2, AiCamScreen(
                key: const PageStorageKey('AiCamScreen'),
                isActive: _selectedIndex == 2,
                onSwitchToUpload: () => _onItemTapped(3),
              )),
              _buildTabChild(3, const UploadScreen(key: PageStorageKey('UploadScreen'))),
              _buildTabChild(4, const ProfileScreen(key: PageStorageKey('ProfileScreen'))),
            ],
          ),
      floatingActionButton: Container(
        height: 72.0, // Make the FAB a bit larger
        width: 72.0,
        margin: const EdgeInsets.only(top: 20),
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(2),
            backgroundColor: _selectedIndex == 2
                ? AppTheme.primaryColor
                : Colors.white,
            elevation: 4.0,
            shape: const CircleBorder(),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: _selectedIndex == 2 ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left Side Tabs
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      label: 'Home',
                    ),
                    _buildTabItem(
                      index: 1,
                      icon: Icons.location_on_outlined,
                      label: 'Map',
                    ),
                  ],
                ),
              ),
              // Space for the floating action button
              const SizedBox(width: 48.0),
              // Right Side Tabs
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabItem(
                      index: 3,
                      icon: Icons.cloud_upload_outlined,
                      label: 'Upload',
                    ),
                    _buildTabItem(
                      index: 4,
                      icon: Icons.person_outline,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ), // closes SizedBox
      ), // closes BottomAppBar
    ), // closes Scaffold
    if (authProvider.isFetchingMe)
      Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? AppTheme.primaryColor
        : AppTheme.unselectedIconColor;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
