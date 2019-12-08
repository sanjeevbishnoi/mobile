class CartProduct {
  int id, uOMId, version, productTmplId;
  double price, oldPrice, discountPurchase, discountSale;
  String name, uOMName, nameGet, nameNoSign;
  String imageUrl;
  String defaultCode;
  double weight;

  double purchasePrice;
  bool saleOK;
  bool purchaseOK;
  bool availableInPOS;
  String barcode;
  int qty = 0;
  double posSalesCount;
  double factor;

  CartProduct(
      {this.id,
      this.uOMId,
      this.version,
      this.productTmplId,
      this.price,
      this.oldPrice,
      this.discountPurchase,
      this.weight,
      this.discountSale,
      this.name,
      this.uOMName,
      this.nameGet,
      this.nameNoSign,
      this.imageUrl,
      this.purchasePrice,
      this.saleOK,
      this.purchaseOK,
      this.availableInPOS,
      this.defaultCode,
      this.barcode,
      this.qty,
      this.posSalesCount,
      this.factor});

  CartProduct.fromJson(Map<String, dynamic> jsonMap) {
    id = jsonMap["Id"];
    name = jsonMap["Name"];
    uOMId = jsonMap["UOMId"];
    uOMName = jsonMap["UOMName"];
    nameNoSign = jsonMap["NameNoSign"];
    nameGet = jsonMap["NameGet"];
    price = jsonMap["Price"];
    oldPrice = jsonMap["OldPrice"];
    version = jsonMap["Version"];
    discountPurchase = (jsonMap["DiscountPurchase"] ?? 0).toDouble();
    weight = (jsonMap["Weight"] ?? 0).toDouble();
    discountSale = jsonMap["DiscountSale"];
    productTmplId = jsonMap["ProductTmplId"];
    imageUrl = jsonMap["ImageUrl"];
    purchasePrice = jsonMap["PurchasePrice"];
    factor = jsonMap["Factor"];
    if (jsonMap["SaleOK"] == true || jsonMap["SaleOK"] == false) {
      saleOK = jsonMap["SaleOK"];
    } else if (jsonMap["SaleOK"] == 0 || jsonMap["SaleOK"] == 1) {
      saleOK = jsonMap["SaleOK"] == 0 ? false : true;
    }
    if (jsonMap["PurchaseOK"] == true || jsonMap["PurchaseOK"] == false) {
      purchaseOK = jsonMap["PurchaseOK"];
    } else if (jsonMap["PurchaseOK"] == 0 || jsonMap["PurchaseOK"] == 1) {
      purchaseOK = jsonMap["PurchaseOK"] == 0 ? false : true;
    }
    if (jsonMap["AvailableInPOS"] == true ||
        jsonMap["AvailableInPOS"] == false) {
      availableInPOS = jsonMap["AvailableInPOS"];
    } else if (jsonMap["AvailableInPOS"] == 0 ||
        jsonMap["AvailableInPOS"] == 1) {
      availableInPOS = jsonMap["AvailableInPOS"] == 0 ? false : true;
    }

    defaultCode = jsonMap["DefaultCode"];
    barcode = jsonMap["Barcode"];

    if (jsonMap["PosSalesCount"] != 0) {
      posSalesCount = jsonMap["PosSalesCount"];
    } else {
      posSalesCount = 0;
    }
  }

  Map<String, dynamic> toJson({bool removeIfNull}) {
    var map = {
      "Id": this.id,
      "Name": this.name,
      "UOMId": this.uOMId,
      "UOMName": this.uOMName,
      "NameNoSign": this.nameNoSign,
      "NameGet": this.nameGet,
      "Price": this.price,
      "OldPrice": this.oldPrice,
      "Version": this.version,
      "DiscountSale": this.discountSale,
      "DiscountPurchase": this.discountPurchase,
      "Weight": this.weight,
      "ProductTmplId": this.productTmplId,
      "ImageUrl": this.imageUrl,
      "PurchasePrice": this.purchasePrice,
      "SaleOK": this.saleOK,
      "PurchaseOK": this.purchaseOK,
      "AvailableInPOS": this.availableInPOS,
      "DefaultCode": this.defaultCode,
      "Barcode": this.barcode,
      "PosSalesCount": this.posSalesCount,
      "Factor": this.factor
    };

    map.removeWhere((key, value) => value == null || value == "");

    return map;
  }
}
