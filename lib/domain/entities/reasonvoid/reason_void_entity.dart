class ReasonVoidEntity {
  final String? reasonCode;
  final String? reasonName;

  ReasonVoidEntity({
    this.reasonCode,
    this.reasonName,
  });

  factory ReasonVoidEntity.fromJson(Map<String, dynamic> json) {
    return ReasonVoidEntity(
      reasonCode: json['reasonCode'],
      reasonName: json['reasonName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reasonCode': reasonCode,
      'reasonName': reasonName,
    };
  }
}
