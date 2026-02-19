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

  Future<Map<String, dynamic>> createStudent({
    required String name,
    required String cpf,
    required String address,
    required String email,
    required String coachEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/students'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'cpf': cpf,
          'address': address,
          'email': email,
          'coachEmail': coachEmail,
        }),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'body': body,
        'status': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'body': {'message': 'Falha na conexão: $e'},
        'status': 500,
      };
    }
  }
}
