import 'package:flutter/material.dart';

class InvitePage extends StatefulWidget {
  final String professionalEmail;

  const InvitePage({required this.professionalEmail});

  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  String? generatedLink;
  bool _lgpdAccepted = false;

  void _generateLink() {
    setState(() {
      // Simulação de link seguro com token
      generatedLink = "https://working.app/invite?ref=${widget.professionalEmail.hashCode}&type=professional";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Convite')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add_outlined, size: 80, color: Colors.teal),
            const SizedBox(height: 24),
            const Text(
              'Vincular Novo Aluno',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gere um link seguro para enviar ao seu aluno. Ao acessar, ele dará o consentimento LGPD automaticamente para compartilhar os dados com você.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'TERMO DE CONSENTIMENTO (LGPD)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ao utilizar este link, o aluno autoriza o profissional a visualizar dados de saúde, treinos e fotos para fins de acompanhamento profissional.',
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.justify,
                  ),
                  CheckboxListTile(
                    title: const Text('Confirmar ciência dos termos', style: TextStyle(fontSize: 12)),
                    value: _lgpdAccepted,
                    onChanged: (val) => setState(() => _lgpdAccepted = val!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (generatedLink == null)
              ElevatedButton(
                onPressed: _lgpdAccepted ? _generateLink : null,
                child: const Text('GERAR LINK DE CONVITE'),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      generatedLink!,
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copiado para a área de transferência!')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('COPIAR LINK'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
