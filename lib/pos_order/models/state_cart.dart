class StateCart {
  String position;
  int check;
  String time;
  int loginNumber;

  StateCart({this.position, this.check, this.time, this.loginNumber});

  StateCart.fromJson(Map<String, dynamic> json) {
    position = json['tb_cart_position'];
    check = json['tb_cart_check'];
    time = json['Time'];
    loginNumber = json['LoginNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tb_cart_position'] = this.position;
    data['tb_cart_check'] = this.check;
    data['Time'] = this.time;
    data['LoginNumber'] = loginNumber;
    return data;
  }
}
