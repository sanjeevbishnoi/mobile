/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_company_current_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCompanyCurrentResult _$GetCompanyCurrentResultFromJson(
    Map<String, dynamic> json) {
  return GetCompanyCurrentResult(
      companyId: json['CompanyId'] as int,
      companyName: json['CompanyName'] as String,
      partnerId: json['PartnerId'] as int);
}

Map<String, dynamic> _$GetCompanyCurrentResultToJson(
    GetCompanyCurrentResult instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('CompanyId', instance.companyId);
  writeNotNull('CompanyName', instance.companyName);
  writeNotNull('PartnerId', instance.partnerId);
  return val;
}
