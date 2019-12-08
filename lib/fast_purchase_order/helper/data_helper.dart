import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/helpers/tpos_api_helper.dart';

DateTime convertDateTime(String timeString) {
  if (timeString != null) {
    String unixTimeStr = RegExp(r"(?<=Date\()\d+").stringMatch(timeString);

    if (unixTimeStr != null && unixTimeStr.isNotEmpty) {
      int unixTime = int.parse(unixTimeStr);
      return DateTime.fromMillisecondsSinceEpoch(unixTime);
    } else {
      if (timeString != null) {
        return convertStringToDateTime(timeString);
      }
    }
  }
  return null;
}

String getDate(DateTime dateTime) =>
    dateTime != null ? DateFormat("dd/MM/yyyy").format(dateTime) : null;

String getTime(DateTime dateTime) => DateFormat("HH:mm").format(dateTime);

double convertDouble(dynamic number) {
  if (number is int) {
    return double.parse(number.toString());
  } else if (number is String) {
    return double.parse(number);
  } else if (number is double) {
    return number;
  }
  return null;
}

int convertInt(dynamic number) {
  if (number is int) {
    return number;
  } else if (number is String) {
    return double.parse(number).toInt();
  } else if (number is double) {
    return number.toInt();
  }
  return null;
}

String getStateVietnamese(String state) {
  switch (state) {
    case "open":
      {
        return "Đã xác nhận";
      }
    case "paid":
      {
        return "Đã thanh toán";
      }
    case "cancel":
      {
        return "Đã hủy bỏ";
      }
    case "draft":
      {
        return "Nháp";
      }
  }
  return "";
}

Color getStateColor(String state) {
  switch (state) {
    case "open":
      {
        return Colors.blue;
      }
    case "paid":
      {
        return Colors.green;
      }
    case "cancel":
      {
        return Colors.red;
      }
  }
  return Colors.grey;
}

///sort:  DateInvoice,AmountTotal,Number
String getSortVietnamese(String sortField) {
  switch (sortField) {
    case "DateInvoice":
      {
        return "Ngày lập";
      }
    case "AmountTotal":
      {
        return "Tổng tiền";
      }
    case "Number":
      {
        return "Mã hóa đơn";
      }
  }
  return "null";
}

String dateTimeOffset(DateTime text) {
  return text != null
      ? "${DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSS'+07:00'").format(text)}"
      : null;
}

/// 14/2/2018
DateTime getDateTime2(String date) {
  List<String> listTime = date.split("/").toList();
  int day = int.parse(listTime[0]);
  int month = int.parse(listTime[1]);
  int year = int.parse(listTime[2]);
  return new DateTime(year, month, day);
}

String convertTime(dynamic date) {
  if (date != null) {
    String time = "";
    DateTime datetime;
    if (date is String) {
      datetime = DateTime.parse(date);
    } else if (date is DateTime) {
      datetime = date;
    }
    DateTime currentTime = new DateTime.now();
    if (datetime.difference(currentTime).inDays.abs() > 30) {
      time =
          "${(datetime.difference(currentTime).inDays.abs() / 30).round()} tháng trước";
    } else if (datetime.difference(currentTime).inDays.abs() > 0) {
      time = "${datetime.difference(currentTime).inDays.abs()} ngày trước";
    } else if (datetime.difference(currentTime).inHours.abs() > 0) {
      time = "${datetime.difference(currentTime).inHours.abs()} giờ trước";
    } else if (datetime.difference(currentTime).inMinutes.abs() > 0) {
      time = "${datetime.difference(currentTime).inMinutes.abs()} phút trước";
    } else if (datetime.difference(currentTime).inSeconds.abs() > 0) {
      time = "${datetime.difference(currentTime).inSeconds.abs()} giây trước";
    } else {
      time = "";
    }
    return time;
  }

  return "";
}

String convertErrorToString(dynamic e) {
  if (e is SocketException) {
    return "Không thể kết nối đến internet";
  } else {
    return "Đã xãy ra lỗi, vui lòng thử lại";
  }
}
