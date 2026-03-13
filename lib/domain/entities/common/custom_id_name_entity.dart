class CustomIdNameEntity {
  String? id;
  String? name;
  String? encodeImage;

  CustomIdNameEntity({
    this.id,
    this.name,
    this.encodeImage,
  });

  CustomIdNameEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    encodeImage = json['encode_image'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "encode_image": encodeImage,
    };
  }
}
