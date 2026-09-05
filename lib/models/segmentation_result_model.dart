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
    );
  }
}
