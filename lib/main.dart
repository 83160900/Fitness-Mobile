import 'package:flutter/material.dart';
import 'pages/common/login_page.dart';
import 'pages/common/registration_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/personal/students_page.dart';
import 'pages/personal/student_detail_page.dart';
import 'pages/personal/invite_page.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Platform',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFA5), // Verde ÃƒÂgua / SaÃƒÂºde
          primary: const Color(0xFF00BFA5),
          secondary: const Color(0xFF00796B),
          tertiary: const Color(0xFF26A69A),
          surface: Colors.white,
          background: const Color(0xFFF1F8F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F8F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00BFA5),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF00796B)),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/students') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => StudentsPage(coachEmail: args['email'] ?? ''),
          );
        }
        if (settings.name == '/student-detail') {
          final student = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => StudentDetailPage(student: student),
          );
        }
        if (settings.name == '/invite') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => InvitePage(professionalEmail: args['email'] ?? ''),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
// Test commit to verify configuration
// Test commit to verify configuration (fixed)

