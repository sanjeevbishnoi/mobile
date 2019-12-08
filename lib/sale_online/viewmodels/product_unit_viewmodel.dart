/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';

import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/src/tpos_apis/models/productUOM.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class ProductUOMViewModel extends Model implements ViewModelBase {
  //log
  final log = new Logger("ProductUnitViewModel");
  ITposApiService _tposApi;
  ProductUOMViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  // List ProductUOM Category
  List<ProductUOM> _productUOM;
  List<ProductUOM> _tempProductUOM;
  List<ProductUOM> get productUOM => _productUOM;
  set productUOM(List<ProductUOM> value) {
    _productUOM = value;
    _productUOMController.add(_productUOM);
  }

  BehaviorSubject<List<ProductUOM>> _productUOMController =
      new BehaviorSubject();
  Stream<List<ProductUOM>> get productUOMStream => _productUOMController.stream;

  int uomCateogoryId;

  Future loadProductUOM() async {
    try {
      if (uomCateogoryId == null) {
        productUOM = await _tposApi.getProductUOM();
        _tempProductUOM = productUOM;
      } else {
        productUOM =
            await _tposApi.getProductUOM(uomCateogoryId: uomCateogoryId);
        _tempProductUOM = productUOM;
      }
    } catch (ex, stack) {
      log.severe("loadProductUOM fail", ex, stack);
      print(ex.toString());
    }
  }

  // Tìm kiếm
  Future<List<ProductUOM>> searchProductUOM(String keyword) async {
    if (keyword == null && keyword == "") {
      return productUOM = _tempProductUOM;
    }

    String key = (removeVietnameseMark(keyword));
    return productUOM = _tempProductUOM
        .where((f) => f.name != null
            ? removeVietnameseMark(f.name.toLowerCase())
                .contains(key.toLowerCase())
            : false)
        .toList();
  }

  Future init() async {
    await loadProductUOM();
    searchProductUOM("");
  }

  @override
  void dispose() {}
}
