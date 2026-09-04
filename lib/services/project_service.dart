import 'package:dio/dio.dart';
import 'package:uvip/core/network/dio_client.dart';

class ProjectService {
  final Dio _dio = DioClient.instance;

  Future<Response> getProjects() async {
    try {
      final response = await _dio.get('/projects/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createProject({
    required String name,
    required String location,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/projects/',
        data: {
          'name': name,
          'location': location,
          'description': description,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProject(
    String projectId, {
    String? name,
    String? location,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (location != null) data['location'] = location;
      if (description != null) data['description'] = description;

      final response = await _dio.put('/projects/$projectId', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> openProject(String projectId) async {
    try {
      final response = await _dio.put('/projects/$projectId/open');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteProject(String projectId) async {
    try {
      final response = await _dio.delete('/projects/$projectId');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
