import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

class PartnerSearchViewModel extends ViewModel implements ViewModelBase {
  //log
  final log = new Logger("PartnerSearchViewModel");
  DialogService _dialog;
  ITposApiService _tposApi;
  bool isCustomer;
  bool isSupplier;
  bool isSearchMode;
  PartnerSearchViewModel(
      {ISettingService settingService,
      ITposApiService tposApi,
      DialogService dialog}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _dialog = dialog ?? locator<DialogService>();

    // Listen keyword changing
    _keywordController
        .debounceTime(new Duration(milliseconds: 500))
        .listen((newKeyword) {
      loadPartners();
    });
  }

//  List<Partner> _partners;
//  List<Partner> get partners => _partners;
//  set partners(List<Partner> value) {
//    _partners = value;
//    _partnersController.add(_partners);
//  }

  BehaviorSubject<List<Partner>> _partnersController = new BehaviorSubject();
  Stream<List<Partner>> get partnersStream => _partnersController.stream;

  // Keyword controll
  String _keyword;
  String get keyword => _keyword;
  BehaviorSubject<String> _keywordController = new BehaviorSubject();
  void _onKeywordAdd(String value) {
    _keyword = value;
    if (_keywordController.isClosed == false) {
      _keywordController.add(value);
    }
  }

  Future<void> keywordChangedCommand(String keyword) async {
    _onKeywordAdd(keyword);
  }

  void init(
      {bool isCustomer = true, bool isSupplier, bool isSearchMode = false}) {
    this.isCustomer = isCustomer;
    this.isSupplier = isSupplier;
    this.isSearchMode = isSearchMode;
  }

  Future<void> loadPartners() async {
    try {
      onIsBusyAdd(true);
      _keyword = removeVietnameseMark(keyword);
      var partners = await _tposApi.getPartnersForSearch(_keyword, 200,
          isCustomer: isCustomer,
          isSupplier: isSupplier,
          onlyActive: isSearchMode);
      onIsBusyAdd(false);
      if (_partnersController.isClosed == false)
        _partnersController.add(partners);
    } catch (ex, stack) {
      log.severe("loadPartners fail", ex, stack);
      _partnersController.addError(ex);
    }
  }

  Future<bool> deletePartner(int id) async {
    onIsBusyAdd(true);
    try {
      await _tposApi.deletePartner(id);
      _dialog.showNotify(message: "Đã xóa khách hàng $id");
      return true;
    } catch (ex, stack) {
      log.severe("deletePartners fail", ex, stack);
      onDialogMessageAdd(new OldDialogMessage.error("", ex.toString(),
          title: "Lỗi không xác định!"));
    }
    onIsBusyAdd(false);
    return false;
  }

  Future<void> initCommand() async {
    onIsBusyAdd(true);
    _keyword = "";
    try {
      await loadPartners();
    } catch (e) {}
    onIsBusyAdd(false);
  }

  @override
  void dispose() {
    _partnersController.close();
    _keywordController.close();
  }
}
