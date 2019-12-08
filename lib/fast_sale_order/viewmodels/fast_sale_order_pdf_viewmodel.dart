import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class FastSaleOrderPDFViewModel extends ViewModel implements ViewModelBase {
  Logger _log = new Logger("FastSaleOrderPDFViewModel");
  ITposApiService _tposApi;

  FastSaleOrderPDFViewModel({TposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  FastSaleOrder _order;
  FastSaleOrder get order => _order;

  set order(FastSaleOrder value) {
    order = value;
  }

  Future<FastSaleOrder> refreshFastSaleOrderInfo(int id) async {
    _order = await _tposApi.getFastSaleOrderForPDF(id);
//    var first = _order.orderLines.first;
//    _order.orderLines.addAll(List.generate(90, (i) => first));
    return order;
  }

  get totalQuantity {
    double totalQuantity = 0;
    for (var f in order.orderLines) {
      totalQuantity = totalQuantity + f.productUOMQty;
    }
    return totalQuantity.toInt();
  }

  Future<String> getBarcodeTrackingRef() async {
    String url;
    if (order.carrierId == 1) {
      url = await _tposApi.getBarcodeShip(order.trackingRef.substring(15));
    } else {
      url = await _tposApi.getBarcodeShip(order.trackingRef);
    }
    return url;
  }

  Future<String> getBarcodeTrackingRefSort() async {
    var url = await _tposApi.getBarcodeShip(order.trackingRefSort);
    return url;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
