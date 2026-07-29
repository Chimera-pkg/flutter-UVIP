import 'package:flutter/material.dart';

class UploadedFile {
  final String name;
  final String size;

  UploadedFile({required this.name, required this.size});
}

class UploadProvider with ChangeNotifier {
  // Mock Data
  final List<UploadedFile> _uploadedFiles = [
    UploadedFile(name: 'IMG 2091.png', size: '1 MB'),
    UploadedFile(name: 'IMG 2091.png', size: '1 MB'),
    UploadedFile(name: 'IMG 2091.png', size: '1 MB'),
  ];

  final List<UploadedFile> _uploadingFiles = [
    UploadedFile(name: 'IMG 2092.png', size: '2 MB'),
    UploadedFile(name: 'IMG 2093.png', size: '3 MB'),
  ];

  double _uploadProgress = 0.65; // Dummy progress (65%)
  final String _timeRemaining = "23 Sec";

  // Getters
  List<UploadedFile> get uploadedFiles => _uploadedFiles;
  List<UploadedFile> get uploadingFiles => _uploadingFiles;
  double get uploadProgress => _uploadProgress;
  String get timeRemaining => _timeRemaining;

  // Mock methods to update state
  void removeUploadedFile(int index) {
    _uploadedFiles.removeAt(index);
    notifyListeners();
  }

  void cancelUpload() {
    _uploadingFiles.clear();
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
