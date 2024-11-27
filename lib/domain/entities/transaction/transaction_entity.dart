class TransactionEntity {
  int? id;
  String? name;
  String? location;
  String? duration;

  TransactionEntity({
    this.id,
    this.name,
    this.location,
    this.duration,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'duration': duration,
    };
  }
}
