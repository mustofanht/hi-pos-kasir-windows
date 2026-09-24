import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_tampilan.dart';
import 'package:jaya_propertiy/app/utils/common/local_storage_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:intl/intl.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/promo/promo_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';

class AppCommon {
  globalInitialize() async {
    // await GetStorage.init("sessions");
    await printerUtil.init();
    // Dibaca sebelum menyambung supaya printer gelang yang tersimpan sudah
    // dikenali saat cetakan pertama datang.
    printerUtil.muatSetelanGelang();
    await printerUtil.connectPrinterFirst();
    logger.safeLog('CURR PRINTER : ${printerUtil.currPrinter?.deviceName}');
  }

  Future<bool> isDeviceTablet() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      return androidInfo.systemFeatures
          .contains('android.hardware.screen.large');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      return iosInfo.model.contains('iPad');
    }

    return false; // default ke handphone
  }

  Future<UserEntity?> getUser({required AuthToken authToken}) async {
    final _service = MainService();
    UserEntity? userEntity;
    try {
      final result = await _service.auth.getUserInformation(
        authToken: authToken,
        userId: sessionUtil.getUserName(),
      );

      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        userEntity = r.data!;
      });
      if (userEntity != null) {
        await _lengkapiKontakLokasi(authToken, userEntity!);
      }
      return userEntity;
    } catch (e) {
      logger.safeLog(e);
      return null;
    }
  }

  /// Kontak lokasi terakhir yang berhasil dimuat, per id lokasi. Dipakai bila
  /// server sedang tidak terjangkau saat struk dicetak, supaya kepala struk
  /// tidak tiba-tiba kehilangan alamatnya.
  final Map<int, ({String? alamat, String? telepon, String? logoPelanggan, String? teksPelanggan})>
      _kontakLokasi = {};

  Future<void> _lengkapiKontakLokasi(AuthToken authToken, UserEntity user) async {
    final locId = user.userLocId;
    if (locId == null) return;
    if (user.locationAddress != null || user.locationPhone != null) return;
    try {
      final hasil = await MainService().auth.getKontakLokasi(
            authToken: authToken,
            locId: locId,
          );
      hasil.fold(
        (l) => logger.safeLog('Kontak lokasi $locId gagal dimuat : $l'),
        (r) => _kontakLokasi[locId] = r,
      );
    } catch (e) {
      logger.safeLog('Kontak lokasi $locId gagal dimuat : $e');
    }
    final kontak = _kontakLokasi[locId];
    user.locationAddress = kontak?.alamat;
    user.locationPhone = kontak?.telepon;

    // Disimpan ke penyimpanan perangkat, bukan sekadar disimpan di memori:
    // layar pelanggan berjalan di engine Flutter tersendiri — jendela kedua di
    // Windows, Presentation di Android — jadi ia tidak bisa membaca objek user
    // milik layar kasir. Lewat penyimpanan, bilah atasnya sudah benar sejak
    // layar itu pertama digambar, tanpa menunggu transaksi pertama.
    layarPelangganTampilan.simpan(
      logo: kontak?.logoPelanggan,
      teks: kontak?.teksPelanggan,
    );
    await kirimTampilanLayarPelanggan();
  }

  /// Memuat logo & teks sambutan outlet, lalu mengirimkannya ke layar pelanggan.
  ///
  /// Dipanggil saat kasir sampai di halaman utama. Sebelumnya keterangan lokasi
  /// hanya dimuat lewat [getUser], dan [getUser] hanya dipanggil pada alur
  /// cetak — sehingga logo dan sambutan tidak pernah tampil sampai kasir
  /// kebetulan mencetak sesuatu.
  Future<void> muatTampilanLayarPelanggan(AuthToken authToken) async {
    try {
      final user = await getUser(authToken: authToken);
      if (user == null) await kirimTampilanLayarPelanggan();
    } catch (e) {
      logger.safeLog('Tampilan layar pelanggan gagal dimuat : $e');
    }
  }

  /// Mengirim logo & teks yang tersimpan ke layar pelanggan yang sedang terbuka.
  ///
  /// Layar pelanggan berjalan di engine Flutter tersendiri dan membaca
  /// penyimpanan perangkat satu kali saat dibuka — padahal ia biasanya dibuka
  /// sebelum kasir login. Tanpa kiriman ini, setelan yang baru disimpan tidak
  /// akan tampil sampai aplikasi dijalankan ulang.
  Future<void> kirimTampilanLayarPelanggan() async {
    await displayUtil.updateSecondDisplay(
      CustomerDisplay(
        key: CustomerDisplayAction.BRANDING,
        value: {
          'logo': layarPelangganTampilan.logo ?? '',
          'teks': layarPelangganTampilan.teks ?? '',
        },
      ).toJson(),
    );
  }

  String randomString(int length) {
    const chars =
        "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";

    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  String setMaxLength({required String data, required int length}) {
    String result = "";

    if (data.length > length) {
      result = "${data.substring(0, length - 1)}...";
    } else {
      result = data;
    }

    return result;
  }

  String getMetadataMessages(String jsonData) {
    String messages = "";
    if (jsonData.isNotEmpty) {
      if (json.decode(jsonData)["message"].runtimeType == List) {
        messages = json.decode(jsonData)["message"].first;
      } else {
        messages = json.decode(jsonData)["message"];
      }
    } else {
      messages = "gagal ambil data!";
    }
    return messages;
  }

  Map<String, String> generateHeader({
    AuthToken? sessionToken,
    String? contentType,
  }) {
    if (sessionToken != null) {
      return {
        "Authorization": "Bearer ${sessionToken.token}",
        "Accept": "application/json",
        "Content-Type":
            (contentType != null) ? contentType : "application/json",
      };
    } else {
      return {
        "Accept": "application/json",
        "Content-Type":
            (contentType != null) ? contentType : "application/json",
      };
    }
  }

  String maxLengthFileName({required String value, required int maxCount}) {
    if (value.length > maxCount) {
      String finalName = "";
      String ext = ".${value.split(".").last}";
      finalName = "${value.substring(0, maxCount - 1)}... $ext";

      return finalName;
    } else {
      return value;
    }
  }

  String generateNameImage() {
    return 'IMG-${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}';
  }

  bool isNullOrEmpty(dynamic data) {
    // logger.safeLog("$data is ${data.runtimeType}");
    bool isEmpty = false;

    if (data == null) {
      isEmpty = true;
    }

    if (data.runtimeType == List) {
      if (!isEmpty && data != null && data.isEmpty) {
        isEmpty = true;
      }

      if (!isEmpty && data == []) {
        isEmpty = true;
      }
    }

    // if (data.runtimeType == Map) {
    //   if (data.isEmpty) {
    //     isEmpty = true;
    //   }

    //   if (data == {}) {
    //     isEmpty = true;
    //   }
    // }

    if (data.runtimeType == String) {
      if (data.isEmpty) {
        isEmpty = true;
      }

      if (!isEmpty && data == "") {
        isEmpty = true;
      }

      if (!isEmpty && data == "-") {
        isEmpty = true;
      }
    }

    // logger.safeLog(isEmpty);

    return isEmpty;
  }

  Widget generateAvatar({required String name, double? fs}) {
    if (name.contains(" ")) {
      var splitName = name.toUpperCase().split(" ");
      return CircleAvatar(
        child: Text(
          splitName[0][0] + splitName[1][0],
          style: GoogleFonts.poppins(
            fontSize: fs ?? fontSize.title,
            fontWeight: fontWeight.bold,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        child: Text(
          name.toUpperCase()[0] + name.toUpperCase()[1],
          style: GoogleFonts.poppins(
            fontSize: fs ?? fontSize.title,
            fontWeight: fontWeight.bold,
          ),
        ),
      );
    }
  }

  String currencyFormat(double value) {
    String result = "";

    try {
      var format = NumberFormat("###,###,###,###", "id_ID");

      result = format.format(value);
    } catch (e) {
      logger.safeLog(e);
    }

    return result;
  }

  List<T> fromJsonList<T>(
      List<dynamic> jsonList, T Function(dynamic) fromJsonT) {
    return jsonList.map((e) => fromJsonT(e)).toList();
  }

  Map<String, dynamic> convertToMapStringDynamic(
      Map<Object?, Object?> original) {
    return original.map((key, value) => MapEntry(key.toString(), value));
  }

  bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  doRefreshAds(AuthToken authToken) async {
    // await common.getImagePromo(authToken);

    logger.safeLog("Start getImagePromo ----------------------------- ");
    final _service = MainService();
    try {
      var locParam = sessionUtil.getLocationIdsQueryParam();
      if (locParam.isNotEmpty) {
        var result = await _service.promo.getPromoByLoc(
          authToken: authToken,
          locParam: locParam,
        );
        result.fold((l) {
          logger.safeLog(l);
          alert.error('Error', 'Terjadi Kesalahan!');
        }, (r) async {
          List<PromoEntity> listData = [];
          listData = r.data!;
          String finDir = await localStorage.deleteDirPromo();
          if (listData.isNotEmpty) {
            for (var element in listData) {
              var imageUrl = element.prmPathImg!;
              await localStorage.downloadAndSaveImagePromo(imageUrl, finDir);
            }
          }
          await displayUtil.updateSecondDisplay(constant.refreshAds);
        });
      }
    } catch (e) {
      logger.safeLog(e);
    }
    logger.safeLog("End getImagePromo ----------------------------- ");
  }

  getImagePromo(AuthToken authToken) async {
    logger.safeLog("Start getImagePromo ----------------------------- ");
    final _service = MainService();
    try {
      var locParam = sessionUtil.getLocationIdsQueryParam();
      if (locParam.isNotEmpty) {
        var result = await _service.promo.getPromoByLoc(
          authToken: authToken,
          locParam: locParam,
        );
        result.fold((l) {
          logger.safeLog(l);
        }, (r) async {
          List<PromoEntity> listData = [];
          listData = r.data!;
          String finDir = await localStorage.deleteDirPromo();
          if (listData.isNotEmpty) {
            for (var element in listData) {
              var imageUrl = element.prmPathImg!;
              await localStorage.downloadAndSaveImagePromo(imageUrl, finDir);
            }
          }
        });
      }
    } catch (e) {
      logger.safeLog(e);
    }
    logger.safeLog("End getImagePromo ----------------------------- ");
  }

  Widget getQrImg(String? qrCode) {
    if (qrCode == null || qrCode.isEmpty) {
      return const Center(child: Text('QR belum tersedia'));
    }
    // Backend mengirim URL gambar (http/https) → muat langsung.
    if (qrCode.contains('http')) {
      return Image.network(qrCode, fit: BoxFit.fill, errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return const Center(child: Text('QR gagal dimuat'));
      });
    }
    // Selain itu dianggap payload QRIS (string) → gambar QR di sisi aplikasi.
    return QrImageView(
      data: qrCode,
      version: QrVersions.auto,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(12),
    );
  }

  Future<bool> shiftActive(AuthToken _authToken) async {
    MainService _service = MainService();
    bool isActive = true;
    var result = await _service.shift.getCurrentShift(authToken: _authToken);
    result.fold(
      (l) {
        logger.safeLog(l);
        isActive = false;
      },
      (r) {
        logger.safeLog(r);
        isActive = (r != null);
      },
    );
    return isActive;
  }

  Widget underConstruction() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            assetsConstant.imgUnderConstruction,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: layoutStyle.blockHorizontal * 50,
            height: layoutStyle.blockVertical * 50,
          ),
          SizedBox(
            height: layoutStyle.defaultMargin,
          ),
          Text(
            'Under Construction',
            style: TextStyle(
              fontSize: fontSize.header * 2,
              fontWeight: fontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  bool isValidIndonesianPhoneNumber(String phone) {
    final RegExp regex = RegExp(r'^(?:\+62|62|0)[2-9][0-9]{8,11}$');
    return regex.hasMatch(phone);
  }
}

AppCommon common = new AppCommon();
