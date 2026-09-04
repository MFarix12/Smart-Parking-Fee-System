import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParkingApp());
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking',
      theme: ParkingTheme.light,
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  final api = ApiService();
  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    final token = await api.getToken();
    if (!mounted) return;
    setState(() {
      loggedIn = token != null && token.isNotEmpty;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: ParkingColors.navy,
        body: Center(
          child: CircularProgressIndicator(color: ParkingColors.cyan),
        ),
      );
    }
    return loggedIn ? const HomeScreen() : const LoginScreen();
  }
}
