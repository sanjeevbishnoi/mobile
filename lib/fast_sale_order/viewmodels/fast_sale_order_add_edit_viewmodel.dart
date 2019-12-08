/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 5:40 PM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/calculate_fee_result.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CheckAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CityAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DistrictAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ShipExtra.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ship_receiver.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ship_service_extra.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ward_address.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

import '../../sale_online/viewmodels/app_viewmodel.dart';

class FastSaleOrderAddEditViewModel extends ViewModel implements ViewModelBase {
  Logger _log = new Logger("FastSaleOrderAddEditViewModel");
  ITposApiService _tposApi;
  IAppService _appService;

  FastSaleOrderAddEditViewModel(
      {TposApiService tposApi, IAppService appService}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _appService = appService ?? locator<IAppService>();
  }

  FastSaleOrderAddEditData _order;
  FastSaleOrderAddEditData get order => _order;

  void init({FastSaleOrderAddEditData editOrder}) {
    _order = editOrder ?? new FastSaleOrderAddEditData();
    _order.dateInvoice = _order.dateInvoice ?? DateTime.now();
    _order.cashOnDelivery = totalAmount;
  }

  //COMMAND
  RxCommand<int, void> _selectShiftCommand;
  RxCommand get selectShiftCommand {
    return _selectShiftCommand ??
        (_selectShiftCommand = RxCommand.createAsyncNoResult((value) async {
          return await _selectShiftCommandHandled(value);
        }));
  }

  Future<void> _selectShiftCommandHandled(value) async {
    _order.shipExtra = new ShipExtra();
    shipExtra.pickWorkShift = value;
    shipExtra.pickWorkShiftName = shifts[value];
    onPropertyChanged("");
  }

  Partner _partner;
  Partner get partner => _partner;

  DeliveryCarrier _selectedDeliveryCarrier;
  DeliveryCarrier get selectedDeliveryCarrier => _selectedDeliveryCarrier;

  ShipReceiver _shipReceiver = new ShipReceiver();
  ShipReceiver get shipReceiver => _shipReceiver;
  double shipInsuranceFee = 0;

  double suggestedDeliveryPrice = 0;

  double get totalAmount {
    double value = 0;
    this.orderLines?.forEach((f) {
      value += (f.priceUnit ?? 0) * (f.productUOMQty ?? 0);
    });

    return value;
  }

// shipWeightController
  var _shipWeightController = new BehaviorSubject<double>();
  BehaviorSubject<double> get shipWeightStream => _shipWeightController;
  Function(double) get shipWeightAdd => _shipWeightController.sink.add;
// cashOndeliveryController
  var _cashOnDeliveryController = new BehaviorSubject<double>();
  BehaviorSubject<double> get cashOnDeliveryStream => _cashOnDeliveryController;
  Function(double) get cashOnDeliveryAdd => _cashOnDeliveryController.sink.add;
  var _deliveryPriceController = new BehaviorSubject<double>();
  BehaviorSubject<double> get deliveryPriceStream => _deliveryPriceController;
  Function(double) get deliveryPriceAdd => _deliveryPriceController.sink.add;
  var _amountDepositController = new BehaviorSubject<double>();
  BehaviorSubject<double> get amountDepositStream => _amountDepositController;
  // checkAddressController

  BehaviorSubject<List<CheckAddress>> _checkAddressResultController =
      new BehaviorSubject();

  BehaviorSubject<List<CheckAddress>> get checkAddressResultStream =>
      _checkAddressResultController;

  // selectedCheckAddress
  CheckAddress selectedCheckAddress;

  // List ShipExtras
  Map<String, String> shifts = {"1": "Sáng", "2": "Chiều", "3": "Tối"};

  //Selected ShipExtras
  ShipExtra get shipExtra {
    if (_order.shipExtra == null) _order.shipExtra = new ShipExtra();
    return _order.shipExtra;
  }

  void selectCheckAddressCommand(CheckAddress value) {
    if (value == null) return;
    this.selectedCheckAddress = value;
    this.shipReceiver.city =
        new CityAddress(name: value.cityName, code: value.cityCode);
    this.shipReceiver.district =
        new DistrictAddress(name: value.districtName, code: value.districtCode);
    this.shipReceiver.ward =
        new WardAddress(name: value.wardName, code: value.wardCode);
    this.shipReceiver.street = value.address;
    onPropertyChanged("");
  }

  void setAmountDepositeCommand(double value) {
    _order.amountDeposit = value;
    _calculateCashOnDelivery();
  }

  void setShipWeightCommand(double value) {
    _order.shipWeight = value;
  }

  void setCashOnDeliveryCommand(double value) {
    if (value != _order.cashOnDelivery) {
      _order.cashOnDelivery = value;
    }
  }

  void setDeliveryPriceCommand(double value) {
    if (_order.deliveryPrice != value) {
      _order.deliveryPrice = value;
      _calculateCashOnDelivery();
    }
  }

  void setAmountTotalCommand(double value) {
    // _order.amountTotal = value;
    _calculateCashOnDelivery();
  }

  List<FastSaleOrderLine> get orderLines {
    if (_order.orderLines == null) {
      _order.orderLines = new List<FastSaleOrderLine>();
    }
    return _order.orderLines;
  }

  CalucateFeeResultData calculateShipingFeeResult;
  // Dịch vụ đối tác giao hàng được chọn
  CalucateFeeResultDataService selectedDeliveryCarrierService;

  Future<void> initCommand() async {
    onStateAdd(true);
    if (_order != null && _order.id != null && _order.id != 0) {
      try {
        await refreshFastSaleOrderInfo();
      } catch (e, s) {
        _log.severe("refreshCommand", e, s);
      }
    }
    if (_order.partnerId != null) {
      try {
        await refreshPartnerInfo();
      } catch (e, s) {
        _log.severe("refreshCommand", e, s);
      }
    }

    onStateAdd(false);
    onPropertyChanged("");
  }

  /// Lưu thông tin hóa đơn
  Future<void> saveCommand([bool isDraft = false]) async {
    onIsBusyAdd(true);
    if (_order.id == 0) {
      if (this.orderLines.length == 0) {
        onDialogMessageAdd(new OldDialogMessage.warning("Chưa nhập sản phẩm"));
        onIsBusyAdd(false);
      }

      _order.shipReceiver = _getShipReceiver();
      _order.carrierId = selectedDeliveryCarrier?.id;
      _order.shipServiceId = selectedDeliveryCarrierService?.serviceId;
      _order.shipServiceName = selectedDeliveryCarrierService?.serviceName;
      if (selectedDeliveryCarrierService != null) {
        _order.shipServiceExtras = _getSelectedShipServiceExtras();
      }
      _order.shipInsuranceFee = this.shipInsuranceFee;
      _order.amountTotal = this.totalAmount;
      _order.customerDeliveryPrice = this.suggestedDeliveryPrice;
      _order.paymentAmount = this.totalAmount;

      _order.type = "invoice";

      // Ship_Extras

      try {
        _order.partnerId = _partner.id;

        var submitResult = await _tposApi.createFastSaleOrder(_order, isDraft);
        onDialogMessageAdd(
            new OldDialogMessage.flashMessage("Lưu hóa đơn thành công"));
        _order.id = submitResult.result.id;
        _order.number = submitResult.result.number;
        onDialogMessageAdd(new OldDialogMessage.flashMessage(
            "Đã tạo hóa đơn!. ${submitResult.message ?? ""}"));
        onPropertyChanged("");
      } catch (e, s) {
        _log.severe("saveOrder", e, s);
        onDialogMessageAdd(new OldDialogMessage.error("", e.toString()));
      }
    } else {
      onDialogMessageAdd(new OldDialogMessage.flashMessage("Đã tạo hóa đơn!"));
    }
    onIsBusyAdd(false);
  }

  /// Làm mới thông tin
  Future<void> refreshCommand() async {
    if (isBusy) return;
    onStateAdd(true);
    assert(_order != null);
    assert(_order.id != null);
    try {
      await refreshFastSaleOrderInfo();
      await refreshPartnerInfo();
    } catch (e, s) {
      _log.severe("refreshCommand", e, s);
    }

    onStateAdd(false);
  }

  /// Chọn đối tác giao hàng
  Future<void> selectDeliveryCarrierCommand(
      DeliveryCarrier selectedDeliveryCarrier) async {
    onIsBusyAdd(true);
    _selectedDeliveryCarrier = selectedDeliveryCarrier;
    setShipWeightCommand(_selectedDeliveryCarrier.configDefaultWeight ?? 0);
    setDeliveryPriceCommand(_selectedDeliveryCarrier.configDefaultFee ?? 0);
    selectedDeliveryCarrierService = null;
    _order.shipExtra = null;
    await calculateShipingFee();
    onIsBusyAdd(false);
    onPropertyChanged("selectedDeliveryCarrier");
  }

  /// Chọn tỉnh/ thành phố command
  Future<void> selectShipReceiverCityCommand(CityAddress city) async {
    _shipReceiver.city = city;
    _shipReceiver.district = null;
    _shipReceiver.ward = null;
    _refreshFullAddress();
    onPropertyChanged("");
  }

  /// Kiểm tra nhanh địa chỉ
  Future<void> quickCheckAddress(String keyword) async {
    onStateAdd(true);
    await Future.delayed(Duration(seconds: 5));
    try {
      var result = await _tposApi.quickCheckAddress(keyword);
      addSubject(_checkAddressResultController, result);
      if (result.length > 0) {
        this.selectCheckAddressCommand(result.first);
      } else {
        this.selectCheckAddressCommand(null);
      }
    } catch (e, s) {
      addErrorSubject(_checkAddressResultController, e, s);
    }
    onStateAdd(false);
  }

  /// Chọn quận/huyện
  Future<void> selectShipReceiverDistrictCommand(
      DistrictAddress district) async {
    _shipReceiver.district = district;
    _shipReceiver.ward = null;
    _refreshFullAddress();
    onPropertyChanged("");
  }

  Future<void> setPartnerCommand(Partner value) async {
    _partner = value;
    onPropertyChanged("");
  }

  /// Tạo địa chỉ
  Future<void> _refreshFullAddress() async {
    String address = _shipReceiver.street ?? "";
    if (_shipReceiver.ward != null) {
      address +=
          "${address.isNotEmpty ? ", " : ""}${_shipReceiver.ward.name ?? ""}";
    }

    if (_shipReceiver.district != null) {
      address +=
          "${address.isNotEmpty ? ", " : ""}${_shipReceiver.district.name ?? ""}";
    }

    if (_shipReceiver.city != null) {
      address +=
          "${address.isNotEmpty ? ", " : ""}${_shipReceiver.city.name ?? ""}";
    }
  }

  /// Chọn phường/xã
  Future<void> selectShipReceiverWardCommand(WardAddress ward) async {
    _shipReceiver.ward = ward;
    _refreshFullAddress();

    onPropertyChanged("");
  }

  /// command Thêm sản phẩm
  Future<void> addNewOrderLineFromProductCommand(
      Product selectedProduct) async {
    // Kiểm tra tồn tại
    if (orderLines.any((f) => f.productId == selectedProduct.id)) {
      onDialogMessageAdd(new OldDialogMessage.confirm(
          "${selectedProduct.name} đã có. Bạn có muốn thêm và tạo thành 1 dòng mới?",
          (result) {
        if (result == OldDialogResult.Yes) {
          _addNewOrderLineFromProduct(selectedProduct);
        }
      }));
    } else {
      _addNewOrderLineFromProduct(selectedProduct);
    }
  }

  void _addNewOrderLineFromProduct(Product item) {
    var newOrderLine = new FastSaleOrderLine();
    newOrderLine.productName = item.name;
    newOrderLine.productNameGet = item.nameGet;
    newOrderLine.productUomName = item.uOMName;
    newOrderLine.productId = item.id;
    newOrderLine.productUOMId = item.uOMId;
    newOrderLine.productUOMQty = 1;
    newOrderLine.priceUnit = item.price;

    this.orderLines.add(newOrderLine);
    // Tính lại phí cod
    _calculateCashOnDelivery();
    onPropertyChanged("order");
  }

  ///Command Thay đổi số lượng sản phẩm
  Future<void> changeQuantityOfProductCommand(
      FastSaleOrderLine orderLine, bool isAdd) async {
    if (isAdd) {
      orderLine.productUOMQty += 1;
    } else {
      if (orderLine.productUOMQty > 1) orderLine.productUOMQty -= 1;
    }
    _calculateCashOnDelivery();
    onPropertyChanged("");
  }

  /// Command thay đổi đơn giá
  Future<void> changePriceOfProductCommand(
      FastSaleOrderLine orderLine, bool isAdd) async {
    if (isAdd) {
      orderLine.priceUnit += 1000;
    } else {
      if (orderLine.priceUnit > 1000) orderLine.priceUnit -= 1000;
    }
    _calculateCashOnDelivery();
    onPropertyChanged("");
  }

  /// Command xóa sản phẩm

  Future<void> deleteOrderLineCommand(FastSaleOrderLine orderLine) async {
    orderLines.remove((orderLine));
    _calculateCashOnDelivery();
    onPropertyChanged("");
  }

  // Command thay đổi đơn giá

  Future<void> updateOrderLinePriceCommand(
      FastSaleOrderLine orderline, double price) async {
    orderline.priceUnit = price;
    _calculateCashOnDelivery();
    onPropertyChanged("");
  }

  Future<void> updateOrderLineQuantityCommand(
      FastSaleOrderLine orderLine, double value) async {
    orderLine.productUOMQty = value;
    _calculateCashOnDelivery();
    onPropertyChanged("orderLine.productUOMQty");
  }

  /// Command chọn dịch vụ đơn vị vận chuyển
  Future<void> selectDeliveryCarrierServiceCommand(
      {CalucateFeeResultDataService service}) async {
    this.selectedDeliveryCarrierService = service;
    this._order.shipServiceId = (service.serviceId);
    this.reCalculateShipingFeeCommand();
    onPropertyChanged("selectedDeliveryCarrierService");
  }

  ///  tính tiền thu hộ
  Future<void> _calculateCashOnDelivery() async {
    var value = (totalAmount ?? 0) +
        (order.deliveryPrice ?? 0) -
        (order.amountDeposit ?? 0);

    if (value != _order.cashOnDelivery) {
      order.cashOnDelivery = value;
      addSubject(_cashOnDeliveryController, value);
    }
  }

  ///Tính phí giao hàng
  Future<void> calculateShipingFee() async {
    this.onStateAdd(true);

    if (_selectedDeliveryCarrier != null) {
      try {
        ShipReceiver sr;
        if (partner != null &&
            partner.city != null &&
            partner.district != null) {
          sr = new ShipReceiver(
              name: _partner.name,
              phone: _partner.phone,
              city: _partner.city,
              district: _partner.district,
              ward: _partner.ward);
        } else {
          sr = new ShipReceiver(
              name: _shipReceiver.name,
              phone: _shipReceiver.phone,
              city: _shipReceiver.city,
              district: _shipReceiver.district,
              ward: _shipReceiver.ward);
        }

        if (sr.city == null || sr.district == null) {
          onDialogMessageAdd(OldDialogMessage.warning(
              "Vui lòng cập nhật thông tin địa chỉ cho khách hàng"));
          this.onStateAdd(false);
          onPropertyChanged("");
          return;
        }

        calculateShipingFeeResult = await _tposApi.calculateShipingFee(
          carrierId: _selectedDeliveryCarrier.id,
          companyId: _appService.selectedCompany.id,
          partnerId: this.partner.id,
          weight: this.order.shipWeight,
          shipReceiver: sr,
        );

        if (calculateShipingFeeResult != null) {
          this.suggestedDeliveryPrice = calculateShipingFeeResult?.totalFee;
          if ((calculateShipingFeeResult.services?.length ?? 0) > 0) {
            if (selectedDeliveryCarrierService != null) {
              selectedDeliveryCarrierService =
                  calculateShipingFeeResult.services.firstWhere((f) =>
                      f.serviceId == selectedDeliveryCarrierService.serviceId);
            }
          }
        }
      } catch (e, s) {
        _log.severe("", e, s);
        this.suggestedDeliveryPrice = 0;
        this.calculateShipingFeeResult = null;
        this.selectedDeliveryCarrierService = null;
        onDialogMessageAdd(new OldDialogMessage.flashMessage(e.toString(),
            receiver: AppRoute.fast_sale_order_add_edit_ship_receiver));
      }
    } else {
      this.suggestedDeliveryPrice = 0;
    }
    this.onStateAdd(false);
    onPropertyChanged("");
  }

  // Tính lại phí giao hàng
  Future<void> reCalculateShipingFeeCommand() async {
    this.onStateAdd(true);

    if (_selectedDeliveryCarrier != null) {
      try {
        ShipReceiver sr;
        if (partner != null &&
            partner.city != null &&
            partner.district != null) {
          sr = new ShipReceiver(
              name: _partner.name,
              phone: _partner.phone,
              city: _partner.city,
              district: _partner.district,
              ward: _partner.ward);
        } else {
          sr = new ShipReceiver(
              name: _shipReceiver.name,
              phone: _shipReceiver.phone,
              city: _shipReceiver.city,
              district: _shipReceiver.district,
              ward: _shipReceiver.ward);
        }

        if (sr.city == null || sr.district == null) {
          onDialogMessageAdd(OldDialogMessage.warning(
              "Vui lòng cập nhật thông tin địa chỉ cho khách hàng"));
          this.onStateAdd(false);
          onPropertyChanged("");
          return;
        }

        var result = await _tposApi.calculateShipingFee(
          carrierId: _selectedDeliveryCarrier.id,
          companyId: _appService.selectedCompany.id,
          partnerId: this.partner.id,
          weight: this.order.shipWeight,
          shipReceiver: sr,
          shipServiceId: selectedDeliveryCarrierService.serviceId,
          shipServiceExtras: _getSelectedShipServiceExtras(),
          shipInsuranceFee: this.shipInsuranceFee,
        );

        if (result != null) {
          this.suggestedDeliveryPrice = result?.totalFee;
          this.selectedDeliveryCarrierService.extras.forEach((sv) {
            var feeResult = result.costs.firstWhere(
                (cs) => cs.serviceId == sv.serviceId,
                orElse: () => null);

            if (feeResult != null) {
              sv.fee = feeResult.totalFee;
            }
          });
        }
      } catch (e, s) {
        _log.severe("", e, s);
        this.suggestedDeliveryPrice = 0;
        onDialogMessageAdd(new OldDialogMessage.error(
            "Không hỗ trợ", e.toString(),
            sender: this,
            receiver: AppRoute.fast_sale_order_add_edit_ship_receiver));
        //TODO
      }
    } else {
      this.suggestedDeliveryPrice = 0;
    }
    this.onStateAdd(false);
    onPropertyChanged("");
  }

  ShipReceiver _getShipReceiver() {
    ShipReceiver sr;
    if (partner != null && partner.city != null && partner.district != null) {
      sr = new ShipReceiver(
          name: _partner.name,
          phone: _partner.phone,
          city: _partner.city,
          district: _partner.district,
          ward: _partner.ward);
    } else {
      sr = new ShipReceiver(
          name: _shipReceiver.name,
          phone: _shipReceiver.phone,
          city: _shipReceiver.city,
          district: _shipReceiver.district,
          ward: _shipReceiver.ward);
    }

    return sr;
  }

  List<ShipServiceExtra> _getSelectedShipServiceExtras() {
    if (selectedDeliveryCarrierService.extras != null &&
        selectedDeliveryCarrierService.extras.length > 0) {
      return selectedDeliveryCarrierService.extras
          .where((f) => f.isSelected == true)
          .map((f) => new ShipServiceExtra(
              id: f.serviceId, name: f.serviceName, fee: f.fee))
          .toList();
    } else {
      return null;
    }
  }

  Future<void> refreshFastSaleOrderInfo() async {
    _order = await _tposApi.getFastSaleOrderForEdit(_order.id);
  }

  Future<void> refreshPartnerInfo() async {
    _partner = await _tposApi.getPartnerById(_order.partnerId);
  }

  String getOrderLineInformation() {
    String comment = "";
    if (orderLines.length > 0) {
      comment = orderLines.first.productName;
      comment += " và ${orderLines.length - 1} sản phẩm khác";
    } else {
      comment = "Chưa có sản phẩm nào";
    }
    return comment;
  }

  double calculateFastSaleOrderAmountFromDetail() {
    if (order.orderLines == null || order.orderLines.length == 0) {
      return 0;
    }

    double amount = 0;
    order.orderLines.forEach((f) {
      amount += (f.productUOMQty * f.priceUnit);
    });
    return amount;
  }

  // Chọn giá hàng hóa

  Future setShipInsuranceCommand(double value) async {
    onIsBusyAdd(true);
    this.shipInsuranceFee = value;
    await this.reCalculateShipingFeeCommand();
    onPropertyChanged("");
    onIsBusyAdd(false);
  }

  void selectShipServiceExtra(CalculateFeeResultDataExtra item, bool value) {
    item.isSelected = value;
    if (item.serviceName.contains("Khai Giá Hàng Hoá")) {
      if (this.shipInsuranceFee == 0 && value == true) {
        this.shipInsuranceFee = totalAmount;
      }
    }

    onPropertyChanged("");
  }

  @override
  void dispose() {
    _cashOnDeliveryController.close();
    _amountDepositController.close();
    _checkAddressResultController.close();
    _deliveryPriceController.close();
    _shipWeightController.close();
    super.dispose();
  }
}
