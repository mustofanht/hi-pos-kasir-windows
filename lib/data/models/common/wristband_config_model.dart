/// Cara media dipisahkan setelah dicetak.
///
/// TSPL tidak punya perintah "potong" yang menyatu dengan cetak seperti ESC/POS.
/// Pemisahan diatur sendiri lewat `SET CUTTER` dan `SET TEAR`, dan pilihannya
/// tergantung perangkat kerasnya: printer label tanpa modul pemotong hanya bisa
/// memajukan media ke bilah sobek.
enum ModePotong {
  /// Tanpa pemotong. Media dimajukan ke bilah sobek agar gelang bisa disobek —
  /// tanpa ini lembar terakhir tertinggal di dalam printer dan sulit diambil.
  sobek,

  /// Potong setiap satu gelang. Butuh modul pemotong terpasang.
  tiapGelang,

  /// Potong sekali di akhir seluruh cetakan. Butuh modul pemotong.
  akhirBatch,
}

/// Ukuran dan setelan media gelang.
///
/// Semuanya bisa diubah dari layar Pengaturan karena media gelang tidak
/// seragam: ada yang label 50x25mm, ada gulungan gelang 25x254mm, dan
/// kerapatan panasnya berbeda antar merek. Nilai bawaan di sini adalah stok
/// label termometer yang paling umum beredar (50x25mm, jarak 2mm, 203 dpi) —
/// titik awal yang wajar, bukan tebakan yang harus dipakai apa adanya.
///
/// Kalibrasi sesungguhnya baru bisa dilakukan di depan printer: cetak uji,
/// ukur hasilnya, sesuaikan angkanya.
class WristbandConfigModel {
  /// Resolusi printer. Hampir semua printer label thermal 203 dpi (8 titik/mm);
  /// sebagian seri industri 300 dpi (11,8 titik/mm).
  int dpi;

  double widthMm;
  double heightMm;

  /// Jarak antar label. 0 berarti media menyambung (continuous) tanpa jeda.
  double gapMm;

  /// Batas kosong di tepi media, agar cetakan tidak terpotong.
  double marginMm;

  /// Kerapatan panas 0–15. Terlalu rendah membuat QR pudar dan gagal dipindai;
  /// terlalu tinggi membuat tinta melebar sampai modul QR saling menempel.
  int density;

  /// Kecepatan cetak 1–6 (inci/detik).
  int speed;

  /// Arah cetak: 0 atau 1. Menentukan tepi mana yang keluar duluan; kalau hasil
  /// cetak terbalik, inilah yang diubah.
  int direction;

  /// Cara memisahkan gelang satu dari berikutnya. Lihat [ModePotong].
  ModePotong potong;

  WristbandConfigModel({
    this.dpi = 203,
    this.widthMm = 50,
    this.heightMm = 25,
    this.gapMm = 2,
    this.marginMm = 2,
    this.density = 8,
    this.speed = 4,
    this.direction = 1,
    this.potong = ModePotong.sobek,
  });

  /// Titik per milimeter untuk resolusi ini.
  double get titikPerMm => dpi / 25.4;

  int dots(double mm) => (mm * titikPerMm).round();

  int get widthDots => dots(widthMm);
  int get heightDots => dots(heightMm);
  int get marginDots => dots(marginMm);

  WristbandConfigModel salin({
    int? dpi,
    double? widthMm,
    double? heightMm,
    double? gapMm,
    double? marginMm,
    int? density,
    int? speed,
    int? direction,
    ModePotong? potong,
  }) {
    return WristbandConfigModel(
      dpi: dpi ?? this.dpi,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      gapMm: gapMm ?? this.gapMm,
      marginMm: marginMm ?? this.marginMm,
      density: density ?? this.density,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
      potong: potong ?? this.potong,
    );
  }

  Map<String, dynamic> toJson() => {
        'dpi': dpi,
        'widthMm': widthMm,
        'heightMm': heightMm,
        'gapMm': gapMm,
        'marginMm': marginMm,
        'density': density,
        'speed': speed,
        'direction': direction,
        'potong': potong.name,
      };

  /// Nilai di luar akal dianggap tidak ada dan diganti bawaan. Berkas setelan
  /// bisa saja rusak atau diisi tangan; printer yang menerima `SIZE 0 mm` tidak
  /// mencetak apa pun dan tidak memberi tahu alasannya.
  factory WristbandConfigModel.fromJson(Map<dynamic, dynamic> json) {
    double angka(String key, double bawaan, double min, double maks) {
      final v = json[key];
      final d = v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
      if (d == null || d < min || d > maks) return bawaan;
      return d;
    }

    int bulat(String key, int bawaan, int min, int maks) {
      final v = json[key];
      final i = v is num ? v.toInt() : int.tryParse('${v ?? ''}');
      if (i == null || i < min || i > maks) return bawaan;
      return i;
    }

    return WristbandConfigModel(
      dpi: bulat('dpi', 203, 100, 600),
      widthMm: angka('widthMm', 50, 10, 200),
      heightMm: angka('heightMm', 25, 10, 400),
      gapMm: angka('gapMm', 2, 0, 20),
      marginMm: angka('marginMm', 2, 0, 20),
      density: bulat('density', 8, 0, 15),
      speed: bulat('speed', 4, 1, 6),
      direction: bulat('direction', 1, 0, 1),
      potong: ModePotong.values.firstWhere(
        (e) => e.name == json['potong'],
        orElse: () => ModePotong.sobek,
      ),
    );
  }
}
