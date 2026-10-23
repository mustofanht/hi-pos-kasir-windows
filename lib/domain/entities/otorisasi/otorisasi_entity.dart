/// Satu permintaan otorisasi leader/SPV atas aksi kasir (syspos V136).
///
/// Alurnya sama seperti void: kasir mengajukan, leader menyetujui di back
/// office, baru aksinya boleh dijalankan.
class OtorisasiEntity {
  /// Cetak ulang struk pembayaran.
  static const String jenisCetakUlangStruk = 'CETAK_ULANG_STRUK';

  /// Cetak tiket dari menu Cek Order.
  static const String jenisCetakTiket = 'CETAK_TIKET';

  /// Memakai deposit pelanggan.
  static const String jenisPakaiDeposit = 'PAKAI_DEPOSIT';

  static const String statusMenunggu = 'P';
  static const String statusDisetujui = 'A';
  static const String statusDitolak = 'R';
  static const String statusDipakai = 'U';
  static const String statusKedaluwarsa = 'E';

  final int? id;
  final String? jenis;
  final String? jenisLabel;
  final String? ref;
  final String? keterangan;
  final String? status;
  final String? statusLabel;
  final String? requestedBy;
  final String? approvedBy;
  final String? rejectionReason;
  final DateTime? expiresDate;

  /// Dihitung **server**: aksinya boleh dijalankan sekarang.
  ///
  /// Tidak dihitung ulang di sini dengan sengaja. Aturan "disetujui, belum
  /// dipakai, belum kedaluwarsa" harus punya satu sumber, dan aplikasi
  /// terpasang tidak bisa diperbarui secepat server — aturan yang disalin ke
  /// sini akan tertinggal tanpa ada yang menyadarinya.
  final bool bolehJalan;

  OtorisasiEntity({
    this.id,
    this.jenis,
    this.jenisLabel,
    this.ref,
    this.keterangan,
    this.status,
    this.statusLabel,
    this.requestedBy,
    this.approvedBy,
    this.rejectionReason,
    this.expiresDate,
    this.bolehJalan = false,
  });

  factory OtorisasiEntity.fromJson(Map<String, dynamic> json) {
    return OtorisasiEntity(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      jenis: json['jenis']?.toString(),
      jenisLabel: json['jenisLabel']?.toString(),
      ref: json['ref']?.toString(),
      keterangan: json['keterangan']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['statusLabel']?.toString(),
      requestedBy: json['requestedBy']?.toString(),
      approvedBy: json['approvedBy']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      expiresDate: json['expiresDate'] == null
          ? null
          : DateTime.tryParse(json['expiresDate'].toString())?.toLocal(),
      bolehJalan: json['bolehJalan'] == true,
    );
  }

  bool get menunggu => status == statusMenunggu;
  bool get ditolak => status == statusDitolak;
  bool get kedaluwarsa => status == statusKedaluwarsa;

  /// Kalimat yang layak dibaca kasir untuk keadaan sekarang.
  String get pesan {
    if (bolehJalan) return 'Sudah disetujui, silakan lanjutkan.';
    if (ditolak) {
      final alasan = (rejectionReason ?? '').trim();
      return alasan.isEmpty
          ? 'Permintaan ditolak leader.'
          : 'Ditolak leader: $alasan';
    }
    if (kedaluwarsa) {
      return 'Permintaan kedaluwarsa. Ajukan ulang bila masih diperlukan.';
    }
    if (status == statusDipakai) {
      return 'Persetujuan ini sudah dipakai. Ajukan ulang bila perlu lagi.';
    }
    return 'Menunggu persetujuan leader…';
  }
}

/// Void milik kasir yang masih menunggu persetujuan leader.
///
/// Selama ini ada, kasir tidak bisa membuat transaksi baru — aturan itu
/// ditegakkan server, dan data ini hanya dipakai memberi tahu lebih dulu
/// supaya kasir tidak mengetahuinya saat tombol Bayar ditolak di depan
/// pelanggan.
class VoidTertundaEntity {
  final String? kasir;
  final int jumlah;
  final List<String> orderNumbers;
  final bool terblokir;
  final String? pesan;

  VoidTertundaEntity({
    this.kasir,
    this.jumlah = 0,
    this.orderNumbers = const [],
    this.terblokir = false,
    this.pesan,
  });

  factory VoidTertundaEntity.fromJson(Map<String, dynamic> json) {
    final daftar = json['orderNumbers'];
    return VoidTertundaEntity(
      kasir: json['kasir']?.toString(),
      jumlah: json['jumlah'] is int
          ? json['jumlah']
          : int.tryParse('${json['jumlah']}') ?? 0,
      orderNumbers: daftar is List
          ? daftar.map((e) => e.toString()).toList()
          : const [],
      terblokir: json['terblokir'] == true,
      pesan: json['pesan']?.toString(),
    );
  }
}
