class AuthToken {
  String? token;
  int? expiresIn;

  AuthToken({
    this.token,
    this.expiresIn,
  });

  AuthToken.empty();

  AuthToken.fromJson(Map<String, dynamic> json) {
    token = json["token"];
    expiresIn = json["expiresIn"];
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "expiresIn": expiresIn,
    };
  }
}
