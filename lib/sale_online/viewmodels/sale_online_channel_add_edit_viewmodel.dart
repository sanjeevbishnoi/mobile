import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/crm_team.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class SaleOnlineChannelAddEditViewModel extends ViewModel {
  ITposApiService _tposApi;
  IAppService _appService;
  Logger _log = Logger("SaleOnlineChannelListViewModel");

  SaleOnlineChannelAddEditViewModel(
      {ITposApiService tposApi, IAppService appService}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _appService = appService ?? locator<IAppService>();
  }

  CRMTeam _channel;
  CRMTeam addOrEditchannel = new CRMTeam();
  CRMTeam get channel => _channel;
  void _setChannel(CRMTeam value) {
    _channel = value;
    if (_channelController != null && _channelController.isClosed == false) {
      _channelController.add(value);
    }
  }
//
//  void _channelAddError(Object exception, [StackTrace stackTrade]) {
//    if (_channelController != null && _channelController.isClosed == false) {
//      _channelController.addError(exception, stackTrade);
//    }
//  }

  var _channelController = BehaviorSubject<CRMTeam>();
  Stream<CRMTeam> get channelStream => _channelController.stream;

  void selectTypeCommand(String type) {
    channel.type = type;
    onPropertyChanged("selectTypeCommand");
  }

  void isCheckActive(bool value) {
    channel.active = value;
    onPropertyChanged("isCheckActive");
  }

  /// Lưu dữ liệu
  Future<bool> saveInfo() async {
    try {
      addOrEditchannel.id = channel.id;
      addOrEditchannel.name = channel.name;
      addOrEditchannel.type = channel.type;
      addOrEditchannel.parentName = channel.parentName;
      addOrEditchannel.shopId = channel.shopId;
      addOrEditchannel.zaloSecretKey = channel.zaloSecretKey;
      addOrEditchannel.active = channel.active;

      if (addOrEditchannel.id != null) {
        await _tposApi.editSaleChannelById(crmTeam: addOrEditchannel);
      } else {
        await _tposApi.addSaleChannel(crmTeam: addOrEditchannel);
      }
      // Thông báo hệ thống
      _appService.onAppMessengerAdd(
        new ObjectChangedMessage(
            sender: this, message: "insert/update", value: addOrEditchannel),
      );
      onDialogMessageAdd(
          OldDialogMessage.flashMessage("Lưu thông tin thành công"));
      return true;
    } catch (ex, stack) {
      _log.severe("saveInfo fail", ex, stack);
      onDialogMessageAdd(
          OldDialogMessage.error("Lưu dữ liệu thất bại", ex.toString()));
    }
    return false;
  }

  /// init Command
  Future<void> initCommand({CRMTeam crmTeam}) async {
    onIsBusyAdd(true);
    _channel = crmTeam ?? new CRMTeam();
    try {
      if (_channel.id != null) {
        _setChannel(crmTeam);
      }
    } catch (e, s) {
      _log.severe("init", e, s);
    }
    onPropertyChanged("init Command");
    onIsBusyAdd(false);
  }

  @override
  void dispose() {
    _channelController.close();
    super.dispose();
  }
}
