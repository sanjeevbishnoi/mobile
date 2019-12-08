import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

import '../../app_service_locator.dart';

class HomePersonalViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("HomePersonalViewModel");
  HomePersonalViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  bool _isInit = false;
  int _expiredIn;

  int get expiredIn => _expiredIn;
  Future<void> initCommand() async {
    if (!_isInit) {
      try {
        await _loadAppExpired();
        _isInit = true;
      } catch (e, s) {
        _log.severe("refreshCommand", e, s);
      }
    }
    notifyListeners();
  }

  Future<void> refreshCommand() async {
    try {
      await _loadAppExpired();
    } catch (e, s) {
      _log.severe("refreshCommand", e, s);
    }
  }

  Future<void> _loadAppExpired() async {
    _expiredIn = await _tposApi.getAppDateExpired();
  }
}
