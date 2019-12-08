/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:intl/intl.dart';
import 'package:tpos_mobile/helpers/tpos_api_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CityAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DistrictAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_payment_term.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_category.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ward_address.dart';

class Partner {
  int id;

  String name;
  String displayName;
  String street;
  String website;
  String phone;
  String email;
  bool supplier;
  bool customer;
  bool isCompany;
  int companyId;
  bool active;
  bool employee;
  double credit;
  int debit;
  String type;
  String companyType;
  bool overCredit;
  int creditLimit;
  String zalo;
  String facebook;
  String categoryNames;
  int categoryId;
  DateTime dateCreated;
  DateTime birthDay;
  String status;
  String statusText;
  int propertyPaymentTermId;
  int propertySupplierPaymentTermId;
  String taxCode;
  String imageUrl;
  String image;
  String statusStyle;

  CityAddress city;
  DistrictAddress district;
  WardAddress ward;
  List<PartnerCategory> partnerCategories;
  AccountPaymentTerm propertyPaymentTerm;
  AccountPaymentTerm propertySupplierPaymentTerm;

  String fax;
  String comment;
  String facebookId;
  String facebookASids;
  int statusInt;
  String barcode;
  String ref;

  String get addressFull {
    String temp = "";
    temp = this.street ?? "";
    if (this.ward != null && this.ward.name != null) {
      if (temp.isNotEmpty)
        temp += ", ${ward.name}";
      else
        temp += ward.name;
    }

    if (this.district != null && this.district.name != null) {
      if (temp.isNotEmpty)
        temp += ", ${this.district.name}";
      else
        temp += this.district.name;
    }

    if (this.city != null && this.city.name != null) {
      if (temp.isNotEmpty)
        temp += ", ${this.city.name}";
      else
        temp += this.city.name;
    }

    return temp;
  }

  Partner({
    this.ref,
    this.image,
    this.imageUrl,
    this.taxCode,
    this.propertySupplierPaymentTermId,
    this.propertyPaymentTermId,
    this.barcode,
    this.id,
    this.name,
    this.displayName,
    this.street,
    this.website,
    this.phone,
    this.email,
    this.supplier,
    this.customer,
    this.isCompany,
    this.companyId,
    this.active,
    this.employee,
    this.credit,
    this.debit,
    this.type,
    this.companyType,
    this.overCredit,
    this.creditLimit,
    this.zalo,
    this.facebook,
    this.categoryNames,
    this.categoryId,
    this.dateCreated,
    this.status,
    this.statusText,
    this.city,
    this.district,
    this.ward,
    this.partnerCategories,
    this.fax,
    this.comment,
    this.facebookId,
    this.facebookASids,
    this.statusInt,
    this.propertyPaymentTerm,
    this.birthDay,
    this.statusStyle,
  });

  Partner.fromJson(Map<String, dynamic> jsonMap) {
    id = jsonMap["Id"];
    name = jsonMap["Name"];
    displayName = jsonMap["DisplayName"];
    street = jsonMap["Street"];
    phone = jsonMap["Phone"];
    comment = jsonMap["Comment"];
    facebook = jsonMap["Facebook"];
    facebookId = jsonMap["FacebookId"];
    facebookASids = jsonMap["FacebookASIds"];
    email = jsonMap["Email"];
    fax = jsonMap["Fax"];
    zalo = jsonMap["Zalo"];
    website = jsonMap["Website"];
    //categoryNames = jsonMap["CategoryNames"];
    categoryId = jsonMap["CategoryId"];
    barcode = jsonMap["Barcode"];
    supplier = jsonMap["Supplier"];
    active = jsonMap["Active"];
    ref = jsonMap["Ref"];
    taxCode = jsonMap["TaxCode"];
    customer = jsonMap["Customer"];
    propertyPaymentTermId = jsonMap["PropertyPaymentTermId"];
    propertySupplierPaymentTermId = jsonMap["PropertySupplierPaymentTermId"];
    imageUrl = jsonMap["ImageUrl"];
    image = jsonMap["Image"];
    credit = (jsonMap["Credit"] ?? 0).toDouble();

    if (jsonMap["BirthDay"] != null) {
      birthDay =
          DateFormat("yyyy-MM-ddTHH:mm:ss+07:00").parse(jsonMap["BirthDay"]);
    }

    statusStyle = jsonMap["StatusStyle"];
    if (jsonMap["PropertyPaymentTerm"] != null) {
      propertyPaymentTerm =
          AccountPaymentTerm.fromJson(jsonMap["PropertyPaymentTerm"]);
    }

    if (jsonMap["PropertySupplierPaymentTerm"] != null) {
      propertySupplierPaymentTerm =
          AccountPaymentTerm.fromJson(jsonMap["PropertySupplierPaymentTerm"]);
    }

    status = jsonMap["Status"].toString();
    statusText = jsonMap["StatusText"];
    companyType = jsonMap["CompanyType"];

    if (jsonMap["City"] != null) {
      city = CityAddress.fromMap(jsonMap["City"]);
    }
    if (jsonMap["District"] != null) {
      district = DistrictAddress.fromMap(jsonMap["District"]);
    }
    if (jsonMap["Ward"] != null) {
      ward = WardAddress.fromMap(jsonMap["Ward"]);
    }
    if (jsonMap["Categories"] != null) {
      partnerCategories = (jsonMap["Categories"] as List).map((map) {
        return PartnerCategory.fromJson(map);
      }).toList();
    }
  }

  Map<String, dynamic> toJson([bool removeIfNull = false]) {
    var data = {
      "Id": id,
      "Name": name,
      "DisplayName": displayName,
      "Street": street,
      "Phone": phone,
      "Comment": comment,
      "Facebook": facebook,
      "FacebookId": facebookId,
      "FacebookASIds": facebookASids,
      "Email": email,
      "Fax": fax,
      "StatusText": statusText,
      "Status": status,
      "Zalo": zalo,
      "Website": website,
      "Barcode": barcode,
      "Supplier": supplier,
      "Customer": customer,
      "Active": active,
      "TaxCode": taxCode,
      "CompanyType": companyType,
      "Ref": ref,
      "PropertyPaymentTermId": propertyPaymentTermId,
      "PropertySupplierPaymentTermId": propertySupplierPaymentTermId,
      "ImageUrl": imageUrl,
      "Image": image,
      "Credit": credit,
      "PropertyPaymentTerm": this.propertyPaymentTerm != null
          ? propertyPaymentTerm.toJson()
          : null,
      "PropertySupplierPaymentTerm": this.propertySupplierPaymentTerm != null
          ? propertySupplierPaymentTerm.toJson()
          : null,
      "City": this.city != null ? city.toJson() : null,
      "District": this.district != null ? district.toJson() : null,
      "Ward": this.ward != null ? ward.toJson() : null,
      "CategoryId": this.categoryId,
      "StatusStyle": this.statusStyle,
      // "CategoryNames": this.categoryNames,
      "Categories": this.partnerCategories != null
          ? partnerCategories.map((map) {
              return map.toJson();
            }).toList()
          : null,
    };

//    if (birthDay != null) {
//      data['BirthDay'] = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSS'+07:00'")
//          .format(this.birthDay);
//    }

    if (removeIfNull) {
      data.removeWhere((key, value) => value == null);
    }

    return data;
  }
}

class PartnerRevenue {
  double revenue;
  double revenueBegan;
  double revenueTotal;

  PartnerRevenue({this.revenue, this.revenueBegan, this.revenueTotal});

  PartnerRevenue.fromJson(Map<String, dynamic> json) {
    revenue = json['Revenue'].toDouble();
    revenueBegan = json['RevenueBegan'].toDouble();
    revenueTotal = json['RevenueTotal'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Revenue'] = this.revenue;
    data['RevenueBegan'] = this.revenueBegan;
    data['RevenueTotal'] = this.revenueTotal;
    return data;
  }
}

class CreditDebitCustomerDetail {
  DateTime date;
  int journalCode;
  int accountCode;
  String displayedName;
  double amountResidual;

  CreditDebitCustomerDetail(
      {this.date,
      this.journalCode,
      this.accountCode,
      this.displayedName,
      this.amountResidual});

  CreditDebitCustomerDetail.fromJson(Map<String, dynamic> json) {
    journalCode = json['JournalCode'];
    accountCode = json['AccountCode'];
    displayedName = json['DisplayedName'];
    amountResidual = json['AmountResidual'];
    if (json["Date"] != null) {
      String unixTimeStr = RegExp(r"(?<=Date\()\d+").stringMatch(json["Date"]);

      if (unixTimeStr != null && unixTimeStr.isNotEmpty) {
        int unixTime = int.parse(unixTimeStr);
        date = DateTime.fromMillisecondsSinceEpoch(unixTime);
      } else {
        if (json["Date"] != null) {
          date = convertStringToDateTime(json["Date"]);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Date'] = this.date;
    data['JournalCode'] = this.journalCode;
    data['AccountCode'] = this.accountCode;
    data['DisplayedName'] = this.displayedName;
    data['AmountResidual'] = this.amountResidual;
    return data;
  }
}
