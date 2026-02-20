import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class BioimpedanceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> student;
  const BioimpedanceDetailsPage({required this.student});

  @override
  _BioimpedanceDetailsPageState createState() => _BioimpedanceDetailsPageState();
}

class _BioimpedanceDetailsPageState extends State<BioimpedanceDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String baseUrl = 'https://fitness-backtend-production.up.railway.app/api';
  bool _isLoading = true;
  List<dynamic> _history = [];

  // Controllers para o formulário
  final _weightController = TextEditingController();
  final _imcController = TextEditingController();
  final _fatPercentController = TextEditingController();
  final _leanMassController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _visceralFatController = TextEditingController();
  final _bodyWaterController = TextEditingController();
  final _metabolicAgeController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  final _armController = TextEditingController();
  final _thighController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bioimpedance/student/${widget.student['email']}'));
      if (response.statusCode == 200) {
        setState(() {
          _history = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBioimpedance() async {
    setState(() => _isLoading = true);
    final data = {
      'studentEmail': widget.student['email'],
      'weight': double.tryParse(_weightController.text),
      'imc': double.tryParse(_imcController.text),
      'fatPercent': double.tryParse(_fatPercentController.text),
      'leanMass': double.tryParse(_leanMassController.text),
      'muscleMass': double.tryParse(_muscleMassController.text),
      'visceralFat': double.tryParse(_visceralFatController.text),
      'bodyWater': double.tryParse(_bodyWaterController.text),
      'metabolicAge': int.tryParse(_metabolicAgeController.text),
      'waist': double.tryParse(_waistController.text),
      'hip': double.tryParse(_hipController.text),
      'arm': double.tryParse(_armController.text),
      'thigh': double.tryParse(_thighController.text),
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bioimpedance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados salvos com sucesso!')));
        _clearForm();
        _loadHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar dados.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro de conexão.')));
    }
    setState(() => _isLoading = false);
  }

  void _clearForm() {
    _weightController.clear();
    _imcController.clear();
    _fatPercentController.clear();
    _leanMassController.clear();
    _muscleMassController.clear();
    _visceralFatController.clear();
    _bodyWaterController.clear();
    _metabolicAgeController.clear();
    _waistController.clear();
    _hipController.clear();
    _armController.clear();
    _thighController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bioimpedância: ${widget.student['name']}'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '🧠 Bioimpedância', icon: Icon(Icons.psychology)),
            Tab(text: '📈 Evolução', icon: Icon(Icons.trending_up)),
            Tab(text: '📊 Histórico', icon: Icon(Icons.history)),
            Tab(text: '🎯 IA Análise', icon: Icon(Icons.auto_awesome)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInputTab(),
          _buildEvolutionTab(),
          _buildHistoryTab(),
          _buildAIAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Dados Corporais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 16),
          _buildField(_weightController, 'Peso (kg)', Icons.monitor_weight),
          _buildField(_imcController, 'IMC', Icons.calculate),
          _buildField(_fatPercentController, 'Percentual de Gordura (%)', Icons.percent),
          _buildField(_leanMassController, 'Massa Magra (kg)', Icons.fitness_center),
          _buildField(_muscleMassController, 'Massa Muscular (kg)', Icons.bolt),
          _buildField(_visceralFatController, 'Gordura Visceral', Icons.warning_amber),
          _buildField(_bodyWaterController, 'Água Corporal (%)', Icons.water_drop),
          _buildField(_metabolicAgeController, 'Idade Metabólica', Icons.cake),
          const SizedBox(height: 24),
          const Text('Circunferências (cm)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 16),
          _buildField(_waistController, 'Cintura', Icons.straighten),
          _buildField(_hipController, 'Quadril', Icons.straighten),
          _buildField(_armController, 'Braço', Icons.straighten),
          _buildField(_thighController, 'Coxa', Icons.straighten),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveBioimpedance,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SALVAR BIOIMPEDÂNCIA'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildEvolutionTab() {
    if (_history.length < 2) {
      return const Center(child: Text('Necessário ao menos duas bioimpedâncias para gerar evolução.'));
    }
    final actual = _history.first;
    final before = _history[1];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Comparativo Antes vs Atual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              _buildEvolutionRow('Peso', before['weight'], actual['weight'], 'kg'),
              _buildEvolutionRow('Gordura %', before['fatPercent'], actual['fatPercent'], '%'),
              _buildEvolutionRow('Massa Magra', before['leanMass'], actual['leanMass'], 'kg'),
              _buildEvolutionRow('Visceral', before['visceralFat'], actual['visceralFat'], ''),
              _buildEvolutionRow('Cintura', before['waist'], actual['waist'], 'cm'),
              _buildEvolutionRow('Idade Metab.', before['metabolicAge'], actual['metabolicAge'], ' anos'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvolutionRow(String label, dynamic before, dynamic actual, String unit) {
    if (before == null || actual == null) return const SizedBox();
    double b = before.toDouble();
    double a = actual.toDouble();
    double diff = a - b;
    bool improved = false;
    
    // Lógica simples de melhoria (diminuir peso/gordura ou aumentar massa magra)
    if (label.contains('Gordura') || label.contains('Peso') || label.contains('Visceral') || label.contains('Cintura')) {
        improved = diff <= 0;
    } else {
        improved = diff >= 0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('$b$unit', style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
          Text('$a$unit', style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: improved ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}$unit',
              style: TextStyle(color: improved ? Colors.green[800] : Colors.red[800], fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) return const Center(child: Text('Nenhum registro encontrado.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final h = _history[index];
        final date = DateTime.parse(h['date']);
        return Card(
          child: ListTile(
            title: Text('Avaliação em ${date.day}/${date.month}/${date.year}'),
            subtitle: Text('Peso: ${h['weight']}kg | Gordura: ${h['fatPercent']}%'),
            trailing: const Icon(Icons.info_outline, color: Colors.teal),
            onTap: () {
                // Poderia abrir um modal com detalhes completos
            },
          ),
        );
      },
    );
  }

  Widget _buildAIAnalysisTab() {
    if (_history.isEmpty) return const Center(child: Text('Necessário ao menos um registro para análise por IA.'));
    
    // Simulando análise por IA baseada nos dados
    final latest = _history.first;
    String analysis = "Análise automática gerada pela IA:\n\n";
    
    if (latest['fatPercent'] != null && latest['fatPercent'] > 25) {
        analysis += "🔴 Pontos de Melhoria: O percentual de gordura está acima do ideal. Recomendamos focar em déficit calórico moderado e aumento de treinos aeróbicos.\n\n";
    }
    if (latest['visceralFat'] != null && latest['visceralFat'] > 12) {
        analysis += "⚠️ Alerta: Gordura visceral elevada pode representar risco metabólico. Sugerimos dieta anti-inflamatória.\n\n";
    }
    if (latest['muscle_mass'] != null && latest['muscle_mass'] < 30) {
        analysis += "💪 Foco Muscular: Massa muscular pode ser aumentada. Sugerimos treinos de força hipertrófica.\n\n";
    }
    
    analysis += "✅ Resumo: Com base no histórico, o aluno apresenta uma tendência de " + 
                (_history.length > 1 && (_history.first['weight'] < _history[1]['weight']) ? "melhora constante no peso." : "estabilidade corporal.") + 
                " Sugerimos manter a constância nos treinos de 4x por semana.";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: Colors.teal),
          const SizedBox(height: 20),
          Card(
            color: Colors.teal[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.teal[200]!)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(analysis, style: const TextStyle(fontSize: 15, height: 1.5, fontStyle: FontStyle.italic)),
            ),
          ),
        ],
      ),
    );
  }
}
