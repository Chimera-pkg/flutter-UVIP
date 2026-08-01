import 'package:flutter/material.dart';
import 'package:uvip/core/theme/app_theme.dart';
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

  // We use PageStorageBucket to keep state of all pages
  final PageStorageBucket _bucket = PageStorageBucket();

  // List of screens for the bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey('HomeScreen')),
    const MapAnalysisScreen(key: PageStorageKey('MapAnalysisScreen')),
    const AiCamScreen(key: PageStorageKey('AiCamScreen')),
    const UploadScreen(key: PageStorageKey('UploadScreen')),
    const ProfileScreen(key: PageStorageKey('ProfileScreen')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _screens[_selectedIndex]),
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
        ),
      ),
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
