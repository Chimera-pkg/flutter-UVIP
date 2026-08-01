import 'package:flutter/material.dart';

class DetectedObject {
  final Rect rect;
  final String label;
  final double score;
  final Color color;

  DetectedObject({
    required this.rect,
    required this.label,
    required this.score,
    required this.color,
  });
}

class AiCamProvider with ChangeNotifier {
  // Live Scores
  final double liveUvi = 8.4;
  final double liveBeauty = 7.2;
  final double liveComfort = 6.9;
  final double liveSafety = 8.1;

  // Dummy Bounding Boxes (Simulating detected objects)
  final List<DetectedObject> detectedObjects = [
    DetectedObject(
      rect: const Rect.fromLTWH(50, 150, 120, 180),
      label: 'Building',
      score: 0.92,
      color: Colors.purpleAccent,
    ),
    DetectedObject(
      rect: const Rect.fromLTWH(200, 300, 140, 100),
      label: 'Vegetation',
      score: 0.88,
      color: Colors.greenAccent,
    ),
    DetectedObject(
      rect: const Rect.fromLTWH(180, 500, 150, 80),
      label: 'Road',
      score: 0.95,
      color: Colors.pinkAccent,
    ),
  ];
}
