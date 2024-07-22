import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/auth/sign_in_model.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/resources/network_source.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/base_response.dart';
import 'package:jaya_propertiy/domain/entities/order/response_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/payment/response_cek_payment_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';

part 'auth_service.dart';
part 'sale_service.dart';
part 'order_service.dart';
part 'payment_service.dart';
part 'message_service.dart';
part 'sale/ticket_service.dart';
part 'sale/voucher_service.dart';
part 'sale/addon_service.dart';
part 'order/order_ticket_service.dart';
part 'payment/payment_order_service.dart';

class MainService {
  final auth = AuthService();
  final sale = SaleService();
  final order = OrderService();
  final payment = PaymentService();
  final message = MessageService();
}
