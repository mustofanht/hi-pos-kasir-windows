import 'package:jaya_propertiy/domain/entities/common/pagination.dart';

class BaseResponse<T> {
  String? timestamp;
  int? statusCode;
  Object? error;
  String? message;
  int? ttlRecords;
  int? ttlPages;
  int? pageNo;
  int? pageRecords;
  Pagination? pagination;
  T? data;

  BaseResponse({
    this.timestamp,
    this.statusCode,
    this.error,
    this.message,
    this.ttlRecords,
    this.ttlPages,
    this.pageNo,
    this.pageRecords,
    this.pagination,
    this.data,
  });

  BaseResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    timestamp = json['timestamp'];
    statusCode = json['statusCode'];
    error = json['error'];
    message = json['message'];
    ttlRecords = json['ttlRecords'];
    ttlPages = json['ttlPages'];
    pageNo = json['pageNo'];
    pageRecords = json['pageRecords'];
    // data = json['data'];
    data = json['data'] != null ? fromJsonT(json['data']) : null;

    pagination = Pagination(
      currentElement: pageRecords,
      currentPage: pageNo,
      totalElement: ttlRecords,
      totalPage: ttlPages,
    );
  }
}
