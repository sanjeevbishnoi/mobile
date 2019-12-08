import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';

class PrintFastSaleOrderData {
  String companyName, companyPhone, compnayAddress, companyMoreInfo;
  String carrierName,
      trackingRef,
      trackingRefSort,
      trackingRefToShow,
      shipCode,
      shipNote;
  String invoiceNumber, invoiceNote;
  DateTime invoiceDate, deliveryDate;
  String customerName, customerAddress, customerPhone;
  String receiverName, receiverPhone, receiverAddress;
  String user, userDelivery;
  double subTotal,
      totalAmount,
      oldCredit,
      totalDeb,
      payment,
      shipAmount,
      shipWeight,
      cashOnDeliveryAmount;

  /// Tiền nợ cũ
  double previousBalance;

  /// Doanh số
  double revenue;

  /// Giảm giá phần trăm
  double discount;

  /// Giảm giá phần trăm quy ra tiền
  double discountAmount;

  /// Giảm giá tiền
  double decreaseAmount;

  String companyLogo;
  String totalInWords;

  /// Lưu ý thêm
  String defaultNote;

  List<FastSaleOrderLine> orderLines;

  bool hideProductCode,
      hideDelivery,
      hideDebt,
      hideLogo,
      hideReceiver,
      hideAddress,
      hidePhone,
      hideStaff,
      hideAmountText,
      hideSign,
      hideTrackingRef,
      hideCustomerNam,
      hideProductNote;

  bool showBarcode,
      showWeightShip,
      showCod,
      showRevenue,
      showCombo,
      showTrackingRefSort;

  PrintFastSaleOrderData(
      {this.companyName,
      this.companyPhone,
      this.compnayAddress,
      this.companyMoreInfo,
      this.carrierName,
      this.trackingRef,
      this.trackingRefSort,
      this.trackingRefToShow,
      this.shipCode,
      this.shipNote,
      this.invoiceNumber,
      this.invoiceNote,
      this.invoiceDate,
      this.deliveryDate,
      this.customerName,
      this.customerAddress,
      this.customerPhone,
      this.receiverName,
      this.receiverPhone,
      this.receiverAddress,
      this.subTotal,
      this.totalAmount,
      this.oldCredit,
      this.totalDeb,
      this.payment,
      this.shipAmount,
      this.companyLogo,
      this.orderLines,
      this.user,
      this.userDelivery,
      this.totalInWords,
      this.shipWeight,
      this.previousBalance,
      this.discount,
      this.decreaseAmount,
      this.discountAmount,
      this.defaultNote});

  Map<String, dynamic> toJson([bool removeIfNull = false]) {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["CompanyName"] = companyName;
    data["CompanyPhone"] = companyPhone;
    data["CompanyAddress"] = compnayAddress;
    data["CompanyMoreInfo"] = companyMoreInfo;
    data["CompanyLogo"] = companyLogo;
    data["CarrierName"] = carrierName;
    data["ShipCode"] = shipCode;
    data["TrackingRef"] = trackingRef;
    data["TrackingRefSort"] = trackingRefSort;
    data["TrackingRefToShow"] = trackingRefToShow;
    data["CashOnDeliveryAmount"] = cashOnDeliveryAmount;
    data["InvoiceNumber"] = invoiceNumber;
    data["InvoiceDate"] =
        "/Date(${invoiceDate.add(Duration(hours: 7)).millisecondsSinceEpoch})/";
    if (deliveryDate != null)
      data["DeliveryDate"] =
          "/Date(${deliveryDate.add(Duration(hours: 7)).millisecondsSinceEpoch})/";
    data["CustomerName"] = customerName;
    data["CustomerPhone"] = customerPhone;
    data["CustomerAddress"] = customerAddress;
    data["SubTotal"] = subTotal;
    data["ShipAmount"] = shipAmount;
    data["TotalAmount"] = totalAmount;
    data["OldCredit"] = oldCredit;
    data["Payment"] = payment;

    data["PreviousBalance"] = previousBalance;
    data["TotalDeb"] = totalDeb;
    data["InvoiceNote"] = invoiceNote;
    data["receiverName"] = receiverName;
    data["receiverPhone"] = receiverPhone;
    data["receiverAddress"] = receiverAddress;

    data["HideProductCode"] = hideProductCode;
    data["HideDelivery"] = hideDelivery;
    data["HideDebt"] = hideDebt;
    data["HideLogo"] = hideLogo;
    data["HideReceiver"] = hideReceiver;
    data["HideAddress"] = hideAddress;

    data["HidePhone"] = hidePhone;
    data["HideStaff"] = hideStaff;
    data["HideAmountText"] = hideAmountText;

    data["HideAmountText"] = hideAmountText;
    data["HideSign"] = hideSign;

    data["HideTrackingRef"] = hideTrackingRef;
    data["HideCustomerName"] = hideCustomerNam;
    data["HideProductNote"] = hideProductNote;
    data["ShowBarcode"] = showBarcode;
    data["ShowWeightShip"] = showWeightShip;
    data["ShowCod"] = showCod;
    data["ShowRevenue"] = showRevenue;
    data["ShowCombo"] = showCombo;
    data["ShowTrackingRefSoft"] = showTrackingRefSort;
    data["User"] = user;
    data["UserDelivery"] = userDelivery;
    data["OrderLines"] =
        orderLines?.map((f) => f.toJson(removeIfNull: true))?.toList();

    data["TotalInWords"] = totalInWords;
    data["DeliveryDate"] = deliveryDate;
    data["ShipWeight"] = shipWeight;
    data["ShipNote"] = shipNote;
    data["Revenue"] = revenue;
    data["Discount"] = discount;
    data["DecreaseAmount"] = decreaseAmount;
    data["DiscountAmount"] = discountAmount;
    data["DefaultNote"] = defaultNote;
    if (removeIfNull) {
      data.removeWhere((key, value) => value == null);
    }

    return data;
  }
}
