// import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/common/ticket_days_entity.dart';

class TicketPriceTimeEntity {
  int? startHour;
  int? endHour;
  double? price;

  TicketPriceTimeEntity({
    this.startHour,
    this.endHour,
    this.price,
  });

  TicketPriceTimeEntity.fromJson(Map<String, dynamic> json) {
    try {
      startHour = json['startHour'];
      endHour = json['endHour'];
      price = json['price'] != null ? (json['price'] as num).toDouble() : null;
    } catch (e) {
      logger.safeLog('error parsing TicketPriceTimeEntity: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'startHour': startHour,
      'endHour': endHour,
      'price': price,
    };
  }
}

class TicketEntity {
  int? ticketId;
  String? ticketName;
  String? ticketType;
  int? ticketLocation;
  String? ticketLocationName;
  // Kategori lokasi tiket (mis. 'PLGRD' = playground). Cadangan bila kategori
  // tiketnya sendiri belum diisi — lihat [kategoriEfektif].
  String? ticketLocationCategory;
  double? ticketPrice;
  String? ticketState;
  int? ticketMinimum;
  String? pathImg;
  TicketDaysEntity? ticketDays;
  String? ticketFlLapangan;
  // Kategori tiket (setup transaction) untuk membedakan setup per kategori pada
  // satu lokasi multi-kategori, mis. KLMRG/LPNGN/WC.
  String? ticketCategory;
  List<TicketPriceTimeEntity>? ticketPriceTimes;

  /// Kategori yang menentukan perlakuan tiket ini: input nama anak & cetak gelang.
  ///
  /// Kategori TIKET dipakai lebih dulu. Satu lokasi bisa menjual beberapa
  /// kategori sekaligus — Club House menjual playground, kolam renang, dan
  /// lapangan dari satu terminal — jadi kategori lokasi tidak mewakili
  /// tiketnya: memakainya membuat tiket kolam ikut diminta nama anak, dan
  /// tiket playground di lokasi yang kategori utamanya bukan playground
  /// malah tidak diminta sama sekali.
  ///
  /// Kategori lokasi tetap dipakai sebagai cadangan untuk tiket lama yang
  /// kategorinya belum diisi di Setup Transaction.
  String? get kategoriEfektif {
    final tiket = ticketCategory?.trim();
    if (tiket != null && tiket.isNotEmpty) return tiket.toUpperCase();
    final lokasi = ticketLocationCategory?.trim();
    if (lokasi != null && lokasi.isNotEmpty) return lokasi.toUpperCase();
    return null;
  }

  /// Tiket playground: yang memicu input nama anak dan dicetak sebagai gelang.
  bool get isPlayground => kategoriEfektif == 'PLGRD';

  TicketEntity({
    this.ticketId,
    this.ticketName,
    this.ticketType,
    this.ticketLocation,
    this.ticketLocationName,
    this.ticketLocationCategory,
    this.ticketPrice,
    this.ticketState,
    this.ticketMinimum,
    this.pathImg,
    this.ticketDays,
    this.ticketFlLapangan,
    this.ticketCategory,
    this.ticketPriceTimes,
  });

  TicketEntity.fromJson(Map<String, dynamic> json) {
    try {
      ticketId = json['ticketId'];
      ticketName = json['ticketName'];
      ticketType = json['ticketType'];
      ticketLocation = json['ticketLocation'];
      ticketLocationName = json['ticketLocationName'];
      ticketLocationCategory = json['ticketLocationCategory'];
      ticketPrice = json['ticketPrice'] != null
          ? (json['ticketPrice'] as num).toDouble()
          : null;
      ticketState = json['ticketState'];
      ticketMinimum = json['ticketMinimum'];
      pathImg = json['pathImg'];
      ticketFlLapangan = json['ticketFlLapangan'];
      ticketCategory = json['ticketCategory'];

      if (json['ticketDays'] != null) {
        if (json['ticketDays'] is Map<Object?, Object?>) {
          Map<String, dynamic> result =
              common.convertToMapStringDynamic(json['ticketDays']);
          ticketDays = TicketDaysEntity.fromJson(result);
        } else {
          ticketDays = TicketDaysEntity.fromJson(json['ticketDays']);
        }
      }

      if (json['ticketPriceTimes'] != null) {
        ticketPriceTimes = <TicketPriceTimeEntity>[];
        if (json['ticketPriceTimes'] is List) {
          json['ticketPriceTimes'].forEach((v) {
            ticketPriceTimes!.add(TicketPriceTimeEntity.fromJson(v));
          });
        }
      }
    } catch (e) {
      logger.safeLog('error $e');
    }
  }
  Map<String, dynamic> toJson() {
    return {
      "ticketId": ticketId,
      "ticketName": ticketName,
      "ticketType": ticketType,
      "ticketLocation": ticketLocation,
      "ticketLocationName": ticketLocationName,
      "ticketLocationCategory": ticketLocationCategory,
      "ticketPrice": ticketPrice,
      "ticketState": ticketState,
      "ticketMinimum": ticketMinimum,
      "pathImg": pathImg,
      "ticketDays": ticketDays?.toJson(),
      "ticketFlLapangan": ticketFlLapangan,
      "ticketCategory": ticketCategory,
      "ticketPriceTimes": ticketPriceTimes?.map((v) => v.toJson()).toList(),
    };
  }
}
