class StreetPhotoModel {
  final String id;
  final String missionId;
  final String uploadedBy;
  final String source;
  final String originalFilename;
  final String filePath;
  final num fileSizeKb;
  final num latitude;
  final num longitude;
  final num gpsAccuracyM;
  final num compassAzimuth;
  final String exifTimestamp;
  final bool isManualCapture;
  final bool isOfflineSync;
  final bool privacyMasked;
  final String processingStatus;
  final String errorMessage;
  final String capturedAt;
  final String createdAt;
  final String? projectId;

  StreetPhotoModel({
    required this.id,
    required this.missionId,
    required this.uploadedBy,
    required this.source,
    required this.originalFilename,
    required this.filePath,
    required this.fileSizeKb,
    required this.latitude,
    required this.longitude,
    required this.gpsAccuracyM,
    required this.compassAzimuth,
    required this.exifTimestamp,
    required this.isManualCapture,
    required this.isOfflineSync,
    required this.privacyMasked,
    required this.processingStatus,
    required this.errorMessage,
    required this.capturedAt,
    required this.createdAt,
    this.projectId,
  });

  factory StreetPhotoModel.fromJson(Map<String, dynamic> json) {
    return StreetPhotoModel(
      id: json['id'] ?? '',
      missionId: json['mission_id'] ?? '',
      uploadedBy: json['uploaded_by'] ?? '',
      source: json['source'] ?? '',
      originalFilename: json['original_filename'] ?? '',
      filePath: json['file_path'] ?? '',
      fileSizeKb: json['file_size_kb'] ?? 0,
      latitude: json['latitude'] ?? 0,
      longitude: json['longitude'] ?? 0,
      gpsAccuracyM: json['gps_accuracy_m'] ?? 0,
      compassAzimuth: json['compass_azimuth'] ?? 0,
      exifTimestamp: json['exif_timestamp'] ?? '',
      isManualCapture: json['is_manual_capture'] ?? false,
      isOfflineSync: json['is_offline_sync'] ?? false,
      privacyMasked: json['privacy_masked'] ?? false,
      processingStatus: json['processing_status'] ?? '',
      errorMessage: json['error_message'] ?? '',
      capturedAt: json['captured_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      projectId: json['project_id']?.toString(),
    );
  }
}
