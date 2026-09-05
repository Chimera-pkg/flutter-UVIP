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
    );
  }
}
