import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:tpos_mobile/app.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';

class TposApiClient {
  ISettingService _setting;
  LogService _log;
  TposApiClient({ISettingService settingService, LogService logService}) {
    _setting = settingService ?? locator<ISettingService>();
    _log = logService ?? locator<LogService>();
  }

  Client _client = new Client();
  String get shopUrl => "${_setting.shopUrl}:44388";
  String get _accessToken => _setting.shopAccessToken;

  /// http GET
  Future<Response> httpGet(
      {String path,
      bool useBasePath = true,
      Map<String, dynamic> param,
      int timeoutInSecond = 300}) async {
    String url = path;
    if (useBasePath) {
      String content = buildUrlEncodeString(param);
      url = "$shopUrl$path$content";
    }
    _log.info("TPOS API GET " + url);
    var response = await _client.get(url, headers: {
      "Authorization": "Bearer " + _accessToken,
      "MobileAppVersion": App.appVersion,
    }).timeout((new Duration(seconds: timeoutInSecond)));

    _log.info("Response==>>>>> " +
        "${response.statusCode}[${response.reasonPhrase}]\nJson: ${response.body}");

    return response;
  }

  /// HTTP POST
  Future<Response> httpPost(
      {@required String path,
      bool useBasePath = true,
      String body,
      bool throwIfStatusCodeNoOk,
      Map<String, dynamic> params,
      Duration timeOut = const Duration(minutes: 5)}) async {
    String url = path;
    String content = buildUrlEncodeString(params);
    if (useBasePath) {
      url = "$shopUrl$path$content";
    }

    _log.info("TPOS API POST " +
            url +
            "\n==>>>>>" +
            "Request Data: " +
            (body ?? "") ??
        "");
    var response = await _client
        .post(url,
            headers: {
              "Authorization": "Bearer " + _accessToken,
              "Content-Type": "application/json",
              "MobileAppVersion": App.appVersion,
            },
            body: body)
        .timeout(timeOut);

    _log.info("=>>>>>> " +
        response.statusCode.toString() +
        "|" +
        response.reasonPhrase +
        "\n=>>>>>" +
        response.body);
    return response;
  }

  /// HTTP PUT
  Future<Response> httpPut(
      {@required String path,
      bool useBasePath = true,
      String body,
      bool throwIfStatusCodeNoOk}) async {
    String url = path;

    if (useBasePath) {
      url = "$shopUrl$path";
    }

    _log.info(
        "TPOS API PUT " + url + "\n==>>>>>" + "Request Data: " + (body ?? "") ??
            "");
    var response = await _client.put(url,
        headers: {
          "Authorization": "Bearer " + _accessToken,
          "Content-Type": "application/json",
          "MobileAppVersion": App.appVersion,
        },
        body: body);

    _log.info("=>>>>>> " +
        response.statusCode.toString() +
        "|" +
        response.reasonPhrase +
        "\n=>>>>>" +
        response.body);
    return response;
  }

  /// HTTP Delete
  /// HTTP Delete
  Future<Response> httpDelete(
      {@required String path,
      bool useBasePath = true,
      String body,
      bool throwIfStatusCodeNoOk}) async {
    String url = path;
    if (useBasePath) {
      url = "$shopUrl$path";
    }

    _log.info("TPOS API DELETE " + url + "\n==>>>>>");
    var response = await _client.delete(
      url,
      headers: {
        "Authorization": "Bearer " + _accessToken,
        "Content-Type": "application/json",
        "MobileAppVersion": App.appVersion,
      },
    );

    _log.info("=>>>>>> " +
        response.statusCode.toString() +
        "|" +
        response.reasonPhrase +
        "\n=>>>>>" +
        response.body);
    return response;
  }

  ///Convert Map to UrlEncode
  String buildUrlEncodeString(Map<String, dynamic> param) {
    if (param != null && param.length > 0)
      return "?" +
          param.keys.map((key) => "$key=${param[key].toString()}").join("&");
    else
      return "";
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
