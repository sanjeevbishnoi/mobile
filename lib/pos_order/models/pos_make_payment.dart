class PosMakePayment {
  int id;
  int journalId;
  double amount;
  String paymentName;
  Journal journal;

  PosMakePayment(
      {this.id, this.journalId, this.amount, this.paymentName, this.journal});

  PosMakePayment.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    journalId = json['JournalId'];
    amount = json['Amount'];
    paymentName = json['PaymentName'];
    journal =
        json['Journal'] != null ? new Journal.fromJson(json['Journal']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['JournalId'] = this.journalId;
    data['Amount'] = this.amount;
    data['PaymentName'] = this.paymentName;
    if (this.journal != null) {
      data['Journal'] = this.journal.toJson();
    }
    return data;
  }
}

class Journal {
  int id;
  String code;
  String name;
  String type;
  bool updatePosted;
  int currencyId;
  int defaultDebitAccountId;
  int defaultCreditAccountId;
  int companyId;
  String companyName;
  bool journalUser;
  int profitAccountId;
  int lossAccountId;
  int amountAuthorizedDiff;
  bool dedicatedRefund;

  Journal(
      {this.id,
      this.code,
      this.name,
      this.type,
      this.updatePosted,
      this.currencyId,
      this.defaultDebitAccountId,
      this.defaultCreditAccountId,
      this.companyId,
      this.companyName,
      this.journalUser,
      this.profitAccountId,
      this.lossAccountId,
      this.amountAuthorizedDiff,
      this.dedicatedRefund});

  Journal.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    code = json['Code'];
    name = json['Name'];
    type = json['Type'];
    updatePosted = json['UpdatePosted'];
    currencyId = json['CurrencyId'];
    defaultDebitAccountId = json['DefaultDebitAccountId'];
    defaultCreditAccountId = json['DefaultCreditAccountId'];
    companyId = json['CompanyId'];
    companyName = json['CompanyName'];
    journalUser = json['JournalUser'];
    profitAccountId = json['ProfitAccountId'];
    lossAccountId = json['LossAccountId'];
    amountAuthorizedDiff = json['AmountAuthorizedDiff'];
    dedicatedRefund = json['DedicatedRefund'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['Type'] = this.type;
    data['UpdatePosted'] = this.updatePosted;
    data['CurrencyId'] = this.currencyId;
    data['DefaultDebitAccountId'] = this.defaultDebitAccountId;
    data['DefaultCreditAccountId'] = this.defaultCreditAccountId;
    data['CompanyId'] = this.companyId;
    data['CompanyName'] = this.companyName;
    data['JournalUser'] = this.journalUser;
    data['ProfitAccountId'] = this.profitAccountId;
    data['LossAccountId'] = this.lossAccountId;
    data['AmountAuthorizedDiff'] = this.amountAuthorizedDiff;
    data['DedicatedRefund'] = this.dedicatedRefund;
    return data;
  }
}
