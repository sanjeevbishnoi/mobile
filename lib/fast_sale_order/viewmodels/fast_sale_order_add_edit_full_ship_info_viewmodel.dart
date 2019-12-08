import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ShipExtra.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ship_service_extra.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/calculate_fee_result.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_viewmodel.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class FastSaleOrderAddEditFullShipInfoViewModel extends ViewModel {
  ITposApiService _tposApi;
  IAppService _appService;
  Logger _log = new Logger("FastSaleOrderAddEditFullShipInfoViewModel");
  FastSaleOrderAddEditFullViewModel editVM;

  FastSaleOrderAddEditFullShipInfoViewModel(
      {ITposApiService tposApi, IAppService appService}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _appService = appService ?? locator<IAppService>();
  }

  void init({FastSaleOrderAddEditFullViewModel editVm}) {
    this.editVM = editVm;
  }

  // List ShipExtras
  Map<String, String> shifts = {"1": "Sáng", "2": "Chiều", "3": "Tối"};

  /// Thông tin ca lấy hàng
  ShipExtra get shipExtra => editVM.shipExtra;

  List<CalucateFeeResultDataService> get deliverCarrierServices =>
      editVM.deliveryCarrierServices;

  /// Đối tác giao hàng đang chọn
  DeliveryCarrier get deliveryCarrier => editVM.carrier;

  ///  Dịch vụ đối tác giao hàng đang chọn
  CalucateFeeResultDataService get deliverCarrierService =>
      editVM.carrierService;

  /// Danh sách tùy chọn dịch vụ đối tác giao hàng
  List<CalculateFeeResultDataExtra> get deliverCarrierServiceExtraList =>
      deliverCarrierService?.extras;

  /// Danh sách tùy chọn dịch vụ của đối tác giao hàng được chọn

  List<ShipServiceExtra> get _selectedServiceExtras =>
      editVM.getSelectedShipServiceExtras();

  double get shippingFee => editVM.order.deliveryPrice ?? 0;
  double get depositeAmount => editVM.order.amountDeposit ?? 0;
  double get cashOnDelivery => editVM.order.cashOnDelivery ?? 0;
  double get shippingFeeOfCarrier => editVM.order.customerDeliveryPrice ?? null;
  double get shipInsuranceFee => editVM.order.shipInsuranceFee ?? 0;
  double get totalAmount => editVM.total ?? 0;
  bool get isInsuranceFeeEquarTotal => this.shipInsuranceFee == totalAmount;
  set deliveryCarrier(DeliveryCarrier value) {
    editVM.carrier = value;
    notifyListeners();
  }

  set deliveryCarrierService(CalucateFeeResultDataService value) {
    editVM.carrierService = value;
  }

  set _shippingFeeOfCarrier(double value) {
    editVM.order.customerDeliveryPrice = value;
  }

  double get weight => editVM.order.shipWeight ?? 0;

  set weight(double value) {
    editVM.order.shipWeight = value;
  }

  set cashOnDelivery(double value) {
    editVM.order.cashOnDelivery = value;
  }

  set depositeAmount(double value) {
    editVM.order.amountDeposit = value;
    editVM.calculateCashOnDelivery();
    notifyListeners();
  }

  set shippingFee(double value) {
    editVM.order.deliveryPrice = value;
    editVM.calculateCashOnDelivery();
    notifyListeners();
  }

  set shipInsuranceFee(double value) {
    editVM.order.shipInsuranceFee = value;
    if (!this.isInsuranceFeeEquarTotal) {
      editVM.isShipInsuranceFeeEquaTotal = false;
    }
  }

  Future<void> _calculateDeliveryFeeForSelectCarrier() async {
    try {
      var result = await _tposApi.calculateShipingFee(
        partnerId: editVM.partner?.id,
        carrierId: deliveryCarrier.id,
        companyId: _appService.selectedCompany?.id ?? null,
        weight: this.weight,
        shipReceiver: editVM.shipReceiver,
        shipServiceId: this.deliverCarrierService?.serviceId,
      );

      _shippingFeeOfCarrier = result?.totalFee;
      editVM.deliveryCarrierServices = result?.services;
      if (editVM.deliveryCarrierServices != null &&
          editVM.deliveryCarrierServices.length > 0) {
        this.deliveryCarrierService = editVM.deliveryCarrierServices?.first;
      }
    } catch (e, s) {
      editVM.deliveryCarrierServices = null;
      _shippingFeeOfCarrier = null;
      _log.severe("calcuateDeliveryFee", e, s);
      onDialogMessageAdd(OldDialogMessage.flashMessage(
          e.toString().replaceAll("exception:", "")));
    }
  }

  Future<void> _calculateDeliveryFeeForSelectService() async {
    try {
      var result = await _tposApi.calculateShipingFee(
        partnerId: editVM.partner.id,
        carrierId: deliveryCarrier.id,
        companyId: _appService.selectedCompany?.id ?? null,
        weight: this.weight,
        shipReceiver: editVM.shipReceiver,
        shipServiceId: this.deliverCarrierService?.serviceId,
      );
      _shippingFeeOfCarrier = result.totalFee;
    } catch (e, s) {
      _log.severe("calcuateDeliveryFee", e, s);
      onDialogMessageAdd(OldDialogMessage.flashMessage(
          e.toString().replaceAll("exception:", "")));
    }
  }

  Future<void> _calculateDeliveryFeeForReCalculateFee() async {
    try {
      var result = await _tposApi.calculateShipingFee(
        partnerId: editVM.partner?.id,
        carrierId: deliveryCarrier.id,
        companyId: _appService.selectedCompany?.id ?? null,
        weight: this.weight,
        shipReceiver: editVM.shipReceiver,
        shipServiceId: this.deliverCarrierService?.serviceId,
        shipServiceExtras: this._selectedServiceExtras,
        shipInsuranceFee: this.shipInsuranceFee,
      );

      if (deliverCarrierService != null) {
        var service = result.services?.firstWhere(
            (f) => f.id == deliverCarrierService.id,
            orElse: () => null);
        if (service != null) {
          this._shippingFeeOfCarrier = service.totalFee;
        } else {
          this._shippingFeeOfCarrier = result.totalFee;
        }
      } else {
        this._shippingFeeOfCarrier = result.totalFee;
      }
    } catch (e, s) {
      _log.severe("calcuateDeliveryFee", e, s);
      onDialogMessageAdd(OldDialogMessage.flashMessage(
          e.toString().replaceAll("exception:", "")));
    }
  }

  Future<void> reCalculateDeliveryFeeCommand() async {
    onStateAdd(true);
    await _calculateDeliveryFeeForReCalculateFee();
    notifyListeners();
    onStateAdd(false);
  }

  /// Chọn đối tác giao hàng
  Future<void> selectDeliveryCarrierCommand(DeliveryCarrier value) async {
    if (value == null) {
      editVM.carrier = null;
      // Load mặc định
      editVM.order?.shipWeight = 0;
      editVM.order?.deliveryPrice = 0;
      editVM.shipExtra = null;
      if (weight == 0) {
        editVM.order?.shipWeight = 100;
      }
      // Tính phí giao hàng
      deliveryCarrierService = null;
      notifyListeners();
      return;
    }
    onStateAdd(true);
    // Load mặc định
    if (editVM.carrier != value) {
      editVM.order?.shipWeight = value.configDefaultWeight;
      editVM.order?.deliveryPrice = value.configDefaultFee;
      editVM.calculateCashOnDelivery();
    }
    editVM.carrier = value;

    //    editVM.shipExtra = value.shipExtra;
    if (weight == 0) {
      editVM.order?.shipWeight = 100;
    }
    // Tính phí giao hàng
    deliveryCarrierService = null;

    await _calculateDeliveryFeeForSelectCarrier();
    notifyListeners();
    onStateAdd(false);
  }

  /// Chọn dịch vụ đối tác giao hàng
  Future<void> selectDeliveryCarrierServiceCommand(
      CalucateFeeResultDataService value) async {
    onStateAdd(true);
    editVM.carrierService = value;
    await _calculateDeliveryFeeForSelectService();

    _shippingFeeOfCarrier = deliverCarrierService.totalFee;
    onStateAdd(false);
    notifyListeners();
  }

  /// Chọn dịch vụ thêm ship extra
  Future<void> selectShipExtraCommand(value) async {
    editVM.shipExtra = new ShipExtra();
    shipExtra.pickWorkShift = value;
    shipExtra.pickWorkShiftName = shifts[value];
    notifyListeners();
  }

  Future<void> getDefaultInsuranceFeeCommand() async {
    if (editVM.isShipInsuranceFeeEquaTotal) {
      this.shipInsuranceFee = totalAmount;
    }

    notifyListeners();
  }
}
