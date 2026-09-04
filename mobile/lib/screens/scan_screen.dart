import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  final String direction;

  const ScanScreen({
    super.key,
    required this.direction,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final api = ApiService();
  final picker = ImagePicker();
  final manualPlate = TextEditingController();

  XFile? image;
  Uint8List? imageBytes;
  bool loading = false;
  String? error;
  Map<String, dynamic>? result;

  bool get isEntry => widget.direction == 'ENTRY';

  Future<void> takePhoto() async {
    final img = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
      maxWidth: 1800,
    );

    if (img != null) {
      final bytes = await img.readAsBytes();
      if (!mounted) return;

      setState(() {
        image = img;
        imageBytes = bytes;
        result = null;
        error = null;
      });
    }
  }

  Future<void> scan() async {
    if (image == null) {
      setState(() => error = 'Take a photo first.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
      result = null;
    });

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

    setState(() {
      loading = true;
      error = null;
      result = null;
    });

    try {
      final r = await api.manual(
        widget.direction,
        manualPlate.text.trim().toUpperCase(),
      );
      if (mounted) setState(() => result = r);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget scannerPreview() {
    return Container(
      height: 330,
      decoration: BoxDecoration(
        color: ParkingColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageBytes != null)
            Image.memory(imageBytes!, fit: BoxFit.cover)
          else
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 54,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Capture the vehicle plate clearly',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Keep the plate centered inside the scan frame.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 82,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ParkingColors.cyan,
                      width: 2.4,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.48),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                isEntry ? 'ENTRY SCAN' : 'EXIT SCAN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultCard() {
    final session =
        (result?['session'] as Map?)?.cast<String, dynamic>() ?? {};
    final fee = session['fee_cents'] as num?;
    final plate =
        result?['plate_number']?.toString().toUpperCase() ?? '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_rounded, color: ParkingColors.success),
                SizedBox(width: 10),
                Text(
                  'Plate verified',
                  style: TextStyle(
                    color: ParkingColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: ParkingColors.navy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                plate,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              result?['message']?.toString() ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ParkingColors.muted,
                height: 1.4,
              ),
            ),
            if (fee != null) ...[
              const SizedBox(height: 18),
              const Text(
                'TOTAL PARKING FEE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ParkingColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'RM ${(fee / 100).toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ParkingColors.text,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Gate action: ${result?['gate_action'] ?? '-'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ParkingColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    manualPlate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = isEntry ? ParkingColors.cyan : ParkingColors.warning;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEntry ? 'Vehicle Entry' : 'Vehicle Exit'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 900 ? 80 : 20,
              vertical: 22,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accent.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withOpacity(.18)),
                ),
                child: Text(
                  isEntry
                      ? 'Scan the arriving vehicle to create a new parking session.'
                      : 'Scan the exiting vehicle to verify duration and calculate the parking fee.',
                  style: const TextStyle(
                    color: ParkingColors.text,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              scannerPreview(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: loading ? null : takePhoto,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        image == null ? 'TAKE PHOTO' : 'RETAKE PHOTO',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: loading ? null : scan,
                      icon: const Icon(Icons.document_scanner_rounded),
                      label: Text('SCAN ${widget.direction}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'MANUAL FALLBACK',
                      style: TextStyle(
                        color: ParkingColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: manualPlate,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Plate number',
                  prefixIcon: Icon(Icons.pin_outlined),
                  hintText: 'e.g. VAB 1234',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: loading ? null : manual,
                icon: const Icon(Icons.keyboard_rounded),
                label: const Text('SUBMIT MANUALLY'),
              ),
              if (loading) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
              if (error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: ParkingColors.danger.withOpacity(.08),
                    borderRadius: BorderRadius.circular(16),
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
              if (result != null) ...[
                const SizedBox(height: 18),
                resultCard(),
              ],
            ],
          );
        },
      ),
    );
  }
}
