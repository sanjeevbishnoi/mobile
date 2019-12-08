import 'dart:async';
import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order_detail.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class SaleOnlineOrderInfoViewModel extends ViewModel implements ViewModelBase {
  //log
  final _log = new Logger("SaleOnlineOrderInfoViewModel");

  ITposApiService _tposApi;
  SaleOnlineOrderInfoViewModel(
      {ISettingService settingService, ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  //Order
  SaleOnlineOrder _order;
  String _orderId;

  SaleOnlineOrder get order => _order;

  set order(SaleOnlineOrder value) {
    _order = value;
    _orderController.add(value);
  }

  BehaviorSubject<SaleOnlineOrder> _orderController = new BehaviorSubject();
  Stream<SaleOnlineOrder> get orderStream => _orderController.stream;
  Sink<SaleOnlineOrder> get orderSink => _orderController.sink;

  //SaleOrderLine
  List<SaleOnlineOrderDetail> _orderLines;

  List<SaleOnlineOrderDetail> get orderLines => _orderLines;

  set orderLines(List<SaleOnlineOrderDetail> value) {
    _orderLines = value;
    _orderLinesController.add(value);
  }

  BehaviorSubject<List<SaleOnlineOrderDetail>> _orderLinesController =
      new BehaviorSubject();
  Stream<List<SaleOnlineOrderDetail>> get orderLinesStream =>
      _orderLinesController.stream;
  Sink<List<SaleOnlineOrderDetail>> get orderLinesSink =>
      _orderLinesController.sink;

  Future loadOrderInfo() async {
    try {
      _order = await _tposApi.getOrderById(_orderId);
      orderLines = _order.details;
      if (_orderController.isClosed == false) _orderController.add(_order);
      if (_orderLinesController.isClosed == false)
        _orderLinesController.add(_orderLines);
    } catch (ex, stack) {
      _log.severe("loadOrderInfo fail", ex, stack);
      onDialogMessageAdd(OldDialogMessage.error("Lỗi cập nhật", ex.toString()));
    }
  }

  Future init({SaleOnlineOrder editOrder, String orderId}) async {
    assert(editOrder != null || orderId != null);
    _order = editOrder;
    _orderId = orderId;

    if (_orderId == null) {
      _orderId = _order.id;
    }
    orderSink.add(_order);
    await loadOrderInfo();
    onPropertyChanged("");
    onIsBusyAdd(false);
  }

  Future reloadCommand() async {
    onStateAdd(true);
    await loadOrderInfo();
    onPropertyChanged("");
    onStateAdd(false);
  }

  @override
  void dispose() {
    _orderController.close();
    _orderLinesController.close();
    super.dispose();
  }
}
