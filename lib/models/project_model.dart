class ProjectModel {
  final String id;
  final String name;
  final String location;
  final String description;
  final String createdAt;
  final String? lastOpenedAt;
  final double? beautyScore;
  final double? safetyScore;
  final double? comfortScore;

  ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.createdAt,
    this.lastOpenedAt,
    this.beautyScore,
    this.safetyScore,
    this.comfortScore,
  });

  factory ProjectModel.fromJson(dynamic rawData) {
    if (rawData == null) {
      return ProjectModel(
        id: '',
        name: '',
        location: '',
        description: '',
        createdAt: '',
      );
    }
    Map<String, dynamic> json;
    if (rawData is Map) {
      json = Map<String, dynamic>.from(rawData);
    } else {
      return ProjectModel(
        id: '',
        name: '',
        location: '',
        description: '',
        createdAt: '',
      );
    }

    return ProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      lastOpenedAt: json['last_opened_at']?.toString(),
      beautyScore: _parseDouble(json['beauty_score'] ?? json['beauty'] ?? json['Beauty']),
      safetyScore: _parseDouble(json['safety_score'] ?? json['safety'] ?? json['Safety']),
      comfortScore: _parseDouble(json['comfort_score'] ?? json['comfort'] ?? json['Comfort']),
    );
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'created_at': createdAt,
      'last_opened_at': lastOpenedAt,
      'beauty_score': beautyScore,
      'safety_score': safetyScore,
      'comfort_score': comfortScore,
    };
  }

  double? get averageUVI {
    if (beautyScore == null || safetyScore == null || comfortScore == null) {
      return null;
    }
    return (beautyScore! + safetyScore! + comfortScore!) / 3;
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? createdAt,
    String? lastOpenedAt,
    double? beautyScore,
    double? safetyScore,
    double? comfortScore,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      beautyScore: beautyScore ?? this.beautyScore,
      safetyScore: safetyScore ?? this.safetyScore,
      comfortScore: comfortScore ?? this.comfortScore,
    );
  }
}
