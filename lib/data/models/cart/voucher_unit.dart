import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';

/// Satu "unit" yang bisa dikenai 1 voucher. Aturan bisnis: 1 voucher = 1 unit,
/// di mana 1 unit = 1 tiket ATAU 1 jam booking lapangan.
class VoucherUnit {
  final double unitPrice;
  int remaining;

  VoucherUnit({required this.unitPrice, required this.remaining});
}

/// Booking lapangan pada keranjang = addon dengan [CartAddon.rentModel] terisi
/// dan produk bertipe 'L' (tiket lapangan). Rental item/produk hourly lain
/// (mis. productType 'H') sengaja TIDAK ikut, karena voucher hanya berlaku
/// untuk tiket dan booking lapangan.
bool _isLapanganBooking(CartAddon addon) =>
    addon.rentModel != null && addon.addon?.productType == 'L';

/// Bangun daftar unit voucher dari tiket + booking lapangan.
///
/// Tiap tiket menyumbang `qtyOrder` unit dengan harga per unit
/// `totalPrice / qtyOrder` (= harga tiket). Tiap booking lapangan menyumbang
/// `rentModel.totalHours` unit (1 unit = 1 jam) dengan harga per unit
/// `totalPrice / totalHours` (= harga per jam pada blok jam tersebut).
List<VoucherUnit> buildVoucherUnits({
  required List<CartTicket> ticketList,
  required List<CartAddon> addonList,
}) {
  final List<VoucherUnit> units = [];

  for (final ticket in ticketList) {
    final int qty = ticket.qtyOrder ?? 0;
    if (qty <= 0) continue;
    units.add(
      VoucherUnit(unitPrice: (ticket.totalPrice ?? 0) / qty, remaining: qty),
    );
  }

  for (final addon in addonList) {
    if (!_isLapanganBooking(addon)) continue;
    final int hours = addon.rentModel?.totalHours ?? 0;
    if (hours <= 0) continue;
    units.add(
      VoucherUnit(unitPrice: (addon.totalPrice ?? 0) / hours, remaining: hours),
    );
  }

  return units;
}

/// Jumlah unit yang bisa dikenai voucher (tiket + jam booking lapangan).
/// Dipakai validasi: qty voucher tidak boleh melebihi jumlah unit ini.
int countVoucherUnits({
  required List<CartTicket> ticketList,
  required List<CartAddon> addonList,
}) {
  int total = 0;
  for (final ticket in ticketList) {
    total += ticket.qtyOrder ?? 0;
  }
  for (final addon in addonList) {
    if (!_isLapanganBooking(addon)) continue;
    total += addon.rentModel?.totalHours ?? 0;
  }
  return total;
}
