import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/models/street_photo_location_model.dart';
import 'package:uvip/models/street_photo_model.dart';
import 'package:uvip/models/street_video_model.dart';
import 'package:uvip/screens/result/result_screen.dart';
import 'package:uvip/providers/map_provider.dart';
import 'package:uvip/providers/home_provider.dart';
import 'package:uvip/widgets/summary_card.dart';
import 'package:uvip/widgets/common/section_header.dart';
import 'package:uvip/widgets/common/time_filter_dropdown.dart';

class MapAnalysisScreen extends StatefulWidget {
  const MapAnalysisScreen({super.key});

  @override
  State<MapAnalysisScreen> createState() => _MapAnalysisScreenState();
}

class _MapAnalysisScreenState extends State<MapAnalysisScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);

      // Hit API street-photos/locations
      mapProvider.fetchPhotoLocations().then((_) {
        if (!mounted) return;
        // Jika lokasi user belum ada dan terdapat titik foto, pusatkan ke titik foto pertama
        if (!mapProvider.isLocationLoaded &&
            _currentLocation == null &&
            mapProvider.photoLocations.isNotEmpty) {
          final first = mapProvider.photoLocations.first;
          _mapController.move(LatLng(first.latitude, first.longitude), 14.0);
        }
      });

      if (mapProvider.isLocationLoaded) {
        setState(() {
          _currentLocation = LatLng(
            mapProvider.latitude,
            mapProvider.longitude,
          );
        });
        _mapController.move(_currentLocation!, 15.0);
      } else {
        mapProvider.determinePosition().then((_) {
          if (mounted && mapProvider.isLocationLoaded) {
            setState(() {
              _currentLocation = LatLng(
                mapProvider.latitude,
                mapProvider.longitude,
              );
            });
            _mapController.move(_currentLocation!, 15.0);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Peta Analisis',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Consumer2<MapProvider, HomeProvider>(
        builder: (context, provider, homeProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: SizedBox(
                      height: 350,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(
                                provider.latitude,
                                provider.longitude,
                              ),
                              initialZoom: provider.isLocationLoaded
                                  ? 15.0
                                  : 13.0,
                              onPositionChanged: (camera, hasGesture) {
                                if ((camera.zoom - _currentZoom).abs() > 0.05) {
                                  setState(() {
                                    _currentZoom = camera.zoom;
                                  });
                                }
                              },
                              interactionOptions: const InteractionOptions(
                                flags:
                                    InteractiveFlag.all &
                                    ~InteractiveFlag.rotate,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.uvip',
                              ),
                              MarkerLayer(
                                markers: [
                                  // User Current Location Marker
                                  if (_currentLocation != null ||
                                      provider.isLocationLoaded)
                                    Marker(
                                      point:
                                          _currentLocation ??
                                          LatLng(
                                            provider.latitude,
                                            provider.longitude,
                                          ),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.my_location,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                    ),
                                  // Street Photo Location Markers (berjejer saat zoom)
                                  ..._buildLocationMarkers(
                                    provider.photoLocations,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Loading indicator overlay (Top Left)
                          if (provider.isLoadingLocations)
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Memuat titik...',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Overlay Buttons (Top Right)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final mapProvider =
                                        Provider.of<MapProvider>(
                                          context,
                                          listen: false,
                                        );
                                    mapProvider.fetchPhotoLocations().then((_) {
                                      if (mounted &&
                                          mapProvider.photoLocations.isNotEmpty) {
                                        final points = mapProvider.photoLocations
                                            .map(
                                              (e) => LatLng(
                                                e.latitude,
                                                e.longitude,
                                              ),
                                            )
                                            .toList();
                                        if (_currentLocation != null) {
                                          points.add(_currentLocation!);
                                        }
                                        _mapController.fitCamera(
                                          CameraFit.bounds(
                                            bounds: LatLngBounds.fromPoints(
                                              points,
                                            ),
                                            padding: const EdgeInsets.all(32),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  child: _buildFloatingMapButton(
                                    Icons.refresh_rounded,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    final mapProvider =
                                        Provider.of<MapProvider>(
                                          context,
                                          listen: false,
                                        );
                                    if (mapProvider.isLocationLoaded) {
                                      _currentLocation = LatLng(
                                        mapProvider.latitude,
                                        mapProvider.longitude,
                                      );
                                      _mapController.move(
                                        _currentLocation!,
                                        15.0,
                                      );
                                    } else {
                                      mapProvider.determinePosition().then((_) {
                                        if (mounted &&
                                            mapProvider.isLocationLoaded) {
                                          setState(() {
                                            _currentLocation = LatLng(
                                              mapProvider.latitude,
                                              mapProvider.longitude,
                                            );
                                          });
                                          _mapController.move(
                                            _currentLocation!,
                                            15.0,
                                          );
                                        }
                                      });
                                    }
                                  },
                                  child: _buildFloatingMapButton(
                                    Icons.my_location,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Legend Overlay (Bottom)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.lightGreen,
                                          Colors.yellow,
                                          Colors.orange,
                                          Colors.red,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        'PVI Tinggi',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        'PVI Rendah',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Selected Area Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Ringkasan Area Terpilih'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.locationName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Summary Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              icon:
                                  Icons.verified_user_rounded, // Shield approx
                              iconColor: Colors.white,
                              iconBgColor: Colors.lightGreen,
                              title: 'Safety Score',
                              score: homeProvider.safetyScore,
                              status: homeProvider.safetyStatus,
                              statusColor: homeProvider.safetyStatusColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              icon: Icons.star_rounded, // Star approx
                              iconColor: Colors.white,
                              iconBgColor: Colors.pinkAccent.shade100,
                              title: 'Beauty Score',
                              score: homeProvider.beautyScore,
                              status: homeProvider.beautyStatus,
                              statusColor: homeProvider.beautyStatusColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              icon: Icons.cloud_rounded, // Cloud approx
                              iconColor: Colors.white,
                              iconBgColor: Colors.orange.shade300,
                              title: 'Comfort Score',
                              score: homeProvider.comfortScore,
                              status: homeProvider.comfortStatus,
                              statusColor: homeProvider.comfortStatusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Chart Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(
                            alpha: 0.9,
                          ), // Dark teal
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Survei',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${homeProvider.totalSurvei}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '+16%',
                                          style: TextStyle(
                                            color: Colors.yellowAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const TimeFilterDropdown(),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Chart Area
                            SizedBox(
                              height: 150,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 50,
                                    getDrawingHorizontalLine: (value) {
                                      return const FlLine(
                                        color: Colors.white24,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 50,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 22,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          final days = [
                                            'Monday',
                                            'Tuesday',
                                            'Wednesday',
                                            'Thursday',
                                            'Friday',
                                          ];
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < days.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                days[value.toInt()],
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: 4,
                                  minY: 0,
                                  maxY: 150,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: homeProvider.chartData
                                          .asMap()
                                          .entries
                                          .map(
                                            (e) => FlSpot(
                                              e.key.toDouble(),
                                              e.value,
                                            ),
                                          )
                                          .toList(),
                                      isCurved: false,
                                      color: Colors.yellowAccent,
                                      barWidth: 2,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.yellowAccent.withValues(
                                              alpha: 0.3,
                                            ),
                                            Colors.yellowAccent.withValues(
                                              alpha: 0.0,
                                            ),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (touchedSpot) =>
                                          Colors.black87,
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((spot) {
                                          return LineTooltipItem(
                                            spot.y.toString(),
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
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
                const SizedBox(height: 100), // padding for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }

  List<Marker> _buildLocationMarkers(List<StreetPhotoLocationModel> locations) {
    if (locations.isEmpty) return [];

    // Kelompokkan titik lokasi dengan koordinat yang sama persis atau sangat berdekatan (~1.1 meter)
    final Map<String, List<StreetPhotoLocationModel>> groups = {};
    for (final loc in locations) {
      final key =
          '${loc.latitude.toStringAsFixed(5)}_${loc.longitude.toStringAsFixed(5)}';
      groups.putIfAbsent(key, () => []).add(loc);
    }

    // Faktor pelebaran berdasarkan tingkat zoom:
    // Zoom < 15.0: tetap menyatu dalam 1 titik (spreadFactor = 0)
    // Zoom 15.0 s/d 16.5: melebar secara halus dan berjejer (spreadFactor 0.0 -> 1.0)
    double spreadFactor = 0.0;
    if (_currentZoom >= 15.0) {
      spreadFactor = ((_currentZoom - 15.0) / 1.5).clamp(0.0, 1.0);
    }

    // Konversi pixel jarak layar ke derajat bujur (longitude) pada tingkat zoom saat ini
    final double degreesPerPixel = 360.0 / (256.0 * math.pow(2, _currentZoom));
    const double spacingPixels = 30.0; // Jarak antar pusat titik (diameter 28px + gap 2px)

    final List<Marker> markers = [];

    for (final group in groups.values) {
      final int count = group.length;

      for (int i = 0; i < count; i++) {
        final loc = group[i];

        // Pergeseran horizontal simetris agar titik-titik berjejer rapi
        double offsetPixels = 0.0;
        if (count > 1) {
          offsetPixels = (i - (count - 1) / 2.0) * spacingPixels;
        }

        final double deltaLng = (offsetPixels * spreadFactor) * degreesPerPixel;
        final LatLng markerPoint = LatLng(
          loc.latitude,
          loc.longitude + deltaLng,
        );
        final Color markerColor = loc.markerColor;
        final bool isStacked = count > 1 && spreadFactor < 0.3;

        markers.add(
          Marker(
            point: markerPoint,
            width: 28,
            height: 28,
            child: GestureDetector(
              onTap: () {
                if (isStacked) {
                  // Jika masih menyatu saat di-tap, langsung zoom in agar berjejer
                  _mapController.move(
                    LatLng(loc.latitude, loc.longitude),
                    16.5,
                  );
                } else {
                  _showLocationDetail(loc);
                }
              },
              child: Tooltip(
                message:
                    '${loc.originalFilename}\nUVI: ${loc.uviScore != null ? loc.uviScore!.toStringAsFixed(2) : "-"}${count > 1 && isStacked ? ' ($count data)' : ''}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: markerColor.withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: markerColor,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: (isStacked && i == count - 1)
                        ? Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _showLocationDetail(StreetPhotoLocationModel loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: loc.markerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        loc.isVideo
                            ? Icons.videocam_rounded
                            : Icons.photo_camera_rounded,
                        color: loc.markerColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.originalFilename,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.streetName ??
                                '${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: loc.markerColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        loc.uviCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'UVI Score:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      loc.uviScore != null
                          ? loc.uviScore!.toStringAsFixed(2)
                          : 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: loc.markerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Koordinat:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (loc.isVideo) {
                        final video = StreetVideoModel(
                          id: loc.id,
                          missionId: '',
                          uploadedBy: '',
                          source: '',
                          originalFilename: loc.originalFilename,
                          filePath: '',
                          fileSizeKb: 0,
                          latitude: loc.latitude,
                          longitude: loc.longitude,
                          streetName: loc.streetName,
                          gpsAccuracyM: 0,
                          compassAzimuth: 0,
                          isManualCapture: false,
                          isOfflineSync: false,
                          privacyMasked: false,
                          processingStatus: '',
                          errorMessage: '',
                          capturedAt: '',
                          createdAt: '',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ResultScreen(video: video, isVideo: true),
                          ),
                        );
                      } else {
                        final photo = StreetPhotoModel(
                          id: loc.id,
                          missionId: '',
                          uploadedBy: '',
                          source: '',
                          originalFilename: loc.originalFilename,
                          filePath: '',
                          fileSizeKb: 0,
                          latitude: loc.latitude,
                          longitude: loc.longitude,
                          streetName: loc.streetName,
                          gpsAccuracyM: 0,
                          compassAzimuth: 0,
                          exifTimestamp: '',
                          isManualCapture: false,
                          isOfflineSync: false,
                          privacyMasked: false,
                          processingStatus: '',
                          errorMessage: '',
                          capturedAt: '',
                          createdAt: '',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultScreen(photo: photo),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Lihat Analisis Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingMapButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.black87),
    );
  }
}
