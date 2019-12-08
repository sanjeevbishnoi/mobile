class Companies {
  int id;
  String name;
  String sender;
  Null moreInfo;
  int partnerId;
  String email;
  String phone;
  int currencyId;
  Null fax;
  String street;
  String currencyExchangeJournalId;
  String incomeCurrencyExchangeAccountId;
  String expenseCurrencyExchangeAccountId;
  String securityLead;
  Null logo;
  String lastUpdated;
  int transferAccountId;
  String saleNote;
  String taxCode;
  int warehouseId;
  String sOFromPO;
  bool pOFromSO;
  String autoValidation;
  bool customer;
  bool supplier;
  bool active;
  String periodLockDate;
  String quatityDecimal;
  String extRegexPhone;
  String imageUrl;
  String city;
  String district;
  String ward;

  Companies(
      {this.id,
      this.name,
      this.sender,
      this.moreInfo,
      this.partnerId,
      this.email,
      this.phone,
      this.currencyId,
      this.fax,
      this.street,
      this.currencyExchangeJournalId,
      this.incomeCurrencyExchangeAccountId,
      this.expenseCurrencyExchangeAccountId,
      this.securityLead,
      this.logo,
      this.lastUpdated,
      this.transferAccountId,
      this.saleNote,
      this.taxCode,
      this.warehouseId,
      this.sOFromPO,
      this.pOFromSO,
      this.autoValidation,
      this.customer,
      this.supplier,
      this.active,
      this.periodLockDate,
      this.quatityDecimal,
      this.extRegexPhone,
      this.imageUrl,
      this.city,
      this.district,
      this.ward});

  Companies.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    sender = json['Sender'];
    moreInfo = json['MoreInfo'];
    partnerId = json['PartnerId'];
    email = json['Email'];
    phone = json['Phone'];
    currencyId = json['CurrencyId'];
    fax = json['Fax'];
    street = json['Street'];
    currencyExchangeJournalId = json['CurrencyExchangeJournalId'];
    incomeCurrencyExchangeAccountId = json['IncomeCurrencyExchangeAccountId'];
    expenseCurrencyExchangeAccountId = json['ExpenseCurrencyExchangeAccountId'];
    securityLead = json['SecurityLead'];
    logo = json['Logo'];
    lastUpdated = json['LastUpdated'];
    transferAccountId = json['TransferAccountId'];
    saleNote = json['SaleNote'];
    taxCode = json['TaxCode'];
    warehouseId = json['WarehouseId'];
    sOFromPO = json['SOFromPO'];
    pOFromSO = json['POFromSO'];
    autoValidation = json['AutoValidation'];
    customer = json['Customer'];
    supplier = json['Supplier'];
    active = json['Active'];
    periodLockDate = json['PeriodLockDate'];
    quatityDecimal = json['QuatityDecimal'];
    extRegexPhone = json['ExtRegexPhone'];
    imageUrl = json['ImageUrl'];
    city = json['City'];
    district = json['District'];
    ward = json['Ward'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['PartnerId'] = this.partnerId;
    data['Email'] = this.email;
    data['Phone'] = this.phone;
    data['CurrencyId'] = this.currencyId;

    data['Street'] = this.street;

    data['LastUpdated'] = this.lastUpdated;
    data['TransferAccountId'] = this.transferAccountId;

    data['WarehouseId'] = this.warehouseId;

    data['PeriodLockDate'] = this.periodLockDate;

    data['City'] = this.city;
    data['District'] = this.district;
    data['Ward'] = this.ward;
    return data;
  }
}
