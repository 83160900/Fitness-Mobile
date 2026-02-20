import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/auth_service.dart';

class BioimpedanceStudentsPage extends StatefulWidget {
  @override
  _BioimpedanceStudentsPageState createState() => _BioimpedanceStudentsPageState();
}

class _BioimpedanceStudentsPageState extends State<BioimpedanceStudentsPage> {
  final StudentService _studentService = StudentService();
  final AuthService _authService = AuthService();
  List<dynamic> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Tentar pegar do e-mail passado via argumentos se o getCurrentUser falhar
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      String? email = args?['email'];

      if (email == null) {
        final user = await _authService.getCurrentUser();
        email = user?['email'];
      }

      if (email != null && email.isNotEmpty) {
        final list = await _studentService.getStudents(email).timeout(const Duration(seconds: 15));
        setState(() {
          _students = list;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Sessão expirada. Por favor, faça login novamente.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar alunos: $e');
      setState(() {
        _errorMessage = "Erro ao carregar lista: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bioimpedância - Selecionar Aluno'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStudents),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando lista de alunos...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: _loadStudents, child: const Text('TENTAR NOVAMENTE')),
                      ],
                    ),
                  ),
                )
              : _students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Nenhum aluno vinculado ainda.'),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                            child: const Text('VOLTAR AO PAINEL'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final s = _students[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.withOpacity(0.1),
                              backgroundImage: (s['photoUrl'] != null && s['photoUrl'].toString().isNotEmpty) 
                                  ? NetworkImage(s['photoUrl']) 
                                  : null,
                              child: (s['photoUrl'] == null || s['photoUrl'].toString().isEmpty) 
                                  ? const Icon(Icons.person, color: Colors.teal) 
                                  : null,
                            ),
                            title: Text(s['name'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(s['email'] ?? ''),
                            trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                            onTap: () {
                              Navigator.pushNamed(context, '/bioimpedance-details', arguments: s);
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
