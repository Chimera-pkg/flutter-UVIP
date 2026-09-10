class PredictionModel {
  final String id;
  final String photoId;
  final String segmentationId;
  final String? modelVersion;
  final num? beautyScore;
  final num? safetyScore;
  final num? comfortScore;
  final num? uviScore;
  final num? gviScore;
  final int? inferenceTimeMs;
  final String? r2Reference;
  final String createdAt;

  PredictionModel({
    required this.id,
    required this.photoId,
    required this.segmentationId,
    this.modelVersion,
    this.beautyScore,
    this.safetyScore,
    this.comfortScore,
    this.uviScore,
    this.gviScore,
    this.inferenceTimeMs,
    this.r2Reference,
    required this.createdAt,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      id: json['id'] ?? '',
      photoId: json['photo_id'] ?? '',
      segmentationId: json['segmentation_id'] ?? '',
      modelVersion: json['model_version'],
      beautyScore: json['beauty_score'],
      safetyScore: json['safety_score'],
      comfortScore: json['comfort_score'],
      uviScore: json['uvi_score'],
      gviScore: json['gvi_score'],
      inferenceTimeMs: json['inference_time_ms'],
      r2Reference: json['r2_reference'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class SegmentationResultModel {
  final String id;
  final String photoId;
  final String modelName;
  final num? vegetationPct;
  final num? buildingPct;
  final num? roadPct;
  final num? sidewalkPct;
  final num? skyPct;
  final num? signagePct;
  final num? vehiclePct;
  final num? pedestrianPct;
  final num? streetFurniturePct;
  final num? greenCoveragePct;
  final num? buildingCoveragePct;
  final num? skyVisibilityPct;
  final num? walkabilityRatio;
  final num? visualClutterIndex;
  final String? maskFilePath;
  final String? segmentationUrl;
  final String? privacyMaskedUrl;
  final String? segmentationOverlayUrl;
  final int? inferenceTimeMs;
  final String createdAt;
  final PredictionModel? prediction;

  SegmentationResultModel({
    required this.id,
    required this.photoId,
    required this.modelName,
    this.vegetationPct,
    this.buildingPct,
    this.roadPct,
    this.sidewalkPct,
    this.skyPct,
    this.signagePct,
    this.vehiclePct,
    this.pedestrianPct,
    this.streetFurniturePct,
    this.greenCoveragePct,
    this.buildingCoveragePct,
    this.skyVisibilityPct,
    this.walkabilityRatio,
    this.visualClutterIndex,
    this.maskFilePath,
    this.segmentationUrl,
    this.privacyMaskedUrl,
    this.segmentationOverlayUrl,
    this.inferenceTimeMs,
    required this.createdAt,
    this.prediction,
  });

  factory SegmentationResultModel.fromJson(Map<String, dynamic> json) {
    return SegmentationResultModel(
      id: json['id'] ?? '',
      photoId: json['photo_id'] ?? '',
      modelName: json['model_name'] ?? '',
      vegetationPct: json['vegetation_pct'],
      buildingPct: json['building_pct'],
      roadPct: json['road_pct'],
      sidewalkPct: json['sidewalk_pct'],
      skyPct: json['sky_pct'],
      signagePct: json['signage_pct'],
      vehiclePct: json['vehicle_pct'],
      pedestrianPct: json['pedestrian_pct'],
      streetFurniturePct: json['street_furniture_pct'],
      greenCoveragePct: json['green_coverage_pct'],
      buildingCoveragePct: json['building_coverage_pct'],
      skyVisibilityPct: json['sky_visibility_pct'],
      walkabilityRatio: json['walkability_ratio'],
      visualClutterIndex: json['visual_clutter_index'],
      maskFilePath: json['mask_file_path'],
      segmentationUrl: json['segmentation_url'],
      privacyMaskedUrl: json['privacy_masked_url'],
      segmentationOverlayUrl: json['segmentation_overlay_url'],
      inferenceTimeMs: json['inference_time_ms'],
      createdAt: json['created_at'] ?? '',
      prediction: json['prediction'] != null
          ? PredictionModel.fromJson(json['prediction'])
          : null,
    );
  }
}
