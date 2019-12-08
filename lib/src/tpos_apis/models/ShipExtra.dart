class ShipExtra {
  String deliverWorkShift;
  String deliverWorkShiftName;
  String pickWorkShift;
  String pickWorkShiftName;
  bool isDropoff;
  String posId;
  dynamic paymentTypeId;

  ShipExtra(
      {this.deliverWorkShift,
      this.deliverWorkShiftName,
      this.pickWorkShift,
      this.pickWorkShiftName,
      this.posId});

  ShipExtra.fromJson(Map<String, dynamic> json) {
    deliverWorkShift = json["DeliverWorkShift"];
    deliverWorkShiftName = json["DeliverWorkShiftName"];
    pickWorkShift = json["PickWorkShift"];
    pickWorkShiftName = json["PickWorkShiftName"];

    posId = json["PosId"];
    isDropoff = json["IsDropoff"];
    paymentTypeId = json["PaymentTypeId"];
  }

  Map<String, dynamic> toJson([bool removeIfNull = false]) {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["DeliverWorkShift"] = deliverWorkShift;
    data["DeliverWorkShiftName"] = deliverWorkShiftName;
    data["PickWorkShift"] = pickWorkShift;
    data["PickWorkShiftName"] = pickWorkShiftName;

    data["PosId"] = posId;
    data["IsDropoff"] = isDropoff;
    data["PaymentTypeId"] = paymentTypeId;

    if (removeIfNull) {
      data.removeWhere((key, value) => value == null);
    }
    return data;
  }
}
