import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CheckAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CityAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DistrictAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ship_receiver.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ward_address.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

import '../../fast_sale_order/viewmodels/fast_sale_order_add_edit_full_viewmodel.dart';

class ShipReceiverModel extends ViewModel {
  ITposApiService _tposApi;
  final Logger _log = new Logger("ShipReceiverModel");
  ShipReceiverModel(
      {ITposApiService tposApi, ShipReceiver shipReceiver, int partnerId}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _shipReceiver = shipReceiver;
    _partnerId = partnerId;
    onIsBusyAdd(false);
  }

  FastSaleOrderAddEditFullViewModel _editVm;

  void init({int partnerId, FastSaleOrderAddEditFullViewModel editVm}) {
    assert(partnerId != null);
    assert(editVm != null);
    this._partnerId = partnerId;
    this._editVm = editVm;
  }

  ShipReceiver _shipReceiver;
  int _partnerId;
  ShipReceiver get shipReceiver => _shipReceiver;
  set shipReceiver(ShipReceiver value) {
    _shipReceiver = value;
  }

  List<CheckAddress> _checkAddressResults;
  CheckAddress _selectedCheckAddress;

  List<CheckAddress> get checkAddressResults => _checkAddressResults;
  CheckAddress get selectedCheckAddress => _selectedCheckAddress;

  String get street => _shipReceiver?.street;

  set name(String value) {
    _shipReceiver?.name = value;
  }

  set phone(String value) {
    _shipReceiver?.phone = value;
  }

  set city(CityAddress value) {
    _shipReceiver?.city = value;
    _shipReceiver?.district = null;
    _shipReceiver?.ward = null;
    notifyListeners();
  }

  set district(DistrictAddress value) {
    _shipReceiver?.district = value;
    _shipReceiver?.ward = null;
    notifyListeners();
  }

  set ward(WardAddress value) {
    _shipReceiver?.ward = value;
    notifyListeners();
  }

  set street(String value) {
    _shipReceiver?.street = value;
    //notifyListeners();
  }

  String checkKeyword;

  Future<void> checkAddressCommand(String keyword) async {
    onStateAdd(true);
    checkKeyword = keyword;
    try {
      _checkAddressResults = await _tposApi.checkAddress(checkKeyword);
      if (shipReceiver.street == null || shipReceiver.street == "") {
        if (_checkAddressResults != null && _checkAddressResults.length > 0) {
          var firstResult = _checkAddressResults.first;
          selectCheckAddressCommand(firstResult);
        }
      }
    } catch (e, s) {
      _log.severe("", e, s);
    }
    onStateAdd(false);
    notifyListeners();
  }

  Future<void> selectCheckAddressCommand(CheckAddress value) async {
    _selectedCheckAddress = value;
    _shipReceiver?.street = value.address;
    if (value.cityCode != null) {
      _shipReceiver?.city =
          new CityAddress(code: value.cityCode, name: value.cityName);
    }

    if (value.districtCode != null) {
      _shipReceiver?.district = new DistrictAddress(
          code: value.districtCode, name: value.districtName);
    } else {
      _shipReceiver?.district = null;
    }
    if (value.wardCode != null) {
      _shipReceiver?.ward =
          new WardAddress(code: value.wardCode, name: value.wardName);
    } else {
      _shipReceiver?.ward = null;
    }
    notifyListeners();
  }

  Future<void> updatePartnerAddressCommand() async {
    // get and update partner
    try {
      var partner = await _tposApi.getPartnerById(_partnerId);
      if (partner != null) {
        //update
        partner.street = this.street;
        partner.city = this._shipReceiver.city;
        partner.district = this._shipReceiver.district;
        partner.ward = this._shipReceiver.ward;

        await _tposApi.editPartner(partner);
        _editVm.partner?.street = this.street;
      }

      onDialogMessageAdd(
        OldDialogMessage.flashMessage("Đã lưu địa chỉ khách hàng"),
      );

      notifyListeners();
    } catch (e, s) {
      _log.severe("updatePartnerAddress", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", e.toString()));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
