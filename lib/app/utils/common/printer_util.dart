import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:jaya_propertiy/app/utils/common/device_simulation_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/print_capture_util.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
import 'package:jaya_propertiy/data/models/common/wristband_config_model.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterUtil {
  var printerManager = PrinterManager.instance;
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  // USBStatus _currentUsbStatus = USBStatus.none;
  BTStatus _currentStatus = BTStatus.none;
  List<int>? pendingTask;
  var defaultPrinterType = PrinterType.usb;
  PrinterModel? currPrinter;
  bool _isConnected = false;
  final _isBle = false;
  final _reconnect = false;
  List<PrinterModel> printerList = [];

  /// Setelan printer gelang disimpan di kotak **perangkat**, bukan kotak sesi.
  ///
  /// Kotak "sessions" dihapus utuh (`erase()`) setiap kali kasir logout. Selama
  /// setelan gelang tinggal di sana, satu kali ganti shift sudah cukup untuk
  /// menghapus hasil kalibrasi media yang didapat lewat puluhan gelang
  /// percobaan. Kehilangannya juga tidak kelihatan saat itu: setelan di memori
  /// masih utuh sampai aplikasi ditutup, lalu keesokan paginya gelang keluar
  /// dengan ukuran bawaan 50x25mm, atau QR-nya diam-diam kembali ke kertas struk.
  ///
  /// Printer dan medianya melekat pada perangkat, bukan pada kasir yang sedang
  /// masuk.
  static final GetStorage _store = GetStorage("perangkat");

  /// Kotak lama, hanya untuk memindahkan setelan yang tersimpan sebelum
  /// pemisahan di atas. Lihat [muatSetelanGelang].
  static final GetStorage _storeLama = GetStorage("sessions");

  /// Printer USB mana yang **benar-benar** sedang dipilih di sisi Android.
  ///
  /// Perlu dilacak sendiri karena `PrinterManager` tidak menyediakannya, dan
  /// karena `connect()` untuk USB berbohong: di sisi Android ia memanggil
  /// `selectDevice()` yang hanya **meminta izin** lalu langsung mengembalikan
  /// true — perangkatnya baru benar-benar berpindah beberapa saat kemudian,
  /// lewat siaran izin. Mengirim byte tepat setelah `connect()` berarti
  /// mengirimnya ke printer yang lama.
  ///
  /// Itu bukan kemungkinan teoretis: perintah TSPL untuk gelang pernah tercetak
  /// utuh sebagai teks di atas kertas struk POS80.
  String? _usbAktif;

  /// Penanda yang sama untuk Bluetooth dan jaringan.
  String? _btAktif;
  String? _tcpAktif;


  /// Printer gelang — perangkat kedua, terpisah dari printer struk.
  ///
  /// Berbeda dari printer struk yang dipilih ulang tiap aplikasi dijalankan
  /// (`connectPrinterFirst`), pilihan ini **disimpan**: satu outlet punya dua
  /// printer sekaligus, dan menebak mana yang mana setiap pagi adalah cara pasti
  /// mencetak gelang di atas kertas struk.
  ///
  /// Null berarti belum diatur — alur cetak kembali ke perilaku lama, yaitu QR
  /// dicetak sebagai sambungan struk. Itu penting supaya outlet yang belum punya
  /// printer gelang tidak berhenti bisa mencetak tiket.
  PrinterModel? wristbandPrinter;

  WristbandConfigModel wristbandConfig = WristbandConfigModel();

  bool get punyaPrinterGelang => wristbandPrinter != null;

  /// Membaca setelan gelang yang tersimpan. Dipanggil sekali saat aplikasi mulai.
  void muatSetelanGelang() {
    _pindahkanDariSesi();
    try {
      final printer = _store.read(constant.wristbandPrinter);
      if (printer is Map) wristbandPrinter = PrinterModel.fromJson(printer);
      final config = _store.read(constant.wristbandConfig);
      if (config is Map) wristbandConfig = WristbandConfigModel.fromJson(config);
    } catch (e) {
      // Setelan rusak tidak boleh menggagalkan aplikasi mulai; kembali ke
      // bawaan, dan kasir tinggal memilih ulang printernya.
      logger.safeLog('Setelan gelang gagal dibaca : $e');
      wristbandPrinter = null;
      wristbandConfig = WristbandConfigModel();
    }
    logger.safeLog('PRINTER GELANG : ${wristbandPrinter?.deviceName ?? "(belum diatur)"}');
  }

  /// Memindahkan setelan gelang dari kotak sesi ke kotak perangkat, sekali.
  ///
  /// Perangkat yang sudah dikalibrasi sebelum pembaruan ini menyimpan setelannya
  /// di kotak sesi. Tanpa pemindahan, pembaruan aplikasi itu sendiri akan
  /// menghapus kalibrasinya — persis masalah yang sedang diperbaiki.
  ///
  /// Hanya menyalin bila kotak perangkat belum punya nilai, supaya setelan yang
  /// lebih baru tidak pernah tertimpa yang lama.
  void _pindahkanDariSesi() {
    for (final kunci in [constant.wristbandPrinter, constant.wristbandConfig]) {
      try {
        final lama = _storeLama.read(kunci);
        if (lama == null) continue;
        if (_store.read(kunci) == null) {
          _store.write(kunci, lama);
          logger.safeLog('SETELAN GELANG dipindah dari sesi : $kunci');
        }
        _storeLama.remove(kunci);
      } catch (e) {
        logger.safeLog('Setelan gelang gagal dipindah ($kunci) : $e');
      }
    }
  }

  void simpanPrinterGelang(PrinterModel? printer) {
    wristbandPrinter = printer;
    if (printer == null) {
      _store.remove(constant.wristbandPrinter);
    } else {
      _store.write(constant.wristbandPrinter, printer.toJson());
    }
    logger.safeLog('PRINTER GELANG DISIMPAN : ${printer?.deviceName ?? "(dihapus)"}');
  }

  void simpanSetelanGelang(WristbandConfigModel config) {
    wristbandConfig = config;
    _store.write(constant.wristbandConfig, config.toJson());
    logger.safeLog('SETELAN GELANG : ${config.toJson()}');
  }

  Future<void> init() async {
    logger.safeLog(' ---- PRINTER ---- ');
    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      logger.safeLog(
        ' ----------------- status usb $status ------------------ ',
      );
      // _currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(
              type: PrinterType.usb,
              bytes: pendingTask!,
            );
            pendingTask = null;
          });
        }
      }
    });
  }

  Future<void> initBt() async {
    logger.safeLog(' ---- PRINTER BT ---- ');
    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      logger.safeLog(
        ' ----------------- status bt $status ------------------ ',
      );
      _currentStatus = status;
      if (status == BTStatus.connected) {
        _isConnected = true;
      }
      if (status == BTStatus.none) {
        _isConnected = false;
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
  }

  Future<void> connect(PrinterModel selectedPrinter) async {
    logger.safeLog('CONNECT TO : ${selectedPrinter.toJson()}');
    if (isSimulated(selectedPrinter)) {
      currPrinter = selectedPrinter;
      _isConnected = true;
      return;
    }
    switch (selectedPrinter.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter.typePrinter,
            model: UsbPrinterInput(
                name: selectedPrinter.deviceName,
                productId: selectedPrinter.productId,
                vendorId: selectedPrinter.vendorId));
        currPrinter = selectedPrinter;
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        var isConnected = await printerManager.connect(
          type: selectedPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: selectedPrinter.deviceName,
            address: selectedPrinter.address!,
            isBle: selectedPrinter.isBle ?? false,
            autoConnect: _reconnect,
          ),
        );
        currPrinter = selectedPrinter;
        if (isConnected) _currentStatus = BTStatus.connected;
        break;
      case PrinterType.network:
        await printerManager.connect(
            type: selectedPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: selectedPrinter.address!));
        _isConnected = true;
        break;
      default:
    }
  }

  Future<void> disconnect(PrinterModel selectedPrinter) async {
    if (isSimulated(selectedPrinter)) {
      currPrinter = null;
      _isConnected = false;
      return;
    }
    printerManager.disconnect(type: selectedPrinter.typePrinter);
    _isConnected = false;
    pendingTask = null;
    _currentStatus = BTStatus.none;
  }

  Future<void> disconnectAll() async {
    currPrinter = null;
    var listPrinter = await getListDevices();
    for (var element in listPrinter) {
      var isDisconnect =
          await printerManager.disconnect(type: element.typePrinter);
      logger.safeLog('${element.deviceName} : $isDisconnect');
    }
    _isConnected = false;
    pendingTask = null;
    _currentStatus = BTStatus.none;
  }

  Future<List<PrinterModel>> getListDevices() async {
    List<PrinterModel> deviceList = [];
    // Ditaruh paling depan supaya jadi pilihan pertama saat mengembangkan tanpa
    // perangkat; pemindaian USB/Bluetooth tetap jalan agar printer sungguhan
    // yang kebetulan terpasang tidak hilang dari daftar.
    if (deviceSimulation.printer) {
      deviceList.add(simulatedPrinter);
    }
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      // logger.safeLog('DEVICE NAME : ${device.name} ');
      deviceList.add(PrinterModel(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
    });
    await _subscription?.asFuture();
    await _subscription?.cancel();
    _subscription = printerManager
        .discovery(type: PrinterType.bluetooth, isBle: _isBle)
        .listen((device) {
      // logger.safeLog('DEVICE NAME : ${device.name} ');
      deviceList.add(PrinterModel(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.bluetooth,
      ));
    });
    await _subscription?.asFuture();
    await _subscription?.cancel();
    logger.safeLog('deviceList : $deviceList');
    return deviceList;
  }

  Future<List<PrinterModel>> getListDevicesUsb() async {
    List<PrinterModel> deviceList = [];
    if (deviceSimulation.printer) {
      deviceList.add(simulatedPrinter);
    }
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      // logger.safeLog('DEVICE NAME : ${device.name} ');
      deviceList.add(PrinterModel(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
    });
    await _subscription?.asFuture();
    await _subscription?.cancel();
    logger.safeLog('deviceList : $deviceList');
    return deviceList;
  }

  Future<void> stopSubscription() async {
    _subscription?.cancel();
    _subscriptionUsbStatus?.cancel();
    _subscriptionBtStatus?.cancel();
  }

  Future<bool> connectPrinter() async {
    logger.safeLog('printerList.length : ${printerList.length}');
    // // List<PrinterModel> printers = await getListDevices();
    // if (printerList.length == 1) {
    //   currPrinter = printerList.first;
    //   logger.safeLog('NAME : ${currPrinter?.deviceName}');
    //   await disconnect(currPrinter!);
    //   await connect(currPrinter!);

    //   // stoped subsciption
    //   _subscription?.cancel();
    //   _subscriptionUsbStatus?.cancel();
    //   _subscriptionBtStatus?.cancel();

    //   logger.safeLog('IS CONNECTED : $_isConnected');
    //   return Future.value(_isConnected);
    // } else {
    //   currPrinter = null;
    //   return Future.value(false);
    // }
    // currPrinter = null;
    // return Future.value(false);
    if (currPrinter == null) {
      return connectPrinterFirst();
    } else {
      return Future.value(_isConnected);
    }
  }

  // connect default is usb
  Future<bool> connectPrinterFirst() async {
    List<PrinterModel> printers = await getListDevicesUsb();
    logger.safeLog('printerList.length : ${printerList.length}');
    printerList = printers;
    // if (printers.length == 1) {
    //   if (currPrinter?.typePrinter == PrinterType.usb) {
    //     currPrinter = printers.first;
    //     logger.safeLog('NAME : ${currPrinter?.deviceName}');
    //     await disconnect(currPrinter!);
    //     await connect(currPrinter!);

    //     // stoped subsciption
    //     _subscription?.cancel();
    //     _subscriptionUsbStatus?.cancel();
    //     _subscriptionBtStatus?.cancel();

    //     logger.safeLog('IS CONNECTED : $_isConnected');
    //     return Future.value(_isConnected);
    //   } else {
    //     currPrinter = null;
    //     return Future.value(false);
    //   }
    // } else {
    //   for (var element in printers) {
    //     if (element.typePrinter == PrinterType.usb) {
    //       currPrinter = element;
    //       logger.safeLog('NAME : ${element.deviceName}');
    //       await disconnect(element);
    //       await connect(element);

    //       // stoped subsciption
    //       _subscription?.cancel();
    //       _subscriptionUsbStatus?.cancel();
    //       _subscriptionBtStatus?.cancel();

    //       logger.safeLog('IS CONNECTED : $_isConnected');
    //       return Future.value(_isConnected);
    //     }
    //   }
    //   currPrinter = null;
    //   return Future.value(false);
    // }

    if (printers.isNotEmpty) {
      for (var element in printers) {
        // Printer gelang tidak boleh dipungut jadi printer struk.
        //
        // Pemilihan otomatis ini mengambil printer USB pertama yang ditemukan.
        // Di outlet yang printer struknya belum tercolok, satu-satunya kandidat
        // adalah printer gelang — lalu struk ikut tercetak di atas gelang,
        // lengkap dengan QR-nya. Di tangan, itu terlihat seperti "dua QR dalam
        // satu gelang", dan sebabnya sama sekali tidak kelihatan.
        if (wristbandPrinter != null &&
            element.kunci == wristbandPrinter!.kunci) {
          logger.safeLog('LEWATI ${element.deviceName} : itu printer gelang, '
              'bukan kandidat printer struk');
          continue;
        }
        if (element.typePrinter == PrinterType.usb) {
          currPrinter = element;
          logger.safeLog('NAME : ${element.deviceName}');
          await disconnect(element);
          await connect(element);
          break;
        }
      }
    }

    // stoped subsciption
    _subscription?.cancel();
    _subscriptionUsbStatus?.cancel();
    _subscriptionBtStatus?.cancel();
    logger.safeLog('IS CONNECTED : $_isConnected');
    return Future.value(_isConnected);
  }

  /// Printer tiruan yang ditawarkan saat mode simulasi menyala, supaya alur
  /// "pilih printer lalu cetak" bisa dijalani utuh tanpa perangkat.
  static final PrinterModel simulatedPrinter = PrinterModel(
    deviceName: 'Printer Simulasi',
    address: 'simulasi',
    typePrinter: PrinterType.network,
    state: true,
  );

  static bool isSimulated(PrinterModel? printer) =>
      printer?.address == simulatedPrinter.address;

  Future<void> print(PrinterModel selectedPrinter, List<int> bytes) async {
    // Mode simulasi memutus jalur ke perangkat sepenuhnya: byte-nya ditangkap,
    // tidak ada yang dikirim ke USB/Bluetooth/TCP. Diperiksa paling awal supaya
    // tidak ada cabang di bawah yang bisa lolos ke perangkat.
    if (deviceSimulation.printer || isSimulated(selectedPrinter)) {
      await printCapture.capture(bytes);
      return;
    }

    // logger.safeLog('_currentStatus : $_currentStatus');
    // logger.safeLog('selectedPrinter : ${selectedPrinter.typePrinter}');
    // logger.safeLog('Platform.isAndroid : ${Platform.isAndroid}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusUSB}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusBT}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusTCP}');
    await _kirim(selectedPrinter, bytes);
  }

  /// Mengembalikan **apakah byte-nya benar-benar diterima perangkat**.
  ///
  /// Hasil ini dulu hanya dicatat ke log lalu dibuang, dan itu menyesatkan:
  /// pemanggil tidak punya cara membedakan cetakan yang keluar dari cetakan yang
  /// gagal, jadi ia melaporkan berhasil apa pun yang terjadi. Bluetooth Android
  /// bahkan tidak mengirim apa-apa saat belum tersambung — diam total.
  Future<bool> _kirim(PrinterModel selectedPrinter, List<int> bytes) async {
    // Satu-satunya tempat yang memastikan byte pergi ke perangkat yang dimaksud.
    // Diletakkan di sini, bukan di pemanggil, supaya tidak ada jalur cetak yang
    // bisa melewatinya — struk maupun gelang, jenis sambungan apa pun.
    if (!await _pastikanSiap(selectedPrinter)) {
      logger.safeLog('KIRIM DIBATALKAN : ${selectedPrinter.deviceName} '
          '(${_namaJenis(selectedPrinter.typePrinter)}) tidak jadi aktif');
      return false;
    }

    // Disalin ke daftar biasa sebelum menyeberang ke Android. `Uint8List`
    // bertipe `List<int>` juga, jadi Dart tidak memberi peringatan apa pun —
    // tetapi jembatan Flutter mengirimkannya sebagai `byte[]`, sedangkan plugin
    // printer hanya menerima `ArrayList`, lalu melempar ClassCastException yang
    // di sini hanya tampak sebagai "cetak gagal". Dijaga di satu tempat yang
    // dilewati semua cetakan, supaya penyusun byte mana pun aman.
    final isPrinted = await printerManager.send(
        type: selectedPrinter.typePrinter,
        bytes: bytes is Uint8List ? List<int>.from(bytes) : bytes);
    if (selectedPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      // Dipakai listener status: bila sambungan bluetooth sempat putus lalu
      // pulih, cetakan yang tertunda dikirim ulang.
      pendingTask = bytes;
    }
    logger.safeLog('IS PRINT : $isPrinted (${selectedPrinter.deviceName})');
    return isPrinted;
  }

  static String _namaJenis(PrinterType jenis) {
    switch (jenis) {
      case PrinterType.usb:
        return 'USB';
      case PrinterType.bluetooth:
        return 'Bluetooth';
      case PrinterType.network:
        return 'Jaringan';
      default:
        return '?';
    }
  }

  /// Memastikan perangkat yang dituju benar-benar tersambung sebelum mengirim.
  ///
  /// Dulu hanya USB yang diperiksa, dan itu lubang yang nyata: printer gelang
  /// tidak harus USB. Printer Bluetooth tidak pernah tersambung sama sekali —
  /// tidak ada satu pun jalur yang menyambungkannya — sehingga setiap cetakan
  /// gagal tanpa sebab yang kelihatan.
  Future<bool> _pastikanSiap(PrinterModel target) async {
    switch (target.typePrinter) {
      case PrinterType.usb:
        if (!Platform.isAndroid) return true;
        return _pastikanUsbSiap(target);
      case PrinterType.bluetooth:
        return _pastikanBtSiap(target);
      case PrinterType.network:
        return _pastikanTcpSiap(target);
      default:
        return true;
    }
  }

  Future<bool> _pastikanBtSiap(PrinterModel target) async {
    if (target.address == null || target.address!.isEmpty) {
      logger.safeLog('BT ${target.deviceName} tidak punya alamat');
      return false;
    }
    if (_btAktif == target.kunci && _currentStatus == BTStatus.connected) {
      return true;
    }

    final menunggu = Completer<bool>();
    StreamSubscription<BTStatus>? langganan;
    try {
      langganan = printerManager.stateBluetooth.listen((status) {
        if (menunggu.isCompleted) return;
        if (status == BTStatus.connected) menunggu.complete(true);
        if (status == BTStatus.none) menunggu.complete(false);
      });

      final tersambung = await printerManager.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: target.deviceName,
          address: target.address!,
          isBle: target.isBle ?? false,
          autoConnect: _reconnect,
        ),
      );

      // Berbeda dari USB, connect() bluetooth sudah mengembalikan hasil
      // sambungan yang sebenarnya; siarannya hanya dipakai bila ia belum tahu.
      final siap = tersambung ||
          await menunggu.future
              .timeout(const Duration(seconds: 20), onTimeout: () => false);

      _btAktif = siap ? target.kunci : null;
      if (siap) _currentStatus = BTStatus.connected;
      logger.safeLog('BT ${target.deviceName} : ${siap ? "aktif" : "gagal"}');
      return siap;
    } catch (e) {
      logger.safeLog('BT gagal disiapkan : $e');
      _btAktif = null;
      return false;
    } finally {
      await langganan?.cancel();
    }
  }

  Future<bool> _pastikanTcpSiap(PrinterModel target) async {
    if (target.address == null || target.address!.isEmpty) {
      logger.safeLog('TCP ${target.deviceName} tidak punya alamat');
      return false;
    }
    if (_tcpAktif == target.kunci) return true;
    try {
      final tersambung = await printerManager.connect(
        type: PrinterType.network,
        model: TcpPrinterInput(ipAddress: target.address!),
      );
      _tcpAktif = tersambung ? target.kunci : null;
      logger.safeLog(
          'TCP ${target.address} : ${tersambung ? "aktif" : "gagal"}');
      return tersambung;
    } catch (e) {
      logger.safeLog('TCP gagal disiapkan : $e');
      _tcpAktif = null;
      return false;
    }
  }

  /// Memastikan printer USB yang dimaksud benar-benar yang aktif di Android.
  ///
  /// `selectDevice()` di sisi Android menutup sambungan lama lalu **meminta
  /// izin** untuk perangkat baru dan langsung mengembalikan true; perpindahannya
  /// selesai belakangan lewat siaran izin. Jadi yang ditunggu adalah siarannya,
  /// bukan nilai balik `connect()`.
  ///
  /// Siarannya sendiri sudah cukup jelas untuk diikuti sampai selesai, dan itu
  /// yang dipakai di sini alih-alih menebak lewat tenggat waktu:
  ///
  /// - `connecting` — dialog izin sedang ditampilkan. **Ditunggu**, tidak
  ///   dianggap siap. Melanjutkan di sini berarti mengirim byte sebelum izinnya
  ///   ada, dan printer menolaknya diam-diam.
  /// - `connected` — izin diberikan, perangkatnya siap.
  /// - `none` — izin ditolak atau perangkatnya lepas. Gagal.
  ///
  /// Sisi Android selalu menyiarkan keadaannya saat `selectDevice` dipanggil,
  /// termasuk saat perangkatnya memang sudah terpilih — jadi diamnya siaran
  /// berarti ada yang tidak beres, bukan berarti sudah siap.
  Future<bool> _pastikanUsbSiap(PrinterModel target) async {
    logger.safeLog('USB SIAPKAN : ${target.deviceName} '
        'vendor=${target.vendorId} product=${target.productId} '
        '(aktif sekarang: ${_usbAktif ?? "belum diketahui"})');
    if (_usbAktif != null && _usbAktif == target.kunci) return true;

    final menunggu = Completer<bool>();
    var izinDiminta = false;

    StreamSubscription<USBStatus>? langganan;
    try {
      // Langganan sendiri, bukan yang dibuat init(): langganan itu dimatikan
      // stopSubscription() setiap kali layar Pengaturan memilih printer.
      langganan = printerManager.stateUSB.listen((status) {
        if (menunggu.isCompleted) return;
        switch (status) {
          case USBStatus.connected:
            menunggu.complete(true);
            break;
          case USBStatus.none:
            menunggu.complete(false);
            break;
          case USBStatus.connecting:
            // Dialog izin muncul. Biarkan menunggu; catat supaya pesan
            // gagalnya bisa menyebut sebab yang benar.
            izinDiminta = true;
            break;
        }
      });

      final diterima = await printerManager.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          name: target.deviceName,
          productId: target.productId,
          vendorId: target.vendorId,
        ),
      );
      if (!diterima) {
        logger.safeLog('USB ${target.deviceName} tidak ditemukan '
            '(vendor ${target.vendorId}, product ${target.productId})');
        _usbAktif = null;
        return false;
      }

      final siap = await menunggu.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
      _usbAktif = siap ? target.kunci : null;
      if (siap && izinDiminta) {
        // Jeda yang sama dipakai plugin ini sendiri setelah siaran tersambung.
        // Siaran itu menandakan izinnya sudah ada, bukan bahwa salurannya sudah
        // terbuka — mengirim byte tepat di detik itu masih bisa ditolak.
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      if (!siap) {
        logger.safeLog(izinDiminta
            ? 'USB ${target.deviceName} : izin belum disetujui'
            : 'USB ${target.deviceName} : tidak ada siaran status');
      } else {
        logger.safeLog('USB AKTIF : ${target.deviceName}');
      }
      return siap;
    } catch (e) {
      logger.safeLog('USB gagal disiapkan : $e');
      _usbAktif = null;
      return false;
    } finally {
      await langganan?.cancel();
    }
  }

  /// Mencetak ke printer gelang, lalu mengembalikan sambungan ke printer struk.
  ///
  /// `PrinterManager` menyimpan **satu** sambungan per jenis: dua printer USB
  /// tidak bisa aktif bersamaan, dan `send(type: usb)` pergi ke printer USB mana
  /// pun yang sedang dipegang sisi Android. Perpindahannya ditangani [_kirim]
  /// lewat [_pastikanUsbSiap] — di sana, bukan di sini, supaya cetakan struk
  /// berikutnya ikut terlindungi saat harus berpindah kembali.
  ///
  /// Mengembalikan false bila printer gelang belum diatur, atau bila byte-nya
  /// tidak sampai ke perangkat — pemanggil memakai itu untuk jatuh kembali ke
  /// cetak QR di kertas struk, dan untuk tidak mengaku berhasil.
  Future<HasilCetakGelang> printWristband(List<int> bytes) async {
    final target = wristbandPrinter;
    if (target == null) return HasilCetakGelang.belumDiatur;

    // Mode simulasi memutus jalur ke perangkat sepenuhnya. Dilaporkan sebagai
    // hasil tersendiri, bukan sebagai "berhasil": tidak ada gelang yang keluar,
    // dan menyebutnya berhasil membuat orang menunggu kertas yang tidak akan
    // pernah datang.
    if (deviceSimulation.printer || isSimulated(target)) {
      await printCapture.capture(bytes);
      return HasilCetakGelang.simulasi;
    }

    final printerStruk = currPrinter;

    try {
      // Tidak ada tarian sambung–putus di sini. `disconnect()` untuk USB di
      // Android tidak melakukan apa-apa (plugin hanya menutup sambungan di
      // Windows), jadi mengandalkannya justru menyembunyikan masalah.
      final terkirim = await _kirim(target, bytes);
      return terkirim ? HasilCetakGelang.terkirim : HasilCetakGelang.gagal;
    } catch (e) {
      logger.safeLog('CETAK GELANG GAGAL : $e');
      return HasilCetakGelang.gagal;
    } finally {
      // `connect()` menggeser penanda printer aktif; kembalikan ke printer struk
      // supaya cetakan struk berikutnya tidak diam-diam pergi ke printer gelang.
      currPrinter = printerStruk;
    }
  }
}

/// Hasil satu upaya cetak gelang.
///
/// Empat keadaan, bukan satu bool, karena ketiga kegagalannya butuh jawaban yang
/// berbeda dari orang di depan kasir: printer belum dipilih, mode simulasi masih
/// menyala, atau perangkatnya menolak. Menyamakan ketiganya jadi "gagal" membuat
/// orang mencabut kabel padahal yang salah adalah saklar simulasi.
enum HasilCetakGelang {
  /// Byte-nya diterima perangkat.
  terkirim,

  /// Printer gelang belum dipilih di Setting.
  belumDiatur,

  /// Mode simulasi menyala — cetakan ditangkap ke pratinjau, tidak ada kertas.
  simulasi,

  /// Perangkat menolak atau sambungannya putus.
  gagal,
}

PrinterUtil printerUtil = PrinterUtil();
