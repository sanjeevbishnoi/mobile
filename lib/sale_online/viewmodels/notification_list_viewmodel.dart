/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 4:22 PM
 *
 */

import 'package:http/http.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/notification.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/notification_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class NotificationListViewModel extends ViewModel {
  INotificationApi _noticationApi;
  NotificationListViewModel({INotificationApi noticationApi}) {
    _noticationApi = noticationApi ?? locator<INotificationApi>();
  }

  bool _isInit = false;
  int get notReadCount => _notReadNotification?.length ?? 0;

  Future<void> initCommand() async {
    onStateAdd(true);
    if (_isInit == false) {
      await _getNotificationList();
    }

    onStateAdd((false));
    _isInit = true;
  }

  Future<void> refreshCommand() async {
    await _getNotificationList();
    await _getNotReadNotification();
  }

  Future<void> fetchNotReadNotification() async {
    try {
      await _getNotReadNotification();
      locator<IAppService>().notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
    }
  }

  List<Notification> _notifications;
  List<Notification> _notReadNotification;
  List<Notification> get notifications => _notifications;
  Future<void> _getNotificationList() async {
    var getResult = await _noticationApi.getAll();
    if (getResult != null) {
      _notifications = getResult.items;
      notifyListeners();
    }
  }

  Future<void> _getNotReadNotification() async {
    var getResult = await _noticationApi.getNotRead();
    _notReadNotification = getResult.items;
  }
}
