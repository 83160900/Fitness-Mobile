import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();
  final TextEditingController formationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    // Pegar o papel sugerido dos argumentos (se houver)
    if (selectedRole == null) {
      selectedRole = ModalRoute.of(context)!.settings.arguments as String? ?? 'ALUNO';
    }

    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de $selectedRole')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Crie sua conta profissional',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email)),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock)),
                validator: (v) => v!.length < 4 ? 'Mínimo 4 caracteres' : null,
              ),
              
              // Campos específicos para Profissionais
              if (selectedRole != 'ALUNO') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: specialtyController,
                  decoration: const InputDecoration(labelText: 'Especialidade', hintText: 'Ex: Musculação, Yoga, Dieta Vegana'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: registrationController,
                  decoration: const InputDecoration(labelText: 'Registro Profissional', hintText: 'CRM, CRN, CREF...'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: formationController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Formação/Graduação'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: experienceController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Experiência Profissional'),
                ),
              ],
              
              const SizedBox(height: 40),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Text('CADASTRAR'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic>? response = await _authService.registerEnhanced({
      'name': nameController.text,
      'email': emailController.text,
      'password': passController.text,
      'role': selectedRole,
      'specialty': specialtyController.text,
      'registrationNumber': registrationController.text,
      'formation': formationController.text,
      'experience': experienceController.text,
    });

    setState(() => _isLoading = false);

    if (response != null && response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso! Faça login.')),
      );
      Navigator.pop(context);
    } else {
      String errorMsg = response?['message'] ?? 'Erro desconhecido ao criar conta.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ERRO: $errorMsg'), duration: Duration(seconds: 10)),
      );
    }
  }
}
