import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:uvip/models/segmentation_result_model.dart';

void main() {
  group('SegmentationResultModel Tests', () {
    test('Parses full JSON response correctly', () {
      const jsonString = '''
{
  "id": "f3a2f025-f5f0-4241-bfd7-bdf4b3d8ccd7",
  "photo_id": "1aafed4b-8f51-4c91-bd49-3c5bed17cf8c",
  "latitude": -7.9520135,
  "longitude": 112.5788028,
  "street_name": "Karangwidoro, Kabupaten Malang",
  "model_name": "AI-Pipeline-V1",
  "vegetation_pct": 24.21,
  "building_pct": 23.24,
  "road_pct": 3.3,
  "sidewalk_pct": 14.8,
  "sky_pct": 16,
  "signage_pct": 1.6,
  "vehicle_pct": 5.32,
  "pedestrian_pct": 0.2,
  "street_furniture_pct": 10.57,
  "traffic_sign_pct": 0,
  "other": 0.75,
  "green_coverage_pct": 24.21,
  "building_coverage_pct": 23.24,
  "sky_visibility_pct": 16,
  "walkability_ratio": 0.8174,
  "visual_clutter_index": 0.7579,
  "mask_file_path": null,
  "segmentation_url": "https://auctions-chemicals-latitude-typing.trycloudflare.com/uploads/segmentation/seg_a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb_1795439109635.jpg",
  "privacy_masked_url": "https://auctions-chemicals-latitude-typing.trycloudflare.com/uploads/masks/mask_a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb_1795439109635.jpg",
  "segmentation_overlay_url": "https://auctions-chemicals-latitude-typing.trycloudflare.com/uploads/segmentation/overlay_a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb_1795439109635.jpg",
  "inference_time_ms": null,
  "created_at": "2026-11-23T13:05:09.850293Z",
  "prediction": {
    "id": "7f1e41e8-c557-4610-82d3-aaa1283416f1",
    "photo_id": "1aafed4b-8f51-4c91-bd49-3c5bed17cf8c",
    "segmentation_id": "f3a2f025-f5f0-4241-bfd7-bdf4b3d8ccd7",
    "model_version": null,
    "beauty_score": 6.69,
    "safety_score": 6.34,
    "comfort_score": 7.86,
    "uvi_score": 0.69,
    "gvi_score": null,
    "inference_time_ms": null,
    "r2_reference": null,
    "created_at": "2026-11-23T13:05:09.850293Z",
    "llm_generate_response": {
      "generated_image_url": "/uploads/generated/img_a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb_1795439143649.png",
      "generated_image_urls": [
        "/uploads/generated/img_a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb_1795439143649.png"
      ],
      "generated_paths": [
        "uploads/generated/img_a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb_1795439143649.png"
      ],
      "raw_image_url": "/uploads/originals/a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb.jpg",
      "photo_path": "/uploads/originals/a63ef606-9cbe-4d96-9d60-3c16562f0a9c_47a66b4b-d680-4dd2-ad34-1f9b75d1f9fb.jpg",
      "target": {
        "perception_prediction": {
          "beauty_score": 6.69,
          "safety_score": 6.34,
          "comfort_score": 7.86,
          "uvi_score": 0.69
        },
        "segmentation_results": {
          "green_coverage_pct": 24.2133,
          "building_coverage_pct": 23.2448,
          "walkability_ratio": 0.8174,
          "visual_clutter_index": 0.7579,
          "sky_visibility_pct": 15.998
        }
      },
      "suggestions": [
        "Tingkatkan tutupan vegetasi",
        "Buka pandangan langit",
        "Nilai UVI saat ini 0.69"
      ],
      "prompt_image": "Redesign this street...",
      "revised_prompt": "Redesign this street...",
      "image_mode": "edit",
      "image_model": "gpt-image-2.5-flare-2026-09-08",
      "size": "1024x1024",
      "count": 1,
      "elapsed_ms": 14282,
      "generated_metrics": {
        "building_visibility_index": 0.2705,
        "vegetation_coverage_index": 0.3416,
        "sky_openness_index": 0.4062,
        "ground_accessibility_index": 0.3818,
        "human_activity_index": 0.0029,
        "vehicle_intensity_index": 0.0467,
        "traffic_infrastructure_index": 0.0798,
        "heritage_dominance_index": 0.4752
      },
      "generated_scores": {
        "beauty_score": 4.51,
        "safety_score": 5.34,
        "comfort_score": 9.3,
        "uvi_score": 0.62
      },
      "generated_overlay_url": "/uploads/segmentation/overlay_gen.png",
      "evaluation": {
        "before": {
          "indices": {
            "building_visibility_index": 0.3524,
            "vegetation_coverage_index": 0.3667,
            "sky_openness_index": 0.3074,
            "ground_accessibility_index": 0.3874,
            "human_activity_index": 0.002,
            "vehicle_intensity_index": 0.0532,
            "traffic_infrastructure_index": 0.1217,
            "heritage_dominance_index": 0.5378
          },
          "scores": {
            "beauty_score": 6.69,
            "safety_score": 6.34,
            "comfort_score": 7.86,
            "uvi_score": 0.69
          }
        },
        "after": {
          "indices": {
            "building_visibility_index": 0.2705,
            "vegetation_coverage_index": 0.3416,
            "sky_openness_index": 0.4062,
            "ground_accessibility_index": 0.3818,
            "human_activity_index": 0.0029,
            "vehicle_intensity_index": 0.0467,
            "traffic_infrastructure_index": 0.0798,
            "heritage_dominance_index": 0.4752
          },
          "scores": {
            "beauty_score": 4.51,
            "safety_score": 5.34,
            "comfort_score": 9.3,
            "uvi_score": 0.62
          }
        },
        "delta": {
          "building_visibility_index": {
            "before": 0.3524,
            "after": 0.2705,
            "diff": -0.0819,
            "percent_change": "-23.2%"
          }
        },
        "scores_delta": {
          "beauty_score": {
            "before": 6.69,
            "after": 4.51,
            "diff": -2.18,
            "formatted": "-2.18"
          }
        },
        "summary": {
          "vegetation_change": "-6.8%",
          "ground_access_change": "-1.4%",
          "vehicle_intensity_change": "-12.2%",
          "sky_openness_change": "+32.1%",
          "uvi_score_change": "-0.07"
        },
        "elapsed_ms": 475
      },
      "usage": null
    }
  },
  "project": {
    "name": "Sekitar Grand Citihub",
    "location": "Basuki Rahmat",
    "description": "Kajoetangan",
    "id": "95c3a615-bdb5-4f0d-b689-e109709214b1",
    "created_by": "a5fe0096-c979-42fa-9de7-8fa713c7c0f4",
    "last_opened_at": null,
    "created_at": "2026-11-23T12:58:12.854978Z"
  },
  "llm_advice_response": {
    "id": "596e82c4-348d-461f-9aab-9dc7659c3b9e",
    "object": "chat.completion",
    "created": 1795439128,
    "model": "deepseek-flash",
    "requested_model": "deepseek-flash",
    "choices": [
      {
        "index": 0,
        "message": {
          "role": "assistant",
          "content": "test",
          "reasoning_content": "test"
        },
        "finish_reason": "stop"
      }
    ],
    "advice": {
      "diagnosis": "Ruang ini tampak...",
      "masalah": [
        {
          "area": "trotoar",
          "temuan": "Bangku...",
          "bukti_angka": "jalur bebas < 1 m",
          "tingkat": "tinggi"
        }
      ],
      "rekomendasi": [
        {
          "peran": "umum",
          "tindakan": "Susun ulang...",
          "standar": "Permen PUPR",
          "dampak": "memulihkan...",
          "prioritas": 1
        }
      ],
      "prompt_gambar": "Urban...",
      "before_after": "Dari...",
      "caveat": "Analisa..."
    },
    "answer": "test",
    "context": {
      "upstream": "https://api.deepseek.com/v1",
      "model": "deepseek-flash",
      "elapsed_ms": 17951
    },
    "usage": {
      "prompt_tokens": 1320,
      "completion_tokens": 1716,
      "total_tokens": 3036
    }
  }
}
''';

      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      final model = SegmentationResultModel.fromJson(parsed);

      expect(model.id, 'f3a2f025-f5f0-4241-bfd7-bdf4b3d8ccd7');
      expect(model.photoId, '1aafed4b-8f51-4c91-bd49-3c5bed17cf8c');
      expect(model.latitude, -7.9520135);
      expect(model.longitude, 112.5788028);
      expect(model.streetName, 'Karangwidoro, Kabupaten Malang');
      expect(model.modelName, 'AI-Pipeline-V1');
      expect(model.vegetationPct, 24.21);
      expect(model.skyPct, 16);
      expect(model.visualClutterIndex, 0.7579);
      expect(model.maskFilePath, isNull);

      // Prediction
      expect(model.prediction, isNotNull);
      expect(model.prediction!.beautyScore, 6.69);
      expect(model.prediction!.safetyScore, 6.34);
      expect(model.prediction!.comfortScore, 7.86);
      expect(model.prediction!.uviScore, 0.69);

      // LLM Generate Response
      final gen = model.prediction!.llmGenerateResponse;
      expect(gen, isNotNull);
      expect(gen!.generatedImageUrl, startsWith('/uploads/generated/'));
      expect(gen.generatedImageUrls.length, 1);
      expect(gen.generatedPaths.length, 1);
      expect(gen.imageMode, 'edit');
      expect(gen.imageModel, 'gpt-image-2.5-flare-2026-09-08');
      expect(gen.size, '1024x1024');
      expect(gen.count, 1);
      expect(gen.elapsedMs, 14282);

      // Target
      expect(gen.target, isNotNull);
      expect(gen.target!.perceptionPrediction?.uviScore, 0.69);
      expect(gen.target!.segmentationResults?.greenCoveragePct, 24.2133);

      // Generated Metrics & Scores
      expect(gen.generatedMetrics?.buildingVisibilityIndex, 0.2705);
      expect(gen.generatedScores?.beautyScore, 4.51);
      expect(gen.generatedScores?.comfortScore, 9.3);

      // Evaluation
      expect(gen.evaluation, isNotNull);
      expect(gen.evaluation!.before?.scores?.beautyScore, 6.69);
      expect(gen.evaluation!.after?.scores?.beautyScore, 4.51);
      expect(gen.evaluation!.delta['building_visibility_index']?.percentChange, '-23.2%');
      expect(gen.evaluation!.scoresDelta['beauty_score']?.formatted, '-2.18');
      expect(gen.evaluation!.summary?.vegetationChange, '-6.8%');
      expect(gen.evaluation!.summary?.uviScoreChange, '-0.07');

      // Project
      expect(model.project, isNotNull);
      expect(model.project!.name, 'Sekitar Grand Citihub');

      // LLM Advice Response
      final adviceResp = model.llmAdviceResponse;
      expect(adviceResp, isNotNull);
      expect(adviceResp!.id, '596e82c4-348d-461f-9aab-9dc7659c3b9e');
      expect(adviceResp.object, 'chat.completion');
      expect(adviceResp.created, 1795439128);
      expect(adviceResp.model, 'deepseek-flash');
      expect(adviceResp.choices.length, 1);
      expect(adviceResp.choices.first.message?.role, 'assistant');
      expect(adviceResp.advice?.masalah.length, 1);
      expect(adviceResp.advice?.masalah.first.area, 'trotoar');
      expect(adviceResp.advice?.rekomendasi.length, 1);
      expect(adviceResp.advice?.rekomendasi.first.prioritas, 1);

      // Serialization test
      final toJson = model.toJson();
      expect(toJson['id'], model.id);
      expect(toJson['prediction']['uvi_score'], 0.69);
    });
  });
}
