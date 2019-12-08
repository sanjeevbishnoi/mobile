import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';

import '../../app_core/viewmodel/viewmodel_base_provider.dart';
import '../../app_service_locator.dart';
import '../../services/dialog_service.dart';
import '../../src/tpos_apis/services/tpos_api_interface.dart';
import '../models/pos_order.dart';

class PosOrderGioHangListViewModel extends ViewModelBase {
  DialogService _dialog;
  IPosTposApi _tposApi;
  PosOrderGioHangListViewModel(
      {IPosTposApi tposApiService, DialogService dialogService}) {
    _tposApi = tposApiService ?? locator<IPosTposApi>();
    _dialog = dialogService ?? locator<DialogService>();
  }

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;
  set sessions(List<Session> value) {
    _sessions = value;
    notifyListeners();
  }

  Future<void> getSession() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getPosSession();

      if (result != null) {
        sessions = result;
      }
    } catch (e, s) {
      logger.error("loadPosOrders", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }
}
