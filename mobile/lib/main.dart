import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParkingApp());
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ANPR Parking',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const SessionGate(),
  );
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
  void initState() { super.initState(); check(); }

  Future<void> check() async {
    final token = await api.getToken();
    if (!mounted) return;
    setState(() { loggedIn = token != null && token.isNotEmpty; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return loggedIn ? const HomeScreen() : const LoginScreen();
  }
}
