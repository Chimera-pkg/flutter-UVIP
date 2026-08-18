import 'package:flutter/material.dart';
import 'package:uvip/providers/result_provider.dart';

class ShapCard extends StatelessWidget {
  final bool isPositive;
  final List<ShapFactor> factors;

  const ShapCard({
    super.key,
    required this.isPositive,
    required this.factors,
  });

  @override
  Widget build(BuildContext context) {
    final Color headerColor = isPositive ? Colors.teal.shade100 : Colors.red.shade100;
    final Color textColor = isPositive ? Colors.teal.shade700 : Colors.red.shade700;
    final String title = isPositive ? 'Faktor Positif' : 'Faktor Negatif';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11.0)),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
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
                final String valString = factor.value > 0
                    ? '+ ${factor.value.abs()}'
                    : '- ${factor.value.abs()}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      // Name
                      Expanded(
                        flex: 3,
                        child: Text(
                          factor.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Value Text
                      SizedBox(
                        width: 45,
                        child: Text(
                          valString,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Progress Bar Indicator
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: LinearProgressIndicator(
                            value: factor.value.abs(),
                            minHeight: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          ),
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
