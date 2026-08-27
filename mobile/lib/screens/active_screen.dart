import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
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
Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: load,
      child: loading
          ? ListView(
              children: const [
                SizedBox(height: 180),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            )
          : error != null
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(error!),
                  ],
                )
              : items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(
                          child: Text('No vehicles inside.'),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final item =
                            (items[i] as Map).cast<String, dynamic>();

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.directions_car),
                          ),
                          title: Text(
                            item['plate_number']?.toString() ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Entered: ${item['entry_at'] ?? '-'}',
                          ),
                        );
                      },
                    ),
    );
}
