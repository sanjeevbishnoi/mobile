/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 4:25 PM
 *
 */

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

class HttpResult<T> {
  String error;
  bool success;
  String body;
  T result;
}

class TPosApiResult<T> {
  bool error;
  String message;
  T result;

  TPosApiResult({this.message, this.result, this.error = false});
}

class OdataResult<T> {
  OdataError error;
  T value;

  OdataResult({this.error, this.value});
  OdataResult.fromJson(Map<String, dynamic> json,
      {T inValue, Function parseValue}) {
    if (json["error"] != null) {
      error = OdataError.fromJson(json["error"]);
    }

    if (parseValue != null) {
      value = parseValue();
    } else {
      value = inValue;
    }
  }
}

class OdataError {
  String code;
  String message;
  String errorDescription;

  OdataError({this.code, this.message});

  OdataError.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    message = json["message"];
  }
}

class PartnerOdataError {
  String code;
  String message;
  String errorDescription;

  PartnerOdataError({this.code, this.message, this.errorDescription});

  PartnerOdataError.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    message = json["message"];
    errorDescription = json["error_description"];
  }
}

void throwOdataError(String errorBody) {
  OdataError err = OdataError.fromJson(jsonDecode(errorBody));
  throw new Exception(err.message);
}

Map<String, dynamic> getHttpResult(Response response) {
  if (response.statusCode.toString().startsWith("2")) {
    return jsonDecode(response.body);
  } else {
    throwHttpException(response);
    return null;
  }
}

String getHttpResultString(Response response) {
  if (response.statusCode.toString().startsWith("2")) {
    return response.body;
  } else {
    throwHttpException(response);
    return null;
  }
}

void catchOdataServerError(Response response) {}

void throwHttpException(Response rp) {
  if (rp.statusCode == 401) {
    throw new Exception("Chưa đăng nhập. Vui lòng đăng nhập");
  } else if (rp.statusCode == 402) {
    throw new Exception("Tài khoản chưa thanh toán");
  } else {
    throw new Exception("${rp.statusCode}, ${rp.reasonPhrase}");
  }
}

void throwTposApiException(Response response) {
  if (response.statusCode == 401) {
    throw new Exception(
        "Tài khoản chưa đăng nhập. Vui lòng đăng xuất và đăng nhập lại");
  } else if (response.statusCode == 402) {
    throw new Exception("Tài khoản chưa thanh toán");
  } else if (response.statusCode == 403) {
    throw new Exception(
        "403. Forbidden. Tài khoản của bạn không có quyền truy cập tính năng này");
  } else {
    //throw  error message
    if (response.body.startsWith("{")) {
      var map = jsonDecode(response.body);
      if (map["message"] != null)
        throw new Exception("${jsonDecode(response.body)["message"]}");
      if (map["error"] != null) {
        throw new Exception("${map["error"]["message"]}");
      } else {
        throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
      }
    } else
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
  }
}

void throwSocketException(SocketException ex) {
  throw new Exception(
      "Không thể truy cập địa chỉ ${ex.address}. Vui lòng kiểm tra dịch vụ, mạng hoặc internet");
}

enum ProductSearchType {
  ALL,
  CODE,
  NAME,
  BARCODE,
}

class ProductSearchResult<T> extends TPosApiResult {
  int resultCount;
  String keyword;
  ProductSearchResult(
      {this.resultCount, this.keyword, bool error, String message, T result})
      : super(error: error, message: message, result: result);
}

class SearchResult<T> extends TPosApiResult {
  int resultCount;
  String keyword;
  SearchResult(
      {this.resultCount, this.keyword, bool error, String message, T result})
      : super(error: error, message: message, result: result);
}
