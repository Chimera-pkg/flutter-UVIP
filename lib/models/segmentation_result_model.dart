import 'package:uvip/models/project_model.dart';

class LlmGenerateResponseModel {
  final String? generatedImageUrl;
  final List<String> generatedImageUrls;
  final List<String> generatedPaths;
  final String? rawImageUrl;
  final String? photoPath;
  final List<String> suggestions;
  final String? promptImage;
  final String? revisedPrompt;
  final String? imageModel;
  final String? size;
  final int? count;
  final int? elapsedMs;

  LlmGenerateResponseModel({
    this.generatedImageUrl,
    this.generatedImageUrls = const [],
    this.generatedPaths = const [],
    this.rawImageUrl,
    this.photoPath,
    this.suggestions = const [],
    this.promptImage,
    this.revisedPrompt,
    this.imageModel,
    this.size,
    this.count,
    this.elapsedMs,
  });

  factory LlmGenerateResponseModel.fromJson(Map<String, dynamic> json) {
    return LlmGenerateResponseModel(
      generatedImageUrl: json['generated_image_url']?.toString(),
      generatedImageUrls:
          (json['generated_image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      generatedPaths:
          (json['generated_paths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rawImageUrl: json['raw_image_url']?.toString(),
      photoPath: json['photo_path']?.toString(),
      suggestions:
          (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      promptImage: json['prompt_image']?.toString(),
      revisedPrompt: json['revised_prompt']?.toString(),
      imageModel: json['image_model']?.toString(),
      size: json['size']?.toString(),
      count: json['count'] is int ? json['count'] : null,
      elapsedMs: json['elapsed_ms'] is int ? json['elapsed_ms'] : null,
    );
  }
}

class LlmAdviceMasalahModel {
  final String area;
  final String temuan;
  final String? buktiAngka;
  final String? tingkat;

  LlmAdviceMasalahModel({
    required this.area,
    required this.temuan,
    this.buktiAngka,
    this.tingkat,
  });

  factory LlmAdviceMasalahModel.fromJson(Map<String, dynamic> json) {
    return LlmAdviceMasalahModel(
      area: json['area']?.toString() ?? '',
      temuan: json['temuan']?.toString() ?? '',
      buktiAngka: json['bukti_angka']?.toString(),
      tingkat: json['tingkat']?.toString(),
    );
  }
}

class LlmAdviceRekomendasiModel {
  final String peran;
  final String tindakan;
  final String? standar;
  final String? dampak;
  final int? prioritas;

  LlmAdviceRekomendasiModel({
    required this.peran,
    required this.tindakan,
    this.standar,
    this.dampak,
    this.prioritas,
  });

  factory LlmAdviceRekomendasiModel.fromJson(Map<String, dynamic> json) {
    return LlmAdviceRekomendasiModel(
      peran: json['peran']?.toString() ?? '',
      tindakan: json['tindakan']?.toString() ?? '',
      standar: json['standar']?.toString(),
      dampak: json['dampak']?.toString(),
      prioritas: json['prioritas'] is int ? json['prioritas'] : null,
    );
  }
}

class LlmAdviceModel {
  final String? diagnosis;
  final List<LlmAdviceMasalahModel> masalah;
  final List<LlmAdviceRekomendasiModel> rekomendasi;
  final String? promptGambar;
  final String? beforeAfter;
  final String? caveat;

  LlmAdviceModel({
    this.diagnosis,
    this.masalah = const [],
    this.rekomendasi = const [],
    this.promptGambar,
    this.beforeAfter,
    this.caveat,
  });

  factory LlmAdviceModel.fromJson(Map<String, dynamic> json) {
    return LlmAdviceModel(
      diagnosis: json['diagnosis']?.toString(),
      masalah:
          (json['masalah'] as List<dynamic>?)
              ?.map(
                (e) =>
                    LlmAdviceMasalahModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      rekomendasi:
          (json['rekomendasi'] as List<dynamic>?)
              ?.map(
                (e) => LlmAdviceRekomendasiModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      promptGambar: json['prompt_gambar']?.toString(),
      beforeAfter: json['before_after']?.toString(),
      caveat: json['caveat']?.toString(),
    );
  }
}

class LlmAdviceResponseModel {
  final String? id;
  final String? model;
  final LlmAdviceModel? advice;
  final String? answer;

  LlmAdviceResponseModel({this.id, this.model, this.advice, this.answer});

  factory LlmAdviceResponseModel.fromJson(Map<String, dynamic> json) {
    return LlmAdviceResponseModel(
      id: json['id']?.toString(),
      model: json['model']?.toString(),
      advice: json['advice'] != null
          ? LlmAdviceModel.fromJson(json['advice'] as Map<String, dynamic>)
          : null,
      answer: json['answer']?.toString(),
    );
  }
}

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
  final LlmGenerateResponseModel? llmGenerateResponse;

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
    this.llmGenerateResponse,
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
      llmGenerateResponse: json['llm_generate_response'] != null
          ? LlmGenerateResponseModel.fromJson(
              json['llm_generate_response'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class SegmentationResultModel {
  final String id;
  final String photoId;
  final String modelName;
  final String streetName;
  final num? vegetationPct;
  final num? buildingPct;
  final num? roadPct;
  final num? sidewalkPct;
  final num? skyPct;
  final num? signagePct;
  final num? vehiclePct;
  final num? pedestrianPct;
  final num? streetFurniturePct;
  final num? trafficSignPct;
  final num? other;
  final num? greenCoveragePct;
  final num? buildingCoveragePct;
  final num? skyVisibilityPct;
  final num? walkabilityRatio;
  final num? visualClutterIndex;
  final num? latitude;
  final num? longitude;
  final String? maskFilePath;
  final String? segmentationUrl;
  final String? privacyMaskedUrl;
  final String? segmentationOverlayUrl;
  final int? inferenceTimeMs;
  final String createdAt;
  final PredictionModel? prediction;
  final ProjectModel? project;
  final LlmAdviceResponseModel? llmAdviceResponse;

  SegmentationResultModel({
    required this.id,
    required this.photoId,
    required this.modelName,
    required this.streetName,
    this.latitude,
    this.longitude,
    this.vegetationPct,
    this.buildingPct,
    this.roadPct,
    this.sidewalkPct,
    this.skyPct,
    this.signagePct,
    this.vehiclePct,
    this.pedestrianPct,
    this.streetFurniturePct,
    this.trafficSignPct,
    this.other,
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
    this.project,
    this.llmAdviceResponse,
  });

  factory SegmentationResultModel.fromJson(Map<String, dynamic> json) {
    return SegmentationResultModel(
      id: json['id'] ?? '',
      photoId: json['photo_id'] ?? '',
      modelName: json['model_name'] ?? '',
      streetName: json['street_name'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      vegetationPct: json['vegetation_pct'],
      buildingPct: json['building_pct'],
      roadPct: json['road_pct'],
      sidewalkPct: json['sidewalk_pct'],
      skyPct: json['sky_pct'],
      signagePct: json['signage_pct'],
      vehiclePct: json['vehicle_pct'],
      pedestrianPct: json['pedestrian_pct'],
      streetFurniturePct: json['street_furniture_pct'],
      trafficSignPct: json['traffic_sign_pct'],
      other: json['other'],
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
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'])
          : null,
      llmAdviceResponse: json['llm_advice_response'] != null
          ? LlmAdviceResponseModel.fromJson(
              json['llm_advice_response'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
