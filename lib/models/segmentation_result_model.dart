class SegmentationResultModel {
  final String id;
  final String photoId;
  final String modelName;
  final num vegetationPct;
  final num buildingPct;
  final num roadPct;
  final num sidewalkPct;
  final num skyPct;
  final num signagePct;
  final num vehiclePct;
  final num pedestrianPct;
  final num streetFurniturePct;
  final num greenCoveragePct;
  final num buildingCoveragePct;
  final num skyVisibilityPct;
  final num walkabilityRatio;
  final num visualClutterIndex;
  final String maskFilePath;
  final int inferenceTimeMs;
  final String createdAt;

  SegmentationResultModel({
    required this.id,
    required this.photoId,
    required this.modelName,
    required this.vegetationPct,
    required this.buildingPct,
    required this.roadPct,
    required this.sidewalkPct,
    required this.skyPct,
    required this.signagePct,
    required this.vehiclePct,
    required this.pedestrianPct,
    required this.streetFurniturePct,
    required this.greenCoveragePct,
    required this.buildingCoveragePct,
    required this.skyVisibilityPct,
    required this.walkabilityRatio,
    required this.visualClutterIndex,
    required this.maskFilePath,
    required this.inferenceTimeMs,
    required this.createdAt,
  });

  factory SegmentationResultModel.fromJson(Map<String, dynamic> json) {
    return SegmentationResultModel(
      id: json['id'] ?? '',
      photoId: json['photo_id'] ?? '',
      modelName: json['model_name'] ?? '',
      vegetationPct: json['vegetation_pct'] ?? 0.0,
      buildingPct: json['building_pct'] ?? 0.0,
      roadPct: json['road_pct'] ?? 0.0,
      sidewalkPct: json['sidewalk_pct'] ?? 0.0,
      skyPct: json['sky_pct'] ?? 0.0,
      signagePct: json['signage_pct'] ?? 0.0,
      vehiclePct: json['vehicle_pct'] ?? 0.0,
      pedestrianPct: json['pedestrian_pct'] ?? 0.0,
      streetFurniturePct: json['street_furniture_pct'] ?? 0.0,
      greenCoveragePct: json['green_coverage_pct'] ?? 0.0,
      buildingCoveragePct: json['building_coverage_pct'] ?? 0.0,
      skyVisibilityPct: json['sky_visibility_pct'] ?? 0.0,
      walkabilityRatio: json['walkability_ratio'] ?? 0.0,
      visualClutterIndex: json['visual_clutter_index'] ?? 0.0,
      maskFilePath: json['mask_file_path'] ?? '',
      inferenceTimeMs: json['inference_time_ms'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
