class CreateQuickFastSaleOrderResult {
  String odataContext;
  bool success;
  dynamic warning;
  String error;
  int orderId;
  List<int> ids;

  CreateQuickFastSaleOrderResult(
      {this.odataContext,
      this.success,
      this.warning,
      this.error,
      this.orderId});

  CreateQuickFastSaleOrderResult.fromJson(Map<String, dynamic> json) {
    odataContext = json['@odata.context'];
    success = json['Success'];
    warning = json['Warning'];
    error = json['Error'];
    orderId = json['OrderId'];
    if (json["Ids"] != null) ids = json["Ids"].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@odata.context'] = this.odataContext;
    data['Success'] = this.success;
    data['Warning'] = this.warning;
    data['Error'] = this.error;
    data['OrderId'] = this.orderId;
    return data;
  }
}
