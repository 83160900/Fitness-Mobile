import 'package:flutter/material.dart';
import 'pages/common/login_page.dart';
import 'pages/dashboard/dashboard_page.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Platform',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/dashboard': (context) => DashboardPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
