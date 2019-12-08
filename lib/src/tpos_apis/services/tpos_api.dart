import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/category/mail_template/mail_template.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/data_helper.dart';
import 'package:tpos_mobile/fast_sale_order/models/create_quick_fast_sale_order_model.dart';
import 'package:tpos_mobile/fast_sale_order/models/create_quick_fast_sale_order_result.dart';
import 'package:tpos_mobile/helpers/tpos_api_helper.dart';
import 'package:tpos_mobile/pos_order/models/pos_make_payment.dart';
import 'package:tpos_mobile/pos_order/models/pos_order.dart';
import 'package:tpos_mobile/sale_online/models/FacebookWinner.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/odata_filter.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/tpos_service_models.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/report_dashboard_viewmodel.dart';
import 'package:tpos_mobile/sale_order/sale_order.dart';
import 'package:tpos_mobile/sale_order/sale_order_line.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models/get_facebook_partner_result.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models/get_saved_facebook_post_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_account_tax.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_application_user.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_payment.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_stock_picking_type.dart';
import 'package:tpos_mobile/src/tpos_apis/models/get_product_template_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/get_ship_token_result_model.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_cateogry_for_stock_ware_house_report.dart';
import 'package:tpos_mobile/src/tpos_apis/models/register_tpos_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/status_extra.dart';
import 'package:tpos_mobile/src/tpos_apis/models/stock_report_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/tpos_city.dart';
import 'package:tpos_mobile/src/tpos_apis/models/user_activities.dart';
import 'package:tpos_mobile/src/tpos_apis/models/web_app_route.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'dart:convert';

import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery.dart';

import '../../../app.dart';

part 'object_apis/delivery_carrier_api.dart';

class TposApiService implements ITposApiService {
  LogService _log;
  Client _client = new Client();
  String _accessToken = "";
  String _shopUrl = "";
  String get _shopUrlWithPort => "$_shopUrl:44388";

  TposApiService({String accessToken, String shopUrl}) {
    _log = locator<LogService>();
    this._shopUrl = shopUrl ?? locator<ISettingService>().shopUrl;
    this._accessToken =
        accessToken ?? locator<ISettingService>().shopAccessToken;
    _log.info("TposApiService Created");
  }

  Future<List<SaleOnlineLiveCampaign>> getSaleOnlineLiveCampaign() async {
    var response = await _client.get(
        "$_shopUrlWithPort/odata/SaleOnline_LiveCampaign/ODataService.GetAvailables",
        headers: {
          "Authorization": "Bearer " + _accessToken,
        });
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      var liveCampaignMap = jsonMap["value"] as List;

      return liveCampaignMap.map((map) {
        return SaleOnlineLiveCampaign.fromMap(map);
      }).toList();
    } else {
      throw new Exception("Loi request");
    }
  }

  /// Hàm lấy Danh sách City
  Future<List<CityAddress>> getCityAddress() async {
    var body = json.encode({" provider": "Undefined"});
    var results;
    try {
      var response = await _client.post(
        "https://aship.skyit.vn/api/ApiShippingCity/GetCities",
        headers: {
          "Content-type": "application/json",
          "accept": "application/json",
        },
        body: body,
      );
      print("Response status: ${response.statusCode}");
      //
      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        var jsonMap = jsonDecode(response.body);
        var cityAddress = jsonMap as List;

        results = cityAddress.map((map) {
          return CityAddress.fromMap(map);
        }).toList();
      } else {
        print("Response status: ${response.statusCode}");
      }
    } catch (ex) {
      print(ex.toString());
    }
    return results;
  }

  /// Hàm lấy Danh sách District
  Future<List<DistrictAddress>> getDistrictAddress(String cityCode) async {
    var data = {
      "data": {"code": cityCode},
      "provider": "Undefined"
    };
    var results;
    try {
      var response = await _client.post(
        "https://aship.skyit.vn/api/ApiShippingDistrict/GetDistricts",
        headers: {
          "Content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode(data),
      );
      print("Response status: ${response.statusCode}");
      //
      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        var jsonMap = jsonDecode(response.body);
        var districtAddress = jsonMap as List;

        results = districtAddress.map((map) {
          return DistrictAddress.fromMap(map);
        }).toList();
      } else {
        print("Response status: ${response.statusCode}");
      }
    } catch (ex) {
      print(ex.toString());
    }
    return results;
  }

  /// Hàm lấy Danh sách Ward
  Future<List<WardAddress>> getWardAddress(String districtCode) async {
    var results;
    var data = {
      "data": {"code": districtCode},
      "provider": "Undefined"
    };
    try {
      var response = await _client.post(
        "https://aship.skyit.vn/api/ApiShippingWard/GetWards",
        headers: {
          "Content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode(data),
      );
      print("Response status: ${response.statusCode}");
      //
      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        var jsonMap = jsonDecode(response.body);
        var wardAddress = jsonMap as List;

        results = wardAddress.map((map) {
          return WardAddress.fromMap(map);
        }).toList();
      } else {
        print("Response status: ${response.statusCode}");
      }
    } catch (ex) {
      print(ex.toString());
    }
    return results;
  }

  @override
  Future<LoginInfo> login({String username, String password}) async {
    var response = await _client.post(
      _shopUrlWithPort + "/token",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      },
      body: {
        "username": username,
        "password": password,
        "grant_type": "password",
        "client_id": "tmtWebApp ",
      },
    ).timeout((new Duration(seconds: 30)));

    _log.debug(
      "login " + response.statusCode.toString() + response.body,
    );

    if (response.statusCode == 200) {
      return LoginInfo.getFromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw new Exception("Tài khoản không có quyền truy cập");
    } else if (response.statusCode == 402) {
      throw new Exception("Tài khoản không có quyền truy cập");
    } else if (response.statusCode == 503) {
      throw new Exception("Không kết nối được máy chủ.");
    } else {
      var respondJson = jsonDecode(response.body);
      String errorDescription = respondJson["error_description"];
      throw Exception("$errorDescription");
    }
  }

  Future<void> setAuthenticationInfo({
    String accessToken,
    String shopUrl,
  }) async {
    if (shopUrl != null) this._shopUrl = shopUrl;
    this._accessToken = accessToken;
  }

  @override
  Future<LoginInfo> setAuthentiacation(
      {String username, String password, String shopUrl}) async {
    _shopUrl = shopUrl;
    var loginInfo = await this.login(username: username, password: password);
    if (loginInfo != null) {
      _accessToken = loginInfo.accessToken;
    }

    print(_shopUrlWithPort);
    return loginInfo;
  }

  /// Get cơ bản
  Future<String> tposGet(
      {String path,
      bool useBasePath = true,
      Map<String, dynamic> param}) async {
    String url = path;
    if (useBasePath) {
      String content = buildHtmlUrlEncodeFromParam(param);
      url = "$_shopUrlWithPort$path$content";
    }

    _log.info("TPOS API GET " + url);

    var response = await _client.get(url, headers: {
      "Authorization": "Bearer " + _accessToken,
      "MobileAppVersion": App.appVersion,
    }).timeout((new Duration(seconds: 200)));

    _log.info("Response==>>>>> " +
        "${response.statusCode}[${response.reasonPhrase}]\nJson: ${response.body}");

    if (response.statusCode.toString().startsWith("2")) {
      return response.body;
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  /// http GET
  Future<Response> httpGet(
      {String path,
      bool useBasePath = true,
      Map<String, dynamic> param,
      int timeoutInSecond = 300}) async {
    String url = path;
    if (useBasePath) {
      String content = buildHtmlUrlEncodeFromParam(param);
      url = "$_shopUrlWithPort$path$content";
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
    String content = buildHtmlUrlEncodeFromParam(params);
    if (useBasePath) {
      url = "$_shopUrlWithPort$path$content";
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
      url = "$_shopUrlWithPort$path";
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
  Future<Response> httpDelete(
      {@required String path,
      bool useBasePath = true,
      String body,
      bool throwIfStatusCodeNoOk}) async {
    String url = path;
    if (useBasePath) {
      url = "$_shopUrlWithPort$path";
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

  /// post cơ bản
  Future<String> tposPost(
      {@required String path,
      bool useBasePath = true,
      String body,
      timeoutSecond = 300}) async {
    String url = path;
    if (useBasePath) {
      url = "$_shopUrlWithPort$path";
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
        .timeout(Duration(seconds: timeoutSecond));

    _log.info("=>>>>>> " +
        response.statusCode.toString() +
        "|" +
        response.reasonPhrase +
        "\n=>>>>>" +
        response.body);

    if (response.statusCode.toString().startsWith("2")) {
      return response.body;
    } else if (response.statusCode.toString().startsWith("4")) {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    } else if (response.statusCode.toString().startsWith("5")) {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    } else {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  /// tposPUT
  Future<String> tposPut(
      {@required String path, bool useBasePath = true, String body}) async {
    String url = path;
    if (useBasePath) {
      url = "$_shopUrlWithPort$path";
    }

    _log.info("TPOS API PUT " + url + '\n' + "TPOS API PUT DATA=====>" + body);

    var response = await _client.put(url,
        headers: {
          "Authorization": "Bearer " + _accessToken,
          "Content-Type": "application/json",
          "MobileAppVersion": App.appVersion,
        },
        body: body);

    _log.debug(response.body);
    if (response.statusCode.toString().startsWith("2")) {
      return response.body;
    } else if (response.statusCode.toString().startsWith("4")) {
      throw new Exception("${response.statusCode},: ${response.reasonPhrase}");
    } else if (response.statusCode.toString().startsWith("5")) {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    } else {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  /// tposPATCH
  Future<String> tposPatch(
      {@required String path, bool useBasePath = true, String body}) async {
    String url = path;
    if (useBasePath) {
      url = "$_shopUrlWithPort$path";
    }

    _log.info(
        "TPOS API PATCH " + url + '\n' + "TPOS API PATCH DATA=====>" + body);

    var response = await _client.patch(url,
        headers: {
          "Authorization": "Bearer " + _accessToken,
          "Content-Type": "application/json",
          "MobileAppVersion": App.appVersion,
        },
        body: body);

    if (response.statusCode.toString().startsWith("2")) {
      return response.body;
    } else if (response.statusCode.toString().startsWith("4")) {
      throw new Exception("${response.statusCode},: ${response.reasonPhrase}");
    } else if (response.statusCode.toString().startsWith("5")) {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    } else {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  /// tpos DELETE
  Future<String> tposDelete(
      {@required String path, bool useBasePath = true, String body}) async {
    String url = path;
    if (useBasePath) {
      url = "$_shopUrlWithPort$path";
    }

    _log.info("TPOS API DELETE " + url + "\n==>>>>>" + "Request Data: ");
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

    if (response.statusCode.toString().startsWith("2")) {
      return response.body;
    } else if (response.statusCode.toString().startsWith("4")) {
      throw new Exception(
          "Client Error: Code: ${response.statusCode}, Reason: ${response.reasonPhrase}");
    } else if (response.statusCode.toString().startsWith("5")) {
      throw new Exception(
          "Server Error: Code: ${response.statusCode}, Reason: ${response.reasonPhrase}");
    } else {
      throw new Exception(
          "Error: Code: ${response.statusCode}, Reason: ${response.reasonPhrase}");
    }
  }

  void checkIfApiReturnError(Map jsonMap) {
    if (jsonMap["value"] == null) {
      throw new Exception("Lỗi. ${jsonMap["error"]}");
    }
  }

  ///Convert Map to UrlEncode
  String buildHtmlUrlEncodeFromParam(Map<String, dynamic> param) {
    if (param != null && param.length > 0)
      return "?" +
          param.keys.map((key) => "$key=${param[key].toString()}").join("&");

//      return "?" +
//          param.keys
//              .map((key) =>
//                  "${Uri.encodeComponent(key)}=${Uri.encodeComponent(param[key].toString())}")
//              .join("&");
    else
      return "";
  }

  @override
  Future<List<CRMTeam>> getCRMTeamAllFacebook() async {
    var response = await httpGet(
      path: "/odata/CRMTeam/ODataService.GetAllFacebook",
      param: {
        "\$expand": "Childs",
      },
    );
    if (response.statusCode == 200)
      return (jsonDecode(response.body)["value"] as List).map((item) {
        return CRMTeam.fromJson(item);
      }).toList();
    throwTposApiException(response);
  }

  @override
  Future<CheckFacebookIdResult> checkFacebookId(
      String asUid, String postId, int teamId,
      {int timeoutSecond = 1000}) async {
    var response = await httpGet(
        path: "/api/facebook/checkfacebookid",
        param: {
          "asuid": asUid,
          "postid": postId,
          "teamId": teamId,
        }..removeWhere((key, value) => value == null),
        timeoutInSecond: timeoutSecond);

    if (response.statusCode == 200)
      return CheckFacebookIdResult.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<Map<String, dynamic>> checkPartnerJson({String aSUId}) async {
    String json = await tposGet(
      path: "/odata/SaleOnline_Order/ODataService.CheckPartner",
      param: {"ASUId": aSUId},
    );
    return jsonDecode(json);
  }

  @override
  Future<List<Partner>> checkPartner(
      {String asuid, @required int crmTeamId}) async {
    String json = await tposGet(
      path: "/odata/SaleOnline_Order/ODataService.CheckPartner",
      param: {"ASUId": asuid, "teamId": crmTeamId}
        ..removeWhere((key, value) => value == null),
    );

    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List)
        .map((item) => Partner.fromJson(item))
        .toList();
  }

  @override
  Future<List<SaleOnlineStatusType>> getSaleOnlineOrderStatus() async {
    String json = await tposGet(
      path: "/json/SaleOnline_StatusType",
      param: {},
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap as List)
        .map((status) => SaleOnlineStatusType.fromJson(status))
        .toList();
  }

  @override
  Future<List<LiveCampaign>> getAvaibleLiveCampaigns() async {
    String json = await tposGet(
      path: "/odata/SaleOnline_LiveCampaign/ODataService.GetAvailables",
      param: {},
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List)
        .map((status) => LiveCampaign.fromJson(status))
        .toList();
  }

  @override
  Future<List<LiveCampaign>> getLiveCampaigns() async {
    String json = await tposGet(
      path: "/odata/SaleOnline_LiveCampaign",
      param: {},
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List)
        .map((status) => LiveCampaign.fromJson(status))
        .toList();
  }

  Future<LiveCampaign> getDetailLiveCampaigns(String liveCampaignId) async {
    String json = await tposGet(
      path: "/odata/SaleOnline_LiveCampaign($liveCampaignId)",
      param: {
        "\$expand": "Details",
      },
    );
    var jsonMap = jsonDecode(json);
    return LiveCampaign.fromJson(jsonMap);
  }

  @override
  Future<bool> addLiveCampaign({LiveCampaign newLiveCampaign}) async {
    var jsonMap = newLiveCampaign.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    await tposPost(
      path: "/odata/SaleOnline_LiveCampaign",
      body: jsonEncode(
        jsonMap,
      ),
    );

    return true;
  }

  @override
  Future<bool> editLiveCampaign(LiveCampaign editLiveCampaign) async {
    var jsonMap = editLiveCampaign.toJson();

    var response = await httpPut(
      path: "/odata/SaleOnline_LiveCampaign(${editLiveCampaign.id})",
      body: jsonEncode(jsonMap),
    );
    if (response.statusCode == 204) return true;
    return false;
  }

  @override
  Future<Map<String, GetFacebookPartnerResult>> getFacebookPartners(
      int teamId) async {
    var json = await tposGet(
      path: "/api/common/getfacebookpartners",
      param: {"legacy": false, "teamId": teamId}
        ..removeWhere((key, value) => value == null),
    );

    Map<String, GetFacebookPartnerResult> results =
        new Map<String, GetFacebookPartnerResult>();
    var jsonD = jsonDecode(json);
    jsonD.forEach((key, value) {
      results[key] = GetFacebookPartnerResult.fromJson(value);
    });

    return results;
  }

  @override
  Future<List<Product>> getProducts() async {
    String json = await tposGet(
        path: "/odata/ProductTemplateUOMLine/ODataService.GetLastVersion",
        param: {"Version": -1});
    return await compute(_getProductsFromJson, json);
  }

  static List<Product> _getProductsFromJson(String json) {
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return Product.fromJson(map);
    }).toList();
  }

  @override
  Future<List<Product>> getLastProductsVersion2(int version) async {
    String json = await tposGet(
        path: "/odata/ProductTemplateUOMLine/ODataService.GetLastVersionV2",
        param: {"\$expand": "Datas", "countIndexDB": 68, "Version": version});
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return Product.fromJson(map);
    }).toList();
  }

  @override
  Future<List<SaleOnlineOrder>> getOrdersByFacebookPostId(String postId) async {
    String json = await tposGet(
      path: "/odata/SaleOnline_Order/ODataService.GetOrdersByPostId",
      param: {
        "PostId": postId,
        "orderby": "DateCreated esc",
        "count": true,
      },
    );

    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return SaleOnlineOrder.fromJson(map);
    }).toList();
  }

  @override
  Future<SaleOnlineOrder> insertSaleOnlineOrderFromApp(SaleOnlineOrder order,
      {int timeoutSecond = 300}) async {
    assert(order.crmTeamId != null);
    assert(order.facebookAsuid != null);
    assert(order.facebookCommentId != null);
    assert(order.facebookPostId != null);
    assert(order.note != null);
    assert(order.facebookUserName != null);
    Map jsonMap = order.toJson(true);

    Map temp = {"model": jsonMap};
    String body = jsonEncode(temp);
    var response = await httpPost(
        path:
            "/odata/SaleOnline_Order/ODataService.InsertFromApp?IsIncrease=True",
        body: body,
        timeOut: Duration(seconds: timeoutSecond));

    if (response.statusCode == 200) {
      Map resultJonMap = jsonDecode(response.body);

      return SaleOnlineOrder.fromJson(resultJonMap);
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> updateSaleOnlineOrder(SaleOnlineOrder order) async {
    Map jsonMap = order.toJson(true);
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    var response = await httpPut(
      path: "/odata/SaleOnline_Order(${order.id})",
      body: body,
    );

    if (response.statusCode == 204) {
      return null;
    } else {
      throwHttpException(response);
      return null;
    }
  }

  @override
  Future<TposUser> getLoginedUserInfo() async {
    var response = await httpGet(path: "/rest/v1.0/user/info");
    if (response.statusCode == 200) {
      return TposUser.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<List<SavedFacebookPost>> getSavedFacebookPost(
      String fromId, List<String> postIds) async {
    Map<String, dynamic> bodyMap = {
      "models": {
        "FromId": fromId,
        "PostIds": postIds,
      },
    };

    String bodyEncode = jsonEncode(bodyMap);
    var json = await tposPost(
      path: "/odata/SaleOnline_Facebook_Post/ODataService.GetSavedPosts",
      body: bodyEncode,
    );

    Map returnJsonMap = jsonDecode(json);
    return (returnJsonMap["value"] as List)
        .map((item) => SavedFacebookPost.fromJson(item))
        .toList();
  }

  @override
  Future<SearchResult<List<SaleOrder>>> getSaleOrderList(int take, int skip,
      String keyword, DateTime dateTo, DateTime dateFrom) async {
    Map<String, dynamic> body = {"take": take, "skip": skip};

    if (dateFrom != null ||
        dateTo != null ||
        keyword != null && keyword != "") {
      OdataFilter filter = new OdataFilter();
      filter.logic = "and";
      if (filter.filters == null) {
        filter.filters = new List<FilterBase>();
      }

      if (keyword != null && keyword != "") {
        filter.filters
            .add(new OdataFilter(logic: "or", filters: <OdataFilterItem>[
          OdataFilterItem(
              field: "PartnerDisplayName",
              operator: "contains",
              value: keyword),
          OdataFilterItem(
              field: "PartnerNameNoSign", operator: "contains", value: keyword),
        ]));
      }
      if (dateTo != null && dateFrom != null) {
        filter.filters.add(
          OdataFilterItem(field: "DateOrder", operator: "gte", value: dateFrom),
        );

        filter.filters.add(
          OdataFilterItem(field: "DateOrder", operator: "lte", value: dateTo),
        );
      }
      body["filter"] = filter.toJson();
    }

    var response = await httpPost(
      path: "/SaleOrder/List",
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return new SearchResult(
          keyword: keyword,
          error: false,
          resultCount: jsonMap["Total"],
          result: (jsonMap["Data"] as List)
              .map((f) => SaleOrder.fromJson(f))
              .toList());
    } else {
      return new SearchResult(
          error: true,
          message:
              OdataError.fromJson(jsonDecode(response.body)["error"]).message);
    }
  }

  @override
  Future<List<SaleOrderLine>> getSaleOrderInfo(int id) async {
    var json = await tposGet(path: "/odata/SaleOrder($id)/OrderLines", param: {
      "\$expand": "Product,ProductUOM,InvoiceUOM",
      "\$orderby": "Sequence",
    });
    var jsonMap = jsonDecode(json);
    var orderMap = jsonMap["value"] as List;
    return orderMap.map((f) {
      return SaleOrderLine.fromJson(f);
    }).toList();
  }

  @override
  Future<bool> resetSaleOnlineOrderSessionIndex() async {
    var json = await tposPost(
        path: "/odata/SaleOnline_Order/ODataService.RefreshSessionIndex");

    Map jsonMap = jsonDecode(json);
    if (jsonMap["value"] != null) {
      return jsonMap["value"];
    } else {
      return null;
    }
  }

  Future<SaleOnlineOrder> getOrderById(String orderId) async {
    var response = await httpGet(
        path: "/odata/SaleOnline_Order($orderId)",
        param: {"\$expand": "Details"});
    if (response.statusCode == 200)
      return SaleOnlineOrder.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<List<FastSaleOrderLine>> getFastSaleOrderLineById(int orderId) async {
    var json = await tposGet(
        path:
            "/odata/FastSaleOrder($orderId)/OrderLines?\$expand=Product,ProductUOM,Account,SaleLine");
    var jsonMap = jsonDecode(json);
    var orderMap = jsonMap["value"] as List;
    return orderMap.map((map) {
      return FastSaleOrderLine.fromJson(map);
    }).toList();
  }

  @override
  Future<List<SaleOrderLine>> getSaleOrderLineById(int orderId) async {
    var json = await tposGet(
        path:
            "/odata/SaleOrder($orderId)/OrderLines?\$expand=Product,ProductUOM,InvoiceUOM&\$orderby=Sequence");
    var jsonMap = jsonDecode(json);
    var orderMap = jsonMap["value"] as List;
    return orderMap.map((map) {
      return SaleOrderLine.fromJson(map);
    }).toList();
  }

  @override
  Future<SaleOrder> getSaleOrderById(int orderId,
      {bool getForEdit = false}) async {
    var json = await tposGet(
        path:
            "/odata/SaleOrder($orderId)?\$expand=Partner,PartnerInvoice,PartnerShipping,User,Warehouse,Currency,Company,Project,PriceList,PaymentJournal");
    var jsonMap = jsonDecode(json);
    return SaleOrder.fromJson(jsonMap);
  }

  @override
  Future<Partner> getPartnerById(int id) async {
    var json = await tposGet(path: "/odata/Partner($id)");
    return Partner.fromJson(jsonDecode(json));
  }

  @override
  Future<bool> updatePartnerStatus(int partnerId, String statusString) async {
    var bodyMap = {"status": statusString};
    var body = jsonEncode(bodyMap);
    var json = await tposPost(
        path: "/odata/Partner($partnerId)/ODataService.UpdateStatus",
        body: body);

    var jsonMap = jsonDecode(json);
    return jsonMap["value"];
  }

  @override
  Future<List<PartnerStatus>> getPartnerStatus() async {
    var json = await tposGet(path: "/api/common/getpartnerstatus");
    var jsonMap = jsonDecode(json);
    return (jsonMap as List).map((f) => PartnerStatus.fromJson(f)).toList();
  }

  @override
  Future<List<CheckAddress>> quickCheckAddress(String keyword) async {
    var json = await tposGet(path: "/home/checkaddress", param: {
      "address": "' + $keyword'",
    });
    var jsonMap = jsonDecode(json);
    var checkAddressMap = jsonMap["data"] as List;
    return checkAddressMap.map((map) {
      return CheckAddress.fromMap(map);
    }).toList();
  }

  @override
  Future<LoginInfo> getLoginInfoFromRefreshToken({String refreshToken}) async {
    var body = {
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "client_id": "tmtWebApp ",
    };
    var response = await _client.post(
      _shopUrlWithPort + "/token",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      },
      body: body,
    );

    _log.info(body);
    _log.info(response.statusCode.toString() + response.body);
    if (response.statusCode == 200) {
      return LoginInfo.getFromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Server error: Mã lỗi: ${response.statusCode}, Lý do: ${response.reasonPhrase}");
    }
  }

  @override
  Future<GetSaleOnlineOrderFromAppResult> getSaleOnlineOrderFromApp(
      List<String> listOrderId) async {
    var bodyMap = {"ids": listOrderId};
    String body = jsonEncode(bodyMap);
    String json = await tposPost(
      path: "/odata/SaleOnline_Order/ODataService.GetOrderFromApp",
      body: body,
    );

    return GetSaleOnlineOrderFromAppResult.fromJson(jsonDecode(json));
  }

  @override
  Future<InsertFastSaleOrderFromAppResult> insertFastSaleOrderFromApp(
      Map data) async {
    String body = jsonEncode(data);
    String json = await tposPost(
      path: "/odata/FastSaleOrder/ODataService.InsertOrderFromApp",
      body: body,
    );

    return InsertFastSaleOrderFromAppResult.fromJson(jsonDecode(json));
  }

  @override
  Future<List<DeliveryCarrier>> getDeliveryCarriers() async {
    var json = await tposGet(
      path: "/odata/DeliveryCarrier",
      param: {
        "\$filter": "Active eq true",
        "\$format": "json",
        "\$count": "true",
      },
    );

    var jsonMap = jsonDecode((json));
    return (jsonMap["value"] as List)
        .map((f) => DeliveryCarrier.fromJson(f))
        .toList();
  }

  @override
  Future<List<DeliveryCarrier>> getDeliveryCarriersList() async {
    var response = await httpPost(
      path: "/DeliveryCarrier/List",
      body: jsonEncode({"take": 50, "skip": 0, "page": 1, "pageSize": 50}),
    );

    if (response.statusCode == 200)
      return (jsonDecode(response.body)["Data"] as List)
          .map((f) => DeliveryCarrier.fromJson(f))
          .toList();
    throwTposApiException(response);
    return null;
  }

  @override
  Future<CalculateFastOrderFeeResult> calculateFeeFastSaleOrder(
      Map order) async {
    String body = jsonEncode({"model": order});
    var json = await tposPost(
      path: ":/odata/FastSaleOrder/ODataService.CalculateFee",
      body: body,
    );

    return CalculateFastOrderFeeResult.fromJson(jsonDecode(json));
  }

  @override
  Future<Map<String, dynamic>> getProductInventory() async {
    var response = await httpGet(
      path: "/rest/v1.0/product/getinventory",
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throwTposApiException(response);
    }
  }

  @override
  Future<ReportSaleOrderGeneral> getReportSaleOrderGeneral(
      int top,
      int skip,
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId) async {
    var json = await tposGet(
        path: "/odata/SaleOrder/ODataService.GetReportSaleGeneral",
        param: {
          "BeginDate": dateFrom,
          "EndDate": dateTo,
          "&TypeReport": 1,
          "OrderType": orderType,
          "CompanyId": companyId,
          "PartnerId": partnerId,
          "StaffId": staffId,
          "\$top": top,
          "\$skip": skip,
          "\$count": true,
          "\$format": "json",
          "\$orderby": "date",
        });

    var jsonMap = jsonDecode(json);
    return ReportSaleOrderGeneral.fromJson(jsonMap);
  }

  @override
  Future<List<ReportSaleOrderLine>> getReportSaleOrderDetail(int id) async {
    var json = await tposGet(
        path: "/odata/SaleOrder/ODataService.GetDetailReport3TypeSale",
        param: {
          "key": id,
          "typeSale": "FastSaleOrder",
        });

    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return ReportSaleOrderLine.fromJson(map);
    }).toList();
  }

  @override
  Future<List<ReportDeliveryOrderLine>> getReportDeliveryOrderDetail(
      int id) async {
    var json = await tposGet(
      path:
          "/odata/FastSaleOrder($id)?\$expand=Partner,User,Warehouse,Company,PriceList,RefundOrder,Account,Journal,PaymentJournal,Carrier,Tax,SaleOrder,OrderLines(\$expand=Product,ProductUOM,Account)",
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["OrderLines"] as List).map((map) {
      return ReportDeliveryOrderLine.fromJson(map);
    }).toList();
  }

  @override
  Future<SumReportSaleGeneral> getSumReportSaleGeneral(
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId) async {
    String json = await tposGet(
        path: "/odata/SaleOrder/ODataService.GetSumReportSaleGeneral",
        param: {
          "BeginDate": dateFrom,
          "EndDate": dateTo,
          "&TypeReport": 1,
          "OrderType": orderType,
          "CompanyId": companyId,
          "PartnerId": partnerId,
          "StaffId": staffId,
        });
    var jsonMap = jsonDecode(json);
    return SumReportSaleGeneral.fromJson(jsonMap);
  }

  @override
  Future<SumAmountReportSale> getSumAmountReportSale(
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId) async {
    String json = await tposGet(
        path: "/odata/SaleOrder/ODataService.SumAmountReport3TypeSale",
        param: {
          "BeginDate": dateFrom,
          "EndDate": dateTo,
          "&TypeReport": 1,
          "CompanyId": companyId,
          "OrderType": orderType,
          "PartnerId": partnerId,
          "StaffId": staffId,
        });
    var jsonMap = jsonDecode(json);
    return SumAmountReportSale.fromJson(jsonMap);
  }

  @override
  Future<ReportSaleOrder> getReportSaleOrder(
      int top,
      int skip,
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId) async {
    String json = await tposGet(
        path: "/odata/SaleOrder/ODataService.GetReport3TypeSale",
        param: {
          "BeginDate": dateFrom,
          "EndDate": dateTo,
          "&TypeReport": 1,
          "OrderType": orderType,
          "CompanyId": companyId,
          "PartnerId": partnerId,
          "StaffId": staffId,
          "\$top": top,
          "\$skip": skip,
          "\$format": "json",
          "\$orderby": "DateOrder+desc",
          "\$count": true,
        });
    var jsonMap = jsonDecode(json);
    return ReportSaleOrder.fromJson(jsonMap);
  }

  @override
  Future<ReportDelivery> getReportDelivery(
      int take,
      int skip,
      DateTime dateFrom,
      DateTime dateTo,
      String shipState,
      int partnerId,
      int carrierId) async {
    var map = {
      "FromDate": dateFrom != null ? convertDatetimeToString(dateFrom) : null,
      "ToDate": dateTo != null ? convertDatetimeToString(dateTo) : null,
      "PartnerId": partnerId,
      "CarrierId": carrierId,
      "ShipState": shipState,
      "\$take": take,
      "\$skip": skip,
      "sort": [
        {"field": "DateInvoice", "dir": "desc"}
      ],
      "aggregate": [
        {"field": "PartnerDisplayName", "aggregate": "count"},
        {"field": "AmountTotal", "aggregate": "sum"},
        {"field": "CashOnDelivery", "aggregate": "sum"},
        {"field": "DeliveryPrice", "aggregate": "sum"}
      ]
    };
    var json = await tposPost(
      path: "/FastSaleOrder/DeliveryReport",
      body: jsonEncode(map),
    );
    var jsonMap = jsonDecode(json);
    return ReportDelivery.fromJson(jsonMap);
  }

  @override
  Future<SumDeliveryReport> getReportSumDelivery(DateTime dateFrom,
      DateTime dateTo, String shipState, int partnerId, int carrierId) async {
    var map = {
      "FromDate": dateFrom != null ? convertDatetimeToString(dateFrom) : null,
      "ToDate": dateTo != null ? convertDatetimeToString(dateTo) : null,
      "PartnerId": partnerId,
      "CarrierId": carrierId,
      "ShipState": shipState,
    };
    var json = await tposPost(
      path: "/FastSaleOrder/SumDeliveryReport ",
      body: jsonEncode(map),
    );
    var jsonMap = jsonDecode(json);
    return SumDeliveryReport.fromJson(jsonMap);
  }

  @override
  Future<List<Product>> getProductsPagination(int top, int skip) async {
    String json = await tposGet(
        path: "/odata/ProductTemplateUOMLine",
        param: {"\$top": top, "\$skip": skip});
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return Product.fromJson(map);
    }).toList();
  }

  @override
  Future<bool> changeLiveCampaignStatus(String liveCampaignId) async {
    String json = await tposPost(
        path: "/SaleOnline_LiveCampaign/Approve?id=$liveCampaignId");

    var jsonMap = jsonDecode(json);
    return jsonMap["success"];
  }

  @override
  Future<CalucateFeeResultData> calculateShipingFee({
    int partnerId,
    int companyId,
    int carrierId,
    double weight,
    ShipReceiver shipReceiver,
    List<ShipServiceExtra> shipServiceExtras,
    double shipInsuranceFee,
    String shipServiceId,
    String shipServiceName,
  }) async {
    Map bodyMap = {
      "PartnerId": partnerId,
      "CompanyId": companyId,
      "CarrierId": carrierId,
      "ShipWeight": weight,
      "InsuranceFee": shipInsuranceFee ?? 0,
      "ServiceId": shipServiceId,
    };

    if (shipReceiver != null) {
      bodyMap["Ship_Receiver"] = shipReceiver.toJson(removeIfNull: true);
    }

    if (shipServiceExtras != null) {
      bodyMap["ServiceExtras"] =
          shipServiceExtras.map((f) => f.toJson(removeIfNull: true)).toList();
    }

    bodyMap.removeWhere((key, value) => value == null);

    var response = await httpPost(
      path: "/rest/v1.0/fastsaleorder/calculatefee",
      body: jsonEncode(bodyMap),
    );

    String error;
    try {
      error = jsonDecode(response.body)["error_description"];
    } catch (e) {}

    if (error != null) {
      throw new Exception(error);
    }

    var jsonMap = getHttpResult(response);
    return CalucateFeeResultData.fromJson(jsonMap);
  }

  @override
  Future<List<SaleOnlineFacebookComment>> getCommentsByUserAndPost(
      {@required String userId, @required String postId}) async {
    assert(userId != null);
    assert(postId != null);
    var json = await tposGet(
        path:
            "/odata/SaleOnline_Facebook_Comment/ODataService.GetCommentsByUserAndPost",
        param: {
          "userId": userId,
          "postId": postId,
        });

    return (jsonDecode(json)["value"] as List)
        .map((f) => SaleOnlineFacebookComment.fromJson(f))
        .toList();
  }

  @override
  Future<bool> updateLiveCampaignFacebook(
      {LiveCampaign campaign,
      TposFacebookPost tposFacebookPost,
      bool isCancel = false}) async {
    var bodyMap = {
      "action": isCancel == true ? "cancel" : "update",
      "model": campaign.toJson(removeNullValue: true),
    };
    String body = jsonEncode(bodyMap);
    await tposPost(
      path:
          "/odata/SaleOnline_LiveCampaign(${campaign.id})/ODataService.UpdateFacebook",
      body: body,
    );

    return true;
  }

  @override
  Future<CRMTeam> insertCRMTeam(CRMTeam data) async {
    var bodyMap = data.toJson(true);
    var body = jsonEncode(bodyMap);
    var response = await httpPost(
      path: "/odata/CRMTeam",
      body: body,
    );

    if (response.statusCode == 200) {
      return CRMTeam.fromJson(jsonDecode(response.body));
    }

    throwTposApiException(response);
    return null;
  }

  @override
  Future<bool> checkSaleOnlineFacebookAccount(
      {String facebookId,
      String facebookName,
      String facebookAvatar,
      String token}) async {
    var bodyMap = {
      "FacebookId": facebookId,
      "FacebookName": facebookName,
      "FacebookAvatar": facebookAvatar,
      "Token": token,
    };
    var response = await httpPost(
      path: "/api/facebook/verify",
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["IsAddRequired"];
    }

    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> deleteCRMTeam(int id) async {
    assert(id != null);
    var response = await httpDelete(path: "/odata/CRMTeam($id)");
    if (response.statusCode == 204) return null;
    throwTposApiException(response);
    return null;
  }

  @override
  Future<List<ProductCategory>> getProductCategories() async {
    String json = await tposGet(
        path:
            "/odata/ProductCategory?%24format=json&%24orderby=ParentLeft&%24count=true");
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return ProductCategory.fromJson(map);
    }).toList();
  }

  @override
  Future<SaleOnlineFacebookPostSummaryUser>
      getSaleOnlineFacebookPostSummaryUser(String id) async {
    var response = await httpGet(
      path: "/odata/SaleOnline_Facebook_Post/ODataService.GetPostSummary",
      param: {
        "\$expand": "Users,Post",
        "fbid": "$id",
      },
    );

    if (response.statusCode == 200)
      return SaleOnlineFacebookPostSummaryUser.fromJson(
          jsonDecode(response.body));
    else
      throwTposApiException(response);
  }

  @override
  Future<List<FacebookShareInfo>> getSharedFacebook(String postId, String uid,
      {bool mapUid = false}) async {
    var response = await httpGet(
        path: "/api/facebook/getshareds",
        param: {
          "uid": uid,
          "objectId": postId,
          "ins": "",
          "fll": "",
          "legacy": false,
          "map": mapUid,
        },
        timeoutInSecond: 1200);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((f) => FacebookShareInfo.fromJson(f))
          .toList();
    } else
      throwTposApiException(response);
    return null;
  }

  @override
  Future<OdataResult<ProductCategory>> getProductCategory(int id) async {
    var response = await httpGet(path: "/odata/ProductCategory($id)", param: {
      "\$expand":
          "Parent,StockAccountInputCateg,StockAccountOutputCateg,StockValuationAccount,StockJournal,AccountIncomeCateg,AccountExpenseCateg,Routes",
    });
    return new OdataResult.fromJson(jsonDecode(response.body), parseValue: () {
      return ProductCategory.fromJson(jsonDecode(response.body));
    });
  }

  @override
  Future<OdataResult<PartnerCategory>> getPartnerCategory(int id) async {
    var response = await httpGet(path: "/odata/PartnerCategory($id)", param: {
      "\$expand": "Parent",
    });
    return new OdataResult.fromJson(jsonDecode(response.body), parseValue: () {
      return PartnerCategory.fromJson(jsonDecode(response.body));
    });
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethod() async {
    String json = await tposGet(
      path: "/odata/AccountJournal/ODataService.GetWithCompany",
      param: {
        "\$format": "json",
        "\&filter": "(Type eq 'cash' or Type eq 'bank')",
        "&\$count": true,
        "&select": "id,Name,Code",
      },
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return PaymentMethod.fromJson(map);
    });
  }

  @override
  Future<FastSaleOrderAddEditData> prepareFastSaleOrder(saleOnlineIds) async {
    Map temp = {"SaleOnlineIds": saleOnlineIds};
    String body = jsonEncode(temp);
    String json = await tposPost(
      path: "/rest/v1.0/fastsaleorder/prepare",
      body: body,
    );

    return FastSaleOrderAddEditData.fromJson(jsonDecode(json));
  }

  @override
  Future<List<StatusReport>> getStatusReport(startDate, endDate) async {
    String json = await tposGet(
        path: "/api/common/getstatusreport",
        param: {"startDate": startDate, "endDate": endDate});
    var jsonMap = jsonDecode(json);
    return (jsonMap as List).map((map) {
      return StatusReport.fromJson(map);
    }).toList();
  }

  @override
  Future<List<CompanyOfUser>> getCompanyOfUser() async {
    var json = await tposGet(path: "/Json/GetCompanyOfUser");
    var jsonMap = jsonDecode(json);
    return (jsonMap as List).map((map) {
      return CompanyOfUser.fromJson(map);
    }).toList();
  }

  @override
  Future<List<UserReportStaff>> getUserReportStaff() async {
    var json = await tposGet(path: "/ReportStaff/GetUser");
    var jsonMap = jsonDecode(json);
    return (jsonMap as List).map((map) {
      return UserReportStaff.fromJson(map);
    }).toList();
  }

  @override
  Future<int> getAppDateExpired() async {
    var response = await httpGet(
        path: "/odata/ApplicationUser/ODataService.ChangeCurrentCompanyGet");
    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      var date = map["ExpiredIn"];
      return date;
    }
    return null;
  }

  Future<CompanyCurrentInfo> getCompanyCurrentInfo() async {
    var response = await httpGet(
        path: "/odata/ApplicationUser/ODataService.ChangeCurrentCompanyGet");
    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      return CompanyCurrentInfo.fromJson(map);
    } else {
      throwTposApiException(response);
    }
  }

  @override
  Future<ProductTemplate> quickInsertProductTemplate(newProduct) async {
    Map jsonMap = newProduct.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    String json = await tposPost(
      path: "/odata/ProductTemplate",
      body: body,
    );

    Map resultJsonMap = jsonDecode(json);
    return ProductTemplate.fromJson(resultJsonMap);
  }

  @override
  Future<Product> quickInsertProduct(newProduct) async {
    Map jsonMap = newProduct.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    String json = await tposPost(
      path: "/odata/Product",
      body: body,
    );

    Map resultJsonMap = jsonDecode(json);
    return Product.fromJson(resultJsonMap);
  }

  @override
  Future<ProductCategory> insertProductCategory(productCategory) async {
    Map jsonMap = productCategory.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    String json = await tposPost(
      path: "/odata/ProductCategory",
      body: body,
    );

    Map resultJsonMap = jsonDecode(json);
    return ProductCategory.fromJson(resultJsonMap);
  }

  @override
  Future<PartnerCategory> insertPartnerCategory(partnerCategory) async {
    Map jsonMap = partnerCategory.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    String json = await tposPost(
      path: "/odata/PartnerCategory",
      body: body,
    );

    Map resultJsonMap = jsonDecode(json);
    return PartnerCategory.fromJson(resultJsonMap);
  }

  @override
  Future<List<ProductUOM>> getProductUOM({uomCateogoryId}) async {
    var param;
    if (uomCateogoryId != null) {
      param = {
        "\$format": "json",
        "\$filter": "CategoryId eq $uomCateogoryId",
        "\$count": "true",
      };
    } else {
      param = {
        "\$format": "json",
        "\$count": "true",
      };
    }
    String json = await tposGet(
      path: "/odata/ProductUOM",
      param: param,
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return ProductUOM.fromJson(map);
    }).toList();
  }

  @override
  Future<List<ProductUOMLine>> getProductUOMLine(productId) async {
    var param;
    param = {
      "\$expand": "UOM",
    };

    String json = await tposGet(
      path: "/odata/ProductTemplate($productId)/UOMLines",
      param: param,
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return ProductUOMLine.fromJson(map);
    }).toList();
  }

  Future<List<ProductAttributeLine>> getProductAttribute(productId) async {
    var param;
    param = {
      "\$expand": "Attribute,Values",
    };

    String json = await tposGet(
      path: "/odata/ProductTemplate($productId)/AttributeLines",
      param: param,
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return ProductAttributeLine.fromJson(map);
    }).toList();
  }

  //Hàm lấy danh sách Order
  Future<List<SaleOnlineOrder>> getSaleOnlineOrders(
      {int take,
      int skip,
      int partnerId,
      String facebookPostId,
      int crmTeamId,
      DateTime fromDate,
      DateTime toDate}) async {
    String filterQuery = "";

    //Thêm điều kiện lọc

    //String sortQuery = "";
    List<String> filter = new List<String>();

    if (facebookPostId != null)
      filter.add("Facebook_PostId eq $facebookPostId");
    if (partnerId != null) filter.add("PartnerId eq $partnerId");
    if (crmTeamId != null) filter.add("CRMTeamId eq $crmTeamId");
    if (fromDate != null)
      filter.add(
          "DateCreated ge ${DateFormat("yyyy-MM-ddTHH:mm:ss'+00:00'").format(fromDate)}");
    if (toDate != null)
      filter.add(
          "DateCreated le ${DateFormat("yyyy-MM-ddTHH:mm:ss'+00:00'").format(toDate)}");

    filterQuery = filter.join(" and ");

    Map<String, dynamic> paramMap = {
      "\$top": take,
//      "\$orderby": orderBy,
      "\$count": true,
      "\$filter": filterQuery != "" ? "($filterQuery)" : filterQuery,
    };

    paramMap.removeWhere((key, value) => value == null || value == "");

    var response = await httpGet(
      path: "/odata/SaleOnline_Order",
      param: paramMap,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => SaleOnlineOrder.fromJson(f))
          .toList();
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<List<SaleOnlineOrder>> getSaleOnlineOrdersFilter(
      {int take, int skip, OdataFilter filter, OdataSortItem sort}) async {
    Map<String, dynamic> paramMap = new Map<String, dynamic>();
    if (take != null) {
      paramMap["\$top"] = take;
    }

    if (skip != null) {
      paramMap["\$skip"] = skip;
    }
    if (filter != null) {
      paramMap["\$filter"] = filter.toUrlEncode();
    }
    if (sort != null) {
      paramMap["\$orderby"] = sort.tourlEncode();
    }

//    paramMap["\$Expand"] = "Details";

    var response = await httpGet(
      path: "/odata/SaleOnline_Order/ODataService.GetView",
      param: paramMap,
    );

    if (response.statusCode == 200) {
      return await compute(_getOrder, response.body);
    }
    throwTposApiException(response);
    return null;
  }

  Future<List<ViewSaleOnlineOrder>> getViewSaleOnlineOrderWithFitter(
      {int take, int skip, OdataFilter filter, OdataSortItem sort}) async {
    Map<String, dynamic> paramMap = new Map<String, dynamic>();
    if (take != null) {
      paramMap["\$top"] = take;
    }

    if (skip != null) {
      paramMap["\$skip"] = skip;
    }
    if (filter != null) {
      paramMap["\$filter"] = filter.toUrlEncode();
    }
    if (sort != null) {
      paramMap["\$orderby"] = sort.tourlEncode();
    }

    var response = await httpGet(
        path: "/odata/SaleOnline_Order/ODataService.GetView", param: paramMap);

    if (response.statusCode == 200) {
      return await compute(_getViewOrder, response.body);
    }
    throwTposApiException(response);
    return null;
  }

  static List<SaleOnlineOrder> _getOrder(String json) {
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map(
      (map) {
        return SaleOnlineOrder.fromJson(map);
      },
    ).toList();
  }

  static List<ViewSaleOnlineOrder> _getViewOrder(String json) {
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map(
      (map) {
        return ViewSaleOnlineOrder.fromJson(map);
      },
    ).toList();
  }

  @override
  Future<FastSaleOrderAddEditData> getFastSaleOrderForEdit(int id) async {
    var json = await tposGet(path: "/odata/FastSaleOrder($id)");
    return FastSaleOrderAddEditData.fromJson(jsonDecode(json));
  }

  @override
  Future<FastSaleOrder> getFastSaleOrderForPDF(int id) async {
    var json = await tposGet(path: "/odata/FastSaleOrder($id)", param: {
      "\$expand":
          "Partner,User,Warehouse,Company,PriceList,RefundOrder,Account,Journal,PaymentJournal,Carrier,Tax,SaleOrder,OrderLines(\$expand=Product,ProductUOM,Account)",
    });
    return FastSaleOrder.fromJson(jsonDecode(json));
  }

  @override
  Future<String> getBarcodeShip(String id) async {
    var url =
        "$_shopUrlWithPort/Web/Barcode?type=Code%20128&value=$id&width=600&height=100";
    return url;
  }

  @override
  Future<TPosApiResult<FastSaleOrderAddEditData>> createFastSaleOrder(
      FastSaleOrderAddEditData order,
      [bool isDraft = false]) async {
    Map bodyMap = order.toJson(removeIfNull: true);
    String body = jsonEncode(bodyMap);

    var response = await httpPost(
        path:
            "/rest/v1.0/fastsaleorder/create${isDraft ? "?IsDraft=true" : ""}",
        body: body);

    if (response.statusCode == 200) {
      String json = response.body;
      return new TPosApiResult(
          result: FastSaleOrderAddEditData.fromJson(jsonDecode(json)["Data"]),
          message: jsonDecode(json)["Message"]);
    } else {
      String errorMessage = jsonDecode(response.body)["message"];
      if (errorMessage != null) {
        throw new Exception("$errorMessage");
      } else {
        throw new Exception(
            "${response.reasonPhrase} (${response.statusCode})");
      }
    }
  }

  @override
  Future<List<Partner>> getPartners(keyWord) async {
    String json = await tposGet(path: "/odata/Partner", param: {
      "\$format": "json",
      "\$orderby": "DisplayName",
      "\$filter":
          "(contains(DisplayName,'$keyWord') or contains(NameNoSign,'$keyWord') or contains(Phone,'$keyWord') or contains(Zalo,'$keyWord'))",
      "\$count": "true",
    });
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return Partner.fromJson(map);
    }).toList();
  }

  @override
  Future<List<Partner>> getPartnersForSearch(keyWord, int take,
      {isCustomer = true,
      bool isSupplier = false,
      bool onlyActive = false}) async {
    var param = {
      "\$format": "json",
      "\$select": "Id,Name,Street,Phone,Facebook",
      "\$orderby": "DisplayName",
      "\$filter":
          "(Customer eq $isCustomer and Supplier eq $isSupplier and (contains(DisplayName,'$keyWord') or contains(NameNoSign,'$keyWord') or contains(Phone,'$keyWord') or contains(Zalo,'$keyWord')))",
      "\$count": "true",
      "\$top": take,
    };
    param.removeWhere((key, value) => value == null);
    String json = await tposGet(path: "/odata/Partner", param: param);
//    var jsonMap = jsonDecode(json);
//    return (jsonMap["value"] as List).map((map) {
//      return Partner.fromJson(map);
//    }).toList();

    return await compute(_getPartnersForSearchData, json);
  }

  static List<Partner> _getPartnersForSearchData(String json) {
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return Partner.fromJson(map);
    }).toList();
  }

  @override
  Future<List<PartnerCategory>> getPartnerCategories() async {
    String json = await tposGet(
      path:
          "/odata/PartnerCategory?\$orderby=ParentLeft&%24format=json&%24count=true",
    );
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return PartnerCategory.fromJson(map);
    }).toList();
  }

  @override
  Future<TPosApiResult<Partner>> addPartner(Partner newPartner) async {
    Map jsonMap = newPartner.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    var response = await httpPost(
      path: "/odata/Partner",
      body: body,
    );

    if (response.statusCode == 201) {
      String json = response.body;
      return new TPosApiResult(
          result: Partner.fromJson(jsonDecode(response.body)),
          message: jsonDecode(json)["Message"]);
    } else {
      var odataError = PartnerOdataError.fromJson(jsonDecode(response.body));
      return new TPosApiResult(
          error: true, message: odataError.errorDescription);
    }
  }

  @override
  Future<List<ProductPrice>> getProductPrices() async {
    var response = await httpGet(path: "/odata/Product_PriceList", param: {
      "\$format": "json",
      "\$count": "true",
    });
    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return (jsonMap["value"] as List).map((map) {
        return ProductPrice.fromJson(map);
      }).toList();
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<List<ProductPrice>> getPriceListAvaible(DateTime dateTime) async {
    var response = await httpGet(
        path: "/odata/Product_PriceList/ODataService.GetPriceListAvailable",
        param: {
          "\date": dateTime.toIso8601String(),
          "\$format": "json",
          "\$count": "true",
        });
    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return (jsonMap["value"] as List).map((map) {
        return ProductPrice.fromJson(map);
      }).toList();
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<List<AccountPaymentTerm>> getAccountPayments() async {
    String json = await tposGet(path: "/odata/AccountPaymentTerm", param: {
      "\$format": "json",
      "\$count": "true",
    });
    var jsonMap = jsonDecode(json);
    return (jsonMap["value"] as List).map((map) {
      return AccountPaymentTerm.fromJson(map);
    }).toList();
  }

  @override
  Future<Partner> loadPartner(id) async {
    String json = await tposGet(
      path: "/odata/Partner($id)",
      param: {
        "\$expand":
            "PurchaseCurrency,Categories,AccountPayable,AccountReceivable,StockCustomer,StockSupplier,Title,PropertyProductPricelist,PropertySupplierPaymentTerm,PropertyPaymentTerm"
      },
    );
    var jsonMap = jsonDecode(json);
    return Partner.fromJson(jsonMap);
  }

  @override
  Future<ProductTemplate> loadProductTemplate(id) async {
    String json = await tposGet(
      path: "/odata/ProductTemplate($id)",
      param: {
        "\$expand":
            "UOM,UOMCateg,Categ,UOMPO,POSCateg,Taxes,SupplierTaxes,Product_Teams,Images"
      },
    );
    var jsonMap = jsonDecode(json);
    return ProductTemplate.fromJson(jsonMap);
  }

  @override
  Future<Product> loadProduct(id) async {
    String json = await tposGet(
      path: "/odata/Product($id)",
      param: {"\$expand": "UOM,Categ,UOMPO,POSCateg,AttributeValues"},
    );
    var jsonMap = jsonDecode(json);
    return Product.fromJson(jsonMap);
  }

  @override
  Future<TPosApiResult<bool>> editProductTemplate(productTemplate) async {
    Map jsonMap = productTemplate.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });
    String body = jsonEncode(jsonMap);
    var response = await httpPut(
      path: "/odata/ProductTemplate(${productTemplate.id})",
      body: body,
    );
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<TPosApiResult<bool>> editProduct(product) async {
    Map jsonMap = product.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });
    String body = jsonEncode(jsonMap);
    var response = await httpPut(
      path: "/odata/Product(${product.id})",
      body: body,
    );
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      String message = (jsonDecode(response.body))["message"];
      return new TPosApiResult(error: true, result: false, message: message);
    }
  }

  @override
  Future<TPosApiResult<bool>> editProductCategory(productCategory) async {
    Map jsonMap = productCategory.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });
    String body = jsonEncode(jsonMap);
    var response = await httpPut(
      path: "/odata/ProductCategory(${productCategory.id})",
      body: body,
    );
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      String message = (jsonDecode(response.body))["message"];
      return new TPosApiResult(error: true, result: false, message: message);
    }
  }

  @override
  Future<TPosApiResult<bool>> editPartnerCategory(partnerCategory) async {
    Map jsonMap = partnerCategory.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });
    String body = jsonEncode(jsonMap);
    var response = await httpPut(
      path: "/odata/PartnerCategory(${partnerCategory.id})",
      body: body,
    );
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      String message = jsonDecode(response.body)["errors"]["model.Phone"];
      return new TPosApiResult(error: true, result: false, message: message);
    }
  }

  @override
  Future<TPosApiResult<bool>> editPartner(partner) async {
    Map jsonMap = partner.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    var response = await httpPut(
      path: "/odata/Partner(${partner.id})",
      body: body,
    );

    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(result: true);
    } else {
      //Return error and message
      //catch Server Error
      var json = jsonDecode(response.body);
      if (json["code"] != "error") {
        var odataError = PartnerOdataError.fromJson(json);
        return new TPosApiResult(
            result: false, error: true, message: odataError.errorDescription);
      }
      return new TPosApiResult(
          result: false,
          error: true,
          message: PartnerOdataError.fromJson(json).errorDescription);
    }
  }

  @override
  Future<List<CRMTeam>> getSaleChannelList() async {
    var response = await httpGet(path: "/odata/CRMTeam");

    return (getHttpResult(response)["value"] as List)
        .map((f) => CRMTeam.fromJson(f))
        .toList();
  }

  /// Hàm check địa chỉ
  Future<List<CheckAddress>> checkAddress(String text) async {
    var response = await httpGet(
      path: "/home/checkaddress",
      param: {
        "address": "+ $text",
      },
    );
    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      var checkAddressMap = jsonMap["data"] as List;
      return checkAddressMap.map((map) {
        return CheckAddress.fromMap(map);
      }).toList();
    } else {
      throw new Exception("Lỗi request");
    }
  }

  @override
  Future<bool> editSaleChannelById({CRMTeam crmTeam}) async {
    var jsonMap = crmTeam.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    await tposPatch(
      path: "/odata/CRMTeam(${crmTeam.id})",
      body: jsonEncode(
        jsonMap,
      ),
    );

    return true;
  }

  @override
  Future<bool> addSaleChannel({CRMTeam crmTeam}) async {
    var jsonMap = crmTeam.toJson();
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    await tposPost(
      path: "/odata/CRMTeam/",
      body: jsonEncode(
        jsonMap,
      ),
    );
    return true;
  }

  @override
  Future<TPosApiResult<bool>> fastSaleOrderCancelShip(int orderId) async {
    Map bodyMap = {"id": orderId};
    String body = jsonEncode(bodyMap);
    var response = await httpPost(
      path: "/odata/FastSaleOrder/ODataService.CancelShip",
      body: body,
    );

    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(result: true);
    } else {
      //Return error and message
      //catch Server Error
      var json = jsonDecode(response.body);
      if (json["error"] != null) {
        var odataError = OdataError.fromJson(json["error"]);
        return new TPosApiResult(
            result: false, error: true, message: odataError.message);
      }
      return new TPosApiResult(
          result: false,
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<TPosApiResult<bool>> fastSaleOrderCancelOrder(
      List<int> orderIds) async {
    assert(orderIds != null && orderIds.length != 0);
    if (orderIds == null || orderIds.length == 0) {
      throw new Exception("orderIds null");
    }
    var bodyMap = {"ids": orderIds.toList()};
    var response = await httpPost(
        path: "/odata/FastSaleOrder/OdataService.ActionCancel",
        body: jsonEncode(bodyMap));

    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(result: true);
    } else {
      //Return error and message
      var json = jsonDecode(response.body);
      String error = json["message"];
      return new TPosApiResult(
          result: false,
          error: true,
          message: error ?? "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<TPosApiResult<bool>> fastSaleOrderConfirmOrder(
      List<int> orderIds) async {
    assert(orderIds != null && orderIds.length != 0);
    if (orderIds == null || orderIds.length == 0) {
      throw new Exception("orderIds null");
    }
    var bodyMap = {"ids": orderIds.toList()};
    String body = jsonEncode(bodyMap);
    var response = await httpPost(
        path: "/odata/FastSaleOrder/OdataService.ActionInvoiceOpen",
        body: body);

    if (response.statusCode.toString().startsWith("2")) {
      Map resultMap = jsonDecode(response.body);
      bool success = resultMap["Success"];
      String error = resultMap["Error"];
      return new TPosApiResult(
          result: success, message: error, error: !success);
    } else {
      //Return error and message
      return new TPosApiResult(
          result: false,
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<bool> confirmSaleOrder(int orderId) async {
    assert(orderId != null);
    if (orderId == null) {
      throw new Exception("orderId null");
    }
    var bodyMap = {"id": orderId};
    var response = await httpPost(
        path: "/odata/SaleOrder/ODataService.ActionConfirm2",
        body: jsonEncode(bodyMap));

    if (response.statusCode.toString().startsWith("2")) {
      return true;
    } else {
      //Return error and message
      return false;
    }
  }

  @override
  Future<TPosApiResult<bool>> deleteSaleOrder(int id) async {
    assert(id != null);
    var response = await httpDelete(path: "/odata/SaleOrder($id)");
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      String message = (jsonDecode(response.body))["message"];
      return new TPosApiResult(error: true, result: false, message: message);
    }
  }

  @override
  Future<TPosApiResult<bool>> cancelSaleOrder(int orderId) async {
    assert(orderId != null);
    if (orderId == null) {
      throw new Exception("orderId null");
    }
    var bodyMap = {"id": orderId};
    var response = await httpPost(
        path: "/odata/SaleOrder/ODataService.ActionCancel2",
        body: jsonEncode(bodyMap));

    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(
          result: true, message: "Đã hủy đơn đặt hàng ", error: !true);
    } else {
      //Return error and message
      Map resultMap = jsonDecode(response.body);
      var error = OdataError.fromJson(resultMap["error"]);
      print(error.message);
      return new TPosApiResult(
          result: false, error: true, message: "${error.message}");
    }
  }

  @override
  Future<TPosApiResult<bool>> createSaleOrderInvoice(int orderId,
      {List<int> orderIds}) async {
    assert(orderId != null && orderIds.length != 0);
    if (orderId == null || orderIds.length == 0) {
      throw new Exception("orderId null");
    }
    var bodyMap = {"id": orderId, "ids": orderIds.toList()};
    var response = await httpPost(
        path:
            "/odata/FastSaleOrder/ODataService.DefaultGet?\$expand=Warehouse,User,PriceList,Company,Journal,PaymentJournal,Partner,Carrier,Tax,SaleOrder",
        body: jsonEncode(bodyMap));

    if (response.statusCode.toString().startsWith("2")) {
      Map resultMap = jsonDecode(response.body);
      bool success = resultMap["Success"];
      String error = resultMap["Error"];
      return new TPosApiResult(
          result: success, message: error, error: !success);
    } else {
      //Return error and message
      return new TPosApiResult(
          result: false,
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<TPosApiResult<int>> accountPaymentCreatePost(
      AccountPayment data) async {
    var dataMap = data.toJson(true);
    var bodyMap = {"model": dataMap};

    String body = jsonEncode(bodyMap);
    var response = await httpPost(
        path: "/odata/AccountPayment/OdataService.ActionCreatePost",
        body: body);

    if (response.statusCode.toString().startsWith("2")) {
      var resultMap = jsonDecode(response.body);
      return new TPosApiResult(
          error: false, message: "", result: resultMap["value"]);
    } else {
      var erorr = OdataError.fromJson(jsonDecode(response.body));
      return new TPosApiResult(
          error: true,
          message: erorr.message ??
              "${response.statusCode}: ${response.reasonPhrase}",
          result: null);
    }
  }

  @override
  Future<TPosApiResult<AccountPayment>> accountPaymentPrepairData(
      int orderId) async {
    var bodyMap = {"orderId": orderId};
    var response = await httpPost(
        path:
            "/odata/AccountPayment/ODataService.DefaultGetFastSaleOrder?\$expand=Currency,FastSaleOrders",
        body: jsonEncode(bodyMap));

    if (response.statusCode.toString().startsWith("2")) {
      Map resultMap = jsonDecode(response.body);
      return new TPosApiResult(
          result: AccountPayment.fromJson(resultMap), error: false);
    } else {
      //Return error and message
      // var odataErorr = OdataError.fromJson(jsonDecode(response.body));
      return new TPosApiResult(
          result: null,
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<TPosApiResult<List<AccountJournal>>>
      accountJournalGetWithCompany() async {
    var response = await httpGet(
        path: "/odata/AccountJournal/ODataService.GetWithCompany",
        param: {
          "\$format": "json",
          "\$filter": "(Type eq 'bank' or Type eq 'cash')",
          "\$count": "true",
        });

    if (response.statusCode == 200) {
      var results = (jsonDecode(response.body)["value"] as List)
          .map((f) => AccountJournal.fromJson(f))
          .toList();
      return new TPosApiResult(error: false, result: results);
    } else {
      return new TPosApiResult(
          error: true,
          result: null,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<OdataResult<List<PaymentInfoContent>>> getPaymentInfoContent(
      int orderId) async {
    var response = await httpGet(
        path: "/odata/FastSaleOrder($orderId)/ODataService.GetPaymentInfoJson");

    //if (response == 200) {
    Map jsonMap = jsonDecode(response.body);
    var lists = (jsonMap["value"] as List)
        ?.map((f) => PaymentInfoContent.fromJson(f))
        ?.toList();
    return OdataResult.fromJson(jsonMap, parseValue: () => lists);
  }

  @override
  Future<OdataResult<AccountPayment>> accountPaymentOnChangeJournal(
      int journalId, String paymentType) async {
    var response = await httpGet(
        path: "/odata/AccountPayment/ODataService.OnChangeJournal",
        param: {
          "\$expand": "Currency",
          "journalId": journalId,
          "paymentType": paymentType,
        });

    return new OdataResult.fromJson(jsonDecode(response.body), parseValue: () {
      return AccountPayment.fromJson(jsonDecode(response.body));
    });
  }

  @override
  Future<ProductSearchResult<List<Product>>> productSearch(String keyword,
      {ProductSearchType type = ProductSearchType.ALL,
      int top,
      int skip,
      bool isSearchStartWith = false,
      OdataSortItem sortBy,
      int groupId}) async {
    Map<String, dynamic> param = {"Version": -1};
    String groupParam = "";
    if (groupId != null) {
      groupParam = " and categId eq $groupId";
    }

    if (keyword != null && keyword != "") {
      switch (type) {
        case ProductSearchType.CODE:
          param["\$filter"] = "DefaultCode eq '$keyword'$groupParam";
          break;
        case ProductSearchType.BARCODE:
          param["\$filter"] = "Barcode eq '$keyword'$groupParam";
          break;
        case ProductSearchType.NAME:
          param["\$filter"] = isSearchStartWith == false
              ? "contains(NameNoSign,'$keyword')$groupParam"
              : "startwith(NameNoSign,'$keyword')$groupParam";
          break;
        case ProductSearchType.ALL:
          if (isSearchStartWith) {
            param["\$filter"] =
                "startwith(DefaultCode,'$keyword') or startwith(NameNoSign,'$keyword') or startwith(Barcode,'$keyword')$groupParam";
          } else {
            param["\$filter"] =
                "contains(DefaultCode, '$keyword') or contains(NameNoSign,'$keyword') or contains(Barcode,'$keyword')$groupParam";
          }
          break;
      }
    }

    if (sortBy != null) {
      param["\$orderby"] = sortBy.tourlEncode();
    }

    if (top != null) {
      param["\$top"] = top;
    }
    if (skip != null) {
      param["\$skip"] = skip;
    }

    param["\$count"] = true;
    var response = await httpGet(
      path: "/odata/ProductTemplateUOMLine/ODataService.GetLastVersion",
      param: param,
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return new ProductSearchResult(
          keyword: keyword,
          error: false,
          resultCount: jsonMap["@odata.count"],
          result: (jsonMap["value"] as List)
              .map((f) => Product.fromJson(f))
              .toList());
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<ProductSearchResult<List<ProductCategory>>> productCategorySearch(
      String keyword,
      {int top,
      int skip,
      OdataSortItem sortBy}) async {
    Map<String, dynamic> param = {};
    if (keyword != null && keyword != "") {
      param["\$filter"] = "contains(NameNoSign,'$keyword')";
    }

    if (sortBy != null) {
      param["\$orderby"] = sortBy.tourlEncode();
    }

    if (top != null) {
      param["\$top"] = top;
    }
    if (skip != null) {
      param["\$skip"] = skip;
    }

    param["\$count"] = true;
    var response = await httpGet(
      path: "/odata/ProductCategory",
      param: param,
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return new ProductSearchResult(
          keyword: keyword,
          error: false,
          resultCount: jsonMap["@odata.count"],
          result: (jsonMap["value"] as List)
              .map((f) => ProductCategory.fromJson(f))
              .toList());
    } else {
      return new ProductSearchResult(
          error: true,
          message:
              OdataError.fromJson(jsonDecode(response.body)["error"]).message);
    }
  }

  @override
  Future<ProductSearchResult<List<ProductTemplate>>> productTemplateSearch(
      String keyword,
      {ProductSearchType type = ProductSearchType.ALL,
      int top,
      int skip,
      bool isSearchStartWith = false,
      OdataSortItem sortBy,
      FilterBase filterItem}) async {
    OdataFilter filter = new OdataFilter();
    filter.logic = "and";
    if (filter.filters == null) {
      filter.filters = new List<FilterBase>();
    }

    Map<String, dynamic> body = {
      "sort": [sortBy],
    };

    if (keyword != null && keyword.isNotEmpty) {
      filter.filters
          .add(new OdataFilter(logic: "or", filters: <OdataFilterItem>[
        OdataFilterItem(
            field: "NameNoSign", operator: "contains", value: keyword),
        OdataFilterItem(field: "Barcode", operator: "eq", value: keyword),
        OdataFilterItem(
            field: "DefaultCode", operator: "contains", value: keyword),
        OdataFilterItem(field: "Name", operator: "contains", value: keyword),
      ]));

      body["filter"] = filter.toJson();
    }

    var response = await httpPost(
      path: "/ProductTemplate/List",
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return new ProductSearchResult(
          error: false,
          resultCount: jsonMap["Total"],
          result: (jsonMap["Data"] as List)
              .map((f) => ProductTemplate.fromJson(f))
              .toList());
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<ProductSearchResult<List<PartnerCategory>>> partnerCategorySearch(
      String keyword,
      {int top,
      int skip,
      bool isSearchStartWith = false,
      OdataSortItem sortBy,
      FilterBase filterItem}) async {
    OdataFilter filter = new OdataFilter();
    filter.logic = "and";
    if (filter.filters == null) {
      filter.filters = new List<FilterBase>();
    }

    Map<String, dynamic> body = {};

    if (keyword != null && keyword.isNotEmpty) {
      filter.filters
          .add(new OdataFilter(logic: "or", filters: <OdataFilterItem>[
        OdataFilterItem(
            field: "CompleteName", operator: "contains", value: keyword),
      ]));

      body["filter"] = filter.toJson();
    }

    var response = await httpPost(
      path: "/PartnerCategory/List",
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return new ProductSearchResult(
          error: false,
          resultCount: jsonMap["Total"],
          result: (jsonMap["Data"] as List)
              .map((f) => PartnerCategory.fromJson(f))
              .toList());
    } else {
      throwTposApiException(response);
    }
  }

  @override
  Future<List<PrinterConfigs>> getPrinterConfigs() async {
    var response = await httpGet(
      path: "/odata/Company_Config/ODataService.GetConfigs",
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      var printerConfigsMap = jsonMap["PrinterConfigs"] as List;
      return printerConfigsMap.map((map) {
        return PrinterConfigs.fromJson(map);
      }).toList();
    } else {
      throw new Exception("Lỗi request");
    }
  }

  @override
  Future<void> deletePartner(int id) async {
    assert(id != null);
    var response = await httpDelete(path: "/odata/Partner($id)");
    if (response.statusCode == 204) {
      return null;
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<TPosApiResult<bool>> deleteProductCategory(int id) async {
    assert(id != null);
    var response = await httpDelete(
      path: "/odata/ProductCategory($id)",
    );
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      String message = (jsonDecode(response.body))["message"];
      return new TPosApiResult(error: true, result: false, message: message);
    }
  }

  @override
  Future<OdataResult<List<ApplicationUser>>> getApplicationUsers() async {
    var response = await httpGet(
      path: "/odata/ApplicationUser",
      param: {"\$count": true},
    );

    Map json = jsonDecode(response.body);
    return OdataResult.fromJson(json, parseValue: () {
      return (json["value"] as List)
          .map((f) => ApplicationUser.fromJson(f))
          .toList();
    });
  }

  @override
  Future<OdataResult<List<ApplicationUser>>> getApplicationUsersSaleOrder(
      String keyword) async {
    var response = await httpGet(
      path: "/odata/ApplicationUser",
      param: {
        "\$format": "json",
        "\$count": true,
        "\$filter": "contains(tolower(Name),'$keyword')",
      },
    );

    Map json = jsonDecode(response.body);
    return OdataResult.fromJson(json, parseValue: () {
      return (json["value"] as List)
          .map((f) => ApplicationUser.fromJson(f))
          .toList();
    });
  }

  @override
  Future<OdataResult<List<StockWareHouse>>>
      getStockWareHouseWithCurrentCompany() async {
    var response = await httpGet(
      path: "/odata/StockWarehouse/ODataService.GetByCompany",
      param: {
        "\$count": true,
        "\$format": "json",
      },
    );

    Map json = jsonDecode(response.body);
    return OdataResult.fromJson(json, parseValue: () {
      return (json["value"] as List)
          .map((f) => StockWareHouse.fromJson(f))
          .toList();
    });
  }

  @override
  Future<TPosApiResult<ProductPrice>> getDefaultProductPrice() async {
    var response = await httpGet(path: "/odata/Product_PriceList", param: {
      "\$format": "json",
      "\$count": "true",
    });

    if (response.statusCode == 200) {
      var firstItem = (jsonDecode(response.body) as List).first;
      return TPosApiResult(
          error: false, result: ProductPrice.fromJson(firstItem));
    } else {
      // Catch odata message
      OdataError error =
          OdataError.fromJson(jsonDecode(response.body)["error"]);
      return TPosApiResult(error: true, result: null, message: error.message);
    }
  }

  @override
  Future<OdataResult<Product>> getProductSearchById(int productId) async {
    assert(productId != null);
    var response = await httpGet(
        path: "/odata/ProductTemplateUOMLine/ODataService.GetLastVersion",
        param: {"Version": -1, "\$filter": "Id eq $productId"});

    var map = jsonDecode(response.body);
    return OdataResult.fromJson(map, parseValue: () {
      var values = (map["value"] as List);
      if (values != null) {
        var firstProduct = values.length > 0 ? values.first : null;
        if (firstProduct != null) {
          return Product.fromJson(firstProduct);
        } else {
          return null;
        }
      } else {
        return null;
      }
    });
  }

  @override
  Future<OdataResult<SaleOrder>> getSaleOrderWhenChangePartner(
      SaleOrder order) async {
    Map<String, dynamic> model = {"model": order.toJson(removeIfNull: true)};
    String body = jsonEncode(model);
    var response = await httpPost(
      path: "/odata/SaleOrder/ODataService.OnChangePartner_PriceList",
      params: {"\$expand": "PartnerInvoice,PartnerShipping,PriceList"},
      body: body,
    );

    var jsonMap = jsonDecode(response.body);
    return OdataResult.fromJson(jsonMap, parseValue: () {
      if (response.statusCode.toString().startsWith("2"))
        return SaleOrder.fromJson(jsonMap);
      else
        return null;
    });
  }

  @override
  Future<OdataResult<SaleOrder>> getSaleOrderDefault() async {
    var response = await httpGet(
      path: "/odata/SaleOrder/ODataService.DefaultGet",
      param: {"\$expand": "Currency,Warehouse,User,PriceList,PaymentJournal"},
    );

    var jsonMap = jsonDecode(response.body);
    return OdataResult.fromJson(jsonMap, parseValue: () {
      return SaleOrder.fromJson(jsonMap);
    });
  }

  @override

  ///@odata.context=/odata/$metadata#FastSaleOrder_SaleOnlinePrepare/$entity
  Future<OdataResult<FastSaleOrderSaleLinePrepareResult>>
      getDetailsForCreateInvoiceFromOrder(List<String> saleOnlineIds) async {
    var model = {"ids": saleOnlineIds.toList()};
    var response = await httpPost(
        path: "/odata/SaleOnline_Order/ODataService.GetDetails",
        params: {"\$expand": "orderLines(\$expand=Product,ProductUOM),partner"},
        body: jsonEncode(model));

    var jsonMap = jsonDecode(response.body);
    return OdataResult.fromJson(jsonMap, parseValue: () {
      return FastSaleOrderSaleLinePrepareResult.fromJson(jsonMap);
    });
  }

  @override
  Future<FastSaleOrder> insertFastSaleOrder(
      FastSaleOrder order, bool isDraft) async {
    var map = order.toJson(removeIfNull: true);
    String body = jsonEncode(map);
    var response = await httpPost(
      path: "/odata/FastSaleOrder",
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonMap = jsonDecode(response.body);
      return FastSaleOrder.fromJson(jsonMap);
    } else {
      var jsonMap = jsonDecode(response.body);
      if (jsonMap["error"] != null) {
        OdataError error = OdataError.fromJson(jsonMap["error"]);
        if (error != null) {
          throw new Exception(error.message);
        }
      }

      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<SaleOrder> insertSaleOrder(SaleOrder order, bool isDraft) async {
    var map = order.toJson();
    String body = jsonEncode(map);
    var response = await httpPost(
      path: "/odata/SaleOrder",
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonMap = jsonDecode(response.body);
      return SaleOrder.fromJson(jsonMap);
    } else {
      var jsonMap = jsonDecode(response.body);
      if (jsonMap["error"] != null) {
        OdataError error = OdataError.fromJson(jsonMap["error"]);
        if (error != null) {
          throw new Exception(error.message);
        }
      }

      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<FastSaleOrderLine> getFastSaleOrderLineProductForCreateInvoice({
    FastSaleOrderLine orderLine,
    FastSaleOrder order,
  }) async {
    Map model = {
      "model": orderLine.toJson(removeIfNull: true),
      "order": order.toJson(removeIfNull: true),
    };

    var response = await httpPost(
      path: "/odata/FastSaleOrderLine/ODataService.OnChangeProduct",
      params: {
        "\$expand": "ProductUOM,Account",
      },
      body: jsonEncode(model),
    );

    if (response.statusCode == 200) {
      return FastSaleOrderLine.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception("${response.statusCode} : ${response.reasonPhrase}");
    }
  }

  @override
  Future<SaleOrderLine> getSaleOrderLineProductForCreateInvoice({
    SaleOrderLine orderLine,
    SaleOrder order,
  }) async {
    Map model = {
      "model": orderLine.toJson(removeIfNull: true),
      "order": order.toJson(removeIfNull: true),
    };

    var response = await httpPost(
      path: "/odata/SaleOrderLine/ODataService.OnChangeProduct",
      params: {
        "\$expand": "ProductUOM",
      },
      body: jsonEncode(model),
    );

    if (response.statusCode == 200) {
      return SaleOrderLine.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception("${response.statusCode} : ${response.reasonPhrase}");
    }
  }

  @override
  Future<void> updateFastSaleOrder(FastSaleOrder order) async {
    var map = order.toJson(removeIfNull: true);
    var response = await httpPut(
      path: "/odata/FastSaleOrder(${order.id})",
      body: jsonEncode(map),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throwTposApiException(response);
    }
  }

  @override
  Future<void> updateSaleOrder(SaleOrder order) async {
    var map = order.toJson();
    var result = jsonEncode(map);
    var response = await httpPut(
      path: "/odata/SaleOrder(${order.id})",
      body: jsonEncode(map),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throw new Exception("${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<DashboardReport> getDashboardReport(
      {String columnChartValue = "W",
      String columnCharText = "TUẦN NÀY",
      String barChartValue = "W",
      String barChartText = "TUẦN NÀY",
      int barChartOrderValue = 1,
      String barChartOrderText = "THEO DOANH SỐ",
      String lineChartValue = "WNWP",
      String lineChartText = "TUẦN NÀY",
      String overViewValue = "T",
      String overViewText = "HÔM NAY"}) async {
    var response = await httpGet(
      path: "/Home/GeneralDashboard",
      param: {
        "ColumnChartValue": columnChartValue,
        "ColumnCharText": columnCharText,
        "BarChartValue": barChartValue,
        "BarChartText": barChartText,
        "BarChartOrderValue": barChartOrderValue,
        "BarChartOrderText": barChartOrderText,
        "LineChartValue": lineChartValue,
        "LineChartText": lineChartText,
        "OverViewValue": overViewValue,
        "OverViewText": overViewText,
      },
    );

    if (response.statusCode == 200) {
      return DashboardReport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("error for read data from server");
    }
  }

  @override
  Future<DashboardReportOverView> getDashboardReportOverview(
      {String columnChartValue = "W",
      String columnCharText = "TUẦN NÀY",
      String barChartValue = "W",
      String barChartText = "TUẦN NÀY",
      int barChartOrderValue = 1,
      String barChartOrderText = "THEO DOANH SỐ",
      String lineChartValue = "WNWP",
      String lineChartText = "TUẦN NÀY",
      String overViewValue = "T",
      String overViewText = "HÔM NAY"}) async {
    var response = await httpGet(
      path: "/Home/GetDataOverview",
      param: {
        "ColumnChartValue": columnChartValue,
        "ColumnCharText": columnCharText,
        "BarChartValue": barChartValue,
        "BarChartText": barChartText,
        "BarChartOrderValue": barChartOrderValue,
        "BarChartOrderText": barChartOrderText,
        "LineChartValue": lineChartValue,
        "LineChartText": lineChartText,
        "OverViewValue": overViewValue,
        "OverViewText": overViewText,
      },
    );

    if (response.statusCode == 200) {
      return DashboardReportOverView.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("error for read data from server");
    }
  }

  DateTime lastCheckTime = DateTime.now();

  @override
  Future<String> getFacebookUidFromAsuid(String asuid, int teamId) async {
    if (DateTime.now().add(Duration(seconds: -30)).isAfter(lastCheckTime)) {
      throw new Exception("Hành động này chỉ cho phép thực hiện mỗi 30 giây");
    }
    var response = await httpGet(path: "/home/checkfacebookid", param: {
      "asuid": asuid,
      "teamId": teamId,
    });
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["uid"];
    } else {
      return null;
    }
  }

  @override
  Future<String> getFastSaleOrderPrintDataAsHtml(
      {@required fastSaleOrderId, String type, int carrierId}) async {
    String url = "";
    Map<String, dynamic> param = {};
    switch (type) {
      case "ship":
        url = "/fastsaleorder/PrintShipThuan";
        param = {
          "ids": fastSaleOrderId,
          "carrierId": carrierId,
        }..removeWhere((key, value) => value == null);
        break;
      case "invoice":
        url = "/fastsaleorder/print";
        param = {
          "ids": fastSaleOrderId,
        };
        break;
      case "orderA4":
        break;
    }

    var response = await httpGet(path: url, param: param);
    if (response.statusCode == 200)
      return response.body;
    else
      return null;
  }

  @override
  Future<CompanyConfig> getCompanyConfig() async {
    var response =
        await httpGet(path: "/odata/Company_Config/OdataService.GetConfigs");

    if (response.statusCode == 200) {
      return CompanyConfig.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<CompanyConfig> saveCompanyConfig(CompanyConfig config) async {
    var bodyMap = config.toJson();
    String body = jsonEncode(bodyMap);
    var response = await httpPost(path: "/odata/Company_Config", body: body);

    if (response.statusCode == 200) {
      return CompanyConfig.fromJson(jsonDecode(response.body));
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<void> switchCompany(int companyId) async {
    Map<String, dynamic> bodyMap = {"companyId": companyId};
    var response = await httpPost(
      path: "/odata/ApplicationUser/ODataService.SwitchCompany",
      body: jsonEncode(bodyMap),
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<bool> checkTokenIsValid() async {
    var response = await httpGet(path: "/rest/v1.0/user/info");
    if (response.statusCode == 401 || response.statusCode == 403) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<List<MailTemplate>> getMailTemplates() async {
    var response = await httpGet(
      path: "/odata/MailTemplate",
      param: {
        "\$orderby": "Name asc",
        "\$filter": "TypeId eq 'General'",
      },
    );

    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      return (map["value"] as List)
          .map((f) => MailTemplate.fromJson(f))
          .toList();
    } else {
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<void> addMailTemplate(MailTemplate template) async {
    Map bodyMap = template.toJson(true);
    var response = await httpPost(
      path: "/odata/MailTemplate",
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<String> getFacebookPSUID({String asuid, String pageId}) async {
    assert(asuid != null && asuid != "");
    assert(pageId != null && pageId != "");
    var response = await httpGet(
      path: "/api/facebook/getfacebookpsuid",
      param: {
        "asuid": asuid,
        "pageid": pageId,
      },
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var success = json["success"];
      if (success) {
        return json["psid"];
      } else {
        return null;
      }
    } else {
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<String> insertFacebookPostComment(
      List<TposFacebookPost> posts, int crmTeamId) async {
    assert(crmTeamId != null);
    var bodyMap = {
      "isEnableDeepScan": false,
      "isInitialized": false,
      "models": posts.map((f) => f.toJson(removeNullValue: true)).toList(),
    };

    var json = jsonEncode(bodyMap);
    var response = await httpPost(
        path: "/odata/SaleOnline_Facebook_Post/ODataService.Inserts",
        params: {"CRMTeamId": crmTeamId},
        body: json);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["Id"];
    } else
      throwHttpException(response);
    return null;
  }

  @override
  Future<List<DeliveryStatusReport>> getFastSaleOrderDeliveryStatusReports(
      {DateTime startDate, DateTime endDate}) async {
    var response = await httpGet(
        path: "/FastSaleOrder/GetStatusReportDelivery",
        param: startDate != null && endDate != null
            ? {
                "startDate": startDate?.toString(),
                "endDate": endDate?.toString(),
              }
            : null);

    if (response.statusCode == 200) {
      if (response.body != null &&
          response.body != "" &&
          response.body != '""' &&
          response.body.length > 10) {
        return (jsonDecode(response.body) as List)
            .map((f) => DeliveryStatusReport.fromJson(f))
            .toList();
      }
    } else {
      throwHttpException(response);
    }
    return null;
  }

  @override
  Future<void> sendFastSaleOrderToShipper(int fastSaleOrderId) async {
    var bodyMap = {"id": fastSaleOrderId};
    var reponse = await httpPost(
      path: "/odata/FastSaleOrder/ODataService.SendToShipper",
      body: jsonEncode(bodyMap),
    );

    if (reponse.statusCode == 200) {
      return null;
    } else {
      throwTposApiException(reponse);
      return null;
    }
  }

  ///Tắt mở tính năng sale online order
  @override
  Future<ApplicationConfigCurrent> updateSaleOnlineSessionEnable() async {
    var response = await httpPost(
        path: "/odata/SaleOnline_Order/ODataService.UpdateSessionEnable");

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return ApplicationConfigCurrent.fromJson(json);
    } else {
      throwHttpException(response);
      return null;
    }
  }

  @override
  Future<ApplicationConfigCurrent> getCheckSaleOnlineSessionEnable() async {
    var response = await httpGet(
        path: "/odata/SaleOnline_Order/ODataService.CheckSessionEnable");
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return ApplicationConfigCurrent.fromJson(json);
    } else {
      throwHttpException(response);
      return null;
    }
  }

  ///sort:  DateInvoice,AmountTotal,Number
  ///dir asc ,desc
  @override
  Future<List<FastPurchaseOrder>> getFastPurchaseOrderList(
      take, skip, page, pageSize, sort, filter) async {
    var body = {
      "take": take,
      "skip": skip,
      "page": page,
      "pageSize": pageSize,
      "sort": sort,
      "filter": filter
    };
    var response =
        await httpPost(path: "/FastPurchaseOrder/List", body: jsonEncode(body));
    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      return (map["Data"] as List).map((f) {
        try {
          //print(f.toString());
          return FastPurchaseOrder.fromJson(f);
        } catch (e) {
          print(e);
          throw new Exception("lỗi nè $e ");
        }
      }).toList();
    } else {
      throwTposApiException(response);
      return null;
    }
  }

  @override
  Future<String> unlinkPurchaseOrder(List<int> ids) async {
    var body = {
      "ids": ids,
    };
    var response = await httpPost(
        path: "/odata/FastPurchaseOrder/ODataService.Unlink",
        body: jsonEncode(body));

    if (response.statusCode == 204) {
      return "Xóa thành công ${ids.length} hóa đơn";
    } else if (response.statusCode == 500) {
      return jsonDecode(response.body)["message"];
    } else {
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<void> sendFacebookPageInbox(
      {@required String message,
      @required int cmrTeamid,
      @required FacebookComment comment,
      @required String facebookPostId}) async {
    assert(message != null);
    assert(cmrTeamid != null && comment != null && facebookPostId != null);
    Map<String, dynamic> body = {
      "Comments": [
        {
          "is_hidden": comment.isHidden,
          "can_hide": comment.canHide,
          "message": comment.message,
          "from": {
            "id": comment.from.id,
            "name": comment.from.name,
            "picture": comment.from.pictureLink,
          },
          "created_time": comment.createdTime?.toString(),
          "facebook_id": comment.id,
          "post": {
            "facebook_id": facebookPostId,
          }
        }
      ],
      "TeamId": cmrTeamid,
      "Message": message,
    };

    var response = await httpPost(
      path: "/api/facebook/sendquickreply",
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return;
    }
    throwTposApiException(response);
  }

  Future<FastPurchaseOrder> getDetailsPurchaseOrderById(int id) async {
    var response = await httpGet(
        path:
            "/odata/FastPurchaseOrder($id)?\$expand=Partner,PickingType,Company,Journal,Account,User,RefundOrder,PaymentJournal,Tax,OrderLines(\$expand%3DProduct,ProductUOM,Account)");
    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      //debugPrint(JsonEncoder.withIndent('  ').convert(jsonMap));
      return FastPurchaseOrder.fromJson(jsonMap);
    } else {
      //catch error
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<Map<String, dynamic>> doPaymentFastPurchaseOrder(
      FastPurchaseOrderPayment fastPurchaseOrderPayment) async {
    Map<String, dynamic> body = {
      "model": fastPurchaseOrderPayment.toJson(),
    };

    var response = await httpPost(
      path: "/odata/AccountPayment/ODataService.ActionCreatePost",
      body: jsonEncode(body),
    );
    debugPrint(JsonEncoder.withIndent('  ').convert(body));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 500) {
      return jsonDecode(response.body);
    }
    throw new Exception((jsonDecode(response.body)["message"]) ??
        "${response.statusCode}, ${response.reasonPhrase}");
  }

  Future<FastPurchaseOrderPayment> getPaymentFastPurchaseOrderForm(
      int id) async {
    Map<String, dynamic> body = {
      "orderId": id,
    };

    var response = await httpPost(
      path:
          "/odata/AccountPayment/ODataService.DefaultGetFastPurchaseOrder?\$expand=Currency,FastPurchaseOrders",
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return FastPurchaseOrderPayment.fromJson(jsonDecode(response.body));
    }
    throw new Exception((jsonDecode(response.body)["message"]) ??
        "${response.statusCode}, ${response.reasonPhrase}");
  }

  Future<List<JournalFPO>> getJournalOfFastPurchaseOrder() async {
    var response = await httpGet(
        path:
            "/odata/AccountJournal/ODataService.GetWithCompany?%24format=json&%24filter=(Type+eq+%27bank%27+or+Type+eq+%27cash%27)&%24count=true");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => JournalFPO.fromJson(f))
          .toList();
    } else {
      throw Exception(jsonDecode(response.body)["message"]);
    }
  }

  Future<String> cancelFastPurchaseOrder(List<int> ids) async {
    Map<String, dynamic> body = {"ids": ids};
    var response = await httpPost(
        path: "/odata/FastPurchaseOrder/ODataService.ActionCancel",
        body: jsonEncode(body));
    if (response.statusCode == 204) {
      return "Success";
    } else {
      return jsonDecode(response.body)["message"];
    }
  }

  Future<FastPurchaseOrder> getDefaultFastPurchaseOrder(
      {bool isRefund = false}) async {
    Map<String, dynamic> body = {
      "model": {"Type": isRefund ? "refund" : "invoice"}
    };
    var response = await httpPost(
        path:
            "/odata/FastPurchaseOrder/ODataService.DefaultGet?\$expand=Company,PickingType,Journal,User,PaymentJournal",
        body: jsonEncode(body));

    if (response.statusCode == 200) {
      debugPrint(
          JsonEncoder.withIndent('  ').convert(jsonDecode(response.body)));
      return FastPurchaseOrder.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<List<AccountTaxFPO>> getListAccountTaxFPO() async {
    var response =
        await httpGet(path: "/odata/AccountTax/ODataService.GetWithCompany");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => AccountTaxFPO.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<List<PartnerFPO>> getListPartnerFPO() async {
    var response = await httpGet(
        path:
            "/odata/Partner?%24format=json&%24top=10&%24filter=(Supplier+eq+true+and+Active+eq+true)&%24count=true");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => PartnerFPO.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<List<StockPickingTypeFPO>> getStockPickingTypeFPO() async {
    var response = await httpGet(
        path:
            "/odata/StockPickingType/ODataService.GetByCompany?%24format=json&%24filter=Code+eq+%27incoming%27&%24count=true");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => StockPickingTypeFPO.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<List<PartnerFPO>> getListPartnerByKeyWord(String text) async {
    var response = await httpGet(
      path:
          "/odata/Partner?%24format=json&%24top=10&%24orderby=DisplayName&%24filter=(contains(DisplayName%2C%27$text%27)+or+contains(NameNoSign%2C%27$text%27)+or+contains(Phone%2C%27$text%27))&%24count=true",
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => PartnerFPO.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<List<ApplicationUserFPO>> getApplicationUserFPO() async {
    var response = await httpGet(
      path: "/odata/ApplicationUser?%24format=json&%24count=true",
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => ApplicationUserFPO.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<Account> onChangePartnerFPO(
      FastPurchaseOrder fastPurchaseOrder) async {
    Map<String, dynamic> body = {
      "model": fastPurchaseOrder.toJson(),
    };
    var response = await httpPost(
        path:
            "/odata/FastPurchaseOrder/ODataService.OnChangePartner?\$expand=Account",
        body: jsonEncode(body));
    debugPrint(JsonEncoder.withIndent('   ').convert(body));
    debugPrint(
        JsonEncoder.withIndent('   ').convert(jsonDecode(response.body)));
    if (response.statusCode == 200) {
      return Account.fromJson(jsonDecode(response.body)["Account"]);
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<OrderLine> onChangeProductFPO(
      FastPurchaseOrder fastPurchaseOrder, OrderLine orderLine) async {
    Map<String, dynamic> body = {
      "paramModel": {
        "PartnerId": fastPurchaseOrder.partner.id,
        "DateOrder": dateTimeOffset(fastPurchaseOrder.dateInvoice)
      },
      "model": orderLine.toJson(),
      "order": fastPurchaseOrder.toJsonOnChangeProduct(),
    };

    var response = await httpPost(
        path:
            "/odata/FastPurchaseOrderLine/ODataService.OnChangeProduct?\$expand=ProductUOM,Account",
        body: jsonEncode(body));

    if (response.statusCode == 200) {
//      debugPrint(
//          JsonEncoder.withIndent('   ').convert(jsonDecode(response.body)));
      Account account = Account.fromJson(jsonDecode(response.body)["Account"]);
      ProductUOM productUOM =
          ProductUOM.fromJson(jsonDecode(response.body)["ProductUOM"]);
      orderLine.accountId = account.id;
      orderLine.account = account;
      orderLine.productUom = productUOM;
      orderLine.productUOMId = productUOM.id;

      return orderLine;
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  Future<List<Product>> getProductsFPO() async {
    Map<String, dynamic> body = {
      "take": 200,
      "skip": 0,
      "page": 1,
      "pageSize": 200,
      "sort": [
        {"field": "Name", "dir": "asc"}
      ]
    };
//    debugPrint(JsonEncoder.withIndent('   ').convert(body));

    var response =
        await httpPost(path: "/ProductTemplate/List", body: jsonEncode(body));

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)['Data'] as List)
          .map((f) => Product.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  /// /odata/ProductTemplate(12108)?$expand=UOM
  Future<ProductUOM> getUomFPO(int id) async {
    var response =
        await httpGet(path: "/odata/ProductTemplate($id)?\$expand=UOM");
    if (response.statusCode == 200) {
      debugPrint(JsonEncoder.withIndent('   ')
          .convert(jsonDecode(response.body)['UOM']));
      return ProductUOM.fromJson(jsonDecode(response.body)["UOM"]);
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  Future<List<AccountTaxFPO>> getTextFPO() async {
    var response =
        await httpGet(path: "/odata/AccountTax/ODataService.GetWithCompany");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => AccountTaxFPO.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  Future<FastPurchaseOrder> actionInvoiceDraftFPO(
      FastPurchaseOrder item) async {
    ///gán id
    item.companyId = item.company.id;
    item.journalId = item.journal.id;
    item.partnerId = item.partner.id;
    item.paymentJournalId = item.paymentJournal.id;
    item.pickingTypeId = item.pickingType.id;
    item.userId = item.user.id;
    item.taxId = item.tax != null ? item.tax.id : null;
    item.accountId = item.account.id;

    Map<String, dynamic> body = item.toJson();

    var response = await httpPost(
      path: "/odata/FastPurchaseOrder",
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return FastPurchaseOrder.fromJsonResponse(jsonDecode(response.body));
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  Future<bool> actionInvoiceOpenFPO(FastPurchaseOrder item) async {
    Map<String, dynamic> body = {
      "ids": [item.id]
    };
    var response = await httpPost(
        path: "/odata/FastPurchaseOrder/ODataService.ActionInvoiceOpen",
        body: jsonEncode(body));
    debugPrint(JsonEncoder.withIndent('   ').convert(body));
    if (response.statusCode == 204) {
      return true;
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  Future<FastPurchaseOrder> actionEditInvoice(FastPurchaseOrder item) async {
    //print("ID của hóa đơn: ${item.id}");

    ///gán id
    item.companyId = item.company.id;
    item.journalId = item.journal.id;
    item.partnerId = item.partner.id;
    item.paymentJournalId = item.paymentJournal.id;
    item.pickingTypeId = item.pickingType.id;
    item.userId = item.user.id;
    item.taxId = item.tax != null ? item.tax.id : null;
    item.accountId = item.account.id;
    item.refundOrderId = item.refundOrder != null ? item.refundOrder.id : null;

    Map<String, dynamic> body = item.toJson();

    var response = await httpPut(
      path: "/odata/FastPurchaseOrder(${item.id})",
      body: jsonEncode(body),
    );
    debugPrint(JsonEncoder.withIndent('   ').convert(body));

    /// 204 = No content
    if (response.statusCode == 204) {
      return item;
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  Future<int> createRefundOrder(int id) async {
    Map<String, dynamic> body = {"id": id};
    var response = await httpPost(
        path: "/odata/FastPurchaseOrder/ODataService.ActionRefund",
        body: jsonEncode(body));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["value"];
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  Future<List<Product>> actionSearchProduct(String text) async {
    Map<String, dynamic> body = {
      "take": 20,
      "skip": 0,
      "page": 1,
      "pageSize": 20,
      "sort": [
        {"field": "Name", "dir": "asc"}
      ],
      "filter": {
        "logic": "and",
        "filters": [
          {
            "logic": "or",
            "filters": [
              {"field": "Name", "operator": "contains", "value": "$text"},
              {"field": "NameNoSign", "operator": "contains", "value": "$text"},
              {
                "field": "CompanyName",
                "operator": "contains",
                "value": "$text"
              },
              {
                "field": "CompanyNameNoSign",
                "operator": "contains",
                "value": "$text"
              },
            ]
          }
        ]
      }
    };
    debugPrint(JsonEncoder.withIndent('   ').convert(body));

    var response =
        await httpPost(path: "/ProductTemplate/List", body: jsonEncode(body));

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)['Data'] as List)
          .map((f) => Product.fromJson(f))
          .toList();
    } else {
      throw new Exception((jsonDecode(response.body)["message"]) ??
          "${response.statusCode}, ${response.reasonPhrase} ${response.body}");
    }
  }

  @override
  Future<GetInventoryProductResult> getProductInventoryById(
      {int tmplId}) async {
    var response = await httpGet(
      path: "/odata/ProductTemplate/ODataService.GetInventoryProduct",
      param: {
        "productTmplId": tmplId,
        "\$format": tmplId,
        "\$filter": "ProductTmplId eq $tmplId",
        "\$orderby": "Name"
      },
    );
  }

  @override
  Future<dynamic> getDashBoardChart(
      {@required String chartType,
      String columnChartValue = "W",
      String columnCharText = "TUẦN NÀY",
      String barChartValue = "W",
      String barChartText = "TUẦN NÀY",
      int barChartOrderValue = 1,
      String barChartOrderText = "THEO DOANH SỐ",
      String lineChartValue = "WNWP",
      String lineChartText = "TUẦN NÀY",
      String overViewValue = "T",
      String overViewText = "HÔM NAY"}) async {
    var response = await httpGet(
      path: "/Home/$chartType",
      param: {
        "ColumChartValue": columnChartValue,
        "ColumChartText": columnCharText,
        "BarChartValue": barChartValue,
        "BarChartText": barChartText,
        "BarChartOrderValue": barChartOrderValue,
        "BarChartOrderText": barChartOrderText,
        "LineChartValue": lineChartValue,
        "LineChartText": lineChartText,
        "OverViewValue": overViewValue,
        "OverViewText": overViewText,
      },
    );

    if (response.statusCode == 200) {
      if (chartType == "GetDataLine")
        return (jsonDecode(response.body)["Data$lineChartValue"] as List)
            .map((f) => DataLineChart.fromJson(f))
            .toList();
      else if (chartType == "GetSales") {
        return (jsonDecode(response.body)["DataDate"] as List)
            .map((f) => DataColumnChart.fromJson(
                f, jsonDecode(response.body)["ListHeader"]))
            .toList();
      } else if (chartType == "GetSales2") {
        return (jsonDecode(response.body) as List)
            .map((f) => DataPieChart.fromJson(f))
            .toList();
      }
    } else {
      throwHttpException(response);
      throw Exception(jsonDecode(response.body)["message"] != null
          ? jsonDecode(response.body)["message"]
          : "Lỗi request !");
    }
  }

  Future<void> deleteProductTemplate(int id) async {
    assert(id != null);
    var response = await httpDelete(path: "/odata/ProductTemplate($id)");
    if (!response.statusCode.toString().startsWith("2")) {
      throwTposApiException(response);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> getPriceListItems(int priceListId) async {
    var response = await httpGet(
        path: "/api/common/getpricelistitems", param: {"id": priceListId});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throwHttpException(response);
    return null;
  }

  Future<PartnerRevenue> getPartnerRevenue(int id) async {
    var response = await httpGet(path: "/partner/GetPartnerRevenueById?id=$id");
    if (response.statusCode == 200) {
      return PartnerRevenue.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)["message"]);
    }
  }

  Future<List<FastSaleOrder>> getInvoicePartner(
      int id, int top, int skip) async {
    var response = await httpGet(
        path:
            "/odata/AccountInvoice/ODataService.GetInvoicePartner?partnerId=$id&\$format=json&\$top=$top&\$skip=$skip&\$orderby=DateInvoice+desc&\$filter=PartnerId+eq+$id&\$count=true");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => FastSaleOrder.fromJson(f))
          .toList();
    } else {
      throw Exception(jsonDecode(response.body)["message"]);
    }
  }

  @override
  Future<List<FastSaleOrder>> getDeliveryInvoicePartner(
      int take, int skip, sort, filter, int page, int pageSize) async {
    var body;
    Map temp = {
      "take": take,
      "skip": skip,
      "sort": sort,
      "page": page,
      "pageSize": pageSize,
      "filter": filter,
    };
    body = jsonEncode(temp);
    var json = await tposPost(
      path: "/FastSaleOrder/DeliveryInvoiceList",
      body: body,
    );
    var jsonMap = jsonDecode((json));
    return (jsonMap["Data"] as List)
        .map((f) => FastSaleOrder.fromJson(f))
        .toList();
  }

  Future<List<CreditDebitCustomerDetail>> getCreditDebitCustomerDetail(
      int id, int top, int skip) async {
    var response = await httpGet(
        path:
            "/Partner/CreditDebitCustomerDetail?partnerId=$id&take=$top&skip=$skip&\$orderby=Date+desc");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["Data"] as List)
          .map((f) => CreditDebitCustomerDetail.fromJson(f))
          .toList();
    } else {
      throw Exception(jsonDecode(response.body)["message"]);
    }
  }

  Future<FacebookWinner> updateFacebookWinner(
      FacebookWinner facebookWinner) async {
    var model = {};
    model["model"] = facebookWinner.toMap();
    var body = json.encode(model);

    var response = await httpPost(
      path: "/odata/SaleOnline_Facebook_Post/ODataService.UpdateWinner",
      body: body,
    );
    return facebookWinner;
  }

  Future<List<FacebookWinner>> getFacebookWinner() async {
    var results;
    var response = await httpGet(
      path: "/odata/SaleOnline_Facebook_Post/ODataService.GetWinners",
    );
    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      var facebookWinner = jsonMap["value"] as List;

      results = facebookWinner.map((map) {
        return FacebookWinner.fromMap(map);
      }).toList();
    } else {
      throw new Exception("Loi request");
    }
    return results;
  }

  @override
  Future<List<String>> getCommentIdsByPostId(String postId) async {
    assert(postId != null);
    var response = await httpGet(
        path: "/odata/SaleOnline_Facebook_Post/ODataService.GetCommentIds",
        param: {"PostId": postId});

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => f.toString())
          .toList();
    }
    throwHttpException(response);
    return null;
  }

  Future<UserActivities> getUserActivities(
      {int skip = 0, int limit = 50}) async {
    var response =
        await httpGet(path: "/api/activity/all?skip=$skip&limit=$limit");
    if (response.statusCode == 200) {
      return UserActivities.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)["message"] != null
          ? jsonDecode(response.body)["message"]
          : "Lỗi rồi!");
    }
  }

  @override
  Future<LiveCampaign> getLiveCampaignByPostId(String postId) async {
    var response = await httpGet(
        path: "/odata/SaleOnline_LiveCampaign/ODataService.GetCampaigns",
        param: {
          "\$expand": "Details",
          "liveId": postId,
        });

    if (response.statusCode == 200) {
      var campaigns = (jsonDecode(response.body)["value"] as List)
          .map((f) => LiveCampaign.fromJson(f))
          .toList();
      if (campaigns != null && campaigns.length > 0)
        return campaigns.first;
      else
        return null;
    }
    throwHttpException(response);
    return null;
  }

  Future<bool> doChangeUserPassWord(
      {String oldPassword, String newPassword, String confirmPassWord}) async {
    Map<String, dynamic> body = {
      "OldPassword": "$oldPassword",
      "NewPassword": "$newPassword",
      "ConfirmPassword": "$confirmPassWord"
    };
    debugPrint(
      JsonEncoder.withIndent('  ').convert(body),
    );
    var response = await httpPost(
      path: "/manage/changepassword",
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      throw Exception("Không thể kết nối máy chủ");
    }
  }

  @override
  Future<void> deleteSaleOnlineOrder(String orderId) async {
    var response = await httpDelete(path: "/odata/SaleOnline_Order($orderId)");

    if (response.statusCode != 204) {
      throwTposApiException(response);
    }
  }

  @override
  Future<CreateQuickFastSaleOrderModel> getQuickCreateFastSaleOrderDefault(
      List<String> saleOnlineIds) async {
    Map<String, dynamic> bodyMap = {"ids": saleOnlineIds.toList()};
    var response = await httpPost(
      path: "/odata/SaleOnline_Order/GetDefaultOrderIds",
      params: {
        "\$expand": "Lines(\$expand=Partner),Carrier",
      },
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200) {
      return CreateQuickFastSaleOrderModel.fromJson(jsonDecode(response.body));
    }

    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> deleteFastSaleOrder(int orderId) async {
    var response = await httpDelete(path: "/odata/FastSaleOrder($orderId)");

    if (response.statusCode != 204) {
      throwTposApiException(response);
    }
  }

  @override
  Future<CreateQuickFastSaleOrderResult> createQuickFastSaleOrder(
      CreateQuickFastSaleOrderModel model) async {
    Map<String, dynamic> bodyMap = {"model": model.toJson(true)};
    var body = jsonEncode(bodyMap);
    var response = await httpPost(
        path: "/odata/FastSaleOrder/InsertOrderProductDefault", body: body);

    if (response.statusCode == 200) {
      return CreateQuickFastSaleOrderResult.fromJson(jsonDecode(response.body));
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<WebUserConfig> getWebUserConfig() async {
    var response = await httpGet(path: "/api/common/userconfigs");
    if (response.statusCode == 200)
      return WebUserConfig.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> deletePartnerCategory(int categoryId) async {
    assert(categoryId != null);
    var response =
        await httpDelete(path: "/odata/PartnerCategory($categoryId)");
    if (response.statusCode == 204) return null;
    throwTposApiException(response);
    return null;
  }

  @override
  Future<RegisterTposResult> registerTpos(
      {String name,
      String message,
      String email,
      String company,
      String phone,
      String cityCode,
      String prefix,
      String facebookPhoneValidateToken,
      String facebookUserToken}) async {
    Map<String, dynamic> bodyMap = {
      "Name": name,
      "Message": message,
      "Email": email,
      "Company": company,
      "Telephone": phone,
      "CityCode": cityCode,
      "Prefix": prefix,
      "ProductCode": "TPOS",
      "PackageCode": "BASIC",
      "recaptcha": null,
      "FacebookUserToken": facebookUserToken,
    };
//    }..removeWhere((key, value) => value == null);
    _log.debug(bodyMap);
    var response = await _client.post(
      "https://tpos.vn/api/Order/Create",
      headers: {"content-type": "application/json"},
      body: jsonEncode(bodyMap),
    );

    print(response.body);
    if (response.statusCode == 200) {
      return RegisterTposResult.fromJson(jsonDecode(response.body));
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<List<TPosCity>> getTposCity() async {
    var response = await _client.get("https://tpos.vn/api/City");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((f) => TPosCity.fromJson(f))
          .toList();
    }

    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> deleteDeliveryCarrier(int carrierId) async {
    assert(carrierId != null);
    var response = await httpDelete(path: "/odata/DeliveryCarrier($carrierId)");
    if (response.statusCode == 204) return null;
    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> refreshFastSaleOnlineOrderDeliveryState() async {
    var response = await httpGet(
      path: "/odata/FastSaleOrder/ODataService.UpdateShipOrdersInfo",
    );

    if (response.statusCode != 200) throwTposApiException(response);
    return null;
  }

  @override
  Future<void> refreshFastSaleOrderDeliveryState(List<int> ids) async {
    var response = await httpPost(
      path: "/odata/FastSaleOrder/ODataService.UpdateShipOrderInfo",
      body: jsonEncode({
        "ids": ids.toList(),
      }),
    );

    if (response.statusCode != 204) throwTposApiException(response);
    return null;
  }

  @override
  Future<StockReport> getStockReport({
    DateTime fromDate,
    DateTime toDate,
    bool isIncludeCanceled = false,
    bool isIncludeReturned = false,
    int wareHouseId,
    int productCategoryId,
  }) async {
    var response = await httpPost(
        path: "/StockReport/XuatNhapTon",
        body: jsonEncode({
          "FromDate": fromDate?.toIso8601String(),
          "ToDate": toDate?.toIso8601String(),
          "IncludeCancelled": false,
          "IncludeReturned": false,
          "take": null,
          "skip": null,
          "page": null,
          "pageSize": null,
          "WarehouseId": wareHouseId,
          "ProductCategoryId": productCategoryId,
          "aggregate": [
            {"field": "Begin", "aggregate": "sum"},
            {"field": "Import", "aggregate": "sum"},
            {"field": "Export", "aggregate": "sum"},
            {"field": "End", "aggregate": "sum"}
          ]
        }..removeWhere((key, value) => value == null)));
    if (response.statusCode == 200) {
      return StockReport.fromJson(
        jsonDecode(response.body),
      );
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<List<StockWareHouse>> getStockWarehouse() async {
    var response = await httpGet(
        path: "/odata/StockWarehouse?%24format=json&%24count=true");

    if (response.statusCode == 200)
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => StockWareHouse.fromJson(f))
          .toList();
    throwTposApiException(response);
    return null;
  }

  @override
  Future<List<ProductCategoryForStockWareHouseReport>>
      getProductCategoryForStockReport() async {
    var response = await httpGet(path: "/StockReport/GetProductCategory");
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((f) => ProductCategoryForStockWareHouseReport.fromJson(f))
          .toList();
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<GetProductTemplateResult> getProductTemplate(
      {int page,
      int pageSize = 1000,
      int skip = 0,
      int take = 1000,
      OdataFilter filter,
      List<OdataSortItem> sorts}) async {
    var response = await httpPost(
      path: "/ProductTemplate/List",
      params: {
        "page": page,
        "pageSize": pageSize,
        "skip": skip,
        "take": take,
        "filter": filter?.toJson(),
        "sort": sorts.map((f) => f.toJson()).toList()
      }..removeWhere((key, value) => value == null),
    );

    if (response.statusCode == 200)
      return GetProductTemplateResult.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<PosOrderResult> getPosOrders(
      {int page,
      int pageSize,
      int skip,
      int take,
      OdataFilter filter,
      List<OdataSortItem> sorts}) async {
    var body = {
      "take": take,
      "skip": skip,
      "page": page,
      "pageSize": pageSize,
      "sort": sorts,
      "filter": filter
    };

    var bodyEncode = jsonEncode(body);
    var response = await httpPost(
      path: "/POS_Order/List",
      body: jsonEncode(body),
    );

    if (response.statusCode == 200)
      return PosOrderResult.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<TPosApiResult<bool>> deletePosOrder(int id) async {
    assert(id != null);
    var response = await httpDelete(path: "/odata/POS_Order($id)");
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      var json = jsonDecode(response.body);
      if (json["error"] != null) {
        var odataError = OdataError.fromJson(json["error"]);
        return new TPosApiResult(
            result: false, error: true, message: odataError.message);
      }
      return new TPosApiResult(
          result: false,
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<PosOrder> getPosOrderInfo(int id) async {
    var response = await httpGet(
      path: "/odata/POS_Order($id)",
      param: {
        "\$expand": "Partner,Table,Session,User,PriceList,Tax",
      },
    );

    if (response.statusCode == 200)
      return PosOrder.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<List<PosOrderLine>> getPosOrderLines(int id) async {
    var response = await httpGet(
        path: "/odata/POS_Order($id)/Lines",
        param: {
          "\$expand": "Product,UOM",
        },
        timeoutInSecond: 1200);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => PosOrderLine.fromJson(f))
          .toList();
    } else
      throwTposApiException(response);
    return null;
  }

  @override
  Future<List<PosAccountBankStatement>> getPosAccountBankStatement(
      int id) async {
    var response = await httpGet(
        path: "/odata/AccountBankStatementLine",
        param: {
          "\$filter": "PosStatementId+eq+$id",
        },
        timeoutInSecond: 1200);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)["value"] as List)
          .map((f) => PosAccountBankStatement.fromJson(f))
          .toList();
    } else
      throwTposApiException(response);
    return null;
  }

  @override
  Future<TPosApiResult<String>> refundPosOrder(int id) async {
    assert(id != null);
    var body = {"id": id};

    var response = await httpPost(
      path: "/odata/POS_Order/ODataService.Refund",
      body: jsonEncode(body),
    );

    var json = jsonDecode(response.body);

    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: json["value"].toString());
    } else {
      if (json != null) {
        var odataError = OdataError.fromJson(json);
        return new TPosApiResult(error: true, message: odataError.message);
      }
      return new TPosApiResult(
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<TPosApiResult<PosMakePayment>> getPosMakePayment(int id) async {
    assert(id != null);
    var body = {"id": id};

    var response = await httpPost(
      path: "/odata/PosMakePayment/ODataService.DefaultGet",
      params: {
        "\$expand": "Journal ",
      },
      body: jsonEncode(body),
    );

    var json = jsonDecode(response.body);
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(
          error: false, result: PosMakePayment.fromJson(json));
    } else {
      if (json != null) {
        var odataError = OdataError.fromJson(json);
        return new TPosApiResult(error: true, message: odataError.message);
      }
      return new TPosApiResult(
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<TPosApiResult<bool>> posMakePayment(
      PosMakePayment payment, int posOrderId) async {
    assert(payment != null);
    var jsonMap = {
      "id": posOrderId,
      "model": payment,
    };

    var body = jsonEncode(jsonMap);

    var response = await httpPost(
      path: "/odata/PosMakePayment/ODataService.Check",
      body: body,
    );

    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      var json = jsonDecode(response.body);
      if (json != null) {
        var odataError = OdataError.fromJson(json);
        return new TPosApiResult(error: true, message: odataError.message);
      }
      return new TPosApiResult(
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<DeliveryCarrier> getDeliverCarrierCreateDefault() async {
    var response =
        await httpGet(path: "/odata/DeliveryCarrier/ODataService.DefaultGet");

    if (response.statusCode == 200) {
      return DeliveryCarrier.fromJson(jsonDecode(response.body));
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<DeliveryCarrier> getDeliveryCarrierById(int id) async {
    var response = await httpGet(path: "/odata/DeliveryCarrier($id)", param: {
      "\$expand": "Product,HCMPTConfig",
    });

    if (response.statusCode == 200) {
      return DeliveryCarrier.fromJson(jsonDecode(response.body));
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> updateDeliveryCarrier(DeliveryCarrier edit) async {
    var response = await httpPut(
      path: "/odata/DeliveryCarrier(${edit.id})",
      body: jsonEncode(edit.toJson(true)),
    );

    if (response.statusCode == 204) {
      return null;
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> createDeliveryCarrier(DeliveryCarrier item) async {
    var response = await httpPost(
      path: "/odata/DeliveryCarrier",
      body: jsonEncode(item.toJson(true)),
    );

    if (response.statusCode == 201) return null;
    throwTposApiException(response);
    return null;
  }

  @override
  Future<GetShipTokenResultModel> getShipToken(
      {String apiKey,
      String email,
      String host,
      String password,
      String provider}) async {
    var response = await httpPost(
      path: "https://aship.skyit.vn/api/ApiShippingConnect/GetToken",
      useBasePath: false,
      timeOut: Duration(minutes: 10),
      body: jsonEncode(
        {
          "data": {
            "email": email,
            "password": password,
            "host": _shopUrl.replaceAll("https://", ""),
            "apiKey": apiKey,
          },
          "provider": provider,
          "config": {"apiKey": ""}
        },
      ),
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return GetShipTokenResultModel.fromJson(json);
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<String> getTokenShip() async {
    var response =
        await httpGet(path: "/odata/Company_Config/ODataService.GetTokenShip");
    if (response.statusCode == 200) return (jsonDecode(response.body)["value"]);
    throwTposApiException(response);
    return null;
  }

  @override
  Future<MailTemplateResult> getMailTemplateResult() async {
    var response = await httpGet(
      path: "/odata/MailTemplate",
      param: {
        "\$format": "json",
        "\$top": 100,
        "\$count": "true",
      },
    );

    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      return MailTemplateResult.fromJson(map);
    } else {
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<MailTemplate> getMailTemplateById(int id) async {
    var response = await httpGet(path: "/odata/MailTemplate($id)");

    if (response.statusCode == 200) {
      return MailTemplate.fromJson(jsonDecode(response.body));
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<TPosApiResult<bool>> deleteMailTemplate(int id) async {
    assert(id != null);
    var response = await httpDelete(path: "/odata/MailTemplate($id)");
    if (response.statusCode.toString().startsWith("2")) {
      return new TPosApiResult(error: false, result: true);
    } else {
      var json = jsonDecode(response.body);
      if (json["error"] != null) {
        var odataError = OdataError.fromJson(json["error"]);
        return new TPosApiResult(
            result: false, error: true, message: odataError.message);
      }
      return new TPosApiResult(
          result: false,
          error: true,
          message: "${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  @override
  Future<List<MailTemplateType>> getMailTemplateType() async {
    var response = await httpGet(
      path: "/api/common/getmailtemplatetypes",
    );

    if (response.statusCode == 200) {
      var mailTemplateMap = jsonDecode(response.body) as List;

      return mailTemplateMap.map((f) {
        return MailTemplateType.fromJson(f);
      }).toList();
    } else {
      throw new Exception("${response.statusCode}, ${response.reasonPhrase}");
    }
  }

  @override
  Future<bool> updateMailTemplate(MailTemplate template) async {
    Map jsonMap = template.toJson(true);
    jsonMap.removeWhere((key, value) {
      return value == null;
    });

    String body = jsonEncode(jsonMap);
    var response = await httpPut(
      path: "/odata/MailTemplate(${template.id})",
      body: body,
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throwHttpException(response);
      return null;
    }
  }

  @override
  Future<List<StatusExtra>> getStatusExtra() async {
    var repsonse = await httpGet(
      path: "/odata/StatusExtra",
    );

    if (repsonse.statusCode == 200)
      return (jsonDecode(repsonse.body)["value"] as List)
          .map((f) => StatusExtra.fromJson(f))
          .toList();

    throwTposApiException(repsonse);
    return null;
  }

  @override
  Future<bool> saveChangeStatus(List<String> ids, String status) async {
    var response = await httpPost(
      path: "/SaleOnline_Order/UpdateStatus",
      body: jsonEncode({"ids": ids, "status": status}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body)["success"];
    throwTposApiException(response);
    return null;
  }
}
