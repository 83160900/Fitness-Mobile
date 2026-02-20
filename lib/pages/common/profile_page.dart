import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  bool _uploading = false;
  String? _photoUrl;
  final ImagePicker _picker = ImagePicker();

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
          _photoUrl = data['photoUrl'];
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
          'photoUrl': _photoUrl,
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

  Future<void> _pickAndUploadPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _uploading = true);

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/upload-photo'));
      
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          await image.readAsBytes(),
          filename: image.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          image.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _photoUrl = data['url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto carregada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no upload: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao carregar foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar foto.')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('URL da Imagem'),
              onTap: () {
                Navigator.pop(context);
                _updatePhotoUrl(); // Mantém suporte a URL se necessário, ou remove
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updatePhotoUrl() {
    String tempUrl = _photoUrl ?? "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL da Foto de Perfil'),
        content: TextField(
          onChanged: (v) => tempUrl = v,
          decoration: const InputDecoration(hintText: 'https://exemplo.com/foto.jpg'),
          controller: TextEditingController(text: _photoUrl),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              setState(() => _photoUrl = tempUrl.trim().isEmpty ? null : tempUrl.trim());
              Navigator.pop(context);
            },
            child: const Text('DEFINIR'),
          ),
        ],
      ),
    );
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
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
                                ? (_photoUrl!.startsWith('http') 
                                    ? NetworkImage(_photoUrl!) 
                                    : NetworkImage('$baseUrl/users/photo/${_photoUrl!.split('/').last}')) as ImageProvider
                                : null,
                            child: (_photoUrl == null || _photoUrl!.isEmpty || _uploading)
                                ? (_uploading 
                                    ? const CircularProgressIndicator() 
                                    : const Icon(Icons.person, size: 50))
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                onPressed: _uploading ? null : _showPhotoOptions,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
