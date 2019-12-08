/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

part 'get_company_current_result.g.dart';

class GetCompanyCurrentResult {
  int companyId;

  String companyName;

  int partnerId;

  GetCompanyCurrentResult({this.companyId, this.companyName, this.partnerId});
  factory GetCompanyCurrentResult.fromJson(Map<String, dynamic> json) =>
      _$GetCompanyCurrentResultFromJson(json);

  Map<String, dynamic> toJson() => _$GetCompanyCurrentResultToJson(this);
}
