import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final api = ApiService();
  bool loading = true;
  String? error;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await api.history();
      if (mounted) setState(() => items = data);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error!,
            style: const TextStyle(
              color: ParkingColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No parking history yet.',
          style: TextStyle(color: ParkingColors.muted),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = (items[i] as Map).cast<String, dynamic>();
          final fee = item['fee_cents'] as num?;
          final isInside = item['status'] == 'IN';

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isInside
                              ? ParkingColors.blue
                              : ParkingColors.success)
                          .withOpacity(.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isInside ? Icons.login_rounded : Icons.logout_rounded,
                      color: isInside
                          ? ParkingColors.blue
                          : ParkingColors.success,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['plate_number']
                                  ?.toString()
                                  .toUpperCase() ??
                              '-',
                          style: const TextStyle(
                            color: ParkingColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entry: ${item['entry_at'] ?? '-'}',
                          style: const TextStyle(
                            color: ParkingColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Exit: ${item['exit_at'] ?? '-'}',
                          style: const TextStyle(
                            color: ParkingColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fee == null
                            ? (item['status']?.toString() ?? '-')
                            : 'RM ${(fee / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: ParkingColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (isInside
                                  ? ParkingColors.warning
                                  : ParkingColors.success)
                              .withOpacity(.10),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          isInside ? 'ACTIVE' : 'COMPLETED',
                          style: TextStyle(
                            color: isInside
                                ? ParkingColors.warning
                                : ParkingColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
