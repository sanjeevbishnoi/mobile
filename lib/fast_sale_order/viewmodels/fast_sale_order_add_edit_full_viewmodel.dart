/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/4/19 6:25 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/4/19 11:14 AM
 *
 */

import 'dart:async';

import 'package:tpos_mobile/app.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/category/viewmodel/product_search_viewmodel.dart'
    as prefix0;
import 'package:tpos_mobile/sale_online/ui/product_search.dart';
import 'package:tpos_mobile/services/data_services/data_service.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CityAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DistrictAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ShipExtra.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account.dart';
import 'package:tpos_mobile/src/tpos_apis/models/application_user.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_price.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ship_receiver.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ship_service_extra.dart';
import 'package:tpos_mobile/src/tpos_apis/models/stock_warehouse.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/fast_sale_order_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/sale_setting_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/calculate_fee_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ward_address.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

class FastSaleOrderAddEditFullViewModel extends ViewModel {
  static const String SAVE_DRAFT_SUCCESS_EVENT = "SAVE_DRAFT_SUCCESS";
  static const String SAVE_CONFIRM_SUCCESS_EVENT = "SAVE_CONFIRM_SUCCESS";
  static const String REQUIRED_CLOSE_UI = "REQUIRED_CLOSE_UI";
  ISettingService _setting;
  ITposApiService _tposApi;
  IFastSaleOrderApi _fastSaleOrderApi;
  ISaleSettingApi _saleSettingApi;
  PrintService _printService;
  DialogService _dialog;

  DataService _dataService;

  FastSaleOrderAddEditFullViewModel(
      {ISettingService setting,
      ITposApiService tposApi,
      IFastSaleOrderApi fastSaleOrderApi,
      ISaleSettingApi saleSettingApi,
      PrintService printService,
      LogService log,
      DataService dataService,
      DialogService dialog})
      : super(logService: log) {
    _setting = setting ?? locator<ISettingService>();
    _tposApi = tposApi ?? locator<ITposApiService>();
    _printService = printService ?? locator<PrintService>();
    _dialog = dialog ?? locator<DialogService>();
    _dataService = dataService ?? locator<DataService>();
    _fastSaleOrderApi = fastSaleOrderApi ?? locator<IFastSaleOrderApi>();
    _saleSettingApi = saleSettingApi ?? locator<ISaleSettingApi>();
  }

  EditType _editType = EditType.ADD_NEW;
  int _editOrderId;
  int _partnerId;

  /// Cấu hình bán hàng
  SaleSetting _saleSetting;

  /// Danh sách bảng giá
  List<ProductPrice> _priceLists;

  /// Danh sách id của đơn hàng facebook.
  List<String> _saleOrderIds;

  /// Hóa đơn mới/ sửa
  FastSaleOrder _order;

  /// có ẩn cảnh báo địa chỉ khách hàng khác địa chỉ giao hàng hanh không?
  bool isHideWarningDeliverAddress = false;

  Partner _partner;

  /// Danh sách hàng hóa / dịch vụ
  List<FastSaleOrderLine> _orderLines;
  List<FastSaleOrderLine> get orderLines => _orderLines;

  // Partner get partner => _partner;

  Account _account;

  /// Phương thức thanh toán
  Journal _journal;

  /// Phương thức thanh toán
  AccountJournal _paymentJournal;

  /// Thông tin giao hàng bổ sung// Name, phone, address
  ShipReceiver _shipReceiver;

  /// Bảng giá
  ProductPrice _productPrice;

  /// Kho hàng
  StockWareHouse _wareHouse;

  /// Danh sách dịch vụ của đối tác giao hàng cung cấp
  List<CalucateFeeResultDataService> _deliveryCarrierServices;

  /*--------------- THÔNG TIN CHUNG -------------*/

  /// Nhân viên bán
  ApplicationUser _saleUser;

  /// Công ty bán
  Company _company;

  /*--------------- THÔNG ĐƠN HÀNG -----------*/

  /*--------------- THÔNG TIN GIAO HÀNG -----------*/

  /// Tiền thu hộ (= Tổng tiền đơn hàng + Phí giao hàng - Tiền cọc)

  /// Đối tác giao hàng đang chọn
  DeliveryCarrier _carrier;

  /// Dịch vụ của đối tác giao hàng
  CalucateFeeResultDataService _carrierService;

  /// Danh sách dịch vụ của đối tác giao hàng
  List<ShipServiceExtra> _carrierServiceExtras;

  /// Thêm thông tin giao hàng
  ShipExtra _shipExtra;

  /// xác định khai giá hàng hóa = giá trị đơn hàng
  bool _isInsuranceFeeEquaTotal = true;

  bool _cantEditPartner = true;

  bool _cantEditPayment = true;
  bool _cantEditDeliveryAddress = true;
  bool _cantEditDelivery = true;
  bool _cantEditOtherInfo = true;

  bool _cantSave = true;
  bool _cantConfirm = true;
  /*--------------------PUBLIC ------------------*/
  EditType get editType => _editType;
  List<ProductPrice> get priceLists => _priceLists;

  /// Có tạo từ đơn hàng saleonline hay không
  bool get isCreateFromSaleOnlineOrder =>
      (_saleOrderIds != null && _saleOrderIds.length > 0);
  FastSaleOrder get order => _order;
  Account get account => _account;
  Partner get partner => _partner;
  ApplicationUser get user => _saleUser;
  DeliveryCarrier get carrier => _carrier;
  AccountJournal get paymentJournal => _paymentJournal;
  StockWareHouse get wareHouse => _wareHouse;
  Company get company => _company;
  Journal get journal => _journal;
  ProductPrice get priceList => _productPrice;
  ShipReceiver get shipReceiver =>
      _shipReceiver ?? (_shipReceiver = new ShipReceiver());

  ShipExtra get shipExtra => _shipExtra;
  CalucateFeeResultDataService get carrierService => _carrierService;
  List<ShipServiceExtra> get carrierServiceExtras => _carrierServiceExtras;
  List<CalucateFeeResultDataService> get deliveryCarrierServices =>
      _deliveryCarrierServices;

  bool get isShipInsuranceFeeEquaTotal => _isInsuranceFeeEquaTotal;

  bool get isValidToConfirm {
    var result = true;
    if (_partner == null) return false;
    if (_orderLines == null || _orderLines.length == 0) return false;
    //if (_carrierService == null) return false;
    return result;
  }

  String get shipReceiverNameAndPhone {
    StringBuffer _stringBuffer = new StringBuffer();
    if (_shipReceiver?.name != null && _shipReceiver?.name != "") {
      _stringBuffer.write("");
      _stringBuffer.write(_shipReceiver.name);
    }

    if (_shipReceiver?.phone != null && _shipReceiver?.phone != "") {
      _stringBuffer.write(" | ");
      _stringBuffer.write(_shipReceiver.phone);
    }

    return _stringBuffer?.toString() ?? null;
  }

  String get shipReceiverAddress {
    if (shipReceiver != null) {
      StringBuffer _stringBuffer = new StringBuffer();

      if (_shipReceiver.street != null) {
        _stringBuffer.write(_shipReceiver.street);
      }

//      if (_shipReceiver.ward != null && _shipReceiver.ward.name != null) {
//        _stringBuffer.write(", ");
//        _stringBuffer.write(_shipReceiver.ward.name);
//      }
//
//      if (_shipReceiver.ward != null && _shipReceiver.district.name != null) {
//        _stringBuffer.write(", ");
//        _stringBuffer.write(_shipReceiver.district.name);
//      }
//
//      if (_shipReceiver.ward != null && _shipReceiver.city.name != null) {
//        _stringBuffer.write(", ");
//        _stringBuffer.write(_shipReceiver.city.name);
//      }

      return _stringBuffer?.toString() ?? null;
    } else {
      return null;
    }
  }

  double get subTotal => (_orderLines == null || _orderLines.length == 0)
      ? 0
      : _orderLines?.map((f) => f.priceTotal ?? 0)?.reduce((a, b) => a + b) ??
          0;
  double get total {
    double total =
        (subTotal ?? 0) * (100 - discount) / 100 - (order?.decreaseAmount ?? 0);

    order?.amountTotal = total;
    return order?.amountTotal ?? 0;
  }

  double get rechargeAmount {
    return total - paymentAmount;
  }

  double get discount => _order?.discount ?? 0;
  double get discountAmount => _order?.discountAmount ?? 0;
  double get amountUntaxed => _order?.amountUntaxed ?? 0;
  double get paymentAmount => _order?.paymentAmount ?? 0;
  String get deliveryNote => _order?.deliveryNote;
  double get totalDiscountAmount =>
      this.discountAmount + (order?.decreaseAmount ?? 0);

  double get deliveryPrice => _order?.deliveryPrice ?? 0;
  double get cashOnDelivery => _order?.cashOnDelivery ?? 0;

  String get note => _order?.comment;

  bool isDiscountPercent = true;

  bool get cantEditPartner => _cantEditPartner;
  bool get cantChangePartner {
    if (_order.id == null || _order.id == 0 || _order.state == "draft")
      return true;
    if (isCreateFromSaleOnlineOrder) return false;
    if (_order.trackingRef != null) return false;

    return false;
  }

  bool get cantEditProduct {
    if (_partner == null) return false;
    if (_order?.id == null || _order?.id == 0 || _order?.state == "draft")
      return true;
    else
      return false;
  }

  bool get canEditPriceList {
    if (_order.id == null || _order.id == 0 || _order?.state == "draft")
      return true;
    return false;
  }

  bool get cantEditPayment => _cantEditPayment;
  bool get cantEditDeliveryAddress => _cantEditDeliveryAddress;
  bool get cantEditDelivery => _cantEditDelivery;
  bool get cantEditOtherInfo => _cantEditOtherInfo;
  bool get cantEditAndChangePartner => _cantEditPartner && _cantEditOtherInfo;

  bool get cantSave => _cantSave;
  bool get cantConfirm => _cantConfirm;
  /* CONDITION VISIBLE


   */

  bool get isProductListEnable => _partner != null;
  bool get isPaymentInfoEnable =>
      _partner != null && _orderLines != null && _orderLines.length > 0;
  bool get isShippingAddressEnable =>
      _partner != null && _orderLines != null && _orderLines.length > 0;
  bool get isShippingCarrierEnable =>
      _partner != null && isShippingAddressEnable;

  String get bottomActionName {
    if (_editType == EditType.ADD_NEW || _editType == EditType.EDIT_DRAFT) {
      return "XÁC NHẬN";
    } else if (_editType == EditType.EDIT_CONFIRM) {
      return "LƯU";
    } else if (_editType == EditType.EDIT_DELIVERY) {
      return "LƯU";
    } else
      return "N/A";
  }

  set paymentJournal(AccountJournal value) {
    _paymentJournal = value;
    _order.paymentJournal = value;
  }

  set carrier(DeliveryCarrier carrier) {
    _carrier = carrier;
  }

  set carrierService(CalucateFeeResultDataService value) {
    _carrierService = value;
  }

  set shipExtra(ShipExtra value) {
    _shipExtra = value;
  }

  set note(String text) {
    _order.comment = text;
  }

  set isShipInsuranceFeeEquaTotal(bool value) {
    this._isInsuranceFeeEquaTotal = value;
  }

  set deliveryCarrierServices(value) {
    this._deliveryCarrierServices = value;
  }

  set orderLines(List<FastSaleOrderLine> value) {
    this._order.orderLines = value;
    this._orderLines = value;
  }

  set priceList(ProductPrice priceList) {
    this._productPrice = priceList;
    this._order.priceList = priceList;
    this._order.priceListId = priceList.id;
    notifyListeners();
  }

  /* COMMAND
  * */

  void init(
      {FastSaleOrder editOrder,
      int editOrderId,
      List<String> saleOnlineIds,
      int partnerId}) {
    this._order = editOrder; // Tạo mới nếu không phải chỉnh sửa
    this._saleOrderIds = saleOnlineIds;
    this._editOrderId = editOrderId;
    this._partnerId = partnerId;

    onStateAdd(false);

    if (_saleOrderIds != null)
      assert(_saleOrderIds != null && _partnerId != null);
  }

  /// Lệnh khởi tạo giá trị mặc định viewmodel
  Future<bool> initCommand() async {
    onStateAdd(true, message: "Đang khởi tạo dữ liệu...");

    bool result = true;
    try {
      await _loadPriceList();
      await _loadSaleSetting();

      if ((_order != null && _order.id != null && _order.id != 0) ||
          (_editOrderId != null && _editOrderId != 0)) {
        // Sửa hóa đơn

        var orderResult =
            await _fastSaleOrderApi.getById(_editOrderId ?? _order.id);
        if (orderResult != null) {
          _order = orderResult;
          // update price list

          this._account = _order.account;
          this._wareHouse = _order.wareHouse;
          this._saleUser = _order.user;
          this._productPrice = _priceLists?.firstWhere(
              (f) => f.id == _order.priceList?.id,
              orElse: () => null);
          this._company = _order.company;
          this._journal = _order.journal;
          this._paymentJournal = _order.paymentJournal;
          this._partner = _order.partner;
          this._carrier = _order.carrier;
          this._saleUser = _order.user;
          this._shipExtra = _order.shipExtra;

          // update other info

          await _loadOrderLine();
        }
      } else if (this._saleOrderIds != null && this._saleOrderIds.length > 0) {
        // Tạo hóa đơn từ đơn hàng

        var getDefaultResult =
            await _fastSaleOrderApi.getFastSaleOrderDefault();
        if (getDefaultResult.value != null) {
          _order = getDefaultResult.value;
          // update price list
          this._account = _order.account;
          this._wareHouse = _order.wareHouse;
          this._saleUser = _order.user;
          this._productPrice = _priceLists?.firstWhere(
              (f) => f.id == _order.priceList?.id,
              orElse: () => null);
          this._company = _order.company;
          this._journal = _order.journal;
          this._paymentJournal = _order.paymentJournal;
          this._partner = _order.partner;
          this._carrier = _order.carrier;
          this._shipExtra = _order.shipExtra;

          _order.saleOnlineIds = _saleOrderIds;
          // Nếu là tạo từ đơn hàng

          // Lấy chi tiết đơn hàng
          var getOrderLineResult =
              await _tposApi.getDetailsForCreateInvoiceFromOrder(_saleOrderIds);

          if (getOrderLineResult.error != null) {
            throw new Exception(
                "Lấy chi tiết đơn hàng không thành công. ${getOrderLineResult.error.message}");
          } else {
            _orderLines = getOrderLineResult.value.orderLines;
            _order.orderLines = _orderLines;
            _order.comment = getOrderLineResult.value.comment;
            _calcalateTotal();
          }

          // Lấy thông tin khách hàng
          onStateAdd(true, message: "Lấy thông tin khách hàng...");
          await selectPartnerCommand(null, this._partnerId);
        }
      } else {
        //  Tạo hóa đơn mới
        var getDefaultResult =
            await _fastSaleOrderApi.getFastSaleOrderDefault();
        if (getDefaultResult.value != null) {
          _order = getDefaultResult.value;
          // update price list
          this._account = _order.account;
          this._wareHouse = _order.wareHouse;
          this._saleUser = _order.user;
          this._productPrice = _priceLists?.firstWhere(
              (f) => f.id == _order.priceList?.id,
              orElse: () => null);
          this._company = _order.company;
          this._journal = _order.journal;
          this._paymentJournal = _order.paymentJournal;
          this._partner = _order.partner;
          this._carrier = _order.carrier;
          this._shipExtra = _order.shipExtra;

          // Cập nhật thông tin liên quan tới khách hàng
          if (_partner != null) {
            onStateAdd(true, message: "Lấy thông tin khách hàng...");
            await selectPartnerCommand(_partner);
          }
        }
      }

      this._isInsuranceFeeEquaTotal =
          (this.total == (_order?.shipInsuranceFee ?? 0));

      // Kiểm tra xem được chỉnh sửa những gì
      if (_order.id == null || _order.id == 0) {
        this._editType = EditType.ADD_NEW;
      } else if (_order.state == "draft") {
        this._editType = EditType.EDIT_DRAFT;
      } else if (_order.state == "paid" || _order.state == "open") {
        this._editType = EditType.EDIT_CONFIRM;
      } else if (_order.trackingRef != null && _order.trackingRef != "") {
        this._editType = EditType.EDIT_DELIVERY;
      }

      _cantEditPartner = true;

      _cantEditPayment = (_order.id == null || _order.state == "draft");
      _cantEditDeliveryAddress =
          (_order?.trackingRef == null || _order?.trackingRef == "");
      _cantEditDelivery =
          (_order.trackingRef == null || _order?.trackingRef == "");
      _cantEditOtherInfo = true;

      //get inventory

      await locator<ProductSearchViewModel>().loadInventory();
      await locator<prefix0.ProductSearchViewModel>().refreshInventory();
      calculatePaymentAmount();
    } catch (e, s) {
      logger.error("", e, s);
      _dialog
          .showError(title: "Đã xảy ra lỗi!.", error: e, isRetry: true)
          .then((result) {
        if (result.type == DialogResultType.RETRY) {
          this.initCommand();
        } else if (result.type == DialogResultType.GOBACK) {
          onEventAdd(REQUIRED_CLOSE_UI, null);
        }
      });
      result = false;
    }

    onPropertyChanged("");
    onStateAdd(false);
    return result;
  }

  /// Lấy danh sách bảng giá
  Future<void> _loadPriceList() async {
    _priceLists = await _tposApi.getPriceListAvaible(DateTime.now());
  }

  /// Lệnh thêm sản phẩm mới vào danh sách
  /// Event thêm sản phẩm mới
  Future<void> addOrderLineCommand(Product product) async {
    var existsItem = _orderLines?.firstWhere((f) => f.productId == product.id,
        orElse: () => null);

    Future _addNew() async {
      FastSaleOrderLine line = new FastSaleOrderLine(
        productName: product.name,
        productNameGet: product.nameGet,
        productId: product.id,
        productUOMId: product.uOMId,
        productUomName: product.uOMName,
        priceUnit: product.price,
        productUOMQty: 1,
        discount: 0,
        discountFixed: 0,
        type: "percent",
        priceSubTotal: product.price,
        priceTotal: product.price,
        product: product,
      );

      if (_orderLines == null) {
        _orderLines = new List<FastSaleOrderLine>();
      }

      //Update order line info
      try {
        _updateOrderInfo();
        var orderLine =
            await _tposApi.getFastSaleOrderLineProductForCreateInvoice(
                orderLine: line, order: this._order);
        if (orderLine != null) {
          line.accountId = orderLine.account?.id;
          line.account = orderLine.account;
          line.productUOMId = orderLine.productUOMId;
          line.productUOM = orderLine.productUOM;
          line.priceUnit = orderLine.priceUnit;
          line.priceSubTotal = orderLine.priceUnit;
          line.priceTotal = orderLine.priceUnit;
        }
      } catch (e, s) {
        logger.error("", e, s);
        _dialog.showError(
            content: "thêm sản phẩm không thành công. \n${e.toString()}");
      }

      _orderLines.add(line);
    }

    if (existsItem != null) {
      if (_setting.addExistsProductWarning ==
          SettingAddExistsProductWarning.ADD_QUANTITY) {
        existsItem.productUOMQty += 1;
        onOrderLineChanged(existsItem);
      } else if (_setting.addExistsProductWarning ==
          SettingAddExistsProductWarning.CONFIRM_QUESTION) {
        var dialogResult = await _dialog.showConfirm(
            title: "Xác nhận",
            content:
                "Sản phẩm ${existsItem.productNameGet} đã tồn tại, bạn có muốn thêm dòng mới");

        if (dialogResult != null && dialogResult.type != DialogResultType.YES) {
          await _addNew();
        }
      }
    } else {
      await _addNew();
    }

    calculatePaymentAmount();
    calculateCashOnDelivery();
    onPropertyChanged("");
    print("added");
  }

  Future<void> copyOrderLinecommand(FastSaleOrderLine line) async {
    FastSaleOrderLine newOrderLine = new FastSaleOrderLine(
        productName: line.productName,
        productNameGet: line.productNameGet,
        productId: line.productId,
        productUOMId: line.productUOMId,
        productUomName: line.productUomName,
        priceUnit: line.priceUnit,
        productUOMQty: line.productUOMQty,
        discount: line.discount,
        discountFixed: line.discountFixed,
        type: line.type,
        priceSubTotal: line.priceSubTotal,
        priceTotal: line.priceTotal,
        product: line.product,
        account: line.account,
        accountId: line.accountId,
        productUOM: line.productUOM);

    _orderLines.insert(_orderLines.indexOf(line) + 1, newOrderLine);
    notifyListeners();
  }

  /// Lệnh xóa sản phẩm trong danh sách
  Future<void> deleteOrderLineCommand(FastSaleOrderLine item) async {
    if (_orderLines.contains(item)) {
      _orderLines.remove(item);
      this.calculatePaymentAmount();
      this.calculateCashOnDelivery();
      onPropertyChanged("orderLines");
    }
  }

  /// Lựa chọn khách hàng
  ///   Cập nhật lại thông tin giao hàng
  //     Chọn lại partner
  //    Cập nhật lại thông tin mặc định
  Future<void> selectPartnerCommand(Partner partner, [int partnerId]) async {
    assert(partner != null || partnerId != null);

    try {
      var newPartnerResult =
          await _tposApi.getPartnerById(partner?.id ?? partnerId);
      // Cập nhật lại thông tin đơn hàng

      _partner = newPartnerResult;
      _shipReceiver = new ShipReceiver(
        name: _partner.name,
        phone: _partner.phone,
        street: _partner.street,
        ward: _partner.ward,
        district: _partner.district,
        city: _partner.city,
      );

      _updateOrderInfo();
      OdataResult<FastSaleOrder> newOrderResult =
          await _fastSaleOrderApi.getFastSaleOrderWhenChangePartner(_order);

      if (newOrderResult.error == null) {
        this._productPrice = _priceLists?.firstWhere(
            (f) => f.id == newOrderResult.value?.priceList?.id,
            orElse: () => null);
        this._account = newOrderResult.value?.account;
      } else {
        throw new Exception(newOrderResult.error.message);
      }

      onPropertyChanged("");
    } catch (e, s) {
      logger.error("load parnter", e, s);
      _dialog.showError(
          title: "Đã xảy ra lỗi",
          content: "Chọn khách hàng không thành công",
          error: e);
    }
  }

  Future<void> selectShipReceiverCityCommand(CityAddress city) async {
    this.shipReceiver?.city = city;
    onPropertyChanged("");
  }

  Future<void> selectShipReceiverDistrictCommand(
      DistrictAddress district) async {
    this.shipReceiver?.district = district;
    onPropertyChanged("");
  }

  Future<void> selectShipReceiverWardCommand(WardAddress ward) async {
    this.shipReceiver?.ward = ward;
    onPropertyChanged("");
  }

  void _updateOrderInfo() {
    if (_account != null) {
      _order.accountId = _account.id;
      _order.account = _account;
    }

    _order.partnerId = _partner?.id ?? null;
    _order.partner = _partner;
    if (_productPrice != null) {
      _order.priceListId = _productPrice.id;
      _order.priceList = _productPrice;
    }

    _order.saleOnlineIds = _saleOrderIds;
    _order.userId = _saleUser.id;
    _order.user = _saleUser;
    _order.journalId = _journal.id;
    _order.journal = journal ?? null;
    _order.carrierId = _carrier?.id;
    _order.carrier = _carrier ?? null;
    _order.companyId = _company.id;
    _order.company = _company;
    _order.warehouseId = _wareHouse.id;
    _order.wareHouse = _wareHouse;
    _order.paymentJournalId = _paymentJournal.id;
    _order.paymentJournal = _paymentJournal;
    _order.orderLines = _orderLines;

    _order.shipReceiver = _shipReceiver;
    _order.shipExtra = _shipExtra;
    if (_carrierService != null) {
      _order.shipServiceId = _carrierService.serviceId;
      _order.shipServiceExtras = getSelectedShipServiceExtras();
      if (_isInsuranceFeeEquaTotal) {
        if (_order.shipServiceExtras != null &&
            _order.shipServiceExtras
                .any((f) => f.name.toLowerCase().contains("khai giá"))) {
          _order.shipInsuranceFee = total;
        }
      }
    }

    _order.amountTax = 0;
    _order.amountTotal = total;
    _order.amountUntaxed = total;
    _order.newCredit = total;
    _order.weightTotal = 0;
  }

  bool _checkConditionForCreateInvoce() {
    List<String> conditions = new List<String>();
    if (partner == null) {
      conditions.add("Khách hàng");
    }

    if (priceList == null) {
      conditions.add("Bảng giá");
    }

    if (_order.orderLines == null || _order.orderLines.length == 0) {
      conditions.add("Danh sách sản phẩm");
    }

    if (conditions.length > 0) {
      logger.info("Không đủ điều kiện tạo hóa đơn");
      _dialog.showInfo(content: "Chưa nhập đủ thông tin");
      return false;
    }
    return true;
  }

  /// Lệnh lưu dữ liệu và xem phiếu
  Future<bool> confirmAndPreviewCommand;

  void changeProductQuantityCommand(FastSaleOrderLine item, double value) {
    item.productUOMQty = value;
    onOrderLineChanged(item);
  }

  // Tính tổng chi tiết
  void onOrderLineChanged(FastSaleOrderLine item) {
    item.calculateTotal();
    this.calculatePaymentAmount();
    this.calculateCashOnDelivery();
    notifyListeners();
  }

  /// Command lưu nháp hóa đơn
  Future<void> saveDraftCommand() async {
    //validate data
    if (_partner == null) {
      _dialog.showError(
          title: "Cảnh báo", content: "Bạn cần phải chọn khách hàng trước");
      return false;
    }

    if (_orderLines == null || _orderLines.length == 0) {
      _dialog.showError(title: "Cảnh báo", content: "Vui lòng chọn sản phẩm");
      return false;
    }

    onStateAdd(true, message: "Đang lưu hóa đơn...");
    var result = await _saveDraft();
    if (result != null && result != 0) {
      onEventAdd(
          FastSaleOrderAddEditFullViewModel.SAVE_DRAFT_SUCCESS_EVENT, result);
    }
    onStateAdd(false);
    return result != null;
  }

  /// Command Lưu và xác nhận hóa đơn
  Future<void> saveAndConfirmCommand(
      {bool isPrintShip = false, isPrintOrder = false}) async {
    // Confirm

    var dialogResult = await _dialog.showConfirm(
        title: "Xác nhận",
        content: "Bạn muốn xác nhận hóa đơn này",
        yesButtonTitle: "XÁC NHẬN",
        noButtonTitle: "HỦY BỎ");
    if (dialogResult.type != DialogResultType.YES) {
      return false;
    }
    // validate
    if (_partner == null) {
      _dialog.showError(
          title: "Cảnh báo", content: "Bạn cần phải chọn khách hàng trước");
      return false;
    }

    if (_orderLines == null || _orderLines.length == 0) {
      _dialog.showError(title: "Cảnh báo", content: "Vui lòng chọn sản phẩm");
      return false;
    }

    if (_carrier != null) {
      if (_carrier.deliveryType.toLowerCase().contains("viettel") ||
          _carrier.deliveryType.toLowerCase().contains("ghn")) {
        if (_carrierService == null) {
          _dialog.showError(
              title: "Cảnh báo",
              content: "Vui lòng chọn dịch vụ của đối tác vận chuyển");
          return false;
        }

        if (_partner.name == null ||
            _partner.phone == null ||
            _partner.street == null) {
          if (_shipReceiver.name == null ||
              _shipReceiver.phone == null ||
              _shipReceiver.street == null) {
            _dialog.showError(
                title: "Cảnh báo",
                content:
                    "Vui lòng cập nhật Địa chỉ giao hàng: Tên, SĐT, Địa chỉ đầy đủ cho khách hàng");
            return false;
          }
        }
      }
    }

    onStateAdd(true, message: "Đang lưu...");

    try {
      int result = await _saveDraft();
      if (result != null && result != 0) {
        // Xác nhận
        onStateAdd(true, message: "Đang xác nhận...");
        bool confirmResult = await _confirmOrder(result);

        if (confirmResult) {
          _dialog.showNotify(
              message: "Đã xác nhận hóa đơn",
              type: DialogType.NOTIFY_INFO,
              showOnTop: true);
          // In phiếu
          if (isPrintShip) {
            onStateAdd(true, message: "Đang in phiếu ship");
            _printShip(result);
          }

          if (isPrintOrder) {
            try {
              onStateAdd(true, message: "Đang in hóa đơn");
              await _printService.printFastSaleOrderInvoice(result);
            } catch (e, s) {
              logger.error("print order", e, s);
            }
          }
        }
        onEventAdd(FastSaleOrderAddEditFullViewModel.SAVE_CONFIRM_SUCCESS_EVENT,
            result);
      }
    } catch (e, s) {
      logger.error("confirm order", e, s);
      _dialog.showError(error: e);
    }

    onStateAdd(false, message: "Đang lưu...");
  }

  Future<bool> _updateInvoice() async {
    if (_checkConditionForCreateInvoce() == false) {
      return false;
    }

    assert(_order.id != 0);
    assert(_order.partnerId != null);
    assert(_order.priceListId != null);
    assert(_order.userId != null);
    assert(_order.state == "draft");
    assert(_order.accountId != null);
    assert(_order.accountId != 0);
    assert(_order.journalId != null);

    try {
      await _tposApi.updateFastSaleOrder(_order);
      return true;
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(error: e, title: "Không thể xác nhận");
      return false;
    }
  }

  Future<void> _printShip(int fastSaleOrderId) async {
    try {
      await _printService.printFastSaleOrderShip(
          fastSaleOrderId: fastSaleOrderId);
    } catch (e, s) {
      logger.error("print ship after confirm", e, s);
      _dialog.showError(title: "In ship thất bại", error: e);
    }
  }

  List<ShipServiceExtra> getSelectedShipServiceExtras() {
    if (this._carrierService?.extras != null &&
        _carrierService.extras.length > 0) {
      return _carrierService.extras
          .where((f) => f.isSelected == true)
          .map(
            (f) => new ShipServiceExtra(
                id: f.serviceId, name: f.serviceName, fee: f.fee),
          )
          .toList();
    } else {
      return null;
    }
  }

  ///Tính phí giao hàng
  void calculateCashOnDelivery() {
    double cod = (this.total ?? 0) +
        (this.order?.deliveryPrice ?? 0) -
        (order?.amountDeposit ?? 0);

    print("amountTotal: ${order.amountTotal}");
    print("cod: ${cod}");

    this.order?.cashOnDelivery = cod;
    notifyListeners();
  }

  /// Tính cột thanh toán
  void calculatePaymentAmount() {
    if (!_saleSetting.groupAmountPaid) {
      _order.paymentAmount = total;
    }
    notifyListeners();
  }

  Future _loadOrderLine() async {
    orderLines = await _tposApi.getFastSaleOrderLineById(this.order.id);
  }

  Future<void> _calcalateTotal() async {
    _orderLines?.forEach((f) {
      f.priceSubTotal = (f.productUOMQty ?? 0) * (f.priceUnit ?? 0);
      f.priceTotal = f.priceSubTotal * (100 - (f.discount ?? 0)) / 100 -
          (f.discountFixed ?? 0);
    });
  }

  /// Lưu nháp hóa đơn
  /// Return int | Saved Order Id
  Future<int> _saveDraft() async {
    _updateOrderInfo();

    if (_order.id == null || _order.id == 0) {
      _order.id = null;
      _order.state = "draft";
      _order.showState = "Nháp";
    }

    assert(_order.id != 0);
    assert(_order.partnerId != null);
    assert(_order.priceListId != null);
    assert(_order.userId != null);
    // assert(_order.state == "draft");
    assert(_order.accountId != null);
    assert(_order.accountId != 0);
    assert(_order.journalId != null);

    int createdOrderId;
    try {
      if (_order.id == null) {
        // Tạo mới
        var createdOrder = await _tposApi.insertFastSaleOrder(_order, true);
        createdOrderId = createdOrder.id;
        this._order.id = createdOrder.id;
        _dataService.addDataNotify(value: _order, type: DataMessageType.INSERT);
        _dialog.showNotify(
            message: "Đã lưu hóa đơn",
            type: DialogType.NOTIFY_INFO,
            showOnTop: true);
      } else {
        // Cập nhật
        await _tposApi.updateFastSaleOrder(_order);
        createdOrderId = _order.id;
        _dataService.addDataNotify(
            value: _order,
            type: DataMessageType.UPDATE,
            valueTargetType: FastSaleOrder);
        _dialog.showNotify(
            message: "Đã lưu hóa đơn",
            type: DialogType.NOTIFY_INFO,
            showOnTop: true);
      }
      return createdOrderId;
    } catch (e, s) {
      logger.error("saveDraft", e, s);
      _dialog.showError(title: "Lưu hóa đơn thất bại", error: e);
      return null;
    }
  }

  /// Xác nhận hóa đơn sau khi lưu nháp thành công
  Future<bool> _confirmOrder(int orderId) async {
    try {
      onStateAdd(true, message: "Xác nhận...");
      var confirmResult = await _tposApi.fastSaleOrderConfirmOrder([
        orderId,
      ]);
      if (confirmResult.result == true) {
        _order.state = "open";
        _order.showState = "Đã thanh toán";
        _dialog.showNotify(
            message: "Đã xác nhận hóa đơn. ID: $orderId",
            type: DialogType.NOTIFY_INFO,
            showOnTop: true);
        _dataService.addDataNotify(
            value: _order.id,
            type: DataMessageType.UPDATE,
            valueTargetType: FastSaleOrder);

        if (_carrier != null) {
          App.analytics.logEvent(
              name: "submit_fast_sale_order_success",
              parameters: {"partner": "${_carrier?.deliveryType}"});
        }
      } else {}
      return true;
    } catch (e, s) {
      logger.error("confirm Order", e, s);
      return false;
    }
  }

  Future<void> _loadSaleSetting() async {
    _saleSetting = await _saleSettingApi.getDefault();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum EditType {
  ADD_NEW,
  EDIT_DRAFT,
  EDIT_CONFIRM,
  EDIT_DELIVERY,
}
