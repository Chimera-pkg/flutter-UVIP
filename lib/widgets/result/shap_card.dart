import 'package:flutter/material.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/result_provider.dart';

class ShapCard extends StatelessWidget {
  final bool isPositive;
  final List<ShapFactor> factors;

  const ShapCard({super.key, required this.isPositive, required this.factors});

  @override
  Widget build(BuildContext context) {
    final Color headerColor =
        isPositive ? AppTheme.primaryColor : const Color(0xFFE53935);
    final Color accentColor =
        isPositive ? AppTheme.primaryColor : const Color(0xFFE53935);
    final String title = isPositive ? 'Faktor Positif' : 'Faktor Negatif';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15.0),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Factors List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: factors.map((factor) {
                final double absVal = factor.value.abs();
                final double progressVal = (absVal / 100).clamp(0.0, 1.0);
                final String valString =
                    absVal < 1 && absVal > 0
                        ? '${absVal.toStringAsFixed(2)}%'
                        : '${absVal.toStringAsFixed(1)}%';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon
                      Icon(factor.icon, color: accentColor, size: 22),
                      const SizedBox(width: 12),
                      // Name & Progress Bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              factor.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: LinearProgressIndicator(
                                value: progressVal,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Value Text
                      Text(
                        valString,
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
