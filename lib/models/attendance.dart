class Attendance {
  final String nama;
  final String nim;
  final String kelas;
  final String jenisKelamin;
  final String device;

  Attendance({
    required this.nama,
    required this.nim,
    required this.kelas,
    required this.jenisKelamin,
    required this.device,
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'nim': nim,
        'kelas': kelas,
        'jenis_kelamin': jenisKelamin,
        'device': device,
      };
}
