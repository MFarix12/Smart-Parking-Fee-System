import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'active_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  int index = 0;
  Map<String, dynamic>? summary;

  @override
  void initState() { super.initState(); loadSummary(); }

  Future<void> loadSummary() async {
    try {
      final s = await api.summary();
      if (mounted) setState(() => summary = s);
    } catch (_) {}
  }

  Future<void> logout() async {
    await api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  Widget stat(String label, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon), const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label),
      ]),
    ),
  );

  Widget dashboard() {
    final revenue = (summary?['today_revenue_cents'] as num?) ?? 0;
    return RefreshIndicator(
      onRefresh: loadSummary,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Today', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
            children: [
              stat('Inside', '${summary?['active_vehicles'] ?? '-'}', Icons.local_parking),
              stat('Entries', '${summary?['today_entries'] ?? '-'}', Icons.login),
              stat('Exits', '${summary?['today_exits'] ?? '-'}', Icons.logout),
              stat('Revenue', 'RM ${(revenue / 100).toStringAsFixed(2)}', Icons.payments),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen(direction: 'ENTRY')));
              loadSummary();
            },
            icon: const Icon(Icons.login), label: const Text('VEHICLE ENTRY')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen(direction: 'EXIT')));
              loadSummary();
            },
            icon: const Icon(Icons.logout), label: const Text('VEHICLE EXIT')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [dashboard(), const ActiveScreen(), const HistoryScreen()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANPR Parking'),
        actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout), tooltip: 'Logout')],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.local_parking), label: 'Inside'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
