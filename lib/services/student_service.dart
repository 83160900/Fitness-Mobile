import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentService {
  final String baseUrl = 'https://fitness-backtend-production.up.railway.app/api/personal';

  Future<List<dynamic>> getStudents(String coachEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$coachEmail/students'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Erro ao buscar alunos: $e');
      return [];
    }
  }
}
