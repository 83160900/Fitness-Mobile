import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final String baseUrl = 'https://fitness-backtend-production.up.railway.app/api';
  Map<String, dynamic> _summary = {
    'activeStudents': '...',
    'alerts': '...',
    'goalProgress': '...',
  };
  bool _isLoadingSummary = false;
  int _notificationCount = 0;
  Map<String, dynamic> _userData = {};
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUserData();
      _loadSummaryData();
      _loadNotificationCount();
    });
  }

  void _initUserData() {
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _userData = Map<String, dynamic>.from(args);
      });
      _refreshProfile();
    }
  }

  Future<void> _refreshProfile() async {
    final String userEmail = _userData['email'] ?? '';
    if (userEmail.isEmpty) return;

    try {
      final response = await http.get(Uri.parse('$baseUrl/users/profile?email=$userEmail')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Atualiza os dados do estado com o que veio do servidor (nome, fotoUrl, etc)
            _userData['name'] = data['name'] ?? _userData['name'];
            _userData['photoUrl'] = data['photoUrl'];
            _userData['phone'] = data['phone'];
            _userData['address'] = data['address'];
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao atualizar perfil no dashboard: $e');
    }
  }

  Future<void> _loadNotificationCount() async {
    final String userEmail = _userData['email'] ?? '';
    if (userEmail.isEmpty) return;

    try {
      // Busca sem filtro de status para ser resiliente a status nulo no backend
      final response = await http.get(Uri.parse('$baseUrl/notifications?email=$userEmail')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> notifs = jsonDecode(response.body);
        // Considera como pendentes tudo que NÃO for LIDA/ARQUIVADA (ou status nulo)
        final int pending = notifs.where((n) {
          final s = n['status'];
          return s == null || (s != 'LIDA' && s != 'ARQUIVADA');
        }).length;
        setState(() {
          _notificationCount = pending;
        });
      }
    } catch (e) {
      print('Erro ao carregar contagem de notificações: $e');
    }
  }

  Future<void> _loadSummaryData() async {
    final String role = _userData['role'] ?? '';
    final String userEmail = _userData['email'] ?? '';

    if (role == 'PERSONAL' && userEmail.isNotEmpty) {
      setState(() => _isLoadingSummary = true);
      try {
        final response = await http.get(Uri.parse('$baseUrl/personal/$userEmail/summary')).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          setState(() {
            _summary = jsonDecode(response.body);
            _isLoadingSummary = false;
          });
        } else {
          setState(() => _isLoadingSummary = false);
        }
      } catch (e) {
        print('Erro ao carregar resumo: $e');
        if (mounted) {
          setState(() => _isLoadingSummary = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se _userData ainda estiver vazio (primeiro frame), tenta pegar dos args
    if (_userData.isEmpty) {
      final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) _userData = Map<String, dynamic>.from(args);
    }

    final String role = _userData['role'] ?? 'ALUNO';
    final String name = _userData['name'] ?? 'Usuário';
    final String userEmail = _userData['email'] ?? '';

    return Scaffold(
      drawer: _buildDrawer(context, name, role, userEmail, _userData),
      appBar: AppBar(
        title: Text(role == 'PERSONAL' ? 'Dashboard 360°' : 'Meu Painel'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 28),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications', arguments: _userData);
                  _loadNotificationCount();
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, name, role, userEmail, userData),
    );
  }

  Widget _buildDrawer(BuildContext context, String name, String role, String userEmail, Map<String, dynamic> userData) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(role, style: const TextStyle(fontSize: 12)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (userData['photoUrl'] != null && userData['photoUrl'].toString().isNotEmpty)
                ? (userData['photoUrl'].toString().startsWith('http')
                  ? NetworkImage(userData['photoUrl'].toString())
                  : NetworkImage('$baseUrl/users/photo/${userData['photoUrl'].toString().split('/').last}')) as ImageProvider
                : null,
              child: (userData['photoUrl'] == null || userData['photoUrl'].toString().isEmpty)
                ? Text(name.isNotEmpty ? name[0] : 'U', style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary))
                : null,
            ),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          ),
          _buildDrawerItem(Icons.dashboard, 'Visão Geral', 0),
          if (role == 'PERSONAL') ...[
            _buildDrawerItem(Icons.groups, 'Meus Alunos', 1, route: '/students', arguments: userData),
            // _buildDrawerItem(Icons.trending_up, 'Evolução e Fotos', 2),
            _buildDrawerItem(Icons.monitor_weight, 'Bioimpedância', 3, route: '/bioimpedance-students', arguments: userData),
            _buildDrawerItem(Icons.calendar_month, 'Minha Agenda', 4, route: '/schedule', arguments: userData),
            _buildDrawerItem(Icons.person, 'Meus Dados', 6, route: '/profile', arguments: userData),
            _buildDrawerItem(Icons.assignment, 'Planos de Treino', 5),
          ],
          if (role == 'ALUNO') ...[
            _buildDrawerItem(Icons.calendar_month, 'Marcar Aula', 1, route: '/schedule', arguments: userData),
            _buildDrawerItem(Icons.fitness_center, 'Meu Treino', 2, route: '/workouts', arguments: userData),
            _buildDrawerItem(Icons.show_chart, 'Minha Evolução', 3, route: '/bioimpedance-details', arguments: {
              'student': {
                'name': name,
                'email': userEmail,
              }
            }),
            _buildDrawerItem(Icons.person, 'Meus Dados', 4, route: '/profile', arguments: userData),
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
    final bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
      )),
      selected: isSelected,
      onTap: () async {
        // Log de diagnóstico imediato
        if (route != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abrindo $title...'), duration: const Duration(seconds: 1)),
          );
        }
        
        Navigator.pop(context); // Fecha o menu
        
        if (route != null) {
          final result = await Navigator.pushNamed(context, route, arguments: arguments);
          // Se voltou da tela de perfil, atualiza os dados locais
          if (route == '/profile' && result == true) {
            _refreshProfile();
          }
        }
        setState(() => _selectedIndex = index);
      },
    );
  }

  Widget _buildBody(BuildContext context, String name, String role, String userEmail, Map<String, dynamic> userData) {
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
                _buildStatCard('Ativos', _summary['activeStudents'].toString(), Colors.blue),
                _buildStatCard('Alertas', _summary['alerts'].toString(), Colors.orange),
                _buildStatCard('Meta', _summary['goalProgress'].toString(), Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionSection(context, name, userEmail, userData),
          ],
          if (role == 'ALUNO') ...[
            Text('Olá, $name!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Bem-vindo ao seu painel', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            // As chamadas 'Treino do Dia' e 'Minha Evolução' foram ocultadas conforme solicitação.
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

  Widget _buildActionSection(BuildContext context, String name, String email, Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Próximas Ações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildModuleCard(context, 'Meus Alunos', Icons.groups, Colors.blue, '/students', userData),
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
