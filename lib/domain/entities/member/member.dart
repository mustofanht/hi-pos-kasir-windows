class Member {
  String? number;
  String? name;
  String? membership;
  String? expire;
  String? state;
  String? extend;

  Member({
    this.number,
    this.name,
    this.membership,
    this.expire,
    this.state,
    this.extend,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      number: json['number'],
      name: json['name'],
      membership: json['membership'],
      expire: json['expire'],
      state: json['state'],
      extend: json['extend'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'membership': membership,
      'expire': expire,
      'state': state,
      'extend': extend,
    };
  }
}
