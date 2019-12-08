import 'dart:async';

import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/src/tpos_apis/models/report_order.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class ReportSaleOrderInfoViewModel extends ViewModel implements ViewModelBase {
  ITposApiService _tposApi;
  ReportSaleOrderInfoViewModel(
      {ISettingService settingService, ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  ReportSaleOrderInfo reportSaleOrderInfo;

  List<ReportSaleOrderLine> fastSaleOrderLines;

  Future _loadSaleOrderInfo(int id) async {
    onStateAdd(true, message: "Đang tải");
    fastSaleOrderLines = await _tposApi.getReportSaleOrderDetail(id);
    notifyListeners();
    onStateAdd(false);
  }

  Future<void> initCommand(int id) async {
    await _loadSaleOrderInfo(id);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
