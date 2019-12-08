/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

class DistrictAddress {
  String cityCode, cityName, code, name;

  DistrictAddress({this.cityCode, this.cityName, this.code, this.name});

  factory DistrictAddress.fromMap(Map<String, dynamic> jsonMap) {
    return new DistrictAddress(
      code: jsonMap["code"],
      name: jsonMap["name"],
      cityCode: jsonMap["cityCode"],
      cityName: jsonMap["cityName"],
    );
  }

  Map toJson({bool removeIfNull = false}) {
    Map data = {
      "code": this.code,
      "name": this.name,
      "cityCode": this.cityCode,
      "cityName": this.cityName,
    };

    if (removeIfNull) {
      data.removeWhere((key, value) => value == null);
    }

    return data;
  }
}
