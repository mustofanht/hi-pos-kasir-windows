import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

class CartAddon {
  int? qtyOrder;
  double? totalPrice;
  CartRentModel? rentModel;
  AddonEntity? addon;

  /// mst_ticket_bundle.bundle_id bila baris ini lahir dari bundling tiket.
  /// null = item yang dipilih kasir sendiri. Baris bundling tidak bisa diubah
  /// qty-nya di keranjang — ia mengikuti jumlah tiketnya.
  int? bundleId;

  bool get isBundle => bundleId != null;

  /// Booking sesi kelas (tab Kelas). Barisnya memakai addon ber-productType
  /// 'K' supaya tampil & dihitung seperti item di keranjang, tetapi dikirim ke
  /// backend sebagai `trnOrderBookeds` (sesi + tanggal + jumlah anak), bukan
  /// sebagai produk. productId-nya negatif (-sessionId) agar tidak bertabrakan
  /// dengan id produk sungguhan.
  int? kelasTicketId;
  int? kelasSessionId;
  DateTime? kelasDate;

  /// Sisa kursi saat sesi dimasukkan ke keranjang; batas tombol + di keranjang.
  /// Backend tetap memeriksa ulang kuota saat order dibuat.
  int? kelasSisa;

  /// Tampilan ringkas di keranjang: nama kelas + baris kecil sesi/jam.
  /// productName tetap lengkap untuk struk & layar kedua.
  String? kelasNama;
  String? kelasSesi;

  bool get isKelas => addon?.productType == 'K' && kelasSessionId != null;

  CartAddon({
    this.qtyOrder,
    this.totalPrice,
    this.rentModel,
    this.addon,
    this.bundleId,
    this.kelasTicketId,
    this.kelasSessionId,
    this.kelasDate,
    this.kelasSisa,
    this.kelasNama,
    this.kelasSesi,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "rentModel": rentModel != null ? rentModel!.toJson() : {},
      "addon": addon != null ? addon!.toJson() : [],
      "bundleId": bundleId,
      "kelasTicketId": kelasTicketId,
      "kelasSessionId": kelasSessionId,
      "kelasDate": kelasDate?.toIso8601String(),
      "kelasSisa": kelasSisa,
      "kelasNama": kelasNama,
      "kelasSesi": kelasSesi,
    };
  }

  CartAddon.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      // Harga bundling gratis bisa tiba sebagai int 0 setelah melewati kanal layar
      // kedua; menugaskannya langsung ke double? melempar dan seluruh baris hilang.
      totalPrice = (json['totalPrice'] as num?)?.toDouble();
      bundleId = json['bundleId'];
      kelasTicketId = json['kelasTicketId'];
      kelasSessionId = json['kelasSessionId'];
      kelasDate = json['kelasDate'] != null
          ? DateTime.tryParse('${json['kelasDate']}')
          : null;
      kelasSisa = json['kelasSisa'];
      kelasNama = json['kelasNama'];
      kelasSesi = json['kelasSesi'];
      // rentModel = json['rentModel'];

      if (json['rentModel'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['rentModel']);
        rentModel = CartRentModel.fromJson(result);
      } else {
        rentModel = CartRentModel.fromJson(json['addon']);
      }
      if (json['addon'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['addon']);
        addon = AddonEntity.fromJson(result);
      } else {
        addon = AddonEntity.fromJson(json['addon']);
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
