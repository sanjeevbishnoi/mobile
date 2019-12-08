/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 2:18 PM
 *
 */

import 'dart:async';

import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';

class SaleOnlineOrderLineEditViewModel extends ViewModel {
  SaleOnlineOrderLineEditViewModel();
  SaleOnlineOrderDetail _orderLine;
  SaleOnlineOrderDetail get orderLine => _orderLine;

  Future<void> init(SaleOnlineOrderDetail orderLine) async {
    _orderLine = orderLine;
  }

  double subTotal;
  double total;
  @override
  void dispose() {
    super.dispose();
  }
}
