import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String score;
  final String status;
  final Color? statusColor;
  final double? width;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.score,
    required this.status,
    this.statusColor,
    this.width,
  });

  static Color getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'sangat rendah':
        return const Color(0xFFC62828);
      case 'rendah':
        return const Color(0xFFE53935);
      case 'cenderung rendah':
        return const Color(0xFFFF7043);
      case 'sedang':
        return const Color(0xFFFFA000);
      case 'cenderung tinggi':
        return const Color(0xFF4CAF50);
      case 'tinggi':
        return const Color(0xFF00BFA5);
      case 'sangat tinggi':
        return const Color(0xFF02BDDB);
      default:
        return const Color(0xFF02BDDB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = statusColor ?? getStatusColor(status);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 28,
            child: Center(
              child: Text(
                status,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
