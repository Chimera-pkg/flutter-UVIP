import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uvip/core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    String? locationName;
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locality = place.subLocality?.isNotEmpty == true
            ? place.subLocality!
            : (place.locality ?? '');
        String city = place.subAdministrativeArea?.isNotEmpty == true
            ? place.subAdministrativeArea!
            : (place.administrativeArea ?? '');

        if (locality.isNotEmpty && city.isNotEmpty) {
          locationName = '$locality, $city';
        } else if (locality.isNotEmpty) {
          locationName = locality;
        } else if (city.isNotEmpty) {
          locationName = city;
        } else {
          locationName = place.country ?? 'Unknown Location';
        }
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }

    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      Provider.of<MapProvider>(context, listen: false).updateCoordinates(
        position.latitude,
        position.longitude,
        locName: locationName,
      );
      _mapController.move(_currentLocation!, 15.0);
    }
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
                              initialZoom: 13.0,
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
                              if (_currentLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _currentLocation!,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.my_location,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Overlay Buttons (Top Right)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Column(
                              children: [
                                _buildFloatingMapButton(Icons.layers_outlined),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    if (_currentLocation != null) {
                                      _mapController.move(
                                        _currentLocation!,
                                        15.0,
                                      );
                                    } else {
                                      _mapController.move(
                                        LatLng(
                                          provider.latitude,
                                          provider.longitude,
                                        ),
                                        13.0,
                                      );
                                      _determinePosition();
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
                                        'UVI Tinggi',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        'UVI Rendah',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SummaryCard(
                            icon: Icons.verified_user_rounded, // Shield approx
                            iconColor: Colors.white,
                            iconBgColor: Colors.lightGreen,
                            title: 'Safety Score',
                            score: homeProvider.safetyScore,
                            status: homeProvider.safetyStatus,
                            statusColor: homeProvider.safetyStatusColor,
                          ),
                          SummaryCard(
                            icon: Icons.star_rounded, // Star approx
                            iconColor: Colors.white,
                            iconBgColor: Colors.pinkAccent.shade100,
                            title: 'Beauty Score',
                            score: homeProvider.beautyScore,
                            status: homeProvider.beautyStatus,
                            statusColor: homeProvider.beautyStatusColor,
                          ),
                          SummaryCard(
                            icon: Icons.cloud_rounded, // Cloud approx
                            iconColor: Colors.white,
                            iconBgColor: Colors.orange.shade300,
                            title: 'Comfort Score',
                            score: homeProvider.comfortScore,
                            status: homeProvider.comfortStatus,
                            statusColor: homeProvider.comfortStatusColor,
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
