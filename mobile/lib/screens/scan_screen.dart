import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ScanScreen extends StatefulWidget {
  final String direction;
  const ScanScreen({super.key, required this.direction});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final api = ApiService();
  final picker = ImagePicker();
  final manualPlate = TextEditingController();
  XFile? image;
  bool loading = false;
  String? error;
  Map<String, dynamic>? result;

  Future<void> takePhoto() async {
    final img = await picker.pickImage(
      source: ImageSource.camera, imageQuality: 88, maxWidth: 1800,
    );
    if (img != null) setState(() { image = img; result = null; error = null; });
  }

  Future<void> scan() async {
    if (image == null) { setState(() => error = 'Take a photo first.'); return; }
    setState(() { loading = true; error = null; result = null; });
    try {
      final r = await api.scan(widget.direction, image!);
      if (mounted) setState(() => result = r);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> manual() async {
    if (manualPlate.text.trim().isEmpty) {
      setState(() => error = 'Enter a plate number.');
      return;
    }
    setState(() { loading = true; error = null; result = null; });
    try {
      final r = await api.manual(widget.direction, manualPlate.text.trim());
      if (mounted) setState(() => result = r);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() { manualPlate.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final session = (result?['session'] as Map?)?.cast<String, dynamic>() ?? {};
    final fee = session['fee_cents'] as num?;
    return Scaffold(
      appBar: AppBar(title: Text(widget.direction == 'ENTRY' ? 'Vehicle Entry' : 'Vehicle Exit')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (image != null)
            ClipRRect(borderRadius: BorderRadius.circular(16),
              child: Image.file(File(image!.path), height: 250, fit: BoxFit.cover))
          else
            Container(height: 250, alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(16)),
              child: const Text('Capture the vehicle with the plate\nlarge and clearly visible.',
                textAlign: TextAlign.center)),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: loading ? null : takePhoto,
            icon: const Icon(Icons.camera_alt), label: const Text('TAKE PHOTO')),
          const SizedBox(height: 10),
          FilledButton.icon(onPressed: loading ? null : scan,
            icon: const Icon(Icons.document_scanner),
            label: Text('SCAN ${widget.direction}')),
          const SizedBox(height: 24),
          const Divider(),
          const Text('Manual fallback', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: manualPlate, textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Plate number', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: loading ? null : manual, child: const Text('SUBMIT MANUALLY')),
          if (loading) ...[const SizedBox(height: 18), const Center(child: CircularProgressIndicator())],
          if (error != null) ...[
            const SizedBox(height: 14),
            Card(child: Padding(padding: const EdgeInsets.all(14),
              child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
          ],
          if (result != null) ...[
            const SizedBox(height: 14),
            Card(child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Text(result!['plate_number']?.toString() ?? '-',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(result!['message']?.toString() ?? ''),
                if (fee != null) Text('RM ${(fee / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge),
                Text('Gate action: ${result!['gate_action'] ?? '-'}'),
              ]),
            )),
          ],
        ],
      ),
    );
  }
}
