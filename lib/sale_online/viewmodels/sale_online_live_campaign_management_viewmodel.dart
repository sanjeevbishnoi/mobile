/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:53 AM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';

import '../../app_service_locator.dart';

class SaleOnlineLiveCampaignManagementViewModel extends ListViewModel
    implements ViewModelBase {
  //log
  final log = new Logger("SaleOnlineLiveCampaignManagementViewModel");

  ITposApiService _tposApi;
  SaleOnlineLiveCampaignManagementViewModel(
      {ITposApiService tposApi, IAppService appService})
      : super(appService) {
    _tposApi = tposApi ?? locator<ITposApiService>();

    _setPermission();
  }

  void _setPermission() {
    this.permissionAdd = locator<IAppService>()
        .getWebPermission(PERMISSION_SALE_ONLINE_LIVE_CAMPAIGN_INSERT);
    this.permissionEdit = locator<IAppService>()
        .getWebPermission(PERMISSION_SALE_ONLINE_LIVE_CAMPAIGN_INSERT);
  }

  bool _isOnlyShowAvaiableCampaign = true;

  bool get isOnlyShowAvaiableCampaign => _isOnlyShowAvaiableCampaign;

  set isOnlyShowAvaiableCampaign(bool value) {
    _isOnlyShowAvaiableCampaign = value;
    _isOnlyShowAvaiableCampaignController.sink.add(value);
  }

  BehaviorSubject<bool> _isOnlyShowAvaiableCampaignController =
      new BehaviorSubject();
  Stream<bool> get isOnlyShowAvaiableCampaignStream =>
      _isOnlyShowAvaiableCampaignController.stream;
  BehaviorSubject<List<LiveCampaign>> _liveCampaignsController =
      new BehaviorSubject();

  void _onLiveCampaignsAdd(List<LiveCampaign> value) {
    if (_liveCampaignsController.isClosed == false) {
      _liveCampaignsController.add(value);
    }
  }

  Stream<List<LiveCampaign>> get liveCampaignsStream =>
      _liveCampaignsController.stream;

  Future refreshLiveCampaign() async {
    try {
      if (_isOnlyShowAvaiableCampaign) {
        var liveCampaigns = await this._tposApi.getAvaibleLiveCampaigns();
        _onLiveCampaignsAdd(liveCampaigns);
      } else {
        var liveCampaigns = await this._tposApi.getLiveCampaigns();
        _onLiveCampaignsAdd(liveCampaigns);
      }
    } catch (e, s) {
      _liveCampaignsController.addError(e, s);
      log.severe("refresh", e, s);
    }

    return null;
  }

  @override
  void dispose() {
    _liveCampaignsController.close();
    _isOnlyShowAvaiableCampaignController.close();
    super.dispose();
  }
}
