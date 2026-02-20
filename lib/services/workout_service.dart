import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkoutService {
  final String baseUrl = 'https://fitness-backtend-production.up.railway.app/api';

  Future<List<dynamic>> getExercises({String? query, String? muscle}) async {
    try {
      final queryParams = <String, String>{};
      if (query != null) queryParams['q'] = query;
      if (muscle != null) queryParams['muscle'] = muscle;
      
      final uri = Uri.parse('$baseUrl/exercises').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Erro ao buscar exercícios: $e');
      return [];
    }
  }

  Future<bool> createWorkout(Map<String, dynamic> workoutData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(workoutData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao criar treino: $e');
      return false;
    }
  }

  Future<List<dynamic>> getStudentWorkouts(String studentEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workouts/student/$studentEmail'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Erro ao buscar treinos: $e');
      return [];
    }
  }

  Future<void> ensureExercises(List<Map<String, String>> exercises) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/exercises/ensure'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(exercises),
      );
    } catch (e) {
      print('Erro ao garantir exercícios: $e');
    }
  }
  Future<List<dynamic>> getCoachWorkouts(String coachEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workouts/coach/$coachEmail'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Erro ao buscar treinos do personal: $e');
      return [];
    }
  }

  Future<bool> linkWorkoutToStudent(String planId, String studentEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts/$planId/link?studentEmail=$studentEmail'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao vincular treino: $e');
      return false;
    }
  }
}
