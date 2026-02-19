import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    final String role = userData['role'] ?? 'ALUNO';
    final String name = userData['name'] ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'PERSONAL' ? 'Espaço do Personal' : 'Meu Espaço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, $name!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role == 'PERSONAL' 
                ? 'Gerencie seus alunos e acompanhamentos' 
                : 'Acompanhe seu progresso e treinos',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Grid de Funcionalidades
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: _buildMenuOptions(context, role),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuOptions(BuildContext context, String role) {
    if (role == 'PERSONAL') {
      return [
        _buildMenuCard(context, 'Meus Alunos', Icons.groups, Colors.blue),
        _buildMenuCard(context, 'Chat Privado', Icons.chat_bubble, Colors.teal),
        _buildMenuCard(context, 'Bioimpedância', Icons.monitor_weight, Colors.orange),
        _buildMenuCard(context, 'Evolução/Fotos', Icons.photo_library, Colors.purple),
      ];
    } else {
      return [
        _buildMenuCard(context, 'Meus Treinos', Icons.fitness_center, Colors.orange),
        _buildMenuCard(context, 'Meu Chat', Icons.chat_bubble, Colors.teal),
        _buildMenuCard(context, 'Minha Bio', Icons.assessment, Colors.blue),
        _buildMenuCard(context, 'Minhas Fotos', Icons.camera_alt, Colors.red),
      ];
    }
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Implementação futura das rotas específicas
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Acessando $title...')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
