import 'package:flutter/material.dart';

/// [AiCamProvider] mengelola data terkait kamera AI (*Live Camera*).
class AiCamProvider with ChangeNotifier {
  // ─── Live Scores ───
  final double liveUvi = 8.4;
  final double liveBeauty = 7.2;
  final double liveComfort = 6.9;
  final double liveSafety = 8.1;
}
