import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/point_sale.dart';
import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

class PosPointSaleListViewModel extends ViewModelBase {
  DialogService _dialog;
  IPosTposApi _tposApi;
  PosPointSaleListViewModel(
      {IPosTposApi tposApiService, DialogService dialogService}) {
    _tposApi = tposApiService ?? locator<IPosTposApi>();
    _dialog = dialogService ?? locator<DialogService>();
  }

  List<PointSale> _pointSales = [];
  List<PointSale> get pointSales => _pointSales;
  set pointSales(List<PointSale> value) {
    _pointSales = value;
    notifyListeners();
  }

  Future<void> loadPointSales() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getPointSales();

      if (result != null) {
        pointSales = result;
      }
    } catch (e, s) {
      logger.error("loadPosOrders", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  Future<void> hanleCreatePointSale(String name, int configId) async {
    if (name == "Phiên mới") {
      var result = await _tposApi.checkCreateSessionSale(configId);
    } else {
      _dialog.showError(
          title: "Error",
          content:
              "Bạn không thể tạo 2 phiên bán hàng với cùng một người chịu trách nhiệm!");
    }
  }
}
