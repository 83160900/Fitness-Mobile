import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String? ?? 'ALUNO';

    return Scaffold(
      appBar: AppBar(
        title: Text('Painel - $role'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => Navigator.pushReplacementNamed(context, '/')),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildModuleCard(context, '🏋️ Espaço Fitness', Colors.orange, '/fitness', role),
            _buildModuleCard(context, '🏃 Espaço Corrida', Colors.green, '/running', role),
            _buildModuleCard(context, '🚴 Espaço Pedal', Colors.blue, '/cycling', role),
            _buildModuleCard(context, '💪 Espaço Crossfit', Colors.red, '/crossfit', role),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, Color color, String route, String role) {
    String subtitle = 'Ver meus treinos';
    if (role == 'PERSONAL') {
      subtitle = 'Gerenciar alunos e treinos';
    } else if (role == 'ADMIN') {
      subtitle = 'Administração total do sistema';
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        leading: Icon(Icons.fitness_center, color: color, size: 40),
        title: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          print('Navegando para $title como $role');
        },
      ),
    );
  }
}
