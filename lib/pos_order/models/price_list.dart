class PriceList {
  int id;
  String name;
  int currencyId;
  String currencyName;
  int active;
  int companyId;
  String partnerCateName;
  int sequence;
  String dateStart;
  String dateEnd;

  PriceList(
      {this.id,
      this.name,
      this.currencyId,
      this.currencyName,
      this.active,
      this.companyId,
      this.partnerCateName,
      this.sequence,
      this.dateStart,
      this.dateEnd});

  PriceList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    currencyId = json['CurrencyId'];
    currencyName = json['CurrencyName'];
    if (json['Active'] == true) {
      active = 1;
    } else {
      active = 0;
    }
    companyId = json['CompanyId'];
    partnerCateName = json['PartnerCateName'];
    sequence = json['Sequence'];
    dateStart = json['DateStart'];
    dateEnd = json['DateEnd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['CurrencyId'] = this.currencyId;
    data['CurrencyName'] = this.currencyName;
    data['Active'] = this.active;
    data['CompanyId'] = this.companyId;
    data['PartnerCateName'] = this.partnerCateName;
    data['Sequence'] = this.sequence;
    data['DateStart'] = this.dateStart;
    data['DateEnd'] = this.dateEnd;
    return data;
  }
}
