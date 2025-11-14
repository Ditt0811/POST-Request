import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'screens/absensi_form_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final seed = Colors.deepPurple;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi Keren',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
      home: const AbsensiFormScreen(),
    );
  }
}

class AbsensiFormPage extends StatefulWidget {
  const AbsensiFormPage({super.key});
  @override
  State<AbsensiFormPage> createState() => _AbsensiFormPageState();
}

class _AbsensiFormPageState extends State<AbsensiFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  String _jenisKelamin = 'Laki-Laki';
  String _device = 'Unknown';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceStr = 'Unknown';
    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceStr = '${info.manufacturer} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceStr = '${info.name} ${info.model}';
      } else {
        deviceStr = Platform.operatingSystem;
      }
    } catch (_) {
      deviceStr = 'Unknown';
    }
    if (mounted) {
      setState(() => _device = deviceStr);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final url = Uri.parse(
      'https://absensi-mobile.primakar­auniversity.ac.id/api/absensi/',
    );
    final body = {
      'nama': _namaController.text.trim(),
      'nim': _nimController.text.trim(),
      'kelas': _kelasController.text.trim(),
      'jenis_kelamin': _jenisKelamin,
      'device': _device,
    };

    setState(() => _loading = true);
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      String message = 'Terjadi kesalahan';
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        if (data is Map && data['status'] != null) {
          message = data['message'] ?? resp.body;
        } else {
          message = 'Absensi berhasil';
        }
      } else {
        try {
          final data = jsonDecode(resp.body);
          message = data['message'] ?? resp.body;
        } catch (_) {
          message = 'HTTP ${resp.statusCode}: ${resp.reasonPhrase}';
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(labelText: 'NIM'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'NIM harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(labelText: 'Kelas'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Kelas harus diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                items: const [
                  DropdownMenuItem(
                    value: 'Laki-Laki',
                    child: Text('Laki-Laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _jenisKelamin = v ?? 'Laki-Laki'),
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _device,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Device'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim Absensi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _kelasController.dispose();
    super.dispose();
  }
}
