/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 4:31 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 3:12 PM
 *
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/services/data_services/data_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CheckAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_facebook_comment.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

import 'new_facebook_post_comment_viewmodel.dart';

class SaleOnlineEditOrderViewModel extends ViewModel implements ViewModelBase {
  //log
  final _log = new Logger("SaleOnlineEditOrderViewModel");

  IAppService _appService;
  ISettingService _settingService;
  ITposApiService _tposApi;
  PrintService _print;
  DataService _dataService;
  SaleOnlineEditOrderViewModel(
      {ISettingService settingService,
      ITposApiService tposApi,
      DataService dataService,
      PrintService print}) {
    _appService = locator<IAppService>();
    _settingService = settingService ?? locator<ISettingService>();
    _tposApi = tposApi ?? locator<ITposApiService>();
    _print = print ?? locator<PrintService>();
    _dataService = dataService ?? locator<DataService>();

    onStateAdd(false);
  }

  // Param
  CRMTeam _crmTeam;
  //editOrder
  SaleOnlineOrder _editOrder;
  String _editOrderId;
  CommentItemModel _comment;
  String _facebookPostId;
  SaleOnlineOrder get editOrder => _editOrder;
  String get editOrderId => _editOrderId;
  Product _product;
  LiveCampaign _liveCampaign;
  double _productQuantity;

  set editOrder(SaleOnlineOrder value) {
    _editOrder = value;
    _editOrderController.add(value);
  }

  BehaviorSubject<SaleOnlineOrder> _editOrderController = new BehaviorSubject();
  Stream<SaleOnlineOrder> get editOrderStream => _editOrderController.stream;
  Sink<SaleOnlineOrder> get editOrderSink => _editOrderController.sink;

  //Parnter
  Partner _partner;
  Partner get partner => _partner;

  set partner(Partner value) {
    _partner = value;
    _partnerController.add(_partner);
  }

  BehaviorSubject<Partner> _partnerController = new BehaviorSubject();
  Stream<Partner> get parterStream => _partnerController.stream;

  // List<CheckAddress>
  List<CheckAddress> _checkAddressResults;
  List<CheckAddress> get checkAddressResults => _checkAddressResults;
  set checkAddressResults(List<CheckAddress> value) {
    _checkAddressResults = value;
    _checkAddressResultsController.add(value);
  }

  BehaviorSubject<List<CheckAddress>> _checkAddressResultsController =
      new BehaviorSubject();
  Stream<List<CheckAddress>> get checkAddressResultStream =>
      _checkAddressResultsController.stream;

  // SelectedAddress
  CheckAddress _selectedCheckAddress;
  CheckAddress get selectedCheckAddress => _selectedCheckAddress;
  set selectedCheckAddress(CheckAddress value) {
    _selectedCheckAddress = value;
    _selectedCheckAddressController.add(value);
    _checkAddressResultsController.add(_checkAddressResults);
  }

  BehaviorSubject<CheckAddress> _selectedCheckAddressController =
      new BehaviorSubject();
  Stream<CheckAddress> get selectedCheckAddressStream =>
      _selectedCheckAddressController.stream;

  // recentComments Bình luận gần đây

  List<SaleOnlineFacebookComment> _recentComments;
  List<SaleOnlineFacebookComment> get recentComments => _recentComments;
  BehaviorSubject<List<SaleOnlineFacebookComment>> _recentCommentsController =
      new BehaviorSubject();
  Observable<List<SaleOnlineFacebookComment>> get recentCommentsObservable =>
      _recentCommentsController.stream;
  void _recentCommentsAdd(List<SaleOnlineFacebookComment> values) {
    _recentComments = values;
    if (_recentCommentsController.isClosed == false) {
      _recentCommentsController.add(_recentComments);
    }
  }

  Future init(
      {SaleOnlineOrder editOrder,
      String orderId,
      String facebookPostId,
      @required CommentItemModel comment,
      CRMTeam crmTeam,
      Product product,
      LiveCampaign liveCampaign,
      double productQuantity}) async {
    assert(orderId != null || editOrder != null || comment != null);

    _comment = comment;
    _editOrderId = orderId ?? editOrder?.id;
    _editOrder = editOrder;
    _facebookPostId = facebookPostId;
    _crmTeam = crmTeam;
    _product = product;
    _liveCampaign = liveCampaign;
    _productQuantity = productQuantity;

    onIsBusyAdd(false);
  }

  Future<void> initData() async {
    onStateAdd(true);
    if (_editOrderId != null) {
      await loadOrderInfo();
    } else {
      _editOrder = new SaleOnlineOrder();
      if (_comment != null) {
        _editOrder.telephone = RegexLibrary.getPhoneNumber(_comment.comment);
        _editOrder.name = _comment.facebookName;
      }
    }

    await loadRecentCommentsCommand();
    if (_editOrderController.isClosed == false)
      _editOrderController.add(_editOrder);
    onStateAdd(false);
  }

  double get totalAmount {
    if (editOrder != null &&
        editOrder.details != null &&
        editOrder.details.length > 0) {
      double sum = editOrder.details
          .map((f) => f.price * f.quantity)
          .reduce((d1, d2) => d1 + d2);
      return sum;
    } else {
      return 0;
    }
  }

  Future loadOrderInfo() async {
    try {
      editOrder = await _tposApi.getOrderById(_editOrderId);
      partner = await _tposApi.getPartnerById(editOrder.partnerId);
    } catch (ex, stack) {
      _log.severe("loadOrderInfo fail", ex, stack);
      onDialogMessageAdd(
          new OldDialogMessage.error("Lỗi cập nhật", ex.toString()));
    }
  }

  /// Kiểm tra địa chỉ nhanh
  Future checkAddress({String keyword}) async {
    try {
      checkAddressResults = await _tposApi.checkAddress(keyword);
      selectedCheckAddress = checkAddressResults.first;
      // Tự thay địa chỉ đã chọn
      if (selectedCheckAddress != null) {
        fillCheckAddress(selectedCheckAddress);
      }
    } catch (ex, stack) {
      _log.severe("checkAddress fail", ex, stack);
      onDialogMessageAdd(
          new OldDialogMessage.error("Lỗi cập nhật", ex.toString()));
    }
  }

  void fillCheckAddress(CheckAddress checkAddress) {
    editOrder.cityCode = checkAddress.cityCode;
    editOrder.cityName = checkAddress.cityName;
    editOrder.districtCode = checkAddress.districtCode;
    editOrder.districtName = checkAddress.districtName;
    editOrder.wardCode = checkAddress.wardCode;
    editOrder.wardName = checkAddress.wardName;
    editOrder.address = checkAddress.address;
    editOrderSink.add(_editOrder);
  }

  Future<void> selectDropDownAddress(CheckAddress newValue) async {
    selectedCheckAddress = newValue;
  }

  /// Lưu đơn hàng
  Future save() async {
    try {
      if (editOrder.id != null) {
        editOrder.companyId = _appService.selectedCompany.id;

        await _tposApi.updateSaleOnlineOrder(editOrder);
        editOrder.totalAmount = totalAmount;

        onDialogMessageAdd(
            new OldDialogMessage.flashMessage("Đã lưu thành công"));
        _dataService.addDataNotify(
            sender: this, value: editOrder, type: DataMessageType.UPDATE);
      } else {
        await createSaleOnlineOrderCommand();
      }
    } catch (ex, stack) {
      _log.severe("save fail", ex, stack);
      onDialogMessageAdd(
          new OldDialogMessage.error("Lỗi cập nhật", ex.toString()));
    }
  }

  // Tạo đơn hàng
  Future<void> createSaleOnlineOrderCommand() async {
    assert(_crmTeam.id != null);
    assert(_facebookPostId != null);
    assert(_comment != null);
    onStateAdd(true);
    // check facebook id
    CheckFacebookIdResult checkResult;
    try {
      checkResult = await _tposApi.checkFacebookId(
          _editOrder.facebookAsuid, editOrder.facebookPostId, _crmTeam?.id);
    } catch (ex, s) {
      _log.severe("createSaleOnlineOrder", ex, s);
    }

    String partnerStatus = "";
    if (checkResult != null) {
      if (checkResult.customers != null && checkResult.customers.length > 0) {
        editOrder.partnerId = checkResult.customers.first.id;
      }
    }

    SaleOnlineOrder result;
    try {
      // update full data
      editOrder.crmTeamId = _crmTeam.id;
      editOrder.facebookPostId = _facebookPostId;
      editOrder.facebookUserName = _comment.facebookComment.from.name;
      editOrder.facebookAsuid = _comment.facebookComment.from.id;
      editOrder.facebookCommentId = _comment.facebookComment.id;

      editOrder.liveCompaignId = _liveCampaign?.id;
      editOrder.liveCampaignName = _liveCampaign?.name;
      editOrder.name = editOrder.facebookUserName;
      editOrder.note = "";
      if (_settingService.isSaleOnlinePrintComment) {
        editOrder.note = _comment.comment;
      }

      /// Add new phone
      String phoneFromComment = RegexLibrary.getPhoneNumber(_comment.comment);
      if (phoneFromComment != null && phoneFromComment != "") {
        editOrder.telephone = phoneFromComment;
      }

      //Add product
      if (_product != null) {
        editOrder.totalAmount = _product.price.toDouble();
        editOrder.details = new List<SaleOnlineOrderDetail>();
        editOrder.details.add(
          new SaleOnlineOrderDetail(
            productId: _product.id,
            price: _product.price,
            productName: _product.name,
            uomId: _product.uOMId,
            uomName: _product.uOMName,
            quantity: _productQuantity?.toDouble(),
          ),
        );

        editOrder.totalQuantity =
            _productQuantity != null ? _productQuantity.toDouble() : 0;
        editOrder.totalAmount = (_productQuantity ?? 0) * _product.price;
      }

      result = await _tposApi.insertSaleOnlineOrderFromApp(editOrder);

      // notify object changed
      _dataService.addDataNotify(
          sender: this, value: result, type: DataMessageType.INSERT);
    } catch (e, s) {
      _log.severe("", e, s);
      onDialogMessageAdd(
          OldDialogMessage.error("Tạo đơn hàng thất bại", e.toString()));
    }

    if (result != null) {
      if (_settingService.isEnablePrintSaleOnline) {
        // In phiếu

        try {
          await _print.printSaleOnlineTag(
              order: result,
              partnerStatus: _partner?.statusText,
              comment: _comment?.comment,
              productName: _product?.name);
        } catch (e, s) {
          onDialogMessageAdd(OldDialogMessage.error(
              "In phiếu thất bại!", e.toString(),
              title: "In phiếu thất bại", error: e));
          _log.severe("createdSaleOnlineOrder- print", e, s);
        }
      }
    }

    onStateAdd(false);
  }

  Future<void> loadRecentCommentsCommand() async {
    String facebookAsuid =
        _comment?.facebookComment?.from?.id ?? editOrder.facebookAsuid;

    String facebookPostId = _editOrder.facebookPostId ?? _facebookPostId;
    try {
      _recentComments = await _tposApi.getCommentsByUserAndPost(
          userId: facebookAsuid, postId: facebookPostId);
      _recentCommentsAdd(_recentComments);
    } catch (e, s) {
      _log.severe("loadRecentCommentsCommand", e, s);
      onDialogMessageAdd(new OldDialogMessage.flashMessage(
          "Không tải được bình luận gần đây"));
    }
  }

  /// In phiếu sale online
  Future printSaleOnlineTag() async {
    onIsBusyAdd(true);
    try {
      await _print.printSaleOnlineTag(
          order: this._editOrder, partnerStatus: _partner?.statusText);
      onDialogMessageAdd(new OldDialogMessage.flashMessage("Đã in"));
    } catch (ex, stack) {
      _log.severe("printSaleOnlineTag fail", ex, stack);
      onDialogMessageAdd(
          new OldDialogMessage.error("Lỗi cập nhật", ex.toString()));
    }
    onIsBusyAdd(false);
  }

  Future updateParterStatus(String status, String statusText) async {
    partner.status = status;
    partner.statusText = statusText;

    try {
      _tposApi.updatePartnerStatus(
          partner.id, "${partner.status}_${partner.statusText}");
    } catch (ex, stack) {
      _log.severe("updateParterStatus fail", ex, stack);
      onDialogMessageAdd(
          new OldDialogMessage.error("Đã xảy ra lỗi", ex.toString()));
    }

    partner = partner;
  }

  String validateFormEmail(String value) {
    return validateEmail(value);
  }

  @override
  void dispose() {
    _editOrderController.close();
    _selectedCheckAddressController.close();
    _checkAddressResultsController.close();
    _recentCommentsController.close();
    super.dispose();
  }
}
