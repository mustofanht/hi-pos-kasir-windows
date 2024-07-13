import 'package:get/get.dart';
import 'package:jaya_propertiy/data/models/proofofpayment/proof_of_payment_model.dart';

class BuktiPembayaranPageController extends GetxController {
  BuktiPembayaranPageController();

  final selectedProofOfPayment = ProofOfPaymentModel();

  List<ProofOfPaymentModel> dummyData = [
    ProofOfPaymentModel(
      id: "1",
      transactionId: "TRX001",
      paymentMethod: "Bank Transfer",
      paymentDate: "2022-01-01",
      amount: "100000",
      status: "Success",
      paymentType: "Online",
    ),
    ProofOfPaymentModel(
      id: "2",
      transactionId: "TRX002",
      paymentMethod: "Credit Card",
      paymentDate: "2022-02-01",
      amount: "200000",
      status: "Pending",
      paymentType: "Offline",
    ),
    ProofOfPaymentModel(
      id: "3",
      transactionId: "TRX003",
      paymentMethod: "Cash",
      paymentDate: "2022-03-01",
      amount: "300000",
      status: "Failed",
      paymentType: "Online",
    ),
  ];
}
