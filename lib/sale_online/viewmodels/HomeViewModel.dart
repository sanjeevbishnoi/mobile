/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */
import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/services/remote_config_service.dart';
import 'package:tpos_mobile/sale_online/services/report_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class HomeViewModel extends Model implements ViewModelBase {
  //log
  final _log = new Logger("HomeViewModel");

  IAppService _appService;
  ISettingService _setting;
  RemoteConfigService _remoteConfig;
  ITposApiService _tposApi;
  HomeViewModel(
      {ISettingService settingService,
      ITposApiService tposAPi,
      IAppService appService,
      ISettingService setting,
      RemoteConfigService remoteConfig,
      IReportService reportService}) {
    _appService = appService ?? locator<IAppService>();
    _setting = setting ?? locator<ISettingService>();
    _remoteConfig = remoteConfig ?? locator<RemoteConfigService>();

    _tposApi = tposAPi ?? locator<ITposApiService>();
    _log.info("---CREATED HomeViewModel");

    isShowAllMenu = _setting.isShowAllMenuInHomePage;
  }

  String lastAppVersion;
  bool _isInit = false;

  bool lastGroupMenuValue = false;
  bool get isShowAllMenu => _setting.isShowAllMenuInHomePage;
  set isShowAllMenu(bool value) {
    _setting.isShowAllMenuInHomePage = value;
    if (value) {
      lastGroupMenuValue = _setting.isShowGroupHeaderOnHome;
      _setting.isShowGroupHeaderOnHome = true;
    } else {
      _setting.isShowGroupHeaderOnHome = lastGroupMenuValue;
    }
  }

  /// init first when app has started
  Future<void> initCommand() async {
    // Refresh login info
    try {
      var tokenIsValid = await _tposApi.checkTokenIsValid();
      _log.fine("Check token is valid: $tokenIsValid");
      // refresh token

      if (tokenIsValid == false) {
        _appService.logout();
      }

      if (!_isInit) {
        if (tokenIsValid) {
          await _appService.refreshToken();
          await _appService.refreshLoginInfo();
        }

        _remoteConfig.fetchLastestConfig();

        _isInit = true;
      }
    } catch (e, s) {
      _log.severe("home init failed!", e, s);
    }

    notifyListeners();
  }

  /// Thông báo cập nhật khi phiên bản phần mềm hiện tại khác phiên bản được thông báo
  Future<UpdateNotify> checkForUpdateNewCommand() async {
    _log.fine(
        "App Version${_appService.version}; Build: ${_appService.buildNumber}");

    UpdateNotify updateNotify;
    try {
      if (Platform.isAndroid) {
        // Andoird
        updateNotify = _remoteConfig.currentAndroidVersion;
      } else if (Platform.isIOS) {
        updateNotify = _remoteConfig.currentIosVersion;
      }

      _log.fine(
          "App Version${updateNotify?.version}; Build: ${updateNotify?.buildNumber}");

      if (updateNotify != null &&
          updateNotify.version != null &&
          updateNotify.notifyEnable == true &&
          _appService.version != null &&
          compareVersion(updateNotify.version, _appService.version)) {
        return updateNotify;
      }
    } catch (e, s) {
      _log.severe("CheckForUpdate", e, s);
    }

    return null;
  }

  @override
  void dispose() {}
}
