import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedRole = 'ALUNO';
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PLATAFORMA FITNESS',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Usuário (ou E-mail)', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Entrar como: '),
                DropdownButton<String>(
                  value: selectedRole,
                  items: ['ALUNO', 'PERSONAL', 'ADMIN'].map((String role) {
                    return DropdownMenuItem<String>(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
              child: Text('ENTRAR'),
              onPressed: () {
                if (userController.text == 'admin' && passController.text == 'admin') {
                  Navigator.pushReplacementNamed(context, '/dashboard', arguments: 'ADMIN');
                } else {
                  Navigator.pushReplacementNamed(context, '/dashboard', arguments: selectedRole);
                }
              },
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
    );
  }
}
