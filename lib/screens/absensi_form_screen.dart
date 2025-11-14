import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';
import '../utils/device_helper.dart';
import '../widgets/loading_button.dart';
import 'success_screen.dart' hide LoadingButton;

class AbsensiFormScreen extends StatefulWidget {
  const AbsensiFormScreen({super.key});
  @override
  State<AbsensiFormScreen> createState() => _AbsensiFormScreenState();
}

class _AbsensiFormScreenState extends State<AbsensiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _nim = TextEditingController();
  final TextEditingController _kelas = TextEditingController();
  final TextEditingController _deviceController =
      TextEditingController(text: 'Memuat...');
  String _jenis = 'Laki-Laki';
  bool _loading = false;

  static const double _fieldHeight = 48.0;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    final name = await DeviceHelper.getDeviceName();
    if (!mounted) return;
    _deviceController.text = name;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final att = Attendance(
      nama: _nama.text.trim(),
      nim: _nim.text.trim(),
      kelas: _kelas.text.trim(),
      jenisKelamin: _jenis,
      device: _deviceController.text,
    );

    try {
      final res = await ApiService.submitAttendance(att);
      final code = res['statusCode'] ?? 0;
      final body = res['body'];
      final msg = (body is Map && body['message'] != null)
          ? body['message']
          : 'Response $code';

      if (code >= 200 &&
          code < 300 &&
          body is Map &&
          (body['status'] == 'success' || body['status'] == true)) {
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => SuccessScreen(message: msg)));
      } else {
        if (!mounted) return;
        // Cek jika error terkait NIM tidak ditemukan
        final isNimError = msg.toLowerCase().contains('nim') &&
            (msg.toLowerCase().contains('tidak ditemukan') ||
                msg.toLowerCase().contains('not found') ||
                msg.toLowerCase().contains('invalid'));
        if (isNimError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('NIM Tidak Ditemukan'),
                content: Text(msg),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _inputContainer({required Widget child}) {
    return Container(
      height: _fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: const Color.fromARGB(255, 23, 162, 255), width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    required String label,
  }) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                if (state.hasError)
                  Text(' ${state.errorText}',
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            _inputContainer(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: readOnly,
                onChanged: (value) => state.didChange(value),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dropdownField({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return FormField<String>(
      initialValue: value,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 6),
            _inputContainer(
              child: DropdownButton<String>(
                value: state.value,
                items: items,
                onChanged: (v) {
                  state.didChange(v);
                  onChanged(v);
                },
                isExpanded: true,
                underline: const SizedBox(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nama.dispose();
    _nim.dispose();
    _kelas.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Form Absensi',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nama
                          _textField(
                            controller: _nama,
                            hint: 'Nama Anda',
                            label: 'Nama',
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'wajib di isi!*'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // NIM
                          _textField(
                            controller: _nim,
                            hint: 'Nomor Induk Mahasiswa',
                            keyboardType: TextInputType.number,
                            label: 'NIM',
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'wajib di isi!*'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Jenis Kelamin
                          _dropdownField(
                            value: _jenis,
                            label: 'Jenis Kelamin',
                            items: const [
                              DropdownMenuItem(
                                  value: 'Laki-Laki', child: Text('Laki-Laki')),
                              DropdownMenuItem(
                                  value: 'Perempuan', child: Text('Perempuan')),
                            ],
                            onChanged: (v) =>
                                setState(() => _jenis = v ?? 'Laki-Laki'),
                          ),
                          const SizedBox(height: 12),

                          // Device
                          _textField(
                            controller: _deviceController,
                            hint: 'Mark dan Model Device yang Digunakan',
                            readOnly: true,
                            label: 'Jenis Device',
                          ),
                          const SizedBox(height: 12),

                          // Kelas
                          _textField(
                            controller: _kelas,
                            hint: 'Kelas Anda',
                            label: 'Kelas',
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'wajib di isi!*'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    LoadingButton(
                      onPressed: _submit,
                      loading: _loading,
                      label: 'Kirim Absensi',
                    ),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      TextButton.icon(
                        onPressed: _loadDevice,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Device'),
                      ),
                    ]),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
