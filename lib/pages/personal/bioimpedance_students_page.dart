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

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final user = await _authService.getCurrentUser();
    if (user != null && user['email'] != null) {
      final list = await _studentService.getStudents(user['email']);
      setState(() {
        _students = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bioimpedância - Selecionar Aluno')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('Nenhum aluno vinculado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final s = _students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: s['photoUrl'] != null ? NetworkImage(s['photoUrl']) : null,
                          child: s['photoUrl'] == null ? const Icon(Icons.person) : null,
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
