import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    final String role = userData['role'] ?? 'ALUNO';
    final String name = userData['name'] ?? 'Usuário';
    final String userEmail = userData['email'] ?? '';

    return Scaffold(
      drawer: _buildDrawer(context, name, role, userEmail),
      appBar: AppBar(
        title: Text(role == 'PERSONAL' ? 'Dashboard 360°' : 'Meu Painel'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 28),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificações e Mensagens')),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, name, role, userEmail),
    );
  }

  Widget _buildDrawer(BuildContext context, String name, String role, String userEmail) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(role, style: const TextStyle(fontSize: 12)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(name[0], style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary)),
            ),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          ),
          _buildDrawerItem(Icons.dashboard, 'Visão Geral', 0),
          if (role == 'PERSONAL') ...[
            _buildDrawerItem(Icons.groups, 'Meus Alunos', 1, route: '/students', arguments: {'email': userEmail}),
            // _buildDrawerItem(Icons.trending_up, 'Evolução e Fotos', 2),
            _buildDrawerItem(Icons.monitor_weight, 'Bioimpedância', 3, route: '/bioimpedance-students'),
            _buildDrawerItem(Icons.assignment, 'Planos de Treino', 4),
          ],
          if (role == 'ALUNO') ...[
            _buildDrawerItem(Icons.fitness_center, 'Meus Treinos', 1),
            _buildDrawerItem(Icons.history, 'Meu Histórico', 2),
          ],
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, {String? route, Object? arguments}) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Theme.of(context).colorScheme.primary : Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // Fecha drawer
        if (route != null) {
          Navigator.pushNamed(context, route, arguments: arguments);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, String name, String role, String userEmail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (role == 'PERSONAL') ...[
            const Text(
              'Visão 360° dos seus alunos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Adesão, evolução, alertas e próximas ações em tempo real',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatCard('Ativos', '24', Colors.blue),
                _buildStatCard('Alertas', '03', Colors.orange),
                _buildStatCard('Meta', '85%', Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionSection(context, name, userEmail),
          ],
          if (role == 'ALUNO') ...[
            Text('Olá, $name!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Seu progresso hoje', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            _buildModuleCard(context, 'Treino do Dia', Icons.play_circle_fill, Colors.orange),
            _buildModuleCard(context, 'Minha Evolução', Icons.show_chart, Colors.green),
          ]
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, String name, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Próximas Ações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildModuleCard(context, 'Meus Alunos', Icons.groups, Colors.blue, '/students', {'email': email}),
        // _buildModuleCard(context, 'Gerar Convite', Icons.link, Colors.teal, '/invite', {'email': email}),
        // _buildModuleCard(context, 'Avaliação de Fotos', Icons.camera_alt, Colors.purple, '/photos'),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, [String? route, Object? args]) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          if (route != null) {
            Navigator.pushNamed(context, route, arguments: args);
          }
        },
      ),
    );
  }
}
