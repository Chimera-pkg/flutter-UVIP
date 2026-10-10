import 'package:uvip/models/project_model.dart';
import 'package:uvip/models/segmentation_result_model.dart';

class VideoSegmentationResultModel {
  final String id;
  final String photoId;
  final String videoUrl;
  final num? fps;
  final num? frameCount;
  final num? width;
  final num? height;
  final num? durationSeconds;
  final num? framesProcessed;
  final num? processingTimeMs;
  final String createdAt;
  final SegmentationResultModel? segmentation;
  final PredictionModel? prediction;
  final ProjectModel? project;

  VideoSegmentationResultModel({
    required this.id,
    required this.photoId,
    required this.videoUrl,
    this.fps,
    this.frameCount,
    this.width,
    this.height,
    this.durationSeconds,
    this.framesProcessed,
    this.processingTimeMs,
    required this.createdAt,
    this.segmentation,
    this.prediction,
    this.project,
  });

  factory VideoSegmentationResultModel.fromJson(Map<String, dynamic> json) {
    return VideoSegmentationResultModel(
      id: json['id'] ?? '',
      photoId: json['photo_id'] ?? '',
      videoUrl: json['video_url'] ?? '',
      fps: json['fps'],
      frameCount: json['frame_count'],
      width: json['width'],
      height: json['height'],
      durationSeconds: json['duration_seconds'],
      framesProcessed: json['frames_processed'],
      processingTimeMs: json['processing_time_ms'],
      createdAt: json['created_at'] ?? '',
      segmentation: json['segmentation'] != null
          ? SegmentationResultModel.fromJson(json['segmentation'])
          : null,
      prediction: json['prediction'] != null
          ? PredictionModel.fromJson(json['prediction'])
          : null,
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'])
          : null,
    );
  }
}
