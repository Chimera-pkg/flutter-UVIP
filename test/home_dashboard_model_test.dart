import 'package:flutter_test/flutter_test.dart';
import 'package:uvip/models/home_dashboard_model.dart';

void main() {
  group('HomeDashboardModel Parsing Tests', () {
    test('Parses direct FastAPI response with target indicator keys (beauty, safety, etc.)', () {
      final json = {
        'status': 'success',
        'total_projects': 14,
        'average_scores': {
          'safety': 8.25,
          'beauty': 7.50,
          'comfort': 6.80,
          'uvi': 7.52,
        },
      };

      final model = HomeDashboardModel.fromJson(json);

      expect(model.status, 'success');
      expect(model.totalProjects, 14);
      expect(model.averageScores?.safetyScore, 8.25);
      expect(model.averageScores?.beautyScore, 7.50);
      expect(model.averageScores?.comfortScore, 6.80);
      expect(model.averageScores?.uviScore, 7.52);
    });

    test('Parses model keys with _score suffix', () {
      final json = {
        'status': 'success',
        'total_projects': 5,
        'average_scores': {
          'safety_score': 9.0,
          'beauty_score': 8.0,
          'comfort_score': 7.0,
          'uvi_score': 8.0,
        },
      };

      final model = HomeDashboardModel.fromJson(json);

      expect(model.totalProjects, 5);
      expect(model.averageScores?.safetyScore, 9.0);
      expect(model.averageScores?.beautyScore, 8.0);
      expect(model.averageScores?.comfortScore, 7.0);
      expect(model.averageScores?.uviScore, 8.0);
    });

    test('Parses raw JSON String (as sometimes returned by Dio in release mode)', () {
      const rawString = '{"status":"success","total_projects":10,"average_scores":{"safety":6.5,"beauty":7.2,"comfort":8.1,"uvi":7.26}}';

      final model = HomeDashboardModel.fromJson(rawString);

      expect(model.totalProjects, 10);
      expect(model.averageScores?.safetyScore, 6.5);
      expect(model.averageScores?.beautyScore, 7.2);
    });

    test('Parses nested data object format', () {
      final json = {
        'status': 'success',
        'data': {
          'total_projects': 8,
          'average_scores': {
            'safety': 7.1,
            'beauty': 6.9,
            'comfort': 7.5,
            'uvi': 7.16,
          },
        },
      };

      final model = HomeDashboardModel.fromJson(json);

      expect(model.totalProjects, 8);
      expect(model.averageScores?.safetyScore, 7.1);
      expect(model.averageScores?.comfortScore, 7.5);
    });

    test('Parses string numbers and alternative total keys safely', () {
      final json = {
        'status': 'success',
        'total_surveys': '12',
        'average_scores': {
          'safety': '8.5',
          'beauty': '7.2',
          'comfort': '9.0',
          'uvi': '8.23',
        },
      };

      final model = HomeDashboardModel.fromJson(json);

      expect(model.totalProjects, 12);
      expect(model.averageScores?.safetyScore, 8.5);
      expect(model.averageScores?.beautyScore, 7.2);
    });
  });
}
