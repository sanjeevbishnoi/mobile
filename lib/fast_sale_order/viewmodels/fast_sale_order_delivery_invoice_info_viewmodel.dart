import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';

import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';
import 'package:tpos_mobile/src/tpos_apis/models/payment_info_content.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';

import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/fast_sale_order_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class FastSaleOrderDeliveryInvoiceInfoViewModel extends ViewModel
    implements ViewModelBase {
  //log
  final _log = new Logger("FastSaleEditOrderViewModel");

  ITposApiService _tposApi;
  IFastSaleOrderApi _fastSaleOrderApi;
  FastSaleOrderDeliveryInvoiceInfoViewModel({
    ISettingService settingService,
    ITposApiService tposApi,
    IFastSaleOrderApi fastSaleOrderApi,
  }) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _fastSaleOrderApi = fastSaleOrderApi ?? locator<IFastSaleOrderApi>();
  }

  // dialog
  BehaviorSubject<OldDialogMessage> dialogController = new BehaviorSubject();

  //editOrder
  FastSaleOrder _editOrder;

  FastSaleOrder get editOrder => _editOrder;

  set editOrder(FastSaleOrder value) {
    _editOrder = value;
    _editOrderController.add(value);
  }

  BehaviorSubject<FastSaleOrder> _editOrderController = new BehaviorSubject();
  Stream<FastSaleOrder> get editOrderStream => _editOrderController.stream;
  Sink<FastSaleOrder> get editOrderSink => _editOrderController.sink;

  //
  List<PaymentInfoContent> _paymentInfoContent;

  List<PaymentInfoContent> get paymentInfoContent => _paymentInfoContent;

  set paymentInfoContent(List<PaymentInfoContent> value) {
    _paymentInfoContent = value;
    _paymentInfoContentController.add(value);
  }

  BehaviorSubject<List<PaymentInfoContent>> _paymentInfoContentController =
      new BehaviorSubject();
  Stream<List<PaymentInfoContent>> get paymentInfoContentStream =>
      _paymentInfoContentController.stream;
  Sink<List<PaymentInfoContent>> get paymentInfoContentSink =>
      _paymentInfoContentController.sink;

  //FastSaleOrderLine
  List<FastSaleOrderLine> _orderLines;

  List<FastSaleOrderLine> get orderLines => _orderLines;

  set orderLines(List<FastSaleOrderLine> value) {
    _orderLines = value;
    _orderLinesController.add(value);
  }

  BehaviorSubject<List<FastSaleOrderLine>> _orderLinesController =
      new BehaviorSubject();
  Stream<List<FastSaleOrderLine>> get orderLinesStream =>
      _orderLinesController.stream;
  Sink<List<FastSaleOrderLine>> get orderLinesSink =>
      _orderLinesController.sink;

  Future loadOrderInfo() async {
    if (editOrder != null && editOrder.id != null) {
      try {
        orderLines = await _tposApi.getFastSaleOrderLineById(editOrder.id);
        editOrder = await _fastSaleOrderApi.getById(editOrder.id);
      } catch (ex, stack) {
        _log.severe("loadOrderInfo fail", ex, stack);
        dialogController
            .add(new OldDialogMessage.error("Lỗi cập nhật", ex.toString()));
      }
    } else {}
  }

  Future init({FastSaleOrder editOrder}) async {
    _editOrder = editOrder;
    editOrderSink.add(_editOrder);
    if (_editOrder == null || _editOrder.id == null) {}
    await loadOrderInfo();
    onIsBusyAdd(false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _editOrderController.close();
    dialogController.close();
    super.dispose();
  }
}
