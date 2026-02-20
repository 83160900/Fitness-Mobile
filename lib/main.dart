import 'package:flutter/material.dart';
import 'pages/common/login_page.dart';
import 'pages/common/change_password_page.dart';
import 'pages/common/registration_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/personal/students_page.dart';
import 'pages/personal/student_detail_page.dart';
import 'pages/personal/bioimpedance_students_page.dart';
import 'pages/personal/bioimpedance_details_page.dart';
import 'pages/personal/schedule_page.dart';
import 'pages/personal/invite_page.dart';
import 'pages/personal/create_workout_page.dart';
import 'pages/notifications/notifications_page.dart';
import 'pages/personal/workout_plans_library_page.dart';
import 'pages/common/profile_page.dart';
import 'pages/student/workouts_page.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F2A3D);
    const secondaryColor = Color(0xFF1F6F5C);
    const backgroundColor = Color(0xFFF4F6F8);
    const darkTextColor = Color(0xFF1C1F26);
    const borderColor = Color(0xFFD1D5DB);

    return MaterialApp(
      title: 'Fitness Platform',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          surface: Colors.white,
          background: backgroundColor,
          error: const Color(0xFFB00020),
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: secondaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor, width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: secondaryColor, width: 2),
          ),
          labelStyle: const TextStyle(color: primaryColor),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: darkTextColor),
          bodyMedium: TextStyle(color: darkTextColor),
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
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => StudentDetailPage(
              student: args['student'] ?? {},
              coachEmail: args['coachEmail'] ?? '',
            ),
          );
        }
        if (settings.name == '/invite') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => InvitePage(professionalEmail: args['email'] ?? ''),
          );
        }
        if (settings.name == '/create-workout') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => CreateWorkoutPage(
              student: args['student'] ?? {},
              coachEmail: args['coachEmail'] ?? '',
            ),
          );
        }
        if (settings.name == '/bioimpedance-details') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => BioimpedanceDetailsPage(
              student: args['student'] ?? {},
              isReadOnly: args['isReadOnly'] ?? false,
            ),
          );
        }
        if (settings.name == '/workout-library') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => WorkoutPlansLibraryPage(coachEmail: args['email'] ?? ''),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
        '/bioimpedance-students': (context) => BioimpedanceStudentsPage(),
        '/schedule': (context) => SchedulePage(),
        '/notifications': (context) => NotificationsPage(),
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return ProfilePage(userData: args);
        },
        '/workouts': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          final email = args['email'] ?? '';
          return WorkoutsPage(userEmail: email);
        },
        '/change-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return ChangePasswordPage(
            identifier: args['identifier'] ?? '',
            currentPassword: args['currentPassword'] ?? '',
          );
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
// Test commit to verify configuration
// Test commit to verify configuration (fixed v2)

