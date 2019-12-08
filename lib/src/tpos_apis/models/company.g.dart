/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  DateTime lastUpdated;
  if (json["LastUpdated"] != null) {
    String unixTimeStr =
        RegExp(r"(?<=Date\()\d+").stringMatch(json["LastUpdated"]);

    if (unixTimeStr != null && unixTimeStr.isNotEmpty) {
      int unixTime = int.parse(unixTimeStr);
      lastUpdated = DateTime.fromMillisecondsSinceEpoch(unixTime);
    } else {
      if (json["LastUpdated"] != null) {
        lastUpdated = convertStringToDateTime(json["LastUpdated"]);
      }
    }
  }
  return Company(
      id: json['Id'] as int,
      name: json['Name'] as String,
      sender: json['Sender'] as String,
      moreInfo: json['MoreInfo'] as String,
      partnerId: json['PartnerId'] as int,
      email: json['Email'] as String,
      phone: json['Phone'] as String,
      currencyId: json['CurrencyId'] as int,
      fax: json['Fax'] as String,
      street: json['Street'] as String,
      currencyExchangeJournalId: json['CurrencyExchangeJournalId'] as int,
      incomeCurrencyExchangeAccountId:
          json['IncomeCurrencyExchangeAccountId'] as int,
      expenseCurrencyExchangeAccountId:
          json['ExpenseCurrencyExchangeAccountId'] as int,
      securityLead: json['SecurityLead'],
      logo: json['Logo'],
      lastUpdated: lastUpdated,
      transferAccountId: json['TransferAccountId'],
      saleNote: json['SaleNote'] as String,
      taxCode: json['TaxCode'] as String,
      warehouseId: json['WarehouseId'] as int,
      sOFromPO: json['SOFromPO'],
      pOFromSO: json['POFromSO'],
      autoValidation: json['AutoValidation'],
      customer: json['Customer'] as bool,
      supplier: json['Supplier'] as bool,
      periodLockDate: json['PeriodLockDate'],
      quatityDecimal: json['QuatityDecimald'],
      extRegexPhone: json['ExtRegexPhone'],
      imageUrl: json['ImageUrl'] as String,
  active: json["Active"]);
}

Map<String, dynamic> _$CompanyToJson(Company instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('Id', instance.id);
  writeNotNull('Name', instance.name);
  writeNotNull('Sender', instance.sender);
  writeNotNull('MoreInfo', instance.moreInfo);
  writeNotNull('PartnerId', instance.partnerId);
  writeNotNull('Email', instance.email);
  writeNotNull('Phone', instance.phone);
  writeNotNull('CurrencyId', instance.currencyId);
  writeNotNull('Fax', instance.fax);
  writeNotNull('Street', instance.street);
  writeNotNull('CurrencyExchangeJournalId', instance.currencyExchangeJournalId);
  writeNotNull('IncomeCurrencyExchangeAccountId',
      instance.incomeCurrencyExchangeAccountId);
  writeNotNull('ExpenseCurrencyExchangeAccountId',
      instance.expenseCurrencyExchangeAccountId);
  writeNotNull('SecurityLead', instance.securityLead);
  writeNotNull('Logo', instance.logo);
  writeNotNull('LastUpdated', convertDatetimeToString(instance.lastUpdated));
  writeNotNull('TransferAccountId', instance.transferAccountId);
  writeNotNull('SaleNote', instance.saleNote);
  writeNotNull('TaxCode', instance.taxCode);
  writeNotNull('WarehouseId', instance.warehouseId);
  writeNotNull('SOFromPO', instance.sOFromPO);
  writeNotNull('POFromSO', instance.pOFromSO);
  writeNotNull('AutoValidation', instance.autoValidation);
  writeNotNull('Customer', instance.customer);
  writeNotNull('Supplier', instance.supplier);
  writeNotNull('PeriodLockDate', instance.periodLockDate);
  writeNotNull('QuatityDecimald', instance.quatityDecimal);
  writeNotNull('ExtRegexPhone', instance.extRegexPhone);
  writeNotNull('ImageUrl', instance.imageUrl);
  writeNotNull('Active', instance.active);
  return val;
}
