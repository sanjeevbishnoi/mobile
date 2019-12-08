/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/tpos_api_helper.dart';

part 'package:tpos_mobile/src/tpos_apis/models/company.g.dart';

class Company {
  int id;
  String name;
  String sender;
  String moreInfo;
  int partnerId;
  String email;
  String phone;
  int currencyId;
  String fax;
  String street;
  int currencyExchangeJournalId;
  int incomeCurrencyExchangeAccountId;
  int expenseCurrencyExchangeAccountId;
  dynamic securityLead;
  dynamic logo;
  DateTime lastUpdated;
  dynamic transferAccountId;
  String saleNote;
  String taxCode;
  int warehouseId;
  dynamic sOFromPO;
  dynamic pOFromSO;
  dynamic autoValidation;
  bool customer;
  bool supplier;
  dynamic periodLockDate;
  dynamic quatityDecimal;
  dynamic extRegexPhone;
  String imageUrl;
  bool active;

  Company(
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
      this.periodLockDate,
      this.quatityDecimal,
      this.extRegexPhone,
      this.imageUrl, this.active});

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
