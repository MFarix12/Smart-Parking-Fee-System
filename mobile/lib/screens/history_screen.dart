import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
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
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));
    if (items.isEmpty) return const Center(child: Text('No parking history.'));
    return RefreshIndicator(
      onRefresh: load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final item = (items[i] as Map).cast<String, dynamic>();
          final fee = item['fee_cents'] as num?;
          return ListTile(
            leading: Icon(item['status'] == 'IN' ? Icons.login : Icons.logout),
            title: Text(item['plate_number']?.toString() ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Entry: ${item['entry_at'] ?? '-'}\nExit: ${item['exit_at'] ?? '-'}'),
            trailing: fee == null ? Text(item['status']?.toString() ?? '-') :
              Text('RM ${(fee / 100).toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
