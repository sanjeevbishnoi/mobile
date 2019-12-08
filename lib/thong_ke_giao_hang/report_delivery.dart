import 'package:tpos_mobile/helpers/tpos_api_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/models/productUOM.dart';

class ReportDelivery {
  List<ReportDeliveryInfo> data;
  int total;
  Aggregates aggregates;

  ReportDelivery({this.data, this.total, this.aggregates});

  ReportDelivery.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = new List<ReportDeliveryInfo>();
      json['Data'].forEach((v) {
        data.add(new ReportDeliveryInfo.fromJson(v));
      });
    }
    total = json['Total'];
    aggregates = json['Aggregates'] != null
        ? new Aggregates.fromJson(json['Aggregates'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['Total'] = this.total;
    if (this.aggregates != null) {
      data['Aggregates'] = this.aggregates.toJson();
    }
    return data;
  }
}

class ReportDeliveryInfo {
  int id;
  Null name;
  int partnerId;
  String partnerDisplayName;
  String partnerFacebookId;
  String partnerFacebookLink;
  String address;
  String phone;
  String facebookName;
  String facebookNameNosign;
  String facebookId;
  String displayFacebookName;
  String deliver;
  double amountTotal;
  String userId;
  String userName;
  DateTime dateInvoice;
  String state;
  String showState;
  int companyId;
  String comment;
  double residual;
  String type;
  String number;
  String partnerNameNoSign;
  double deliveryPrice;
  int carrierId;
  String carrierName;
  double cashOnDelivery;
  String trackingRef;
  String shipStatus;
  String showShipStatus;
  String carrierDeliveryType;
  String trackingUrl;
  String wardName;
  String districtName;
  String cityName;
  String fullAddress;
  double weightTotal;
  double amountTax;
  double amountUntaxed;
  double discount;
  double discountAmount;
  double decreaseAmount;
  String shipPaymentStatus;
  String companyName;
  String shipReceiverName;
  String shipReceiverPhone;
  String shipReceiverStreet;
  double amountDeposit;
  double customerDeliveryPrice;
  String createdById;
  String deliveryNote;
  String partnerEmail;

  ReportDeliveryInfo(
      {this.id,
        this.name,
        this.partnerId,
        this.partnerDisplayName,
        this.partnerFacebookId,
        this.partnerFacebookLink,
        this.address,
        this.phone,
        this.facebookName,
        this.facebookNameNosign,
        this.facebookId,
        this.displayFacebookName,
        this.deliver,
        this.amountTotal,
        this.userId,
        this.userName,
        this.dateInvoice,
        this.state,
        this.showState,
        this.companyId,
        this.comment,
        this.residual,
        this.type,
        this.number,
        this.partnerNameNoSign,
        this.deliveryPrice,
        this.carrierId,
        this.carrierName,
        this.cashOnDelivery,
        this.trackingRef,
        this.shipStatus,
        this.showShipStatus,
        this.carrierDeliveryType,
        this.trackingUrl,
        this.wardName,
        this.districtName,
        this.cityName,
        this.fullAddress,
        this.weightTotal,
        this.amountTax,
        this.amountUntaxed,
        this.discount,
        this.discountAmount,
        this.decreaseAmount,
        this.shipPaymentStatus,
        this.companyName,
        this.shipReceiverName,
        this.shipReceiverPhone,
        this.shipReceiverStreet,
        this.amountDeposit,
        this.customerDeliveryPrice,
        this.createdById,
        this.deliveryNote,
        this.partnerEmail});

  ReportDeliveryInfo.fromJson(Map<String, dynamic> json) {
    if (json["DateInvoice"] != null) {
      String unixTimeStr =
      RegExp(r"(?<=Date\()\d+").stringMatch(json["DateInvoice"]);

      if (unixTimeStr != null && unixTimeStr.isNotEmpty) {
        int unixTime = int.parse(unixTimeStr);
        dateInvoice = DateTime.fromMillisecondsSinceEpoch(unixTime);
      } else {
        if (json["DateInvoice"] != null) {
          dateInvoice = convertStringToDateTime(json["DateInvoice"]);
        }
      }
    }
    id = json['Id'];
    name = json['Name'];
    partnerId = json['PartnerId'];
    partnerDisplayName = json['PartnerDisplayName'];
    partnerFacebookId = json['PartnerFacebookId'];
    partnerFacebookLink = json['PartnerFacebookLink'];
    address = json['Address'];
    phone = json['Phone'];
    facebookName = json['FacebookName'];
    facebookNameNosign = json['FacebookNameNosign'];
    facebookId = json['FacebookId'];
    displayFacebookName = json['DisplayFacebookName'];
    deliver = json['Deliver'];
    amountTotal = json['AmountTotal'];
    userId = json['UserId'];
    userName = json['UserName'];
//    dateInvoice = json['DateInvoice'];
    state = json['State'];
    showState = json['ShowState'];
    companyId = json['CompanyId'];
    comment = json['Comment'];
    residual = json['Residual'];
    type = json['Type'];
    number = json['Number'];
    partnerNameNoSign = json['PartnerNameNoSign'];
    deliveryPrice = json['DeliveryPrice'];
    carrierId = json['CarrierId'];
    carrierName = json['CarrierName'];
    cashOnDelivery = json['CashOnDelivery'];
    trackingRef = json['TrackingRef'];
    shipStatus = json['ShipStatus'];
    showShipStatus = json['ShowShipStatus'];
    carrierDeliveryType = json['CarrierDeliveryType'];
    trackingUrl = json['TrackingUrl'];
    wardName = json['WardName'];
    districtName = json['DistrictName'];
    cityName = json['CityName'];
    fullAddress = json['FullAddress'];
    weightTotal = json['WeightTotal'];
    amountTax = json['AmountTax'];
    amountUntaxed = json['AmountUntaxed'];
    discount = json['Discount'];
    discountAmount = json['DiscountAmount'];
    decreaseAmount = json['DecreaseAmount'];
    shipPaymentStatus = json['ShipPaymentStatus'];
    companyName = json['CompanyName'];
    shipReceiverName = json['Ship_Receiver_Name'];
    shipReceiverPhone = json['Ship_Receiver_Phone'];
    shipReceiverStreet = json['Ship_Receiver_Street'];
    amountDeposit = json['AmountDeposit'];
    customerDeliveryPrice = json['CustomerDeliveryPrice'];
    createdById = json['CreatedById'];
    deliveryNote = json['DeliveryNote'];
    partnerEmail = json['PartnerEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['PartnerId'] = this.partnerId;
    data['PartnerDisplayName'] = this.partnerDisplayName;
    data['PartnerFacebookId'] = this.partnerFacebookId;
    data['PartnerFacebookLink'] = this.partnerFacebookLink;
    data['Address'] = this.address;
    data['Phone'] = this.phone;
    data['FacebookName'] = this.facebookName;
    data['FacebookNameNosign'] = this.facebookNameNosign;
    data['FacebookId'] = this.facebookId;
    data['DisplayFacebookName'] = this.displayFacebookName;
    data['Deliver'] = this.deliver;
    data['AmountTotal'] = this.amountTotal;
    data['UserId'] = this.userId;
    data['UserName'] = this.userName;
    data['DateInvoice'] = convertDatetimeToString(this.dateInvoice);
    data['State'] = this.state;
    data['ShowState'] = this.showState;
    data['CompanyId'] = this.companyId;
    data['Comment'] = this.comment;
    data['Residual'] = this.residual;
    data['Type'] = this.type;
    data['Number'] = this.number;
    data['PartnerNameNoSign'] = this.partnerNameNoSign;
    data['DeliveryPrice'] = this.deliveryPrice;
    data['CarrierId'] = this.carrierId;
    data['CarrierName'] = this.carrierName;
    data['CashOnDelivery'] = this.cashOnDelivery;
    data['TrackingRef'] = this.trackingRef;
    data['ShipStatus'] = this.shipStatus;
    data['ShowShipStatus'] = this.showShipStatus;
    data['CarrierDeliveryType'] = this.carrierDeliveryType;
    data['TrackingUrl'] = this.trackingUrl;
    data['WardName'] = this.wardName;
    data['DistrictName'] = this.districtName;
    data['CityName'] = this.cityName;
    data['FullAddress'] = this.fullAddress;
    data['WeightTotal'] = this.weightTotal;
    data['AmountTax'] = this.amountTax;
    data['AmountUntaxed'] = this.amountUntaxed;
    data['Discount'] = this.discount;
    data['DiscountAmount'] = this.discountAmount;
    data['DecreaseAmount'] = this.decreaseAmount;
    data['ShipPaymentStatus'] = this.shipPaymentStatus;
    data['CompanyName'] = this.companyName;
    data['Ship_Receiver_Name'] = this.shipReceiverName;
    data['Ship_Receiver_Phone'] = this.shipReceiverPhone;
    data['Ship_Receiver_Street'] = this.shipReceiverStreet;
    data['AmountDeposit'] = this.amountDeposit;
    data['CustomerDeliveryPrice'] = this.customerDeliveryPrice;
    data['CreatedById'] = this.createdById;
    data['DeliveryNote'] = this.deliveryNote;
    data['PartnerEmail'] = this.partnerEmail;
    return data;
  }
}

class Aggregates {
  PartnerDisplayName partnerDisplayName;
  AmountTotal amountTotal;
  CashOnDelivery cashOnDelivery;
  DeliveryPrice deliveryPrice;

  Aggregates(
      {this.partnerDisplayName,
        this.amountTotal,
        this.cashOnDelivery,
        this.deliveryPrice});

  Aggregates.fromJson(Map<String, dynamic> json) {
    partnerDisplayName = json['PartnerDisplayName'] != null
        ? new PartnerDisplayName.fromJson(json['PartnerDisplayName'])
        : null;
    amountTotal = json['AmountTotal'] != null
        ? new AmountTotal.fromJson(json['AmountTotal'])
        : null;
    cashOnDelivery = json['CashOnDelivery'] != null
        ? new CashOnDelivery.fromJson(json['CashOnDelivery'])
        : null;
    deliveryPrice = json['DeliveryPrice'] != null
        ? new DeliveryPrice.fromJson(json['DeliveryPrice'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.partnerDisplayName != null) {
      data['PartnerDisplayName'] = this.partnerDisplayName.toJson();
    }
    if (this.amountTotal != null) {
      data['AmountTotal'] = this.amountTotal.toJson();
    }
    if (this.cashOnDelivery != null) {
      data['CashOnDelivery'] = this.cashOnDelivery.toJson();
    }
    if (this.deliveryPrice != null) {
      data['DeliveryPrice'] = this.deliveryPrice.toJson();
    }
    return data;
  }
}

class PartnerDisplayName {
  int count;

  PartnerDisplayName({this.count});

  PartnerDisplayName.fromJson(Map<String, dynamic> json) {
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    return data;
  }
}

class AmountTotal {
  double sum;

  AmountTotal({this.sum});

  AmountTotal.fromJson(Map<String, dynamic> json) {
    sum = json['sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sum'] = this.sum;
    return data;
  }
}

class CashOnDelivery {
  double sum;

  CashOnDelivery({this.sum});

  CashOnDelivery.fromJson(Map<String, dynamic> json) {
    sum = json['sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sum'] = this.sum;
    return data;
  }
}

class DeliveryPrice {
  double sum;

  DeliveryPrice({this.sum});

  DeliveryPrice.fromJson(Map<String, dynamic> json) {
    sum = json['sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sum'] = this.sum;
    return data;
  }
}

class SumDeliveryReport {
  int id;
  int sumQuantityCollectionOrder;
  double sumCollectionAmount;
  int sumQuantityRefundedOrder;
  double sumRefundedAmount;
  int sumQuantityPaymentOrder;
  double sumPaymentAmount;
  int sumQuantityDelivering;
  double sumDeliveringAmount;

  SumDeliveryReport(
      {this.id,
        this.sumQuantityCollectionOrder,
        this.sumCollectionAmount,
        this.sumQuantityRefundedOrder,
        this.sumRefundedAmount,
        this.sumQuantityPaymentOrder,
        this.sumPaymentAmount,
        this.sumQuantityDelivering,
        this.sumDeliveringAmount});

  SumDeliveryReport.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    sumQuantityCollectionOrder = json['SumQuantityCollectionOrder'];
    sumCollectionAmount = json['SumCollectionAmount']?.toDouble();
    sumQuantityRefundedOrder = json['SumQuantityRefundedOrder'];
    sumRefundedAmount = json['SumRefundedAmount']?.toDouble();
    sumQuantityPaymentOrder = json['SumQuantityPaymentOrder'];
    sumPaymentAmount = json['SumPaymentAmount']?.toDouble();
    sumQuantityDelivering = json['SumQuantityDelivering'];
    sumDeliveringAmount = json['SumDeliveringAmount']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SumQuantityCollectionOrder'] = this.sumQuantityCollectionOrder;
    data['SumCollectionAmount'] = this.sumCollectionAmount;
    data['SumQuantityRefundedOrder'] = this.sumQuantityRefundedOrder;
    data['SumRefundedAmount'] = this.sumRefundedAmount;
    data['SumQuantityPaymentOrder'] = this.sumQuantityPaymentOrder;
    data['SumPaymentAmount'] = this.sumPaymentAmount;
    data['SumQuantityDelivering'] = this.sumQuantityDelivering;
    data['SumDeliveringAmount'] = this.sumDeliveringAmount;
    return data;
  }
}

class ReportDeliveryOrderLine {
  int id;
  int productId;
  int productUOMId;
  double priceUnit;
  double productUOMQty;
  double discount;
  double discountFixed;
  double priceTotal;
  double priceSubTotal;
  double weight;
  double weightTotal;
  int accountId;
  double priceRecent;
  String productName;
  String productUOMName;
  List<Null> saleLineIds;
  String productNameGet;
  int saleLineId;
  String type;
  int promotionProgramId;
  String note;
  String productBarcode;
  Product product;
  ProductUOM productUOM;
  Account account;

  ReportDeliveryOrderLine(
      {this.id,
        this.productId,
        this.productUOMId,
        this.priceUnit,
        this.productUOMQty,
        this.discount,
        this.discountFixed,
        this.priceTotal,
        this.priceSubTotal,
        this.weight,
        this.weightTotal,
        this.accountId,
        this.priceRecent,
        this.productName,
        this.productUOMName,
        this.saleLineIds,
        this.productNameGet,
        this.saleLineId,
        this.type,
        this.promotionProgramId,
        this.note,
        this.productBarcode,
        this.product,
        this.productUOM,
        this.account});

  ReportDeliveryOrderLine.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    productId = json['ProductId'];
    productUOMId = json['ProductUOMId'];
    priceUnit = json['PriceUnit'];
    productUOMQty = json['ProductUOMQty'];
    discount = json['Discount'];
    discountFixed = json['Discount_Fixed'];
    priceTotal = json['PriceTotal'];
    priceSubTotal = json['PriceSubTotal'];
    weight = json['Weight'];
    weightTotal = json['WeightTotal'];
    accountId = json['AccountId'];
    priceRecent = json['PriceRecent']?.toDouble();
    productName = json['ProductName'];
    productUOMName = json['ProductUOMName'];
//    if (json['SaleLineIds'] != null) {
//      saleLineIds = new List<Null>();
//      json['SaleLineIds'].forEach((v) {
//        saleLineIds.add(new Null.fromJson(v));
//      });
//    }
    productNameGet = json['ProductNameGet'];
    saleLineId = json['SaleLineId'];
    type = json['Type'];
    promotionProgramId = json['PromotionProgramId'];
    note = json['Note'];
    productBarcode = json['ProductBarcode'];
    product =
    json['Product'] != null ? new Product.fromJson(json['Product']) : null;
    productUOM = json['ProductUOM'] != null
        ? new ProductUOM.fromJson(json['ProductUOM'])
        : null;
    account =
    json['Account'] != null ? new Account.fromJson(json['Account']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['ProductId'] = this.productId;
    data['ProductUOMId'] = this.productUOMId;
    data['PriceUnit'] = this.priceUnit;
    data['ProductUOMQty'] = this.productUOMQty;
    data['Discount'] = this.discount;
    data['Discount_Fixed'] = this.discountFixed;
    data['PriceTotal'] = this.priceTotal;
    data['PriceSubTotal'] = this.priceSubTotal;
    data['Weight'] = this.weight;
    data['WeightTotal'] = this.weightTotal;
    data['AccountId'] = this.accountId;
    data['PriceRecent'] = this.priceRecent;
    data['ProductName'] = this.productName;
    data['ProductUOMName'] = this.productUOMName;
//    if (this.saleLineIds != null) {
//      data['SaleLineIds'] = this.saleLineIds.map((v) => v.toJson()).toList();
//    }
    data['ProductNameGet'] = this.productNameGet;
    data['SaleLineId'] = this.saleLineId;
    data['Type'] = this.type;
    data['PromotionProgramId'] = this.promotionProgramId;
    data['Note'] = this.note;
    data['ProductBarcode'] = this.productBarcode;
    if (this.product != null) {
      data['Product'] = this.product.toJson();
    }
    if (this.productUOM != null) {
      data['ProductUOM'] = this.productUOM.toJson();
    }
    if (this.account != null) {
      data['Account'] = this.account.toJson();
    }
    return data;
  }
}