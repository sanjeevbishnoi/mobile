import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class DeliveryCarrierListViewModel extends ViewModel {
  ITposApiService _tposApi;
  DialogService _dialog;
  DeliveryCarrierListViewModel(
      {ITposApiService tposApi, LogService log, DialogService dialog})
      : super(logService: log) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _dialog = dialog ?? locator<DialogService>();
  }

  List<DeliveryCarrier> _deliveryCarries;
  // Danh sách đối tác để hiện kết quả tìm kiếm
  List<DeliveryCarrier> _viewDeliveryCarries;

  List<DeliveryCarrier> get deliveryCarries => _deliveryCarries;
  List<DeliveryCarrier> get viewDeliveryCarries => _viewDeliveryCarries;

  /// Khởi tạo giữ liệu
  Future<void> initData() async {
    onStateAdd(true, message: "Đang tải...");
    try {
      _deliveryCarries = await _tposApi.getDeliveryCarriers();
      notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(error: e);
    }
    onStateAdd(false);
  }

  Future<void> deleteCarrier(DeliveryCarrier deliveryCarrier) async {
    try {
      await _tposApi.deleteDeliveryCarrier(deliveryCarrier.id);
      _deliveryCarries.remove(deliveryCarrier);
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(error: e);
    }
  }

  /// Trong khi tìm kiếm
  void onSearch(String keyword) {
    String keywordNoSign = removeVietnameseMark(keyword.toLowerCase());
    _viewDeliveryCarries = _deliveryCarries
        ?.where(
          (f) => removeVietnameseMark(f.name.toLowerCase())
              .contains(keywordNoSign),
        )
        ?.toList();
    notifyListeners();
  }
}
