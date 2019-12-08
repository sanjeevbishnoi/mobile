import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/fast_sale_order/models/create_quick_fast_sale_order_model.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class FastSaleOrderQuickCreateFromSaleOnlineOrderViewModel extends ViewModel {
  ITposApiService _tposApi;
  DialogService _dialog;
  List<String> _saleOnlineOrderIds;
  PrintService _print;

  FastSaleOrderQuickCreateFromSaleOnlineOrderViewModel(
      {ITposApiService tposApi,
      LogService logService,
      PrintService printService,
      DialogService dialogService})
      : super(logService: logService) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _dialog = dialogService ?? locator<DialogService>();
    _print = printService ?? locator<PrintService>();
  }

  CreateQuickFastSaleOrderModel _quickModel;
  CreateQuickFastSaleOrderModel get quickModel => _quickModel;
  DeliveryCarrier get carrier => _quickModel?.carrier;
  List<CreateQuickFastSaleOrderLineModel> get lines => _quickModel?.lines;

  set carrier(DeliveryCarrier carrier) {
    quickModel?.carrierId = carrier?.id;
    quickModel?.carrier = carrier;
    notifyListeners();
  }

  /// Khởi tạo và nhận param
  void init({@required List<String> saleOnlineOrderIds}) {
    _saleOnlineOrderIds = saleOnlineOrderIds;
  }

  /// Khởi tạo dữ liệu ban đầu
  Future<void> initData() async {
    onStateAdd(true);
    try {
      _quickModel = await _tposApi
          .getQuickCreateFastSaleOrderDefault(_saleOnlineOrderIds);
      notifyListeners();
    } catch (e, s) {
      logger.error("init data", e, s);
      _dialog
          .showError(isRetry: true, error: e, buttonTitle: "Đồng ý")
          .then((result) {
        if (result != null && result.type == DialogResultType.RETRY)
          initData();
        else if (result != null && result.type == DialogResultType.GOBACK) {
          onEventAdd("GO_BACK", null);
        }
      });
    }
    onStateAdd(false);
  }

  ///Action Đồng ý tạo hóa đơn
  Future<bool> save({bool printOrder = false, bool printShip = false}) async {
    // validate

    if (carrier != null) {
      if (lines
          .any((f) => f.partner?.phone == null || f.partner?.phone == "")) {
        _dialog.showNotify(
            message: "Vui lòng cập nhật số điện thoại cho khách hàng");
        return false;
      }
      if (lines.any((f) =>
          f.partner?.addressFull == null || f.partner?.addressFull == "")) {
        _dialog.showNotify(message: "Vui lòng cập nhật địa chỉ cho khách hàng");
        return false;
      }
    }
    bool isSuccess = false;

    onStateAdd(true, message: "Đang lưu...");

    try {
      // Bỏ COD
      _quickModel.lines?.forEach((f) {
        f.cOD = null;
      });
      var result = await _tposApi.createQuickFastSaleOrder(this._quickModel);
      if (result.error != null && result.error.isNotEmpty) {
        _dialog.showError(content: result.error);
      } else
        _dialog.showNotify(message: "Đã tạo hóa đơn thành công");
      isSuccess = true;
      if (printOrder) {
        await printOrders(result.ids);
      }

      if (printShip) {
        await printShips(result.ids);
      }
    } catch (e, s) {
      logger.error("save", e, s);
      _dialog.showError(error: e);
      isSuccess = false;
    }
    onStateAdd(false, message: "false lưu...");
    return isSuccess;
  }

  Future<bool> printOrders(List<int> ids) {
    ids.forEach(
      (f) async {
        try {
          await _print.printFastSaleOrderInvoice(f);
        } catch (e, s) {
          logger.error("", e, s);
        }
      },
    );
  }

  Future<bool> printShips(List<int> ids) {
    ids.forEach((f) async {
      try {
        await _print.printFastSaleOrderShip(fastSaleOrderId: f);
      } catch (e, s) {
        logger.error("", e, s);
      }
    });
  }

  Future<bool> printOrderAndShip() {}
}
