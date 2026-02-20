import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/workout_service.dart';
import '../../services/student_service.dart';

class WorkoutPlansLibraryPage extends StatefulWidget {
  final String coachEmail;
  const WorkoutPlansLibraryPage({Key? key, required this.coachEmail}) : super(key: key);

  @override
  State<WorkoutPlansLibraryPage> createState() => _WorkoutPlansLibraryPageState();
}

class _WorkoutPlansLibraryPageState extends State<WorkoutPlansLibraryPage> {
  final WorkoutService _workoutService = WorkoutService();
  final StudentService _studentService = StudentService();
  List<dynamic> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    final data = await _workoutService.getCoachWorkouts(widget.coachEmail);
    if (mounted) {
      setState(() {
        _plans = data;
        _isLoading = false;
      });
    }
  }

  void _showLinkDialog(dynamic plan) async {
    final students = await _studentService.getStudents(widget.coachEmail);
    if (!mounted) return;

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum aluno cadastrado para vincular este treino.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular Treino a Aluno'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (student['photoUrl'] != null && student['photoUrl'].toString().isNotEmpty)
                      ? NetworkImage(student['photoUrl'].toString())
                      : null,
                  child: student['photoUrl'] == null ? const Icon(Icons.person) : null,
                ),
                title: Text(student['name']),
                subtitle: Text(student['email']),
                onTap: () async {
                  Navigator.pop(context);
                  _linkPlanToStudent(plan, student['email']);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _linkPlanToStudent(dynamic plan, String studentEmail) async {
    setState(() => _isLoading = true);
    final success = await _workoutService.linkWorkoutToStudent(plan['id'], studentEmail);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Treino "${plan['name']}" vinculado com sucesso ao aluno!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao vincular treino.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Treinos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? const Center(child: Text('Nenhum plano de treino criado ainda.'))
              : RefreshIndicator(
                  onRefresh: _loadPlans,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      final title = (plan['name'] ?? 'Sem nome').toString();
                      final createdAt = plan['createdAt'];
                      final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(createdAt)) : '';
                      final studentName = plan['student'] != null ? plan['student']['name'] : 'Modelo/Livre';
                      final exerciseCount = (plan['items'] as List?)?.length ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Original: $studentName • $exerciseCount exs • $dateStr'),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.teal),
                            tooltip: 'Vincular a outro aluno',
                            onPressed: () => _showLinkDialog(plan),
                          ),
                          children: [
                            if ((plan['items'] as List?)?.isEmpty ?? true)
                              const ListTile(title: Text('Sem exercícios'))
                            else
                              ...((plan['items'] as List).map((item) {
                                final exName = item['exercise'] != null ? item['exercise']['name'] : 'Exercício';
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.fitness_center, size: 16),
                                  title: Text(exName.toString()),
                                  subtitle: Text('${item['sets']} x ${item['reps']}'),
                                );
                              }).toList()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
