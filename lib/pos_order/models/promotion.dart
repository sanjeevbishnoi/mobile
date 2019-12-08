class Promotion {
  int id;
  int companyId;
  String name;
  String notice;
  int productId;
  int uOMId;
  String uOMName;
  String productNameGet;
  String discountType;
  double priceUnit;
  int qty;
  double discount;
  double discountFixed;
  String orderId;
  double priceSubTotal;
  bool isPromotion;
  int promotionProgramId;
  String couponId;

  Promotion(
      {this.id,
      this.companyId,
      this.name,
      this.notice,
      this.productId,
      this.uOMId,
      this.uOMName,
      this.productNameGet,
      this.discountType,
      this.priceUnit,
      this.qty,
      this.discount,
      this.discountFixed,
      this.orderId,
      this.priceSubTotal,
      this.isPromotion,
      this.promotionProgramId,
      this.couponId});

  Promotion.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    companyId = json['CompanyId'];
    name = json['Name'];
    notice = json['Notice'];
    productId = json['ProductId'];
    uOMId = json['UOMId'];
    uOMName = json['UOMName'];
    productNameGet = json['ProductNameGet'];
    discountType = json['DiscountType'];
    priceUnit = json['PriceUnit'];
    qty = json['Qty'];
    discount = double.parse(json['Discount'].toString());
    discountFixed = json['DiscountFixed'];
    orderId = json['OrderId'];
    priceSubTotal = json['PriceSubTotal'];
    isPromotion = json['IsPromotion'];
    promotionProgramId = json['PromotionProgramId'];
    couponId = json['CouponId'];
  }

  Map<String, dynamic>  toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['Id'] = this.id;
    // data['CompanyId'] = this.companyId;
    data['Name'] = this.name;
    // data['Notice'] = this.notice;
    data['ProductId'] = this.productId;
    data['UOMId'] = this.uOMId;
    // data['UOMName'] = this.uOMName;
    data['ProductNameGet'] = this.productNameGet;
    data['DiscountType'] = this.discountType;
    data['PriceUnit'] = this.priceUnit;
    data['Qty'] = this.qty;
    data['Discount'] = this.discount;
    data['DiscountFixed'] = this.discountFixed;
    // data['OrderId'] = this.orderId;
    //data['PriceSubTotal'] = this.priceSubTotal;
    if(this.isPromotion != null){
      if(this.isPromotion){
        data['IsPromotion'] = this.isPromotion;
      }
    }
    //data['PromotionProgramId'] = this.promotionProgramId;
    //data['CouponId'] = this.couponId;
    return data;
  }
}
