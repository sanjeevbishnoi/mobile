/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

class WardAddress {
  String cityCode, cityName, code, name, districtCode, districtName;

  WardAddress(
      {this.cityCode,
      this.cityName,
      this.code,
      this.name,
      this.districtCode,
      this.districtName});

  factory WardAddress.fromMap(Map<String, dynamic> jsonMap) {
    return new WardAddress(
      code: jsonMap["code"],
      name: jsonMap["name"],
      cityCode: jsonMap["cityCode"],
      cityName: jsonMap["cityName"],
      districtCode: jsonMap["districtCode"],
      districtName: jsonMap["districtName"],
    );
  }

  Map toJson({bool removeIfNull = false}) {
    Map data = {
      "cityCode": this.cityCode,
      "cityName": this.cityName,
      "code": this.code,
      "name": this.name,
      "districtCode": districtCode,
      "districtName": districtName,
    };

    if (removeIfNull) {
      data.removeWhere((key, value) => value == null);
    }

    return data;
  }
}
