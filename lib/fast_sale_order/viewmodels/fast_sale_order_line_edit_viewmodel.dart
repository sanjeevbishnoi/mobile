/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 1:25 PM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class FastSaleOrderLineEditViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("FastSaleOrderLineEditViewModel");
  FastSaleOrderLineEditViewModel({TposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  List<ResInventoryModel> _inventories;
  List<ResInventoryModel> get inventories => _inventories;
  FastSaleOrderLine _orderLine;
  FastSaleOrderLine get orderLine => _orderLine;

  Product _product;
  Product get product => _product;

  double _priceDiscount;
  double get priceDiscount => _priceDiscount;

  var _totalSubject = new BehaviorSubject<double>();
  var _priceDiscountSubject = new BehaviorSubject<double>();
  var _discountSubject = new BehaviorSubject<double>();
  var _discountFixSubject = new BehaviorSubject<double>();

  Stream<double> get totalStream => _totalSubject.stream;
  Stream<double> get priceDiscountStream => _priceDiscountSubject.stream;
  Stream<double> get discountStream => _discountSubject.stream;
  Stream<double> get discountFixStream => _discountFixSubject.stream;

  double get quantity => _orderLine.productUOMQty ?? 0;
  double get price => _orderLine.priceUnit ?? 0;
  double get discountPercent => _orderLine.discount ?? 0;
  double get discountFix => _orderLine.discountFixed ?? 0;
  double get total => _orderLine.priceTotal ?? 0;
  double get priceSubTotal => _orderLine.priceSubTotal ?? 0;
  String get orderLineNote => _orderLine.note;

  set quantity(double value) {
    _orderLine.productUOMQty = value;
    _calcTotal();
    onPropertyChanged("quantity");
  }

  set price(double value) {
    _orderLine.priceUnit = value;
    _calcTotal();
  }

  set discountPercent(double value) {
    _orderLine.discount = value;
    _calcTotal();
  }

  set discountFix(double value) {
    _orderLine.discountFixed = value;
    _calcTotal();
  }

  set total(double value) {
    _orderLine.priceTotal = value;
  }

  set priceSubTotal(double value) {
    _orderLine.priceSubTotal = value;
  }

  set orderLineNote(String value) {
    _orderLine.note = value;
  }

  void _calcTotal() {
    if (_isDiscountPercent) {
      _priceDiscount = (price * (100 - discountPercent) / 100);
    } else {
      _priceDiscount = (price - discountFix);
    }

    _priceDiscountSubject.add(_priceDiscount);

    _orderLine.calculateTotal();
    _totalSubject.add(total);
  }

  bool _isDiscountPercent = true;
  bool get isDiscountPercent => _isDiscountPercent;
  set isDiscountPercent(bool value) {
    double oldDiscountPercent = discountPercent;
    double oldDiscountFix = discountFix;
    _isDiscountPercent = value;
    _orderLine.type = value ? "percent" : "fixed";

    // Tính ngược lại
    if (value == true) {
      discountPercent = oldDiscountFix / price * 100;
    } else {
      discountFix = oldDiscountPercent / 100 * price;
    }
    _calcTotal();
    onPropertyChanged("isDiscountPercent");
  }

  void init(FastSaleOrderLine orderLine) {
    _orderLine = orderLine;
    _isDiscountPercent = orderLine.type == "percent";
    initCommand();
  }

  Future<void> initCommand() async {
    try {
      await _loadProductInfo();
      _calcTotal();
    } catch (e, s) {
      _log.severe("initCommand", e, s);
    }

    onPropertyChanged("");
  }

  /// Khi  thay đổi giảm giá bằng tiền hoặc phần  trăm
  Future<void> changeDiscountTypeCommand(bool isPercent) async {
    bool oldValue = _isDiscountPercent;
    double oldPercentValue = discountPercent;
    double oldDiscountFix = discountFix;
    _isDiscountPercent = isPercent;
    _orderLine.type = isPercent ? "percent" : "fixed";
    if (oldValue != isPercent) {
      if (!isPercent) {
        discountFix = price * oldPercentValue / 100;
        _discountFixSubject.add(discountFix);
      } else {
        discountPercent = oldDiscountFix / price * 100;
        _discountSubject.add(discountPercent);
      }
    }

    onPropertyChanged("");
  }

  Future<void> _loadProductInfo() async {
    var getProductResult =
        await _tposApi.getProductSearchById(_orderLine.productId);

    if (getProductResult.value != null) {
      this._product = getProductResult.value;
    } else {
      onDialogMessageAdd(OldDialogMessage.flashMessage(
          "Không  tải được thông tin sản phẩm. ${getProductResult.error.message}"));
    }
    // tồn kho
    var inventoryResult =
        await _tposApi.getProductInventoryById(tmplId: _orderLine.productId);
    this._inventories = inventoryResult?.value
        ?.where((f) => f.id == locator<IAppService>().selectedCompany?.id)
        ?.toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
