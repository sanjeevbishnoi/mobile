class PrintShipConfig {
  bool isHideShipAmount = false;
  bool isHideShip = false;
  bool isHideNoteShip = false;
  bool isHideInfoShip = false;
  bool isHideAddress = false;
  bool isShowLogo = true;
  bool isHideCod = false;
  bool isHideInvoiceCode = false;
  bool isShowStaff = false;

  PrintShipConfig(
      {this.isHideShipAmount,
      this.isHideShip,
      this.isHideNoteShip,
      this.isHideInfoShip,
      this.isHideAddress,
      this.isShowLogo,
      this.isHideCod,
      this.isHideInvoiceCode,
      this.isShowStaff});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["IsHideShipAmount"] = isHideShipAmount;
    data["IsHideShip"] = isHideShip;
    data["IsHideNoteShip"] = isHideNoteShip;
    data["IsHideInfoShip"] = isHideInfoShip;
    data["IsHideAddress"] = isHideAddress;
    data["IsShowLogo"] = isShowLogo;
    data["IsHideCod"] = isHideCod;
    data["IsHideInvoiceCode"] = isHideInvoiceCode;
    data["IsShowStaff"] = isShowStaff;
    return data;
  }
}
