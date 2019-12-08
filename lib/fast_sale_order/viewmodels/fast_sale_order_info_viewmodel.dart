/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/4/19 6:25 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/4/19 5:46 PM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/services/data_services/data_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_payment.dart';

import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';
import 'package:tpos_mobile/src/tpos_apis/models/payment_info_content.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';

import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/fast_sale_order_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class FastSaleOrderInfoViewModel extends ViewModel implements ViewModelBase {
  //log
  final _log = new Logger("FastSaleEditOrderViewModel");

  ITposApiService _tposApi;
  IFastSaleOrderApi _fastSaleOrderApi;
  PrintService _print;
  DataService _dataService;
  FastSaleOrderInfoViewModel(
      {ISettingService settingService,
      ITposApiService tposApi,
      IFastSaleOrderApi fastSaleOrderApi,
      DataService dataService,
      PrintService print}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _print = print ?? locator<PrintService>();
    _dataService = dataService ?? locator<DataService>();
    _fastSaleOrderApi = fastSaleOrderApi ?? locator<IFastSaleOrderApi>();
    _initViewModelCommand();
  }

  ViewModelCommand _editCommand;
  ViewModelCommand _printShipCommand;
  ViewModelCommand _printInvoiceCommand;
  ViewModelCommand _printDeliveryInvoiceCommand;
  ViewModelCommand _cancelShipCommand;
  ViewModelCommand _cancelInvoiceCommand;
  ViewModelCommand _makePaymentCommand;
  ViewModelCommand _confirmCommand;
  ViewModelCommand _sendToShipperCommand;
  List<ViewModelCommand> _commands = new List<ViewModelCommand>();

  ViewModelCommand get printShipCommand => _printShipCommand;
  ViewModelCommand get printInvoiceCommand => _printInvoiceCommand;
  ViewModelCommand get cancelShipCommand => _cancelShipCommand;
  ViewModelCommand get cancelInvoiceCommand => _cancelInvoiceCommand;
  ViewModelCommand get makePaymentCommand => _makePaymentCommand;
  ViewModelCommand get confirmCommand => _confirmCommand;
  ViewModelCommand get sendToShipperCommand => _sendToShipperCommand;

  bool isConfirmAndPrintShip = false;
  bool isConfirmAndPrintOrder = false;

  void _initViewModelCommand() {
    _log.fine("state: ${editOrder?.state}");
    _editCommand = new ViewModelCommand(
      name: "Sửa",
      actionName: "edit",
    );
    _printShipCommand = new ViewModelCommand(
      name: "In phiếu ship",
      actionName: "printShip",
      action: _printShip,
      actionBusy: () async {
        onStateAdd(true, message: "Đang in phiếu ship");
        var rs = await _printShip();
        onStateAdd(false);
        return rs;
      },
    );

    _printInvoiceCommand = new ViewModelCommand(
      name: "In hóa đơn",
      actionName: "printInvoice",
      action: _printInvoice,
      actionBusy: () async {
        onStateAdd(true, message: "Đang in hóa đơn");
        var rs = await _printInvoice();
        onStateAdd(false);
        return rs;
      },
    );
    _cancelShipCommand = new ViewModelCommand(
      name: "Hủy vận đơn",
      actionName: "cancelShip",
      action: cancelShipOderCommand,
      enable: () =>
          (editOrder.carrierId != null && editOrder.trackingRef != null),
    );
    _cancelInvoiceCommand = new ViewModelCommand(
      name: "Hủy hóa đơn",
      actionName: "cancelInvoice",
      enable: () => (editOrder.state != "cancel" && editOrder.state != "draft"),
      action: cancelFastSaleOrderCommand,
    );

    _confirmCommand = new ViewModelCommand(
      name: "Xác nhận",
      enable: () => (_editOrder.state == "draft"),
      actionName: "confirmOrder",
      action: () async {
        return await _submitOrder();
      },
    );

    _makePaymentCommand = new ViewModelCommand(
        name: "Thanh toán",
        actionName: "makePayment",
        execute: () => (!isBusy &&
            editOrder?.state == "open" &&
            _editOrder?.residual != null &&
            _editOrder.residual > 0),
        enable: () => (!isBusy &&
            editOrder?.state == "open" &&
            _editOrder?.residual != null &&
            _editOrder.residual > 0),
        action: prepareAccountPaymentCommand,
        actionBusy: () async {
          onStateAdd(true);
          return await prepareAccountPaymentCommand();
        });

    _sendToShipperCommand = new ViewModelCommand(
      name: "Gửi lại vận đơn",
      actionName: "sendToShipper",
      action: () {
        _resentDeliveryCommandAction();
      },
      enable: () => (editOrder.state != "cancel" &&
          editOrder.state != "draft" &&
          editOrder.trackingRef == null &&
          editOrder.carrierId != null),
    );

    _commands.add(_editCommand);
    _commands.add(_confirmCommand);
    _commands.add(_printShipCommand);
    _commands.add(_cancelShipCommand);
    _commands.add(_cancelInvoiceCommand);

    onPropertyChanged("");
  }

  //editOrder
  FastSaleOrder _editOrder;
  FastSaleOrder get editOrder => _editOrder;

  String get shipAddress {
    String address = "";
    if (_editOrder.shipReceiver != null &&
        _editOrder.shipReceiver.street != null) {
      address =
          "${_editOrder.shipReceiver.name ?? "<Chưa có tên>"}, ${_editOrder.shipReceiver.phone ?? "<Chưa có SĐT>"} | ${_editOrder.shipReceiver.street ?? "<Chưa có địa chỉ>"}";
    } else {
      // Lấy thông tin khách hàng
      address =
          "${_editOrder.partner?.name ?? "<Chưa có tên>"}, ${_editOrder.partner?.phone ?? "<Chưa có SĐT>"} | ${_editOrder.partner?.street ?? "<Chưa có địa chỉ>"}";
    }
    return address;
  }

  set editOrder(FastSaleOrder value) {
    _editOrder = value;
    if (_editOrderController.isClosed == false) _editOrderController.add(value);
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

  double get subTotal => _editOrder?.subTotal;

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

  Future _loadOrderInfo() async {
    orderLines = await _tposApi.getFastSaleOrderLineById(editOrder.id);
    editOrder = await _fastSaleOrderApi.getById(editOrder.id);
  }

  Future _loadPaymentInfo() async {
    var getResult = await _tposApi.getPaymentInfoContent(this.editOrder.id);
    if (getResult.error == null) {
      this._paymentInfoContent = getResult.value;
      if (_paymentInfoContentController.isClosed == false)
        this._paymentInfoContentController.add(_paymentInfoContent);

      onPropertyChanged("");
    } else {
      onDialogMessageAdd(
          OldDialogMessage.flashMessage(getResult.error.message));
    }
  }

  Future init({FastSaleOrder editOrder}) async {
    _editOrder = editOrder;
    editOrderSink.add(_editOrder);
    if (_editOrder == null || _editOrder.id == null) {}
    onStateAdd(false);
  }

  Future initCommand() async {
    onStateAdd(true, message: "Đang tải...");
    try {
      await _loadOrderInfo();
      await _loadPaymentInfo();
      onPropertyChanged("");
    } catch (e, s) {
      _log.severe("init", e, s);
      onDialogMessageAdd(
        OldDialogMessage.error(
          "",
          e.toString(),
          title: "Lỗi không xác định",
          isRetryRequired: true,
          callback: (value) {
            initCommand();
          },
        ),
      );
    }

    onStateAdd(false);
  }

  // Xác nhận đơn hàng
  Future _submitOrder() async {
    onStateAdd(true, message: "Đang xác nhận...");
    try {
      var result =
          await _tposApi.fastSaleOrderConfirmOrder(<int>[editOrder.id]);
      if (result.result == true) {
        onDialogMessageAdd(
            new OldDialogMessage.flashMessage("Đã xác nhận hóa đơn"));

        if (_editOrder?.carrier != null) {
          App.analytics.logEvent(
              name: "submit_fast_sale_order_success",
              parameters: {"partner": "${_editOrder?.carrier?.deliveryType}"});
          print("event log");
        }

        // In phiêu ship & hóa đơn
        try {
          if (isConfirmAndPrintShip) {
            isConfirmAndPrintShip = false;
            await _print.printFastSaleOrderShip(
                fastSaleOrderId: this.editOrder.id);
          }
          if (isConfirmAndPrintOrder) {
            isConfirmAndPrintOrder = false;
            await _print.printFastSaleOrderInvoice(this.editOrder.id);
          }
        } catch (e, s) {
          _log.severe("", e, s);
        }

        await initCommand();
        _dataService.addDataNotify(
            value: editOrder,
            type: DataMessageType.UPDATE,
            valueTargetType: FastSaleOrder);
      } else {
        await initCommand();
        onDialogMessageAdd(new OldDialogMessage.error(
            "Có lỗi xảy ra khi gửi vận đơn!", result.message));
      }
    } catch (e, s) {
      _log.severe("submitOrder", e, s);
      onDialogMessageAdd(new OldDialogMessage.error("Lỗi không xác định!",
          "Xác nhận không thành công. Log: ${e.toString()}"));
    }
    onStateAdd(false);
  }

  Future cancelShipOderCommand() async {
    onStateAdd(true, message: "Đang thực hiện");
    try {
      var result = await _tposApi.fastSaleOrderCancelShip(this.editOrder.id);
      if (result.error == false) {
        onDialogMessageAdd(
            OldDialogMessage.flashMessage("Đã hủy vận đơn thành công"));
        await initCommand();
      } else {
        onDialogMessageAdd(
            OldDialogMessage.error("", result.message, title: "Thông tin!"));
      }
    } catch (e, s) {
      _log.severe("canncel ship command", e, s);
      onDialogMessageAdd(OldDialogMessage.error(
          "Không thực hiện được!", e.toString(),
          title: "Lỗi không xác định!"));
    }
    onStateAdd(false);
  }

  // Hủy bỏ hóa đơn
  Future cancelFastSaleOrderCommand() async {
    onStateAdd(true, message: "Đang thực hiện");
    try {
      var result =
          await _tposApi.fastSaleOrderCancelOrder(<int>[this.editOrder.id]);
      if (result.error == false) {
        onDialogMessageAdd(OldDialogMessage.flashMessage("Đã hủy hóa đơn"));
        await initCommand();
      } else {
        onDialogMessageAdd(
            OldDialogMessage.error("", result.message, title: "Thất bại!"));
      }
    } catch (e, s) {
      _log.severe("canncel order command", e, s);
      onDialogMessageAdd(OldDialogMessage.error(
          "Không thực hiện được!", e.toString(),
          title: "Lỗi không xác định!"));
    }
    onStateAdd(false);
  }

  // Chuẩn bị thanh toán
  Future<AccountPayment> prepareAccountPaymentCommand() async {
    onIsBusyAdd(true);
    try {
      var result = await _tposApi.accountPaymentPrepairData(editOrder.id);

      if (result.error == false) {
        onIsBusyAdd(false);
        return result.result;
      } else {
        onDialogMessageAdd(
            OldDialogMessage.error("Không thể thanh toán", result.message));
      }
    } catch (e, s) {
      _log.severe("preparePayment", e, s);
      onDialogMessageAdd(
          OldDialogMessage.error("Lỗi không xác định", e.toString()));
    }
    onIsBusyAdd(false);
    return null;
  }

  Future<bool> checkConditionToBeginEditInvoice() async {
    var isAllowEdit = true;
    if (this._editOrder.state != "draft") isAllowEdit = false;
    return isAllowEdit;
  }

  Future<void> _printShip() async {
    try {
      await _print.printFastSaleOrderShip(fastSaleOrderId: this.editOrder.id);
    } catch (e, s) {
      _log.severe("printShip", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", e.toString(), error: e));
    }
  }

  Future<void> _printInvoice() async {
    try {
      await _print.printFastSaleOrderInvoice(this.editOrder.id);
    } catch (e, s) {
      onDialogMessageAdd(OldDialogMessage.error("", e.toString(), error: e));
      _log.severe("", e, s);
    }
  }

  /// Gửi lại vận đơn
  Future<void> _resentDeliveryCommandAction() async {
    if (editOrder.carrierId == null) return;
    if (editOrder.trackingRef != null) return;
    try {
      onStateAdd(true, message: "Đang gửi...");
      await _tposApi.sendFastSaleOrderToShipper(this.editOrder.id);
      onDialogMessageAdd(
          OldDialogMessage.flashMessage("Đã gửi lại mã vận đơn"));
    } catch (e, s) {
      _log.severe("re send ship", e, s);
      onDialogMessageAdd(
        OldDialogMessage.error("", "", error: e, title: "Không gửi được!"),
      );
    }
    onStateAdd(false, message: "Đang gửi...");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _editOrderController.close();
    _paymentInfoContentController.close();

    super.dispose();
  }
}

class ViewModelCommand {
  final String name;
  final String description;
  final String tag;
  final Function action;
  final Function actionBusy;
  final String actionName;
  final Function active;
  final Function enable;
  final Function execute;

  bool get isActive => active != null ? active() : true;
  bool get isEnable => enable != null ? enable() : true;
  bool get canExecute => execute != null ? execute() : true;

  ViewModelCommand({
    this.name,
    this.description,
    this.tag,
    this.action,
    this.actionBusy,
    this.actionName,
    this.active,
    this.enable,
    this.execute,
  });
}
