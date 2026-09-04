import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ActiveScreen extends StatefulWidget {
  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
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
      final data = await api.active();
      if (mounted) setState(() => items = data);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: load,
      child: loading
          ? ListView(
              children: const [
                SizedBox(height: 180),
                Center(child: CircularProgressIndicator()),
              ],
            )
          : error != null
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: ParkingColors.danger.withOpacity(.08),
                        borderRadius: BorderRadius.circular(18),
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
                )
              : items.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 100),
                        Icon(
                          Icons.local_parking_rounded,
                          color: ParkingColors.cyan,
                          size: 70,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Parking area is clear',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ParkingColors.text,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No active vehicle sessions are currently recorded.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: ParkingColors.muted),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item =
                            (items[i] as Map).cast<String, dynamic>();

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: ParkingColors.cyan.withOpacity(.10),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.directions_car_filled_rounded,
                                    color: ParkingColors.cyan,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['plate_number']
                                                ?.toString()
                                                .toUpperCase() ??
                                            '-',
                                        style: const TextStyle(
                                          color: ParkingColors.text,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Entered: ${item['entry_at'] ?? '-'}',
                                        style: const TextStyle(
                                          color: ParkingColors.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        ParkingColors.success.withOpacity(.10),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: const Text(
                                    'INSIDE',
                                    style: TextStyle(
                                      color: ParkingColors.success,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
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
