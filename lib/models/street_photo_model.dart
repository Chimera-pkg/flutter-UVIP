import 'package:uvip/models/project_model.dart';
import 'package:uvip/models/segmentation_result_model.dart';

class StreetPhotoUploaderModel {
  final String id;
  final String name;
  final String email;
  final String? profileFilePath;

  StreetPhotoUploaderModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileFilePath,
  });

  factory StreetPhotoUploaderModel.fromJson(Map<String, dynamic> json) {
    return StreetPhotoUploaderModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileFilePath: json['profile_file_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_file_path': profileFilePath,
    };
  }
}

class StreetPhotoModel {
  final String id;
  final String? projectId;
  final String? missionId;
  final String uploadedBy;
  final StreetPhotoUploaderModel? uploader;
  final String source;
  final String originalFilename;
  final String filePath;
  final num fileSizeKb;
  final num latitude;
  final num longitude;
  final String? streetName;
  final num? gpsAccuracyM;
  final num? compassAzimuth;
  final String? exifTimestamp;
  final bool isManualCapture;
  final bool isOfflineSync;
  final bool privacyMasked;
  final String processingStatus;
  final String? errorMessage;
  final PredictionModel? prediction;
  final ProjectModel? project;
  final String capturedAt;
  final String createdAt;

  StreetPhotoModel({
    required this.id,
    this.projectId,
    this.missionId,
    required this.uploadedBy,
    this.uploader,
    required this.source,
    required this.originalFilename,
    required this.filePath,
    required this.fileSizeKb,
    required this.latitude,
    required this.longitude,
    this.streetName,
    this.gpsAccuracyM,
    this.compassAzimuth,
    this.exifTimestamp,
    this.isManualCapture = false,
    this.isOfflineSync = false,
    this.privacyMasked = false,
    required this.processingStatus,
    this.errorMessage,
    this.prediction,
    this.project,
    required this.capturedAt,
    required this.createdAt,
  });

  factory StreetPhotoModel.fromJson(Map<String, dynamic> json) {
    return StreetPhotoModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      missionId: json['mission_id']?.toString(),
      uploadedBy: json['uploaded_by']?.toString() ?? '',
      uploader: json['uploader'] != null && json['uploader'] is Map
          ? StreetPhotoUploaderModel.fromJson(
              Map<String, dynamic>.from(json['uploader'] as Map),
            )
          : null,
      source: json['source']?.toString() ?? '',
      originalFilename: json['original_filename']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      fileSizeKb: json['file_size_kb'] as num? ?? 0,
      latitude: json['latitude'] as num? ?? 0,
      longitude: json['longitude'] as num? ?? 0,
      streetName: json['street_name'] != null &&
              json['street_name'].toString().trim().isNotEmpty
          ? json['street_name'].toString()
          : null,
      gpsAccuracyM: json['gps_accuracy_m'] as num?,
      compassAzimuth: json['compass_azimuth'] as num?,
      exifTimestamp: json['exif_timestamp']?.toString(),
      isManualCapture: json['is_manual_capture'] as bool? ?? false,
      isOfflineSync: json['is_offline_sync'] as bool? ?? false,
      privacyMasked: json['privacy_masked'] as bool? ?? false,
      processingStatus: json['processing_status']?.toString() ?? '',
      errorMessage: json['error_message']?.toString(),
      prediction: json['prediction'] != null && json['prediction'] is Map
          ? PredictionModel.fromJson(
              Map<String, dynamic>.from(json['prediction'] as Map),
            )
          : null,
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'])
          : null,
      capturedAt: json['captured_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'mission_id': missionId,
      'uploaded_by': uploadedBy,
      'uploader': uploader?.toJson(),
      'source': source,
      'original_filename': originalFilename,
      'file_path': filePath,
      'file_size_kb': fileSizeKb,
      'latitude': latitude,
      'longitude': longitude,
      'street_name': streetName,
      'gps_accuracy_m': gpsAccuracyM,
      'compass_azimuth': compassAzimuth,
      'exif_timestamp': exifTimestamp,
      'is_manual_capture': isManualCapture,
      'is_offline_sync': isOfflineSync,
      'privacy_masked': privacyMasked,
      'processing_status': processingStatus,
      'error_message': errorMessage,
      'captured_at': capturedAt,
      'created_at': createdAt,
    };
  }
}
