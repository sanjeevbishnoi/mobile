/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:53 AM
 *
 */

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/new_facebook_post_comment_viewmodel.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/services/data_services/data_service.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CheckAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CityAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DistrictAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_status.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_facebook_comment.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ward_address.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/partner_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

class SaleOnlinePartnerAddEditViewModel extends ViewModel
    implements ViewModelBase {
  //log

  ITposApiService _tposApi;
  IPartnerApi _partnerApi;
  DialogService _dialog;
  DataService _dataService;

  // Param
  Partner _partner;
  CommentItemModel _comment;
  String _facebookPostId;
  CRMTeam _crmTeam;

  Function(Partner, CommentItemModel) _onSaved;

  // Viewmodel

  CityAddress _city;
  DistrictAddress _district;
  WardAddress _ward;

  // Public variable

  //Partner get partner => _partner;
  int get id => _partner?.id;
  String get name => _partner?.name;
  String get phone => _partner?.phone;
  String get email => _partner?.email;
  String get note => _partner?.comment;
  String get street => _partner?.street;
  String get statusStyle => _partner?.statusStyle;
  String get statusText => _partner?.statusText;
  String get status => _partner?.status;

  CityAddress get city => _city;
  DistrictAddress get district => _district;
  WardAddress get ward => _ward;

  int get commentCount => _comments?.length ?? 0;
  List<SaleOnlineFacebookComment> get comments => _comments;

  bool get isEdit =>
      _partner != null && _partner.id != null && _partner.id != 0;

  // set

  set name(String value) {
    _partner.name = value;
  }

  set phone(String value) {
    _partner.phone = value;
  }

  set email(String value) {
    _partner.email = value;
  }

  set note(String value) {
    _partner.comment = value;
  }

  set street(String value) {
    _partner.street = value;
  }

  SaleOnlinePartnerAddEditViewModel(
      {ITposApiService tposApi,
      IAppService appService,
      IPartnerApi partnerApi,
      LogService log,
      DialogService dialog,
      DataService dataService})
      : super(logService: log) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _dialog = dialog ?? locator<DialogService>();
    _dataService = dataService ?? locator<DataService>();
    _partnerApi = partnerApi ?? locator<IPartnerApi>();
  }

  /// init param
  Future init(
      {Partner partner,
      @required CommentItemModel comment,
      String facebookPostId,
      @required CRMTeam crmTeam,
      @required Function(Partner, CommentItemModel) onSaved,
      Function()}) async {
    assert(comment != null);
    this._partner = partner;
    this._comment = comment;
    this._facebookPostId = facebookPostId;
    this._crmTeam = crmTeam;
    this._onSaved = onSaved;
  }

  /* VARIABLE*/
  List<CheckAddress> _checkAddressResults;
  CheckAddress _selectedCheckAddress;
  List<SaleOnlineFacebookComment> _comments;

  /*METHOD*/

  void setCity(CityAddress city) {
    _city = city;
    _district = null;
    _ward = null;
    notifyListeners();
  }

  void setDistrict(DistrictAddress district) {
    _district = district;
    _ward = null;
    notifyListeners();
  }

  void setWard(WardAddress ward) {
    _ward = ward;
    notifyListeners();
  }

  void setPartnerStatus(PartnerStatus status) {
    try {
      _tposApi.updatePartnerStatus(
          _partner.id, "${status.value}_${status.text}");
      _partner.statusText = status.text;
      _partner.statusStyle = null;

      notifyListeners();
    } catch (e, s) {
      logger.error("Cập nhật trạng thái", e, s);
      _dialog.showError(content: e.toString());
    }
  }

  void setCheckAddress(CheckAddress value) {
    _city = new CityAddress(code: value.cityCode, name: value.cityName);
    _district =
        new DistrictAddress(code: value.districtCode, name: value.districtName);
    _ward = new WardAddress(code: value.wardCode, name: value.wardName);

    _partner.city = _city;
    _partner.district = _district;
    _partner.ward = _ward;
    _partner.street = value.address;

    notifyListeners();
  }

  Future<void> initData() async {
    onStateAdd(true);
    try {
      var checkParterResult = await _tposApi.checkPartner(
          asuid: _comment.facebookComment.from.id, crmTeamId: _crmTeam?.id);
      if (checkParterResult != null && checkParterResult.length > 0) {
        _partner = checkParterResult.first;
        _city = _partner.city;
        _district = _partner.district;
        _ward = _partner.ward;
      } else {
        _partner = new Partner();
      }

      // Cập nhật bình luận gần đây
      if (_facebookPostId != null) {
        _comments = await _tposApi.getCommentsByUserAndPost(
            userId: _comment.facebookComment?.from?.id,
            postId: _facebookPostId);
      }

      if (_partner.id == null) {
        _partner.phone = RegexLibrary.getPhoneNumber(_comment.comment);
        _partner.name = _comment.facebookName;
      }

      notifyListeners();
    } catch (e, s) {
      logger.error("init data", e, s);
      _dialog.showError(title: "Đã xảy ra lỗi", content: e.toString());
    }

    onStateAdd(false);
  }

  Future<bool> save() async {
    // update info
    _partner.facebookASids = _comment.facebookComment.from.id;
    try {
      if (isEdit) {
        //save
        var updatedPartner =
            await _partnerApi.createOrUpdate(_partner, _crmTeam?.id);
        this._partner.status = updatedPartner.status;
        this._partner.statusText = updatedPartner.statusText;
        this._partner.statusStyle = updatedPartner.statusStyle;

        _dataService.addDataNotify(
            type: DataMessageType.UPDATE,
            value: [updatedPartner, _comment],
            sender: this);
        _onSaved(updatedPartner, _comment);
        _dialog.showNotify(title: "Lưu dữ liệu", message: "Đã lưu khách hàng");
      } else {
        //insert
        var insertedPartner =
            await _partnerApi.createOrUpdate(_partner, _crmTeam?.id);
        this._partner.status = insertedPartner.status;
        this._partner.statusText = insertedPartner.statusText;
        this._partner.statusStyle = insertedPartner.statusStyle;
        this._partner.ref = insertedPartner.ref;
        this._partner.id = insertedPartner.id;
        _dataService.addDataNotify(
            type: DataMessageType.INSERT,
            value: [insertedPartner, _comment],
            sender: this);
        _onSaved(insertedPartner, _comment);
        _dialog.showNotify(
            title: "Đã thêm khách hàng",
            message: "Thêm khách hàng ${insertedPartner.ref} thành công");
      }

      notifyListeners();
      return true;
    } catch (e, s) {
      logger.error("save", e, s);
      _dialog.showError(content: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
