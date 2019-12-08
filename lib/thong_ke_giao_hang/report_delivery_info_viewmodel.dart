import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery.dart';

class ReportDeliveryInfoViewModel extends ViewModel implements ViewModelBase {
  //log
  final _log = new Logger("ReportDeliveryInfoViewModel");

  ITposApiService _tposApi;
  ReportDeliveryInfoViewModel(
      {ISettingService settingService, ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  ReportDeliveryInfo reportDeliveryInfo;

  List<ReportDeliveryOrderLine> reportDeliveryOrderLines;

  Future _loadSaleOrderInfo(int id) async {
    onStateAdd(true, message: "Đang tải");
    reportDeliveryOrderLines = await _tposApi.getReportDeliveryOrderDetail(id);
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
