import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'screens/login_screen.dart';
import 'screens/donor_dashboard.dart';
import 'screens/admin_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://njxdumbvmbimpoveplia.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qeGR1bWJ2bWJpbXBvdmVwbGlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzMTYyNDcsImV4cCI6MjA4ODg5MjI0N30.oWwoFmuvOmFmtgoh6EC7v2xvehWFBdCI9qmtD0lDbqY',
  );

  runApp(const BloodDonationApp());
}

class BloodDonationApp extends StatelessWidget {
  const BloodDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'Blood Donation App',
        theme: AppTheme.themeData,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

/// AuthGate decides which screen to show based on auth state and role
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.user;

        if (user == null) {
          return const LoginScreen();
        }

        // Route based on user role, just like Swift MainView
        if (user.isAdmin) {
          return const AdminDashboard();
        } else {
          return const DonorDashboard();
        }
      },
    );
  }
}
