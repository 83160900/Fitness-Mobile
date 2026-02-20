import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/themed_icon_card.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo e Boas-vindas (Personal Trainer Focus)
                  const ThemedIconCard(
                    icon: Icons.fitness_center,
                    size: 80,
                    filled: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'WORKING',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'Sua saúde em um só lugar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Campos de Login
                  TextField(
                    controller: userController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'CPF ou E-mail',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão Entrar
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text(
                        'ENTRAR',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Implementar lógica de recuperação de senha
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidade de recuperação enviada para o e-mail.')),
                      );
                    },
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 40),
                  // Seção de Cadastro para Profissionais
                  const Text(
                    'Cadastre-se como Profissional',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRoleIcon(Icons.person_pin_rounded, 'Personal', Colors.blue, 'PERSONAL'),
                      _buildRoleIcon(Icons.restaurant, 'Nutri', Colors.green, 'NUTRICIONISTA'),
                      _buildRoleIcon(Icons.healing, 'Fisio', Colors.red, 'FISIOTERAPEUTA'),
                      _buildRoleIcon(Icons.accessibility_new, 'Quiro', Colors.orange, 'QUIROPRAXIA'),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleIcon(IconData icon, String label, Color color, String role) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/register', arguments: role);
      },
      child: ThemedIconCard(
        icon: icon,
        label: label,
        size: 48,
        filled: false,
      ),
    );
  }

  void _handleLogin() async {
    String user = userController.text.trim();
    String pass = passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(user, pass);
      if (response != null) {
        final bool forceChange = (response['forcePasswordChange'] == true);
        if (forceChange) {
          // Redireciona para troca de senha no primeiro login
          Navigator.pushNamed(context, '/change-password', arguments: {
            'identifier': user,
            'currentPassword': pass,
          });
        } else {
          // Enviar o objeto completo de resposta para o dashboard
          Navigator.pushReplacementNamed(context, '/dashboard', arguments: response);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciais inválidas! Verifique e-mail e senha.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
