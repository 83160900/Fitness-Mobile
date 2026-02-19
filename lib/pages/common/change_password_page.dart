import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String identifier; // cpf ou e-mail usado no login
  final String currentPassword;

  const ChangePasswordPage({required this.identifier, required this.currentPassword, Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definir Nova Senha')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Por segurança, defina uma nova senha para continuar.',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
                validator: (v) => (v == null || v.trim().length < 4) ? 'Mínimo 4 caracteres' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                validator: (v) => (v != _newPassCtrl.text) ? 'As senhas não conferem' : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleChange,
                      child: const Text('SALVAR NOVA SENHA'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleChange() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await _auth.changePassword(
      user: widget.identifier,
      currentPassword: widget.currentPassword,
      newPassword: _newPassCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        Navigator.pop(context); // volta ao login
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível alterar a senha.')),
        );
      }
    }
  }
}
