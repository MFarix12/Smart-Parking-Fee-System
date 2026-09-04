import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final api = ApiService();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;
  String? error;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Enter email and password.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await api.login(email.text.trim(), password.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Widget _brandPanel() {
    return Container(
      padding: const EdgeInsets.all(42),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ParkingColors.navy, ParkingColors.navySoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ParkingColors.cyan,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: ParkingColors.navy,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'PARKVISION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Smarter parking.\nFaster verification.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'ANPR-powered parking fee verification with real-time entry, exit and revenue tracking.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 16,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginCard() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Operator Sign In',
                    style: TextStyle(
                      color: ParkingColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Access the smart parking control panel.',
                    style: TextStyle(
                      color: ParkingColors.muted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    obscureText: obscurePassword,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ParkingColors.danger.withOpacity(.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: ParkingColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: loading ? null : submit,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: ParkingColors.navy,
                            ),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(loading ? 'SIGNING IN...' : 'SIGN IN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              children: [
                Expanded(flex: 11, child: _brandPanel()),
                Expanded(flex: 9, child: _loginCard()),
              ],
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ParkingColors.navy, ParkingColors.navySoft],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_parking_rounded,
                          color: ParkingColors.cyan,
                          size: 36,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'PARKVISION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _loginCard()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
