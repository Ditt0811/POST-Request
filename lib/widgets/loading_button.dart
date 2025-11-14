import 'package:flutter/material.dart';

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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 23, 162, 255),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: loading
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
                SizedBox(width: 12),
                Text('Mengirim...', style: TextStyle(color: Colors.white))
              ])
            : Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
