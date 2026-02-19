import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedRole = 'ALUNO';
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80),
              Text(
                'PLATAFORMA FITNESS V2',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              TextField(
                controller: userController,
                decoration: InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                onSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                onSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: 24),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                  child: Text('ENTRAR'),
                  onPressed: _handleLogin,
                ),
              SizedBox(height: 32),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Não tem conta? '),
                      TextButton(
                        onPressed: () => print('Registro de Cliente'),
                        child: Text('Registre-se como Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('É Profissional? '),
                      TextButton(
                        onPressed: () => print('Registro de Coach'),
                        child: Text('Registre-se como Coach', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    String user = userController.text.trim();
    String pass = passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    setState(() => _isLoading = true);

    final response = await _authService.login(user, pass);

    setState(() => _isLoading = false);

    if (response != null) {
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: response['role']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Credenciais inválidas ou erro de conexão')));
    }
  }
}
