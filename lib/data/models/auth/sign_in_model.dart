class SignInModel {
  String? username;
  String? password;

  SignInModel({
    required this.username,
    required this.password,
  });

  SignInModel.fromJson(Map<String, dynamic> json) {
    username = json["username"];
    password = json["password"];
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
    };
  }
}
