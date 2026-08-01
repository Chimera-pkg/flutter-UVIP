import 'package:flutter/material.dart';

class ObjectDetectorBox extends StatelessWidget {
  final Rect rect;
  final String label;
  final double score;
  final Color color;

  const ObjectDetectorBox({
    super.key,
    required this.rect,
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bounding Box
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
              color: color.withValues(alpha: 0.1), // Slight tint inside
            ),
          ),
          // Label above the box
          Positioned(
            left: -3,
            top: -24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
              ),
              child: Text(
                '$label ${(score * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
