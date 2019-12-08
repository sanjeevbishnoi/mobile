import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/notification.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_service_base.dart';

abstract class INotificationApi {
  Future<bool> markRead(String key);
  Future<GetNotificationResult> getAll();
  Future<GetNotificationResult> getNotRead();
}

class NotificationApi extends ApiServiceBase implements INotificationApi {
  @override
  Future<bool> markRead(String key) async {
    assert(key != null);
    var response =
        await apiClient.httpPost(path: "/api/notification/markread/$key");
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["success"];
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<GetNotificationResult> getNotRead() async {
    var response = await apiClient.httpGet(
      path: "/api/notification/notread",
    );
    if (response.statusCode == 200)
      return GetNotificationResult.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<GetNotificationResult> getAll() async {
    var response = await apiClient.httpGet(
      path: "/api/notification/all",
    );
    if (response.statusCode == 200)
      return GetNotificationResult.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }
}
