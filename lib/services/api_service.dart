import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';

class ApiService {
  static String _endpoint =
      'https://absensi-mobile.primakarauniversity.ac.id/api/absensi';
  static void setEndpoint(String url) {
    _endpoint = url;
  }

  static Future<Map<String, dynamic>> submitAttendance(Attendance att) async {
    if (_endpoint.isEmpty) {
      return {
        'statusCode': 0,
        'body': {'status': 'error', 'message': 'NIM tidak ditemukan'}
      };
    }

    final uri = Uri.parse(_endpoint);
    try {
      final resp = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(att.toJson()))
          .timeout(const Duration(seconds: 12));
      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = resp.body;
      }
      print('API Response Status: ${resp.statusCode}');
      print('API Response Body: $body');
      return {'statusCode': resp.statusCode, 'body': body};
    } catch (e) {
      return {
        'statusCode': 0,
        'body': {'status': 'error', 'message': 'Error: $e'}
      };
    }
  }
}
