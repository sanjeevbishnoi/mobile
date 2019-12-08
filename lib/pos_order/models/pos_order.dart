import 'package:tpos_mobile/helpers/tpos_api_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/application_user.dart';
import 'package:tpos_mobile/src/tpos_apis/models/company.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/models/productUOM.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_price.dart';

class PosOrderResult {
  List<PosOrder> data;
  int total;
  dynamic aggregates;

  PosOrderResult({this.data, this.total, this.aggregates});

  PosOrderResult.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = new List<PosOrder>();
      json['Data'].forEach((v) {
        data.add(new PosOrder.fromJson(v));
      });
    }
    total = json['Total'];
    aggregates = json['Aggregates'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['Total'] = this.total;
    data['Aggregates'] = this.aggregates;
    return data;
  }
}

class PosOrder {
  int id;
  String name;
  int companyId;
  String companyName;
  Company company;
  DateTime dateOrder;
  String userId;
  ApplicationUser user;
  String userName;
  int priceListId;
  ProductPrice priceList;
  String priceListName;
  int partnerId;
  Partner partner;
  String partnerName;
  String partnerRef;
  int sequenceNumber;
  int sessionId;
  Session session;
  String sessionName;
  String state;
  String showState;
  double beganPoints;
  int invoiceId;
  int accountMoveId;
  int pickingId;
  String pickingName;
  int locationId;
  String locationName;
  String note;
  int nbPrint;
  String pOSReference;
  int saleJournalId;
  String dateCreated;
  double amountSubTotal;
  double amountDiscount;
  double amountTax;
  double amountUntaxed;
  double amountTotal;
  double amountPaid;
  double amountReturn;
  double wonPoints;
  double spentPoints;
  double totalPoints;
  Null tableId;
  Null table;
  int customerCount;
  List<PosOrderLine> lines;
  Null taxId;
  Null tax;
  double discount;
  double discountFixed;
  String discountType;

  PosOrder(
      {this.id,
      this.name,
      this.companyId,
      this.companyName,
      this.company,
      this.dateOrder,
      this.userId,
      this.user,
      this.userName,
      this.priceListId,
      this.priceList,
      this.priceListName,
      this.partnerId,
      this.partner,
      this.partnerName,
      this.partnerRef,
      this.sequenceNumber,
      this.sessionId,
      this.session,
      this.sessionName,
      this.state,
      this.showState,
      this.beganPoints,
      this.invoiceId,
      this.accountMoveId,
      this.pickingId,
      this.pickingName,
      this.locationId,
      this.locationName,
      this.note,
      this.nbPrint,
      this.pOSReference,
      this.saleJournalId,
      this.dateCreated,
      this.amountSubTotal,
      this.amountDiscount,
      this.amountTax,
      this.amountUntaxed,
      this.amountTotal,
      this.amountPaid,
      this.amountReturn,
      this.wonPoints,
      this.spentPoints,
      this.totalPoints,
      this.tableId,
      this.table,
      this.customerCount,
      this.lines,
      this.taxId,
      this.tax,
      this.discount,
      this.discountFixed,
      this.discountType});

  PosOrder.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    companyId = json['CompanyId'];
    companyName = json['CompanyName'];
    company =
        json['Company'] != null ? new Company.fromJson(json['Company']) : null;
    if (json["DateOrder"] != null) {
      String unixTimeStr =
          RegExp(r"(?<=Date\()\d+").stringMatch(json["DateOrder"]);

      if (unixTimeStr != null && unixTimeStr.isNotEmpty) {
        int unixTime = int.parse(unixTimeStr);
        dateOrder = DateTime.fromMillisecondsSinceEpoch(unixTime);
      } else {
        if (json["DateOrder"] != null) {
          dateOrder = convertStringToDateTime(json["DateOrder"]);
        }
      }
    }
    userId = json['UserId'];
    if (json["User"] != null) {
      this.user = ApplicationUser.fromJson(json["User"]);
    }
    userName = json['UserName'];
    priceListId = json['PriceListId'];
    if (json["PriceList"] != null) {
      this.priceList = ProductPrice.fromJson(json["PriceList"]);
    }
    priceListName = json['PriceListName'];
    partnerId = json['PartnerId'];
    if (json["Partner"] != null) {
      this.partner = Partner.fromJson(json["Partner"]);
    }
    partnerName = json['PartnerName'];
    partnerRef = json['PartnerRef'];
    sequenceNumber = json['SequenceNumber'];
    sessionId = json['SessionId'];
    session =
        json['Session'] != null ? new Session.fromJson(json['Session']) : null;
    sessionName = json['SessionName'];
    state = json['State'];
    showState = json['ShowState'];
    beganPoints = json['BeganPoints'].toDouble();
    invoiceId = json['InvoiceId'];
    accountMoveId = json['AccountMoveId'];
    pickingId = json['PickingId'];
    pickingName = json['PickingName'];
    locationId = json['LocationId'];
    locationName = json['LocationName'];
    note = json['Note'];
    nbPrint = json['NbPrint'];
    pOSReference = json['POSReference'];
    saleJournalId = json['SaleJournalId'];
    dateCreated = json['DateCreated'];
    amountSubTotal = json['AmountSubTotal'];
    amountDiscount = json['AmountDiscount'];
    amountTax = json['AmountTax'];
    amountUntaxed = json['AmountUntaxed'];
    amountTotal = json['AmountTotal'];
    amountPaid = json['AmountPaid'];
    amountReturn = json['AmountReturn'];
    wonPoints = json['Won_Points'];
    spentPoints = json['Spent_Points'];
    totalPoints = json['Total_Points'];
    tableId = json['TableId'];
    table = json['Table'];
    customerCount = json['CustomerCount'];
    if (json['Lines'] != null) {
      lines = new List<Null>();
      json['Lines'].forEach((v) {
        lines.add(new PosOrderLine.fromJson(v));
      });
    }
    taxId = json['TaxId'];
    tax = json['Tax'];
    discount = json['Discount'];
    discountFixed = json['DiscountFixed'];
    discountType = json['DiscountType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['CompanyId'] = this.companyId;
    data['CompanyName'] = this.companyName;
    if (this.company != null) {
      data['Company'] = this.company.toJson();
    }
    data['DateOrder'] = convertDatetimeToString(this.dateOrder);
    data['UserId'] = this.userId;
    data['User'] = this.user;
    data['UserName'] = this.userName;
    data['PriceListId'] = this.priceListId;
    data['PriceList'] = this.priceList;
    data['PriceListName'] = this.priceListName;
    data['PartnerId'] = this.partnerId;
    data['Partner'] = this.partner;
    data['PartnerName'] = this.partnerName;
    data['PartnerRef'] = this.partnerRef;
    data['SequenceNumber'] = this.sequenceNumber;
    data['SessionId'] = this.sessionId;
    data['Session'] = this.session;
    data['SessionName'] = this.sessionName;
    data['State'] = this.state;
    data['ShowState'] = this.showState;
    data['BeganPoints'] = this.beganPoints;
    data['InvoiceId'] = this.invoiceId;
    data['AccountMoveId'] = this.accountMoveId;
    data['PickingId'] = this.pickingId;
    data['PickingName'] = this.pickingName;
    data['LocationId'] = this.locationId;
    data['LocationName'] = this.locationName;
    data['Note'] = this.note;
    data['NbPrint'] = this.nbPrint;
    data['POSReference'] = this.pOSReference;
    data['SaleJournalId'] = this.saleJournalId;
    data['DateCreated'] = this.dateCreated;
    data['AmountSubTotal'] = this.amountSubTotal;
    data['AmountDiscount'] = this.amountDiscount;
    data['AmountTax'] = this.amountTax;
    data['AmountUntaxed'] = this.amountUntaxed;
    data['AmountTotal'] = this.amountTotal;
    data['AmountPaid'] = this.amountPaid;
    data['AmountReturn'] = this.amountReturn;
    data['Won_Points'] = this.wonPoints;
    data['Spent_Points'] = this.spentPoints;
    data['Total_Points'] = this.totalPoints;
    data['TableId'] = this.tableId;
    data['Table'] = this.table;
    data['CustomerCount'] = this.customerCount;
    if (this.lines != null) {
      data['Lines'] = this.lines.map((v) => v.toJson()).toList();
    }
    data['TaxId'] = this.taxId;
    data['Tax'] = this.tax;
    data['Discount'] = this.discount;
    data['DiscountFixed'] = this.discountFixed;
    data['DiscountType'] = this.discountType;
    return data;
  }
}

class Session {
  int id;
  int configId;
  String configName;
  String name;
  String userId;
  String userName;
  String startAt;
  String stopAt;
  String state;
  String showState;
  int sequenceNumber;
  int loginNumber;
  bool cashControl;
  String cashRegisterId;
  int cashRegisterBalanceStart;
  int cashRegisterTotalEntryEncoding;
  int cashRegisterBalanceEnd;
  int cashRegisterBalanceEndReal;
  int cashRegisterDifference;
  String dateCreated;

  Session(
      {this.id,
      this.configId,
      this.configName,
      this.name,
      this.userId,
      this.userName,
      this.startAt,
      this.stopAt,
      this.state,
      this.showState,
      this.sequenceNumber,
      this.loginNumber,
      this.cashControl,
      this.cashRegisterId,
      this.cashRegisterBalanceStart,
      this.cashRegisterTotalEntryEncoding,
      this.cashRegisterBalanceEnd,
      this.cashRegisterBalanceEndReal,
      this.cashRegisterDifference,
      this.dateCreated});

  Session.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    configId = json['ConfigId'];
    configName = json['ConfigName'];
    name = json['Name'];
    userId = json['UserId'];
    userName = json['UserName'];
    startAt = json['StartAt'];
    stopAt = json['StopAt'];
    state = json['State'];
    showState = json['ShowState'];
    sequenceNumber = json['SequenceNumber'];
    loginNumber = json['LoginNumber'];
    cashRegisterId = json['CashRegisterId'];
    cashRegisterBalanceStart = json['CashRegisterBalanceStart'];
    cashRegisterTotalEntryEncoding = json['CashRegisterTotalEntryEncoding'];
    cashRegisterBalanceEnd = json['CashRegisterBalanceEnd'];
    cashRegisterBalanceEndReal = json['CashRegisterBalanceEndReal'];
    cashRegisterDifference = json['CashRegisterDifference'];
    dateCreated = json['DateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['ConfigId'] = this.configId;
    data['ConfigName'] = this.configName;
    data['Name'] = this.name;
    data['UserId'] = this.userId;
    data['UserName'] = this.userName;
    data['StartAt'] = this.startAt;
    data['StopAt'] = this.stopAt;
    data['State'] = this.state;
    data['ShowState'] = this.showState;
    data['SequenceNumber'] = this.sequenceNumber;
    data['LoginNumber'] = this.loginNumber;
    if (this.cashControl != null) {
      data['CashControl'] = this.cashControl;
    }
    data['CashRegisterId'] = this.cashRegisterId;
    data['CashRegisterBalanceStart'] = this.cashRegisterBalanceStart;
    data['CashRegisterTotalEntryEncoding'] =
        this.cashRegisterTotalEntryEncoding;
    data['CashRegisterBalanceEnd'] = this.cashRegisterBalanceEnd;
    data['CashRegisterBalanceEndReal'] = this.cashRegisterBalanceEndReal;
    data['CashRegisterDifference'] = this.cashRegisterDifference;
    data['DateCreated'] = this.dateCreated;
    return data;
  }
}

class PosOrderSort {
  PosOrderSort(this.id, this.name, this.value, this.orderBy);

  String name;
  int id;
  String value;
  String orderBy;
}

class PosOrderLine {
  int id;
  int companyId;
  String name;
  String notice;
  int productId;
  int uOMId;
  String uOMName;
  String productNameGet;
  double priceUnit;
  double qty;
  double discount;
  int orderId;
  double priceSubTotal;
  Product product;
  ProductUOM uOM;

  PosOrderLine(
      {this.id,
      this.companyId,
      this.name,
      this.notice,
      this.productId,
      this.uOMId,
      this.uOMName,
      this.productNameGet,
      this.priceUnit,
      this.qty,
      this.discount,
      this.orderId,
      this.priceSubTotal,
      this.product,
      this.uOM});

  PosOrderLine.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    companyId = json['CompanyId'];
    name = json['Name'];
    notice = json['Notice'];
    productId = json['ProductId'];
    uOMId = json['UOMId'];
    uOMName = json['UOMName'];
    productNameGet = json['ProductNameGet'];
    priceUnit = json['PriceUnit'];
    qty = json['Qty'];
    discount = json['Discount'];
    orderId = json['OrderId'];
    priceSubTotal = json['PriceSubTotal'];
    product =
        json['Product'] != null ? new Product.fromJson(json['Product']) : null;
    uOM = json['UOM'] != null ? new ProductUOM.fromJson(json['UOM']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CompanyId'] = this.companyId;
    data['Name'] = this.name;
    data['Notice'] = this.notice;
    data['ProductId'] = this.productId;
    data['UOMId'] = this.uOMId;
    data['UOMName'] = this.uOMName;
    data['ProductNameGet'] = this.productNameGet;
    data['PriceUnit'] = this.priceUnit;
    data['Qty'] = this.qty;
    data['Discount'] = this.discount;
    data['OrderId'] = this.orderId;
    data['PriceSubTotal'] = this.priceSubTotal;
    if (this.product != null) {
      data['Product'] = this.product.toJson();
    }
    if (this.uOM != null) {
      data['UOM'] = this.uOM.toJson();
    }
    return data;
  }
}

class PosAccountBankStatement {
  int id;
  int statementId;
  String statementName;
  int sequence;
  int journalId;
  String journalName;
  int partnerId;
  String partnerName;
  int companyId;
  String note;
  String ref;
  int accountId;
  String moveName;
  DateTime date;
  int currencyId;
  String name;
  double amount;
  double amountCurrency;
  int posStatementId;

  PosAccountBankStatement(
      {this.id,
      this.statementId,
      this.statementName,
      this.sequence,
      this.journalId,
      this.journalName,
      this.partnerId,
      this.partnerName,
      this.companyId,
      this.note,
      this.ref,
      this.accountId,
      this.moveName,
      this.date,
      this.currencyId,
      this.name,
      this.amount,
      this.amountCurrency,
      this.posStatementId});

  PosAccountBankStatement.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    statementId = json['StatementId'];
    statementName = json['StatementName'];
    sequence = json['Sequence'];
    journalId = json['JournalId'];
    journalName = json['JournalName'];
    partnerId = json['PartnerId'];
    partnerName = json['PartnerName'];
    companyId = json['CompanyId'];
    note = json['Note'];
    ref = json['Ref'];
    accountId = json['AccountId'];
    moveName = json['MoveName'];
    if (json["Date"] != null) {
      date = convertStringToDateTime((json['Date']));
    }
    currencyId = json['CurrencyId'];
    name = json['Name'];
    amount = json['Amount'];
    amountCurrency = json['AmountCurrency'];
    posStatementId = json['PosStatementId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['StatementId'] = this.statementId;
    data['StatementName'] = this.statementName;
    data['Sequence'] = this.sequence;
    data['JournalId'] = this.journalId;
    data['JournalName'] = this.journalName;
    data['PartnerId'] = this.partnerId;
    data['PartnerName'] = this.partnerName;
    data['CompanyId'] = this.companyId;
    data['Note'] = this.note;
    data['Ref'] = this.ref;
    data['AccountId'] = this.accountId;
    data['MoveName'] = this.moveName;
    data['Date'] = this.date;
    data['CurrencyId'] = this.currencyId;
    data['Name'] = this.name;
    data['Amount'] = this.amount;
    data['AmountCurrency'] = this.amountCurrency;
    data['PosStatementId'] = this.posStatementId;
    return data;
  }
}
