import 'package:flutter/material.dart';

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student['name'] ?? 'Detalhes do Aluno'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com Foto e Resumo
            _buildStudentHeader(),
            const SizedBox(height: 32),
            
            // Seção de Treinos
            _buildSectionTitle(context, 'Treinos Atuais'),
            // Card mocado removido para limpeza de dados fakes
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Nenhum treino cadastrado ainda para este aluno.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            )),
            const SizedBox(height: 24),

            // Dashboard de Bioimpedância (Ocultado conforme solicitado)
            // _buildSectionTitle(context, 'Evolução Bioimpedância'),
            // _buildBioimpedanceChart(),
            // const SizedBox(height: 24),

            // Comparativo Antes e Depois (Ocultado conforme solicitado)
            // _buildSectionTitle(context, 'Evolução Física (Antes vs Depois)'),
            // _buildBeforeAfterGallery(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(student['photoUrl'] ?? 'https://i.pravatar.cc/150'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student['name'] ?? 'Aluno',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Objetivo: Emagrecimento / Definição', style: TextStyle(color: Colors.grey)),
            const Text('Adesão: 98%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, [String? studentEmail]) {
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
              onPressed: () {
                final Map<String, dynamic> args = {
                  'student': student,
                  'coachEmail': 'personal@teste.com', // Aqui idealmente viria do Provider/Auth
                };
                Navigator.pushNamed(context, '/create-workout', arguments: args);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo'),
            ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orange, width: 1),
      ),
      child: const ListTile(
        leading: Icon(Icons.fitness_center, color: Colors.orange),
        title: Text('Treino A - Membros Superiores'),
        subtitle: Text('Frequência: 3x por semana'),
        trailing: Icon(Icons.video_collection_outlined, color: Colors.blue),
      ),
    );
  }

  Widget _buildBioimpedanceChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar('Gordura', 32, Colors.red),
          _buildBar('Músculo', 45, Colors.green),
          _buildBar('Água', 60, Colors.blue),
          _buildBar('Peso', 85, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${height.toInt()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: height * 1.2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildBeforeAfterGallery() {
    return Row(
      children: [
        Expanded(
          child: _buildImageCard('Antes (Jan)', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=200'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildImageCard('Depois (Hoje)', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200'),
        ),
      ],
    );
  }

  Widget _buildImageCard(String label, String url) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(url, height: 150, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
