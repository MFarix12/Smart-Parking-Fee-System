import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
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
  bool summaryLoading = true;

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    setState(() => summaryLoading = true);
    try {
      final s = await api.summary();
      if (mounted) setState(() => summary = s);
    } catch (_) {
      // Keep the dashboard usable when the summary endpoint is unavailable.
    } finally {
      if (mounted) setState(() => summaryLoading = false);
    }
  }

  Future<void> logout() async {
    await api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> openScanner(String direction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanScreen(direction: direction),
      ),
    );
    loadSummary();
  }

  Widget statCard(String label, String value, IconData icon, Color accent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withOpacity(.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 27),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: ParkingColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: ParkingColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboard() {
    final revenue = (summary?['today_revenue_cents'] as num?) ?? 0;

    return RefreshIndicator(
      onRefresh: loadSummary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 650
                  ? 2
                  : 1;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 1200 ? 36 : 20,
              vertical: 22,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ParkingColors.navy, ParkingColors.navySoft],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final wide = box.maxWidth > 680;
                    final intro = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: ParkingColors.cyan.withOpacity(.13),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            '●  SYSTEM ONLINE',
                            style: TextStyle(
                              color: ParkingColors.cyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Smart Parking Control',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Scan vehicle plates, verify parking sessions and monitor today’s activity.',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );

                    final action = FilledButton.icon(
                      onPressed: () => openScanner('ENTRY'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(190, 54),
                      ),
                      icon: const Icon(Icons.document_scanner_rounded),
                      label: const Text('SCAN VEHICLE'),
                    );

                    return wide
                        ? Row(
                            children: [
                              Expanded(child: intro),
                              const SizedBox(width: 24),
                              action,
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              intro,
                              const SizedBox(height: 22),
                              action,
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Today at a glance',
                      style: TextStyle(
                        color: ParkingColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (summaryLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 3.4 : 2.1,
                children: [
                  statCard(
                    'Vehicles inside',
                    '${summary?['active_vehicles'] ?? '-'}',
                    Icons.local_parking_rounded,
                    ParkingColors.cyan,
                  ),
                  statCard(
                    'Entries today',
                    '${summary?['today_entries'] ?? '-'}',
                    Icons.login_rounded,
                    ParkingColors.blue,
                  ),
                  statCard(
                    'Exits today',
                    '${summary?['today_exits'] ?? '-'}',
                    Icons.logout_rounded,
                    ParkingColors.warning,
                  ),
                  statCard(
                    'Revenue today',
                    'RM ${(revenue / 100).toStringAsFixed(2)}',
                    Icons.payments_rounded,
                    ParkingColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const Text(
                'Quick actions',
                style: TextStyle(
                  color: ParkingColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => openScanner('ENTRY'),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('VEHICLE ENTRY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openScanner('EXIT'),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('VEHICLE EXIT'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboard(),
      const ActiveScreen(),
      const HistoryScreen(),
    ];

    const titles = ['Dashboard', 'Active Vehicles', 'Parking History'];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: ParkingColors.cyan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_parking_rounded,
                color: ParkingColors.navy,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARKVISION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  titles[index],
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: loadSummary,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking_rounded),
            label: 'Inside',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
