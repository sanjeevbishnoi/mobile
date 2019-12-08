/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

class PrintSaleOnlineData {
  String uid,
      name,
      time,
      product,
      phone,
      code,
      note,
      partnerCode,
      header,
      partnerStatus;

  int index;

  PrintSaleOnlineData(
      {this.index,
      this.uid,
      this.name,
      this.time,
      this.product,
      this.phone,
      this.code,
      this.note,
      this.partnerCode,
      this.partnerStatus,
      this.header});

  Map<String, dynamic> toJsonMap() => {
        'index': index,
        'name': name,
        'uid': uid,
        'time': time,
        'product': product,
        'phone': phone,
        'code': code,
        'note': note,
        'partnerCode': partnerCode,
        "partnerStatus": partnerStatus,
        'header': header,
      };
}
