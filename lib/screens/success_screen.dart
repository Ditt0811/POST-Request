import 'package:flutter/material.dart';

class SuccessScreen extends StatefulWidget {
  final String message;
  const SuccessScreen({super.key, this.message = 'Absensi berhasil'});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _ctl, curve: Curves.elasticOut),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                      radius: 40,
                      backgroundColor: p.withOpacity(0.12),
                      child: Icon(Icons.check, color: p, size: 44)),
                  const SizedBox(height: 14),
                  Text(widget.message,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Terima kasih sudah melakukan absensi.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      child: const Text('Kembali ke Form'))
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  const LoadingButton(
      {required this.onPressed,
      required this.loading,
      required this.label,
      super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // gunakan variabel di sini
        ),
        child: Text(label),
      ),
    );
  }
}
