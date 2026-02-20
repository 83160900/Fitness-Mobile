import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String baseUrl = 'https://fitness-backtend-production.up.railway.app/api';
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController(text: widget.userData['email'] ?? '');
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final email = widget.userData['email'] ?? '';
    if (email.isEmpty) { setState(() => _loading = false); return; }
    try {
      final resp = await http.get(Uri.parse('$baseUrl/users/profile?email=$email')).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _nameCtrl.text = data['name'] ?? '';
          _phoneCtrl.text = data['phone'] ?? '';
          _addressCtrl.text = data['address'] ?? '';
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final resp = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailCtrl.text,
          'name': _nameCtrl.text,
          'phone': _phoneCtrl.text,
          'address': _addressCtrl.text,
        }),
      );
      if (resp.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados atualizados com sucesso.')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao salvar: ${resp.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar dados.')));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Dados')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Telefone (WhatsApp)'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: 'Endereço'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Salvar'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
