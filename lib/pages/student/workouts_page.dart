import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/workout_service.dart';

class WorkoutsPage extends StatefulWidget {
  final String userEmail;
  const WorkoutsPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final WorkoutService _service = WorkoutService();
  bool _loading = true;
  List<dynamic> _plans = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final plans = await _service.getStudentWorkouts(widget.userEmail);
      if (mounted) setState(() { _plans = plans; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível carregar seu treino.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Treino')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? const Center(child: Text('Nenhum treino ativo encontrado.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      final title = (plan['title'] ?? 'Plano de Treino').toString();
                      final createdAt = plan['createdAt'];
                      final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(createdAt)) : '';
                      final exercises = (plan['items'] as List?) ?? [];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: dateStr.isNotEmpty ? Text('Criado em $dateStr') : null,
                          children: [
                            if (exercises.isEmpty)
                              const ListTile(
                                title: Text('Sem exercícios cadastrados'),
                              )
                            else
                              ...exercises.map((ex) {
                                final name = (ex['name'] ?? '').toString();
                                final reps = (ex['reps'] ?? '').toString();
                                final sets = (ex['sets'] ?? '').toString();
                                final rest = (ex['rest'] ?? '').toString();
                                return ListTile(
                                  leading: const Icon(Icons.fitness_center),
                                  title: Text(name.isNotEmpty ? name : 'Exercício'),
                                  subtitle: Text(_buildSubtitle(sets, reps, rest)),
                                );
                              }).toList(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _buildSubtitle(String sets, String reps, String rest) {
    final parts = <String>[];
    if (sets.isNotEmpty) parts.add('$sets séries');
    if (reps.isNotEmpty) parts.add('$reps reps');
    if (rest.isNotEmpty) parts.add('descanso $rest');
    return parts.isEmpty ? 'Exercício' : parts.join(' • ');
  }
}
