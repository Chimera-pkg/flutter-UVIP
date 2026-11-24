import 'package:uvip/models/project_model.dart';

class LlmGenerateTargetPerceptionModel {
  final num? beautyScore;
  final num? safetyScore;
  final num? comfortScore;
  final num? uviScore;

  LlmGenerateTargetPerceptionModel({
    this.beautyScore,
    this.safetyScore,
    this.comfortScore,
    this.uviScore,
  });

  factory LlmGenerateTargetPerceptionModel.fromJson(Map<String, dynamic> json) {
    return LlmGenerateTargetPerceptionModel(
      beautyScore: json['beauty_score'] as num?,
      safetyScore: json['safety_score'] as num?,
      comfortScore: json['comfort_score'] as num?,
      uviScore: json['uvi_score'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
    'beauty_score': beautyScore,
    'safety_score': safetyScore,
    'comfort_score': comfortScore,
    'uvi_score': uviScore,
  };
}

class LlmGenerateTargetSegmentationModel {
  final num? greenCoveragePct;
  final num? buildingCoveragePct;
  final num? walkabilityRatio;
  final num? visualClutterIndex;
  final num? skyVisibilityPct;

  LlmGenerateTargetSegmentationModel({
    this.greenCoveragePct,
    this.buildingCoveragePct,
    this.walkabilityRatio,
    this.visualClutterIndex,
    this.skyVisibilityPct,
  });

  factory LlmGenerateTargetSegmentationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LlmGenerateTargetSegmentationModel(
      greenCoveragePct: json['green_coverage_pct'] as num?,
      buildingCoveragePct: json['building_coverage_pct'] as num?,
      walkabilityRatio: json['walkability_ratio'] as num?,
      visualClutterIndex: json['visual_clutter_index'] as num?,
      skyVisibilityPct: json['sky_visibility_pct'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
    'green_coverage_pct': greenCoveragePct,
    'building_coverage_pct': buildingCoveragePct,
    'walkability_ratio': walkabilityRatio,
    'visual_clutter_index': visualClutterIndex,
    'sky_visibility_pct': skyVisibilityPct,
  };
}

class LlmGenerateTargetModel {
  final LlmGenerateTargetPerceptionModel? perceptionPrediction;
  final LlmGenerateTargetSegmentationModel? segmentationResults;

  LlmGenerateTargetModel({
    this.perceptionPrediction,
    this.segmentationResults,
  });

  factory LlmGenerateTargetModel.fromJson(Map<String, dynamic> json) {
    return LlmGenerateTargetModel(
      perceptionPrediction: json['perception_prediction'] != null
          ? LlmGenerateTargetPerceptionModel.fromJson(
              json['perception_prediction'] as Map<String, dynamic>,
            )
          : null,
      segmentationResults: json['segmentation_results'] != null
          ? LlmGenerateTargetSegmentationModel.fromJson(
              json['segmentation_results'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'perception_prediction': perceptionPrediction?.toJson(),
    'segmentation_results': segmentationResults?.toJson(),
  };
}

class LlmIndicesModel {
  final num? buildingVisibilityIndex;
  final num? vegetationCoverageIndex;
  final num? skyOpennessIndex;
  final num? groundAccessibilityIndex;
  final num? humanActivityIndex;
  final num? vehicleIntensityIndex;
  final num? trafficInfrastructureIndex;
  final num? heritageDominanceIndex;

  LlmIndicesModel({
    this.buildingVisibilityIndex,
    this.vegetationCoverageIndex,
    this.skyOpennessIndex,
    this.groundAccessibilityIndex,
    this.humanActivityIndex,
    this.vehicleIntensityIndex,
    this.trafficInfrastructureIndex,
    this.heritageDominanceIndex,
  });

  factory LlmIndicesModel.fromJson(Map<String, dynamic> json) {
    return LlmIndicesModel(
      buildingVisibilityIndex: json['building_visibility_index'] as num?,
      vegetationCoverageIndex: json['vegetation_coverage_index'] as num?,
      skyOpennessIndex: json['sky_openness_index'] as num?,
      groundAccessibilityIndex: json['ground_accessibility_index'] as num?,
      humanActivityIndex: json['human_activity_index'] as num?,
      vehicleIntensityIndex: json['vehicle_intensity_index'] as num?,
      trafficInfrastructureIndex:
          json['traffic_infrastructure_index'] as num?,
      heritageDominanceIndex: json['heritage_dominance_index'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
    'building_visibility_index': buildingVisibilityIndex,
    'vegetation_coverage_index': vegetationCoverageIndex,
    'sky_openness_index': skyOpennessIndex,
    'ground_accessibility_index': groundAccessibilityIndex,
    'human_activity_index': humanActivityIndex,
    'vehicle_intensity_index': vehicleIntensityIndex,
    'traffic_infrastructure_index': trafficInfrastructureIndex,
    'heritage_dominance_index': heritageDominanceIndex,
  };
}

class LlmScoresModel {
  final num? beautyScore;
  final num? safetyScore;
  final num? comfortScore;
  final num? uviScore;

  LlmScoresModel({
    this.beautyScore,
    this.safetyScore,
    this.comfortScore,
    this.uviScore,
  });

  factory LlmScoresModel.fromJson(Map<String, dynamic> json) {
    return LlmScoresModel(
      beautyScore: json['beauty_score'] as num?,
      safetyScore: json['safety_score'] as num?,
      comfortScore: json['comfort_score'] as num?,
      uviScore: json['uvi_score'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
    'beauty_score': beautyScore,
    'safety_score': safetyScore,
    'comfort_score': comfortScore,
    'uvi_score': uviScore,
  };
}

class LlmEvaluationStateModel {
  final LlmIndicesModel? indices;
  final LlmScoresModel? scores;

  LlmEvaluationStateModel({this.indices, this.scores});

  factory LlmEvaluationStateModel.fromJson(Map<String, dynamic> json) {
    return LlmEvaluationStateModel(
      indices: json['indices'] != null
          ? LlmIndicesModel.fromJson(json['indices'] as Map<String, dynamic>)
          : null,
      scores: json['scores'] != null
          ? LlmScoresModel.fromJson(json['scores'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'indices': indices?.toJson(),
    'scores': scores?.toJson(),
  };
}

class LlmEvaluationDeltaItemModel {
  final num? before;
  final num? after;
  final num? diff;
  final String? percentChange;

  LlmEvaluationDeltaItemModel({
    this.before,
    this.after,
    this.diff,
    this.percentChange,
  });

  factory LlmEvaluationDeltaItemModel.fromJson(Map<String, dynamic> json) {
    return LlmEvaluationDeltaItemModel(
      before: json['before'] as num?,
      after: json['after'] as num?,
      diff: json['diff'] as num?,
      percentChange: json['percent_change']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'before': before,
    'after': after,
    'diff': diff,
    'percent_change': percentChange,
  };
}

class LlmEvaluationScoreDeltaItemModel {
  final num? before;
  final num? after;
  final num? diff;
  final String? formatted;

  LlmEvaluationScoreDeltaItemModel({
    this.before,
    this.after,
    this.diff,
    this.formatted,
  });

  factory LlmEvaluationScoreDeltaItemModel.fromJson(Map<String, dynamic> json) {
    return LlmEvaluationScoreDeltaItemModel(
      before: json['before'] as num?,
      after: json['after'] as num?,
      diff: json['diff'] as num?,
      formatted: json['formatted']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'before': before,
    'after': after,
    'diff': diff,
    'formatted': formatted,
  };
}

class LlmEvaluationSummaryModel {
  final String? vegetationChange;
  final String? groundAccessChange;
  final String? vehicleIntensityChange;
  final String? skyOpennessChange;
  final String? uviScoreChange;

  LlmEvaluationSummaryModel({
    this.vegetationChange,
    this.groundAccessChange,
    this.vehicleIntensityChange,
    this.skyOpennessChange,
    this.uviScoreChange,
  });

  factory LlmEvaluationSummaryModel.fromJson(Map<String, dynamic> json) {
    return LlmEvaluationSummaryModel(
      vegetationChange: json['vegetation_change']?.toString(),
      groundAccessChange: json['ground_access_change']?.toString(),
      vehicleIntensityChange: json['vehicle_intensity_change']?.toString(),
      skyOpennessChange: json['sky_openness_change']?.toString(),
      uviScoreChange: json['uvi_score_change']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'vegetation_change': vegetationChange,
    'ground_access_change': groundAccessChange,
    'vehicle_intensity_change': vehicleIntensityChange,
    'sky_openness_change': skyOpennessChange,
    'uvi_score_change': uviScoreChange,
  };
}

class LlmGenerateEvaluationModel {
  final LlmEvaluationStateModel? before;
  final LlmEvaluationStateModel? after;
  final Map<String, LlmEvaluationDeltaItemModel> delta;
  final Map<String, LlmEvaluationScoreDeltaItemModel> scoresDelta;
  final LlmEvaluationSummaryModel? summary;
  final int? elapsedMs;

  LlmGenerateEvaluationModel({
    this.before,
    this.after,
    this.delta = const {},
    this.scoresDelta = const {},
    this.summary,
    this.elapsedMs,
  });

  factory LlmGenerateEvaluationModel.fromJson(Map<String, dynamic> json) {
    final rawDelta = json['delta'] as Map<String, dynamic>?;
    final Map<String, LlmEvaluationDeltaItemModel> parsedDelta = {};
    if (rawDelta != null) {
      rawDelta.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          parsedDelta[k] = LlmEvaluationDeltaItemModel.fromJson(v);
        }
      });
    }

    final rawScoresDelta = json['scores_delta'] as Map<String, dynamic>?;
    final Map<String, LlmEvaluationScoreDeltaItemModel> parsedScoresDelta = {};
    if (rawScoresDelta != null) {
      rawScoresDelta.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          parsedScoresDelta[k] = LlmEvaluationScoreDeltaItemModel.fromJson(v);
        }
      });
    }

    return LlmGenerateEvaluationModel(
      before: json['before'] != null
          ? LlmEvaluationStateModel.fromJson(
              json['before'] as Map<String, dynamic>,
            )
          : null,
      after: json['after'] != null
          ? LlmEvaluationStateModel.fromJson(
              json['after'] as Map<String, dynamic>,
            )
          : null,
      delta: parsedDelta,
      scoresDelta: parsedScoresDelta,
      summary: json['summary'] != null
          ? LlmEvaluationSummaryModel.fromJson(
              json['summary'] as Map<String, dynamic>,
            )
          : null,
      elapsedMs: (json['elapsed_ms'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'before': before?.toJson(),
    'after': after?.toJson(),
    'delta': delta.map((k, v) => MapEntry(k, v.toJson())),
    'scores_delta': scoresDelta.map((k, v) => MapEntry(k, v.toJson())),
    'summary': summary?.toJson(),
    'elapsed_ms': elapsedMs,
  };
}

class LlmGenerateResponseModel {
  final String? generatedImageUrl;
  final List<String> generatedImageUrls;
  final List<String> generatedPaths;
  final String? rawImageUrl;
  final String? photoPath;
  final LlmGenerateTargetModel? target;
  final List<String> suggestions;
  final String? promptImage;
  final String? revisedPrompt;
  final String? imageMode;
  final String? imageModel;
  final String? size;
  final int? count;
  final int? elapsedMs;
  final LlmIndicesModel? generatedMetrics;
  final LlmScoresModel? generatedScores;
  final String? generatedOverlayUrl;
  final LlmGenerateEvaluationModel? evaluation;
  final dynamic usage;

  LlmGenerateResponseModel({
    this.generatedImageUrl,
    this.generatedImageUrls = const [],
    this.generatedPaths = const [],
    this.rawImageUrl,
    this.photoPath,
    this.target,
    this.suggestions = const [],
    this.promptImage,
    this.revisedPrompt,
    this.imageMode,
    this.imageModel,
    this.size,
    this.count,
    this.elapsedMs,
    this.generatedMetrics,
    this.generatedScores,
    this.generatedOverlayUrl,
    this.evaluation,
    this.usage,
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
      target: json['target'] != null
          ? LlmGenerateTargetModel.fromJson(
              json['target'] as Map<String, dynamic>,
            )
          : null,
      suggestions:
          (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      promptImage: json['prompt_image']?.toString(),
      revisedPrompt: json['revised_prompt']?.toString(),
      imageMode: json['image_mode']?.toString(),
      imageModel: json['image_model']?.toString(),
      size: json['size']?.toString(),
      count: (json['count'] as num?)?.toInt(),
      elapsedMs: (json['elapsed_ms'] as num?)?.toInt(),
      generatedMetrics: json['generated_metrics'] != null
          ? LlmIndicesModel.fromJson(
              json['generated_metrics'] as Map<String, dynamic>,
            )
          : null,
      generatedScores: json['generated_scores'] != null
          ? LlmScoresModel.fromJson(
              json['generated_scores'] as Map<String, dynamic>,
            )
          : null,
      generatedOverlayUrl: json['generated_overlay_url']?.toString(),
      evaluation: json['evaluation'] != null
          ? LlmGenerateEvaluationModel.fromJson(
              json['evaluation'] as Map<String, dynamic>,
            )
          : null,
      usage: json['usage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'generated_image_url': generatedImageUrl,
    'generated_image_urls': generatedImageUrls,
    'generated_paths': generatedPaths,
    'raw_image_url': rawImageUrl,
    'photo_path': photoPath,
    'target': target?.toJson(),
    'suggestions': suggestions,
    'prompt_image': promptImage,
    'revised_prompt': revisedPrompt,
    'image_mode': imageMode,
    'image_model': imageModel,
    'size': size,
    'count': count,
    'elapsed_ms': elapsedMs,
    'generated_metrics': generatedMetrics?.toJson(),
    'generated_scores': generatedScores?.toJson(),
    'generated_overlay_url': generatedOverlayUrl,
    'evaluation': evaluation?.toJson(),
    'usage': usage,
  };
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

  Map<String, dynamic> toJson() => {
    'area': area,
    'temuan': temuan,
    'bukti_angka': buktiAngka,
    'tingkat': tingkat,
  };
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
      prioritas: (json['prioritas'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'peran': peran,
    'tindakan': tindakan,
    'standar': standar,
    'dampak': dampak,
    'prioritas': prioritas,
  };
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

  Map<String, dynamic> toJson() => {
    'diagnosis': diagnosis,
    'masalah': masalah.map((e) => e.toJson()).toList(),
    'rekomendasi': rekomendasi.map((e) => e.toJson()).toList(),
    'prompt_gambar': promptGambar,
    'before_after': beforeAfter,
    'caveat': caveat,
  };
}

class LlmAdviceChoiceMessageModel {
  final String? role;
  final String? content;
  final String? reasoningContent;

  LlmAdviceChoiceMessageModel({
    this.role,
    this.content,
    this.reasoningContent,
  });

  factory LlmAdviceChoiceMessageModel.fromJson(Map<String, dynamic> json) {
    return LlmAdviceChoiceMessageModel(
      role: json['role']?.toString(),
      content: json['content']?.toString(),
      reasoningContent: json['reasoning_content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'reasoning_content': reasoningContent,
  };
}

class LlmAdviceChoiceModel {
  final int? index;
  final LlmAdviceChoiceMessageModel? message;
  final String? finishReason;

  LlmAdviceChoiceModel({this.index, this.message, this.finishReason});

  factory LlmAdviceChoiceModel.fromJson(Map<String, dynamic> json) {
    return LlmAdviceChoiceModel(
      index: (json['index'] as num?)?.toInt(),
      message: json['message'] != null
          ? LlmAdviceChoiceMessageModel.fromJson(
              json['message'] as Map<String, dynamic>,
            )
          : null,
      finishReason: json['finish_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'message': message?.toJson(),
    'finish_reason': finishReason,
  };
}

class LlmAdviceResponseModel {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final String? requestedModel;
  final List<LlmAdviceChoiceModel> choices;
  final LlmAdviceModel? advice;
  final String? answer;
  final Map<String, dynamic>? context;
  final Map<String, dynamic>? usage;

  LlmAdviceResponseModel({
    this.id,
    this.object,
    this.created,
    this.model,
    this.requestedModel,
    this.choices = const [],
    this.advice,
    this.answer,
    this.context,
    this.usage,
  });

  factory LlmAdviceResponseModel.fromJson(Map<String, dynamic> json) {
    return LlmAdviceResponseModel(
      id: json['id']?.toString(),
      object: json['object']?.toString(),
      created: (json['created'] as num?)?.toInt(),
      model: json['model']?.toString(),
      requestedModel: json['requested_model']?.toString(),
      choices:
          (json['choices'] as List<dynamic>?)
              ?.map(
                (e) =>
                    LlmAdviceChoiceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      advice: json['advice'] != null
          ? LlmAdviceModel.fromJson(json['advice'] as Map<String, dynamic>)
          : null,
      answer: json['answer']?.toString(),
      context: json['context'] as Map<String, dynamic>?,
      usage: json['usage'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created': created,
    'model': model,
    'requested_model': requestedModel,
    'choices': choices.map((e) => e.toJson()).toList(),
    'advice': advice?.toJson(),
    'answer': answer,
    'context': context,
    'usage': usage,
  };
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
      id: json['id']?.toString() ?? '',
      photoId: json['photo_id']?.toString() ?? '',
      segmentationId: json['segmentation_id']?.toString() ?? '',
      modelVersion: json['model_version']?.toString(),
      beautyScore: json['beauty_score'] as num?,
      safetyScore: json['safety_score'] as num?,
      comfortScore: json['comfort_score'] as num?,
      uviScore: json['uvi_score'] as num?,
      gviScore: json['gvi_score'] as num?,
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toInt(),
      r2Reference: json['r2_reference']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      llmGenerateResponse: json['llm_generate_response'] != null
          ? LlmGenerateResponseModel.fromJson(
              json['llm_generate_response'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo_id': photoId,
    'segmentation_id': segmentationId,
    'model_version': modelVersion,
    'beauty_score': beautyScore,
    'safety_score': safetyScore,
    'comfort_score': comfortScore,
    'uvi_score': uviScore,
    'gvi_score': gviScore,
    'inference_time_ms': inferenceTimeMs,
    'r2_reference': r2Reference,
    'created_at': createdAt,
    'llm_generate_response': llmGenerateResponse?.toJson(),
  };
}

class SegmentationResultModel {
  final String id;
  final String photoId;
  final num? latitude;
  final num? longitude;
  final String streetName;
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
  final num? trafficSignPct;
  final num? other;
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
      id: json['id']?.toString() ?? '',
      photoId: json['photo_id']?.toString() ?? '',
      latitude: json['latitude'] as num?,
      longitude: json['longitude'] as num?,
      streetName: json['street_name']?.toString() ?? '',
      modelName: json['model_name']?.toString() ?? '',
      vegetationPct: json['vegetation_pct'] as num?,
      buildingPct: json['building_pct'] as num?,
      roadPct: json['road_pct'] as num?,
      sidewalkPct: json['sidewalk_pct'] as num?,
      skyPct: json['sky_pct'] as num?,
      signagePct: json['signage_pct'] as num?,
      vehiclePct: json['vehicle_pct'] as num?,
      pedestrianPct: json['pedestrian_pct'] as num?,
      streetFurniturePct: json['street_furniture_pct'] as num?,
      trafficSignPct: json['traffic_sign_pct'] as num?,
      other: json['other'] as num?,
      greenCoveragePct: json['green_coverage_pct'] as num?,
      buildingCoveragePct: json['building_coverage_pct'] as num?,
      skyVisibilityPct: json['sky_visibility_pct'] as num?,
      walkabilityRatio: json['walkability_ratio'] as num?,
      visualClutterIndex: json['visual_clutter_index'] as num?,
      maskFilePath: json['mask_file_path']?.toString(),
      segmentationUrl: json['segmentation_url']?.toString(),
      privacyMaskedUrl: json['privacy_masked_url']?.toString(),
      segmentationOverlayUrl: json['segmentation_overlay_url']?.toString(),
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toInt(),
      createdAt: json['created_at']?.toString() ?? '',
      prediction: json['prediction'] != null
          ? PredictionModel.fromJson(json['prediction'] as Map<String, dynamic>)
          : null,
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      llmAdviceResponse: json['llm_advice_response'] != null
          ? LlmAdviceResponseModel.fromJson(
              json['llm_advice_response'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo_id': photoId,
    'latitude': latitude,
    'longitude': longitude,
    'street_name': streetName,
    'model_name': modelName,
    'vegetation_pct': vegetationPct,
    'building_pct': buildingPct,
    'road_pct': roadPct,
    'sidewalk_pct': sidewalkPct,
    'sky_pct': skyPct,
    'signage_pct': signagePct,
    'vehicle_pct': vehiclePct,
    'pedestrian_pct': pedestrianPct,
    'street_furniture_pct': streetFurniturePct,
    'traffic_sign_pct': trafficSignPct,
    'other': other,
    'green_coverage_pct': greenCoveragePct,
    'building_coverage_pct': buildingCoveragePct,
    'sky_visibility_pct': skyVisibilityPct,
    'walkability_ratio': walkabilityRatio,
    'visual_clutter_index': visualClutterIndex,
    'mask_file_path': maskFilePath,
    'segmentation_url': segmentationUrl,
    'privacy_masked_url': privacyMaskedUrl,
    'segmentation_overlay_url': segmentationOverlayUrl,
    'inference_time_ms': inferenceTimeMs,
    'created_at': createdAt,
    'prediction': prediction?.toJson(),
    'project': project?.toJson(),
    'llm_advice_response': llmAdviceResponse?.toJson(),
  };
}
