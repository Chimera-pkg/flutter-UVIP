import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/map_provider.dart';
import 'package:uvip/widgets/data_summary_card.dart';
import 'package:uvip/widgets/common/section_header.dart';
import 'package:uvip/widgets/common/time_filter_dropdown.dart';
class MapAnalysisScreen extends StatefulWidget {
  const MapAnalysisScreen({super.key});

  @override
  State<MapAnalysisScreen> createState() => _MapAnalysisScreenState();
}

class _MapAnalysisScreenState extends State<MapAnalysisScreen> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Peta Analisis',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<MapProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    children: provider.filters.map((filter) {
                      final isSelected = provider.selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) provider.setFilter(filter);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryColor, // Teal background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                            ),
                          ),
                          avatar: isSelected
                              ? const Icon(Icons.eco, color: Colors.white, size: 18) // Leaf icon for UVI
                              : const Icon(Icons.eco_outlined, color: Colors.grey, size: 18),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Map Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: SizedBox(
                      height: 350,
                      child: Stack(
                        children: [
                          GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(provider.latitude, provider.longitude),
                              zoom: 13.0,
                            ),
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                          // Overlay Buttons (Top Right)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Column(
                              children: [
                                _buildFloatingMapButton(Icons.layers_outlined),
                                const SizedBox(height: 8),
                                _buildFloatingMapButton(Icons.my_location),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text('UVI Tinggi', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                      Text('UVI Rendah', style: TextStyle(fontSize: 10, color: Colors.black54)),
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
                          const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Klojen, Malang',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Summary Cards Row
                      Row(
                        children: [
                          DataSummaryCard(
                            title: 'Rata-rata UVI',
                            value: provider.rataRataUvi,
                            subtitle: 'Baik',
                            subtitleColor: Colors.lightGreen,
                          ),
                          const SizedBox(width: 8),
                          DataSummaryCard(
                            title: 'Survei Points',
                            value: provider.surveyPoints,
                            subtitle: 'Pts',
                            subtitleColor: Colors.pinkAccent,
                          ),
                          const SizedBox(width: 8),
                          DataSummaryCard(
                            title: 'Luas Area',
                            value: provider.luasArea,
                            subtitle: 'Km2',
                            subtitleColor: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Chart Card
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Rata-Rata UVI', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          provider.rataRataUvi,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '+16%',
                                          style: TextStyle(
                                            color: Colors.lightGreen,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const TimeFilterDropdown(
                                  backgroundColor: AppTheme.secondaryColor,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Area Chart
                            SizedBox(
                              height: 100,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 2,
                                    getDrawingHorizontalLine: (value) {
                                      return const FlLine(
                                        color: Colors.black12,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 2,
                                        reservedSize: 20,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(color: Colors.black54, fontSize: 8),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 18,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
                                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                days[value.toInt()],
                                                style: const TextStyle(color: Colors.black54, fontSize: 8),
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
                                  minY: 2,
                                  maxY: 8,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: provider.chartData
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                                          .toList(),
                                      isCurved: false,
                                      color: AppTheme.primaryColor,
                                      barWidth: 2,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: AppTheme.primaryColor,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryColor.withValues(alpha: 0.3),
                                            AppTheme.primaryColor.withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (touchedSpot) => Colors.white,
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((spot) {
                                          return LineTooltipItem(
                                            spot.y.toString(),
                                            const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.black87),
    );
  }
}
