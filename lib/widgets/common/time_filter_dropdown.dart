import 'package:flutter/material.dart';

class TimeFilterDropdown extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const TimeFilterDropdown({
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            'Last 5 days',
            style: TextStyle(color: textColor ?? Colors.white70, fontSize: 10),
          ),
          Icon(Icons.arrow_drop_down, color: textColor ?? Colors.white70, size: 16),
        ],
      ),
    );
  }
}
