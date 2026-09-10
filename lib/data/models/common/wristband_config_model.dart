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

  /// Media tidak dimajukan sama sekali setelah mencetak.
  ///
  /// Dipakai bila setiap cetakan mengeluarkan **satu gelang kosong tambahan**:
  /// pada media bergelang panjang, memajukan ke bilah sobek berarti memuntahkan
  /// sisa gelang yang sedang dicetak sampai jeda berikutnya — terlihat seperti
  /// gelang kedua yang tercetak sendiri. Konsekuensinya bagian tercetak berhenti
  /// di dalam printer dan perlu ditarik keluar sebelum disobek.
  tanpaMaju,
}

/// Di mana isi diletakkan pada lembar, searah kolom Tinggi.
///
/// Bukan hal yang sama dengan Geser Y. Geser memindahkan isi **dengan
/// mengorbankan ruang**: menggeser 1mm mengecilkan ruang tata letak 2mm, jadi
/// QR ikut menyusut. Perataan hanya memilih ujung mana yang dipakai — ukuran
/// isinya tidak berubah sama sekali.
///
/// Dibuat setelah berhari-hari menyetel gelang bermerek: area bersihnya ada di
/// satu ujung, dan isi yang dipusatkan selalu jatuh menimpa cetakan pabrik.
enum PosisiIsi {
  /// Menempel ke awal lembar.
  atas,

  /// Di tengah lembar. Bawaan, dan benar untuk media polos.
  tengah,

  /// Menempel ke akhir lembar.
  bawah,
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

  /// Geseran cetakan searah kolom **Lebar**, dalam milimeter. Boleh negatif.
  ///
  /// Ada karena bagian yang boleh dicetaki pada gelang jarang berada di tengah
  /// medianya: satu ujungnya perekat, ujung lain lubang atau sambungan. Tanpa
  /// geseran, satu-satunya cara menjauhkan cetakan dari perekat adalah
  /// memalsukan ukuran media — yang lalu merusak perhitungan ukuran QR.
  double geserXMm;

  /// Geseran cetakan searah kolom **Tinggi**, dalam milimeter. Boleh negatif.
  double geserYMm;

  /// Menggeser **seluruh lembar** terhadap titik registrasi media, dalam
  /// milimeter. Boleh negatif. 0 berarti tidak dikirim sama sekali.
  ///
  /// Berbeda dari Geser Y dan Posisi isi, yang keduanya memindahkan isi **di
  /// dalam** lembar. Ini memindahkan lembarnya sendiri terhadap gelang —
  /// satu-satunya cara mencetak di atas titik awal cetak, yang tidak bisa
  /// dijangkau tata letak.
  ///
  /// Dipakai saat printer sudah mengunci takik gelang tapi titik awalnya jatuh
  /// beberapa milimeter dari tempat yang diinginkan. Nilai negatif memajukan
  /// cetakan ke arah awal gelang.
  ///
  /// Dikirim sebagai perintah `SHIFT` dan **tidak semua firmware TSPL
  /// mendukungnya**. Karena itu bawaannya 0 dan perintahnya tidak dikirim sama
  /// sekali — printer yang menolak perintah asing tidak ikut terganggu selama
  /// setelan ini tidak dipakai.
  double shiftMm;

  /// Perataan isi searah kolom Tinggi. Lihat [PosisiIsi].
  PosisiIsi posisi;

  /// Batas atas ukuran QR dalam milimeter. 0 berarti sebesar mungkin.
  ///
  /// Ada karena kadang yang langka bukan lebar media, melainkan **panjang area
  /// yang boleh dicetaki**. Gelang bermerek sudah punya cetakan pabrik di
  /// sebagian panjangnya; isi kita harus muat di sisa yang bersih, dan satu-
  /// satunya bagian yang bisa dikecilkan tanpa kehilangan makna adalah QR.
  ///
  /// Mengecilkan QR menukar jarak pindai dengan ruang gerak — di bawah ±8mm
  /// pemindai gate perlu didekatkan. Karena itu bawaannya 0: hanya dipakai bila
  /// medianya memang memaksa.
  double qrMaksMm;

  /// Memutar isi 90 derajat sehingga membaca **menyusuri** panjang gelang,
  /// bukan melintang pitanya.
  ///
  /// Pada pita 25 mm, arah melintang hanya memuat 12 digit nomor tiket pada
  /// huruf kecil — nomornya sendiri sudah 24 mm. Menyusuri gelang tersedia
  /// ratusan milimeter, jadi hurufnya bisa berkali-kali lebih besar tanpa apa
  /// pun terpotong.
  ///
  /// Bawaannya mati karena tata letak berputar baru bisa dipastikan benar di
  /// depan printer: penempatan jangkar teks berputar berbeda antar firmware
  /// TSPL. Nyalakan, lalu buktikan dengan satu kali **Cetak Uji**.
  bool putarIsi;

  /// Apakah tiket pendamping ikut dicetak sebagai gelang.
  ///
  /// Dimatikan saat mengkalibrasi media: order playground membuat satu tiket
  /// pendamping gratis per tiket berbayar, jadi setiap percobaan memakan dua
  /// kali lipat gelang.
  ///
  /// Yang dimatikan **cetaknya saja**, bukan tiketnya. Tiket pendamping tetap
  /// dibuat server dan tetap sah di gate; QR-nya kembali dicetak menyambung
  /// struk, persis seperti sebelum ada printer gelang. Mematikan tiketnya
  /// sendiri akan mengubah data dan membuat pendamping tidak bisa masuk.
  bool gelangPendamping;

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
    this.geserXMm = 0,
    this.geserYMm = 0,
    this.gelangPendamping = true,
    this.putarIsi = false,
    this.qrMaksMm = 0,
    this.posisi = PosisiIsi.tengah,
    this.shiftMm = 0,
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
    double? geserXMm,
    double? geserYMm,
    bool? gelangPendamping,
    bool? putarIsi,
    double? qrMaksMm,
    PosisiIsi? posisi,
    double? shiftMm,
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
      geserXMm: geserXMm ?? this.geserXMm,
      geserYMm: geserYMm ?? this.geserYMm,
      gelangPendamping: gelangPendamping ?? this.gelangPendamping,
      putarIsi: putarIsi ?? this.putarIsi,
      qrMaksMm: qrMaksMm ?? this.qrMaksMm,
      posisi: posisi ?? this.posisi,
      shiftMm: shiftMm ?? this.shiftMm,
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
        'geserXMm': geserXMm,
        'geserYMm': geserYMm,
        'gelangPendamping': gelangPendamping,
        'putarIsi': putarIsi,
        'qrMaksMm': qrMaksMm,
        'posisi': posisi.name,
        'shiftMm': shiftMm,
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
      geserXMm: angka('geserXMm', 0, -100, 100),
      geserYMm: angka('geserYMm', 0, -100, 100),
      // Bawaan menyala: pendamping yang diam-diam tidak dapat gelang lebih
      // merepotkan daripada gelang yang terbuang saat menguji.
      gelangPendamping: json['gelangPendamping'] != false,
      putarIsi: json['putarIsi'] == true,
      qrMaksMm: angka('qrMaksMm', 0, 0, 50),
      posisi: PosisiIsi.values.firstWhere(
        (e) => e.name == json['posisi'],
        orElse: () => PosisiIsi.tengah,
      ),
      shiftMm: angka('shiftMm', 0, -100, 100),
    );
  }
}
