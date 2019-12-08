/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 5:46 PM
 *
 */

class CalculateFastOrderFeeResult {
  bool success;
  String message;
  CalucateFeeResultData data;

  CalculateFastOrderFeeResult({this.success, this.message, this.data});
  CalculateFastOrderFeeResult.fromJson(Map jsonMap) {
    success = jsonMap["Success"];
    message = jsonMap["Message"];
    data = CalucateFeeResultData.fromJson(jsonMap["Data"]);
  }
}

class CalucateFeeResultData {
  double totalFee;
  double serviceFee;
  List<CalucateFeeResultDataService> services;
  List<CaculateFeeResultCost> costs;
  CalucateFeeResultData({this.totalFee, this.services, this.costs});

  CalucateFeeResultData.fromJson(Map jsonMap) {
    totalFee = (jsonMap["TotalFee"])?.toDouble() ?? 0;
    if (jsonMap["Services"] != null) {
      services = (jsonMap["Services"] as List)
          .map((f) => CalucateFeeResultDataService.fromJson(f))
          .toList();
    }

    if (jsonMap["Costs"] != null) {
      costs = (jsonMap["Costs"] as List)
          .map((f) => CaculateFeeResultCost.fromJson(f))
          .toList();
    }
  }
}

class CalucateFeeResultDataService {
  String serviceId;
  String serviceName;
  double totalFee;
  int id;
  double fee;
  List<CalculateFeeResultDataExtra> extras;

  CalucateFeeResultDataService({
    this.serviceId,
    this.serviceName,
    this.totalFee,
    this.extras,
  });

  CalucateFeeResultDataService.fromJson(jsonMap) {
    serviceId = jsonMap["ServiceId"];
    serviceName = jsonMap["ServiceName"];
    totalFee = (jsonMap["TotalFee"])?.toDouble();
    extras = (jsonMap["Extras"] as List)
        ?.map((f) => CalculateFeeResultDataExtra.fromJson(f))
        ?.toList();
  }
}

class CalculateFeeResultDataExtra {
  bool isSelected = false;
  double fee;
  String serviceId;
  String serviceName;
  int id;

  CalculateFeeResultDataExtra(
      {this.fee,
      this.serviceId,
      this.serviceName,
      this.isSelected = false,
      this.id}) {
    this.isSelected = false;
  }

  CalculateFeeResultDataExtra.fromJson(Map<String, dynamic> jsonMap) {
    serviceId = jsonMap["ServiceId"];
    serviceName = jsonMap["ServiceName"];
    fee = jsonMap["Fee"]?.toDouble();
    id = jsonMap["Id"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["ServiceId"] = serviceId;
    data["ServiceName"] = serviceName;
    data["Fee"] = fee;
    data["Id"] = id;
    return data;
  }
}

class CaculateFeeResultCost {
  String serviceId;
  String serviceName;
  double totalFee;

  CaculateFeeResultCost({this.serviceId, this.serviceName, this.totalFee});
  CaculateFeeResultCost.fromJson(Map<String, dynamic> json) {
    serviceId = json["ServiceId"];
    serviceName = json["ServiceName"];
    totalFee = (json["TotalFee"])?.toDouble() ?? 0;
  }
}
