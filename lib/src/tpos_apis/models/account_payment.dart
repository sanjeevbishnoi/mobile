import 'package:intl/intl.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';
import 'package:tpos_mobile/src/tpos_apis/models/currency.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';

class AccountPayment {
  String odataContext;
  int id;
  int companyId;
  int currencyId;
  int partnerId;
  String partnerDisplayName;
  int paymentMethodId;
  String partnerType;
  DateTime paymentDate;
  DateTime dateCreated;
  int journalId;
  String journalName;
  String state;
  String name;
  String paymentType;
  double amount;
  String amountStr;
  String communication;
  dynamic searchDate;
  String stateGet;
  String paymentType2;
  String description;
  String paymentDifferenceHandling;
  String writeoffAccountId;
  int paymentDifference;
  String senderReceiver;
  String phone;
  String address;
  String accountId;
  String accountName;
  Currency currency;
  List<FastSaleOrder> fastSaleOrders;
  AccountJournal journal;

  AccountPayment(
      {this.odataContext,
      this.id,
      this.companyId,
      this.currencyId,
      this.partnerId,
      this.partnerDisplayName,
      this.paymentMethodId,
      this.partnerType,
      this.paymentDate,
      this.dateCreated,
      this.journalId,
      this.journalName,
      this.state,
      this.name,
      this.paymentType,
      this.amount,
      this.amountStr,
      this.communication,
      this.searchDate,
      this.stateGet,
      this.paymentType2,
      this.description,
      this.paymentDifferenceHandling,
      this.writeoffAccountId,
      this.paymentDifference,
      this.senderReceiver,
      this.phone,
      this.address,
      this.accountId,
      this.accountName,
      this.currency,
      this.fastSaleOrders,
      this.journal});

  AccountPayment.fromJson(Map<String, dynamic> json) {
    odataContext = json['@odata.context'];
    id = json['Id'];
    companyId = json['CompanyId'];
    currencyId = json['CurrencyId'];
    partnerId = json['PartnerId'];
    partnerDisplayName = json['PartnerDisplayName'];
    paymentMethodId = json['PaymentMethodId'];
    partnerType = json['PartnerType'];
    if (json["PaymentDate"] != null) {
      paymentDate =
          DateFormat("yyyy-MM-ddTHH:mm:ss+07:00").parse(json["PaymentDate"]);
    }
    if (json['DateCreated'] != null) {
      dateCreated = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSSZZZZZZ")
          .parse(json['DateCreated']);
    }

    journalId = json['JournalId'];
    journalName = json['JournalName'];
    state = json['State'];
    name = json['Name'];
    paymentType = json['PaymentType'];
    amount = json['Amount']?.toDouble() ?? 0;
    amountStr = json['AmountStr'];
    communication = json['Communication'];
    searchDate = json['SearchDate'];
    stateGet = json['StateGet'];
    paymentType2 = json['PaymentType2'];
    description = json['Description'];
    paymentDifferenceHandling = json['PaymentDifferenceHandling'];
    writeoffAccountId = json['WriteoffAccountId'];
    paymentDifference = json['PaymentDifference'];
    senderReceiver = json['SenderReceiver'];
    phone = json['Phone'];
    address = json['Address'];
    accountId = json['AccountId'];
    accountName = json['AccountName'];
    currency = json['Currency'] != null
        ? new Currency.fromJson(json['Currency'])
        : null;
    if (json['FastSaleOrders'] != null) {
      fastSaleOrders = new List<FastSaleOrder>();
      json['FastSaleOrders'].forEach((v) {
        fastSaleOrders.add(new FastSaleOrder.fromJson(v));
      });
    }

    if (json["Journal"] != null) {
      journal = AccountJournal.fromJson(json["Journal"]);
    }
  }

  Map<String, dynamic> toJson([bool removeIfNull = false]) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CompanyId'] = this.companyId;
    data['CurrencyId'] = this.currencyId;
    data['PartnerId'] = this.partnerId;
    data['PartnerDisplayName'] = this.partnerDisplayName;
    data['PaymentMethodId'] = this.paymentMethodId;
    data['PartnerType'] = this.partnerType;
    if (paymentDate != null) {
      data['PaymentDate'] = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSS'+07:00'")
          .format(this.paymentDate);
    }

    if (dateCreated != null) {
      data['DateCreated'] = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSS'+07:00'")
          .format(this.dateCreated);
    }

    data['JournalId'] = this.journalId;
    data['JournalName'] = this.journalName;
    data['State'] = this.state;
    data['Name'] = this.name;
    data['PaymentType'] = this.paymentType;
    data['Amount'] = this.amount;
    data['AmountStr'] = this.amountStr;
    data['Communication'] = this.communication;
    data['SearchDate'] = this.searchDate;
    data['StateGet'] = this.stateGet;
    data['PaymentType2'] = this.paymentType2;
    data['Description'] = this.description;
    data['PaymentDifferenceHandling'] = this.paymentDifferenceHandling;
    data['WriteoffAccountId'] = this.writeoffAccountId;
    data['PaymentDifference'] = this.paymentDifference;
    data['SenderReceiver'] = this.senderReceiver;
    data['Phone'] = this.phone;
    data['Address'] = this.address;
    data['AccountId'] = this.accountId;
    data['AccountName'] = this.accountName;
    if (this.currency != null) {
      data['Currency'] = this.currency.toJson();
    }
    if (this.fastSaleOrders != null) {
      data['FastSaleOrders'] = this
          .fastSaleOrders
          .map((v) => v.toJson(removeIfNull: removeIfNull))
          .toList();
    }

    data["Journal"] = this.journal?.toJson();

    if (removeIfNull) {
      data.removeWhere((key, value) => value == null);
    }
    return data;
  }
}
