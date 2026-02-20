import 'package:flutter/material.dart';
import '../../services/workout_service.dart';
import 'package:fitness_mobile/widgets/themed_icon_card.dart';

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

  final Map<String, List<String>> _exerciseCatalog = {
    'Membros Inferiores': [
      'Agachamento Livre', 'Agachamento Frontal', 'Agachamento Sumô', 'Agachamento Búlgaro',
      'Agachamento Hack', 'Agachamento Smith', 'Leg Press 45°', 'Leg Press Horizontal',
      'Avanço (Lunge)', 'Passada Caminhando', 'Afundo no Smith', 'Step Up', 'Cadeira Extensora',
      'Agachamento com Salto', 'Agachamento Isométrico', 'Sissy Squat',
      'Levantamento Terra', 'Terra Romeno', 'Stiff', 'Mesa Flexora', 'Flexora em Pé',
      'Flexora Sentada', 'Glute Bridge', 'Hip Thrust', 'Elevação Pélvica Unilateral',
      'Good Morning', 'Kettlebell Swing',
      'Panturrilha em Pé', 'Panturrilha Sentado', 'Panturrilha no Leg Press',
      'Panturrilha no Smith', 'Panturrilha Unilateral'
    ],
    'Membros Superiores': [
      'Supino Reto', 'Supino Inclinado', 'Supino Declinado', 'Supino com Halteres',
      'Crucifixo Reto', 'Crucifixo Inclinado', 'Peck Deck', 'Flexão de Braço',
      'Flexão com Pés Elevados', 'Supino no Smith',
      'Barra Fixa', 'Puxada na Frente', 'Puxada na Nuca', 'Remada Curvada',
      'Remada Unilateral', 'Remada Baixa', 'Remada Cavalinho', 'Pulldown',
      'Pull Over', 'Remada no TRX',
      'Desenvolvimento com Barra', 'Desenvolvimento com Halteres', 'Elevação Lateral',
      'Elevação Frontal', 'Elevação Posterior', 'Arnold Press', 'Encolhimento para Trapézio',
      'Face Pull',
      'Rosca Direta', 'Rosca Alternada', 'Rosca Martelo', 'Rosca Concentrada',
      'Rosca Scott', 'Rosca no Cabo',
      'Tríceps Pulley', 'Tríceps Testa', 'Tríceps Francês', 'Mergulho em Banco',
      'Tríceps Corda', 'Supino Fechado'
    ],
    'Core / Abdômen': [
      'Abdominal Tradicional', 'Abdominal Infra', 'Abdominal Supra', 'Prancha',
      'Prancha Lateral', 'Prancha com Elevação de Perna', 'Abdominal Bicicleta',
      'Abdominal Máquina', 'Elevação de Pernas', 'Russian Twist', 'Ab Wheel', 'Dead Bug'
    ],
    'Funcional / Cardio': [
      'Burpee', 'Polichinelo', 'Mountain Climber', 'Corrida na Esteira',
      'Bicicleta Ergométrica', 'Elíptico', 'Pular Corda', 'Sprint', 'Box Jump',
      'Battle Rope', 'Agachamento com Salto', 'Corrida Intervalada'
    ],
    'Máquinas': [
      'Cadeira Abdutora', 'Cadeira Adutora', 'Pulley Frente', 'Pulley Tríceps',
      'Remada Máquina', 'Supino Máquina', 'Desenvolvimento Máquina',
      'Flexora Máquina', 'Extensora Máquina'
    ],
    'Mobilidade': [
      'Alongamento de Posterior', 'Alongamento de Quadríceps', 'Mobilidade de Quadril',
      'Mobilidade de Ombro', 'Mobilidade Torácica', 'Liberação Miofascial', 'Alongamento Cervical'
    ],
    'Reabilitação': [
      'Elevação Pélvica Terapêutica', 'Mini Agachamento', 'Ponte Isométrica',
      'Exercício com Faixa Elástica', 'Fortalecimento de Manguito',
      'Extensão Lombar Controlada', 'Exercícios Proprioceptivos',
      'Equilíbrio Unilateral'
    ],
  };

  final Map<String, IconData> _categoryIcons = {
    'Membros Inferiores': Icons.accessibility_new,
    'Membros Superiores': Icons.fitness_center,
    'Core / Abdômen': Icons.grid_view,
    'Funcional / Cardio': Icons.directions_run,
    'Máquinas': Icons.settings,
    'Mobilidade': Icons.self_improvement,
    'Reabilitação': Icons.medical_services,
  };

  @override
  void initState() {
    super.initState();
    _ensureExercisesInBackend();
  }

  Future<void> _ensureExercisesInBackend() async {
    try {
      List<Map<String, String>> allEx = [];
      _exerciseCatalog.forEach((cat, list) {
        for (var name in list) {
          allEx.add({'name': name, 'category': cat});
        }
      });
      await _workoutService.ensureExercises(allEx);
      print('[DEBUG_LOG] Catálogo de exercícios garantido no backend.');
    } catch (e) {
      print('[DEBUG_LOG] Erro ao garantir catálogo: $e');
    }
  }

  void _openExerciseCategory(String category) async {
    final List<String> available = _exerciseCatalog[category] ?? [];
    
    final List<String>? selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _CategoryExercisesModal(
        category: category,
        exercises: available,
        alreadySelected: _selectedExercises.map((e) => e['name'].toString()).toList(),
      ),
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        for (var name in selected) {
          // Busca o ID no banco antes ou usa o nome para buscar depois
          _selectedExercises.add({
            'exerciseId': null, // Será buscado pelo nome no momento do save ou via busca imediata
            'name': name,
            'sets': 3,
            'reps': '12',
            'restTime': '60s',
            'order': _selectedExercises.length + 1,
            'observations': '',
          });
        }
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

    // Resolver IDs dos exercícios pelo nome
    try {
      // 1. Garante que todos os exercícios do catálogo existam (redundância de segurança)
      List<Map<String, String>> allEx = [];
      _exerciseCatalog.forEach((cat, list) {
        for (var name in list) {
          allEx.add({'name': name, 'category': cat});
        }
      });
      await _workoutService.ensureExercises(allEx);

      // 2. Busca IDs para os selecionados
      for (var ex in _selectedExercises) {
        if (ex['exerciseId'] == null) {
          // Tenta busca exata pelo nome para evitar 500 em queries com caracteres especiais se possível
          // ou simplesmente confia que o 'ensure' acima populou o banco e o search deve funcionar.
          final results = await _workoutService.getExercises(query: ex['name']);
          if (results.isNotEmpty) {
            final match = results.firstWhere(
              (element) => element['name'].toString().toLowerCase() == ex['name'].toString().toLowerCase(),
              orElse: () => results.first
            );
            ex['exerciseId'] = match['id'];
          }
        }
      }
    } catch (e) {
      print('[DEBUG_LOG] Erro ao resolver IDs: $e');
    }

    // Filtra exercícios que ainda não possuem ID (falha de segurança)
    final validExercises = _selectedExercises.where((e) => e['exerciseId'] != null).toList();

    if (validExercises.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao vincular exercícios no banco.')));
      return;
    }

    final workoutData = {
      'name': _nameController.text,
      'description': _descController.text,
      'coachEmail': widget.coachEmail,
      'studentEmail': widget.student['email'],
      'exercises': validExercises.map((e) => {
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
                Text('Aluno: ${widget.student['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Treino (ex: Treino A)', prefixIcon: Icon(Icons.edit)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Descrição/Foco', prefixIcon: Icon(Icons.description)),
                ),
                const SizedBox(height: 32),
                const Text('Selecione por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCategoryGrid(),
                const SizedBox(height: 32),
                const Text('Exercícios Selecionados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                if (_selectedExercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('Nenhum exercício selecionado.', style: TextStyle(color: Colors.grey))),
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

  Widget _buildCategoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75, // Ajustado para acomodar o novo design
      children: _exerciseCatalog.keys.map((cat) {
        return InkWell(
          onTap: () => _openExerciseCategory(cat),
          borderRadius: BorderRadius.circular(20),
          child: ThemedIconCard(
            category: cat,
            label: cat,
            size: 48,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseCard(dynamic ex, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              dense: true,
              leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.fitness_center, color: Colors.white, size: 16)),
              title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => setState(() => _selectedExercises.removeAt(index)),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Séries', isDense: true),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => ex['sets'] = int.tryParse(v) ?? 3,
                    controller: TextEditingController(text: ex['sets'].toString()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Reps', isDense: true),
                    onChanged: (v) => ex['reps'] = v,
                    controller: TextEditingController(text: ex['reps']),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Descanso', isDense: true),
                    onChanged: (v) => ex['restTime'] = v,
                    controller: TextEditingController(text: ex['restTime']),
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

class _CategoryExercisesModal extends StatefulWidget {
  final String category;
  final List<String> exercises;
  final List<String> alreadySelected;

  const _CategoryExercisesModal({required this.category, required this.exercises, required this.alreadySelected});

  @override
  __CategoryExercisesModalState createState() => __CategoryExercisesModalState();
}

class __CategoryExercisesModalState extends State<_CategoryExercisesModal> {
  late List<String> _filtered;
  final List<String> _selected = [];
  String _query = "";

  @override
  void initState() {
    super.initState();
    _filtered = widget.exercises;
  }

  void _filter(String q) {
    setState(() {
      _query = q;
      _filtered = widget.exercises
          .where((e) => e.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.category, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar em ${widget.category}...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: _filter,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final name = _filtered[index];
                final isAlreadyInWorkout = widget.alreadySelected.contains(name);
                final isSelectedNow = _selected.contains(name);

                return CheckboxListTile(
                  title: Text(name),
                  value: isSelectedNow || isAlreadyInWorkout,
                  enabled: !isAlreadyInWorkout,
                  onChanged: (val) {
                    if (isAlreadyInWorkout) return;
                    setState(() {
                      if (val == true) {
                        _selected.add(name);
                      } else {
                        _selected.remove(name);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: Text('ADICIONAR SELECIONADOS (${_selected.length})'),
          ),
        ],
      ),
    );
  }
}
