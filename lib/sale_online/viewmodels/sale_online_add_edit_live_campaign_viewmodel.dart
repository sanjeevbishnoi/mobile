/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:53 AM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';

import '../../app_service_locator.dart';

class SaleOnlineAddEditLiveCampaignViewModel extends ViewModel {
  //log
  final log = new Logger("SaleOnlineAddEditLiveCampaignViewModel");

  ITposApiService _tposApi;

  SaleOnlineAddEditLiveCampaignViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  LiveCampaign liveCampaign;
  String campaignName;
  String note;

  BehaviorSubject<LiveCampaign> _liveCampaignController = new BehaviorSubject();
  Stream<LiveCampaign> get liveCampaignStream => _liveCampaignController.stream;

  bool get isEditMode => liveCampaign != null && liveCampaign.id != null;
  Future<void> initViewModel({LiveCampaign editLiveCampaign}) async {
    onStateAdd(true, message: "Đang tải");
    liveCampaign = editLiveCampaign ?? new LiveCampaign();
    if (liveCampaign.id != null) {
      await refreshLiveCampaign();
    }
    _liveCampaignController.add(liveCampaign);
    onStateAdd(false);
  }

  // Lấy thông tin chi tiết chiến dịch live
  Future<void> refreshLiveCampaign() async {
    liveCampaign = await this._tposApi.getDetailLiveCampaigns(liveCampaign.id);
  }

  // Thêm chiến dịch live
  Future<bool> addLiveCampaign(LiveCampaign newLiveCampaign) async {
    try {
      var result =
          await _tposApi.addLiveCampaign(newLiveCampaign: newLiveCampaign);
      if (result) {
        onDialogMessageAdd(
            OldDialogMessage.flashMessage("Thêm chiến dịch live thành công"));
      } else {
        onDialogMessageAdd(
            OldDialogMessage.error("Lỗi", "Lỗi thêm chiến dịch live"));
      }
      return true;
    } catch (e, s) {
      log.severe("addLiveCampaign", e, s);
      return false;
    }
  }

  // Sửa thông tin chiến dịch live
  Future<void> editLiveCampaign(LiveCampaign editLiveCampaign) async {
    var result = await _tposApi.editLiveCampaign(editLiveCampaign);
    if (result) {
      onDialogMessageAdd(
          OldDialogMessage.flashMessage("Sửa chiến dịch live thành công"));
    } else {
      onDialogMessageAdd(
          OldDialogMessage.error("Lỗi", "Lỗi sửa chiến dịch live"));
    }
  }

  Future<void> changeStatus(bool isActive) async {
    if (liveCampaign.id != null) {
      try {
        await _tposApi.changeLiveCampaignStatus(liveCampaign.id);
      } catch (e, s) {
        log.severe("change status", e, s);
      }
    }
  }

  Future<bool> save() async {
    try {
      if (liveCampaign.id != null && liveCampaign.id != "") {
        await editLiveCampaign(liveCampaign);
      } else {
        await addLiveCampaign(liveCampaign);
      }
      return true;
    } catch (ex, stack) {
      log.severe("save fail", ex, stack);
      onDialogMessageAdd(
          OldDialogMessage.error("Lưu dữ liệu thất bại", ex.toString()));
    }
    return false;
  }

  @override
  void dispose() {
    dialogMessageController?.close();
    _liveCampaignController?.close();
    super.dispose();
  }
}
