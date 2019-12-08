class Payment {
  String name;
  double amountPaid;
  double amountTotal;
  double amountTax;
  double amountReturn;
  double discount;
  String discountType;
  double discountFixed;
  List<Lines> lines = [];
  List<StatementIds> statementIds = [];
  int posSessionId;
  int partnerId;
  String taxId;
  String userId;
  String uid;
  int sequenceNumber;
  String creationDate;
  String tableId;
  String floor;
  String floorId;
  int customerCount;
  int loyaltyPoints;
  int wonPoints;
  int spentPoints;
  int totalPoints;

  Payment(
      {this.name,
      this.amountPaid,
      this.amountTotal,
      this.amountTax,
      this.amountReturn,
      this.discount,
      this.discountType,
      this.discountFixed,
      this.lines,
      this.statementIds,
      this.posSessionId,
      this.partnerId,
      this.taxId,
      this.userId,
      this.uid,
      this.sequenceNumber,
      this.creationDate,
      this.tableId,
      this.floor,
      this.floorId,
      this.customerCount,
      this.loyaltyPoints,
      this.wonPoints,
      this.spentPoints,
      this.totalPoints});

  Payment.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    amountPaid = json['amount_paid'];
    amountTotal = json['amount_total'];
    amountTax = json['amount_tax'];
    amountReturn = json['amount_return'];
    discount = json['discount'];
    discountType = json['discount_type'];
    discountFixed = json['discount_fixed'];
    if (json['lines'] != null) {
      lines = new List<Lines>();
      json['lines'].forEach((v) {
        lines.add(new Lines.fromJson(v));
      });
    }
    if (json['statement_ids'] != null) {
      statementIds = new List<StatementIds>();
      json['statement_ids'].forEach((v) {
        statementIds.add(new StatementIds.fromJson(v));
      });
    }
    posSessionId = json['pos_session_id'];
    partnerId = json['partner_id'];
    taxId = json['tax_id'];
    userId = json['user_id'];
    uid = json['uid'];
    sequenceNumber = json['sequence_number'];
    creationDate = json['creation_date'];
    tableId = json['table_id'];
    floor = json['floor'];
    floorId = json['floor_id'];
    customerCount = json['customer_count'];
    loyaltyPoints = json['loyalty_points'];
    wonPoints = json['won_points'];
    spentPoints = json['spent_points'];
    totalPoints = json['total_points'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['amount_paid'] = this.amountPaid;
    data['amount_total'] = this.amountTotal;
    data['amount_tax'] = this.amountTax;
    data['amount_return'] = this.amountReturn;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['discount_fixed'] = this.discountFixed;
    if (this.lines != null) {
      data['lines'] = this.lines.map((v) => v.toJson()).toList();
    }
    if (this.statementIds != null) {
      data['statement_ids'] = this.statementIds.map((v) => v.toJson()).toList();
    }
    data['pos_session_id'] = this.posSessionId;
    data['partner_id'] = this.partnerId;
    data['tax_id'] = this.taxId;
    data['user_id'] = this.userId;
    data['uid'] = this.uid;
    data['sequence_number'] = this.sequenceNumber;
    data['creation_date'] = this.creationDate;
    data['table_id'] = this.tableId;
    data['floor'] = this.floor;
    data['floor_id'] = this.floorId;
    data['customer_count'] = this.customerCount;
    data['loyalty_points'] = this.loyaltyPoints;
    data['won_points'] = this.wonPoints;
    data['spent_points'] = this.spentPoints;
    data['total_points'] = this.totalPoints;
    return data;
  }
}

class Lines {
  int qty;
  double priceUnit;
  double discount;
  int productId;
  int uomId;
  String discountType;
  int id;
  String note;
  int promotionProgramId;
  // List<String> taxIds;
  String tb_cart_position;
  String productName;
  bool isPromotion;

  Lines(
      {this.qty,
      this.priceUnit,
      this.discount,
      this.productId,
      this.uomId,
      this.discountType,
      this.id,
      this.note,
      this.tb_cart_position,
      this.productName,
      this.promotionProgramId,
        this.isPromotion
      });

  Lines.fromJson(Map<String, dynamic> json) {
    qty = json['qty'];
    priceUnit = json['price_unit'];
    discount = json['discount'];
    productId = json['product_id'];
    uomId = json['uom_id'];
    discountType = json['discount_type'];
    id = json['id'];
    note = json['note'];
    tb_cart_position = json['tb_cart_position'];
    productName = json['productName'];
    promotionProgramId = json["promotionprogram_id"];
    isPromotion = json["IsPromotion"] == 1 ? true : false;
//    if (json['tax_ids'] != null) {
//      taxIds = new List<Null>();
//      json['tax_ids'].forEach((v) {
//        taxIds.add(new Null.fromJson(v));
//      });
//    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['qty'] = this.qty;
    data['price_unit'] = this.priceUnit;
    data['discount'] = this.discount;
    data['product_id'] = this.productId;
    data['uom_id'] = this.uomId;
    data['discount_type'] = this.discountType;
    data['note'] = this.note;
    if (this.tb_cart_position != null && this.productName != null) {
      data['tb_cart_position'] = this.tb_cart_position;
      data['productName'] = this.productName;
    }
    if(this.promotionProgramId != null){
      data["promotionprogram_id"] = this.promotionProgramId;
    }
    if(this.isPromotion != null){
      data["IsPromotion"] = this.isPromotion ? 1: 0;
    }
//    if (this.taxIds != null) {
//      data['tax_ids'] = this.taxIds.map((v) => v.toJson()).toList();
//    }

    return data;
  }
}

class StatementIds {
  String position;
  String name;
  int statementId;
  int accountId;
  int journalId;
  double amount;

  StatementIds(
      {this.name,
      this.statementId,
      this.accountId,
      this.journalId,
      this.amount,
      this.position});

  StatementIds.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    statementId = json['statement_id'];
    accountId = json['account_id'];
    journalId = json['journal_id'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['statement_id'] = this.statementId;
    data['account_id'] = this.accountId;
    data['journal_id'] = this.journalId;
    data['amount'] = this.amount;
    if (this.position != null) {
      data['positon'] = this.position;
    }
    return data;
  }
}

class InvoicePayment {
  String sequence;
  int isCheck;
  InvoicePayment({this.sequence, this.isCheck});
  InvoicePayment.fromJson(Map<String, dynamic> json) {
    sequence = json['sequence'];
    isCheck = json['isCheck'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sequence'] = this.sequence;
    data['isCheck'] = this.isCheck;
    return data;
  }
}
