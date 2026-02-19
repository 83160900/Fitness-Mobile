import 'package:flutter/material.dart';
import '../../services/workout_service.dart';

class CreateWorkoutPage extends StatefulWidget {
  final Map<String, dynamic> student;
  final String coachEmail;

  const CreateWorkoutPage({required this.student, required this.coachEmail});

  @override
  _CreateWorkoutPageState createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final WorkoutService _workoutService = WorkoutService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  List<dynamic> _selectedExercises = [];
  bool _isLoading = false;

  void _addExercise() async {
    final exercise = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ExerciseSearchModal(),
    );

    if (exercise != null) {
      setState(() {
        _selectedExercises.add({
          'exerciseId': exercise['id'],
          'name': exercise['name'],
          'imageUrl': exercise['imageUrl'],
          'sets': 3,
          'reps': '12',
          'restTime': '60s',
          'order': _selectedExercises.length + 1,
          'observations': '',
        });
      });
    }
  }

  void _saveWorkout() async {
    if (_nameController.text.isEmpty || _selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do treino e adicione ao menos um exercício')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final workoutData = {
      'name': _nameController.text,
      'description': _descController.text,
      'coachEmail': widget.coachEmail,
      'studentEmail': widget.student['email'],
      'exercises': _selectedExercises.map((e) => {
        'exerciseId': e['exerciseId'],
        'sets': e['sets'],
        'reps': e['reps'],
        'restTime': e['restTime'],
        'order': e['order'],
        'observations': e['observations'],
      }).toList(),
    };

    final success = await _workoutService.createWorkout(workoutData);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino criado com sucesso!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar treino. Verifique os dados.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Treino')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aluno: ${widget.student['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Treino (ex: Treino A)', filled: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Descrição/Foco', filled: true),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Exercícios Selecionados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.teal, size: 32),
                      onPressed: _addExercise,
                    ),
                  ],
                ),
                const Divider(),
                if (_selectedExercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('Nenhum exercício adicionado ainda.', style: TextStyle(color: Colors.grey))),
                  ),
                ..._selectedExercises.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var ex = entry.value;
                  return _buildExerciseCard(ex, idx);
                }).toList(),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveWorkout,
                  child: const Text('SALVAR PLANO DE TREINO'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildExerciseCard(dynamic ex, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              leading: ex['imageUrl'] != null 
                ? Image.network(ex['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.fitness_center),
              title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _selectedExercises.removeAt(index)),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Séries'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => ex['sets'] = int.tryParse(v) ?? 3,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Reps'),
                    onChanged: (v) => ex['reps'] = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Descanso'),
                    onChanged: (v) => ex['restTime'] = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSearchModal extends StatefulWidget {
  @override
  __ExerciseSearchModalState createState() => __ExerciseSearchModalState();
}

class __ExerciseSearchModalState extends State<_ExerciseSearchModal> {
  final WorkoutService _service = WorkoutService();
  List<dynamic> _results = [];
  bool _searching = false;

  void _doSearch(String val) async {
    if (val.length < 2) return;
    setState(() => _searching = true);
    final res = await _service.getExercises(query: val);
    setState(() {
      _results = res;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar exercício...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _doSearch,
          ),
          const SizedBox(height: 16),
          if (_searching) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final ex = _results[index];
                return ListTile(
                  leading: ex['imageUrl'] != null 
                    ? Image.network(ex['imageUrl'], width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.fitness_center),
                  title: Text(ex['name']),
                  subtitle: Text(ex['primaryMuscles'] ?? ''),
                  onTap: () => Navigator.pop(context, ex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
