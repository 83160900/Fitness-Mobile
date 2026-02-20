import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/workout_service.dart';

class StudentDetailPage extends StatefulWidget {
  final Map<String, dynamic> student;
  final String coachEmail;

  const StudentDetailPage({required this.student, required this.coachEmail});

  @override
  _StudentDetailPageState createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  final WorkoutService _workoutService = WorkoutService();
  List<dynamic> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final data = await _workoutService.getStudentWorkouts(widget.student['email'] ?? '');
      setState(() {
        _workouts = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar treinos: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student['name'] ?? 'Detalhes do Aluno'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadWorkouts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com Foto e Resumo
              _buildStudentHeader(),
              const SizedBox(height: 32),
              
              // Seção de Treinos
              _buildSectionTitle(context, 'Treinos Atuais'),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_workouts.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Nenhum treino cadastrado ainda para este aluno.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ))
              else
                ..._workouts.map((w) => _buildTrainingCard(w)).toList(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.teal.withOpacity(0.1),
          backgroundImage: (widget.student['photoUrl'] != null && widget.student['photoUrl'].toString().isNotEmpty)
              ? (widget.student['photoUrl'].toString().startsWith('http')
                  ? NetworkImage(widget.student['photoUrl'].toString())
                  : NetworkImage('https://fitness-backtend-production.up.railway.app/api/users/photo/${widget.student['photoUrl'].toString().split('/').last}')) as ImageProvider
              : null,
          child: (widget.student['photoUrl'] == null || widget.student['photoUrl'].toString().isEmpty)
              ? Text(widget.student['name'] != null ? widget.student['name'][0] : 'A', style: const TextStyle(fontSize: 32, color: Colors.teal))
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.student['name'] ?? 'Aluno',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text('Objetivo: Emagrecimento / Definição', style: TextStyle(color: Colors.grey)),
              const Text('Ativo', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (title == 'Treinos Atuais')
            TextButton.icon(
              onPressed: () async {
                final Map<String, dynamic> args = {
                  'student': widget.student,
                  'coachEmail': widget.coachEmail,
                };
                
                final result = await Navigator.pushNamed(context, '/create-workout', arguments: args);
                if (result == true) {
                  _loadWorkouts();
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo'),
            ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(dynamic plan) {
    final title = (plan['name'] ?? 'Plano de Treino').toString();
    final createdAt = plan['createdAt'];
    final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(createdAt)) : '';
    final exerciseCount = (plan['items'] as List?)?.length ?? 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.fitness_center, color: Colors.white, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$exerciseCount exercícios${dateStr.isNotEmpty ? ' • Criado em $dateStr' : ''}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Visualizar detalhes do treino (opcional por enquanto)
        },
      ),
    );
  }
}
