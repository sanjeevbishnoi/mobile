/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

/// Lấy màu từ trạng thái khách hàng
Color getColorFromPartnerStatus(String status) {
  switch (status) {
    case "Warning":
      return Colors.orange;
      break;
    case "Vip":
      return Colors.green;
      break;
    case "Bomb":
      return Colors.red;
      break;
    case "Normal":
      return Colors.greenAccent.shade200;
      break;
    default:
      return Colors.white;
      break;
  }
}

/// Lấy màu từ trạng thái khách hàng
List getTextColorFromParterStatus(String status) {
  switch (status) {
    case "Warning":
      return [Colors.orange, Colors.white];
      break;
    case "Vip":
      return [Colors.green, Colors.white];
      break;
    case "Bomb":
      return [Colors.red, Colors.white];
      break;
    case "Normal":
      return [Colors.greenAccent.shade100, Colors.black];
      break;
    default:
      return [Colors.white, Colors.black];
      break;
  }
}

Color getPartnerStatusColor(String style, [String status]) {
  Map<String, Color> bootstrapColors = {
    "primary": Color.fromARGB(204, 229, 255, 1),
    "secondary": Color.fromRGBO(226, 227, 229, 1),
    "success": Color.fromRGBO(92, 184, 92, 1),
    "danger": Color.fromRGBO(217, 83, 79, 1),
    "warning": Color.fromRGBO(240, 173, 78, 1),
    "info": Color.fromRGBO(189, 13, 95, 1),
    "Bomb": Color.fromRGBO(217, 83, 79, 1),
    "Warning": Color.fromRGBO(240, 173, 78, 1),
    "Normal": Color.fromRGBO(226, 227, 229, 1),
  };
  return bootstrapColors[style ?? ""] ?? bootstrapColors["secondary"];
}

FastSaleOrderStateOption getFastSaleOrderStateOption({String state}) {
  List<FastSaleOrderStateOption> options = [
    FastSaleOrderStateOption(
        state: FastSaleOrderState.draft,
        description: "Nháp",
        backgroundColor: Colors.white,
        textColor: Colors.grey),
    FastSaleOrderStateOption(
        state: FastSaleOrderState.open,
        description: "Đã xác nhận",
        backgroundColor: Colors.blue,
        textColor: Colors.blue),
    FastSaleOrderStateOption(
        state: FastSaleOrderState.cancel,
        description: "Hủy bỏ",
        backgroundColor: Colors.orange,
        textColor: Colors.red),
    FastSaleOrderStateOption(
        state: FastSaleOrderState.paid,
        description: "Đã thanh toán",
        backgroundColor: Colors.orange,
        textColor: Colors.green),
    FastSaleOrderStateOption(
        state: FastSaleOrderState.na,
        description: "N/A",
        backgroundColor: Colors.orange,
        textColor: Colors.orange),
  ];

  return options.firstWhere((f) => f.state.toString().contains(state ?? ""),
      orElse: () => options.last);
}

Color getSaleOrderColor(String state) {
  switch (state) {
    case "draft":
      return Colors.grey;
      break;
    case "sale":
      return Colors.blue;
      break;
    default:
      return Colors.grey;
  }
}

Color getSaleOnlineOrderColor(String state) {
  switch (state) {
    case "Nháp":
      return Colors.grey;
      break;
    case "Đơn hàng":
      return Colors.orange;
      break;
    default:
      return Colors.grey;
  }
}

SaleOrderStateOption getSaleOrderStateOption({String state}) {
  List<SaleOrderStateOption> options = [
    SaleOrderStateOption(
        state: SaleOrderState.no,
        description: "Không cần lập hóa đơn",
        backgroundColor: Colors.orange,
        textColor: Colors.red),
    SaleOrderStateOption(
        state: SaleOrderState.toinvoice,
        description: "Chờ lập hóa đơn",
        backgroundColor: Colors.blue,
        textColor: Colors.blue),
    SaleOrderStateOption(
        state: SaleOrderState.invoiced,
        description: "Đã tạo hóa đơn",
        backgroundColor: Colors.orange,
        textColor: Colors.green),
    SaleOrderStateOption(
        state: SaleOrderState.na,
        description: "N/A",
        backgroundColor: Colors.orange,
        textColor: Colors.black),
  ];

  return options.firstWhere((f) => f.state.toString().contains(state ?? ""),
      orElse: () => options.last);
}

String convertShipStatusToVietnamese(String status) {
  switch (status) {
    case "sent":
      return "Đã tiếp nhận";
      break;
    case "cancel":
      return "Đã hủy";
      break;
    case "none":
      return "Chưa tiếp nhận";
      break;
    case "done":
      return "Đã thu tiền";
      break;
    default:
      return status;
  }
}

// Quét mã vạch
Future<ScanBarcodeResult> scanBarcode() async {
  try {
    var barcode = await BarcodeScanner.scan();
    if (barcode != "" && barcode != null) {
      return ScanBarcodeResult(result: barcode, isError: false);
    } else
      return ScanBarcodeResult(
          result: barcode, isError: true, message: "Không có dữ liệu");
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.CameraAccessDenied) {
      return ScanBarcodeResult(
          result: "", isError: true, message: "Không có quyền truy cập camera");
    } else {
      return ScanBarcodeResult(
          result: "", isError: true, message: "Không quét được mã vạch");
    }
  } on FormatException {
    return ScanBarcodeResult(
        result: "", isError: true, message: "Không quét được mã vạch");
  } catch (e) {
    return ScanBarcodeResult(
        result: "", isError: true, message: "Không quét được mã vạch");
  }
}

class ScanBarcodeResult {
  final String result;
  final bool isError;
  final String message;

  ScanBarcodeResult({this.result = "", this.isError = false, this.message});
}

class FastSaleOrderStateOption {
  FastSaleOrderState state;
  String description;
  Color backgroundColor;
  Color textColor;

  FastSaleOrderStateOption(
      {this.state, this.description, this.backgroundColor, this.textColor});
}

Future confirmClosePage(BuildContext context,
    {String title = "Xác nhận đóng",
    String message = "Bạn có muốn đóng trang này không?"}) async {
  return await showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        title,
        style: TextStyle(color: Colors.deepOrangeAccent),
      ),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text("HỦY BỎ"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FlatButton(
          child: Text("XÁC NHẬN"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        )
      ],
    ),
  );
}

class SaleOrderStateOption {
  SaleOrderState state;
  String description;
  Color backgroundColor;
  Color textColor;

  SaleOrderStateOption(
      {this.state, this.description, this.backgroundColor, this.textColor});
}
