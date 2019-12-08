import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/date_filter_template.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery.dart';

import '../app_service_locator.dart';

class ReportDeliveryViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("ReportDeliveryViewModel");
  ReportDeliveryViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  // take, skip
  int take = 100;
  int skip = 0;
  int reportDeliveryLength = 0;

  ReportDelivery reportDelivery;
  SumDeliveryReport sumDeliveryReport;

  // init
  Future<void> initCommand() async {
    try {
      _initDateFilter();
      await getDeliveryCarrier();
      selectedDeliveryCarrier = deliveryCarriers.first;
      await filter();
    } catch (e, s) {
      _log.severe("init", e, s);
    }
  }

  // Lọc
  Future<void> filter() async {
    onStateAdd(true, message: "Đang tải");
    try {
      sumDeliveryReport = await _tposApi.getReportSumDelivery(fromDate, toDate,
          selectedShipState, partner?.id, selectedDeliveryCarrier?.id);
      reportDelivery = await _tposApi.getReportDelivery(take, skip, fromDate,
          toDate, selectedShipState, partner?.id, selectedDeliveryCarrier?.id);
    } catch (e, s) {
      _log.severe("filter", e, s);
    }
    notifyListeners();
    onStateAdd(false);
  }

  // Load more
  Future<void> loadMoreReportDelivery() async {
    if (reportDeliveryLength - (skip + take) < 100) {
      take = reportDeliveryLength - (skip + take);
      skip = reportDeliveryLength - take;
    } else {
      skip += 100;
    }

    onStateAdd(true, message: "Đang tải");
    var result = await _tposApi.getReportDelivery(take, skip, fromDate, toDate,
        selectedShipState, partner?.id, selectedDeliveryCarrier.id);
    if (result != null) reportDelivery.data.addAll(result.data);
    notifyListeners();
    onStateAdd(false);
  }

  bool get canLoadMore {
    if (skip + take >= reportDeliveryLength) return false;
    return reportDeliveryLength > 100 && skip < reportDeliveryLength;
  }

  // Lọc theo ngày
  List<DateFilterTemplate> filterByDates;
  DateFilterTemplate selectedFilterByDate;
  DateTime fromDate;
  DateTime toDate;

  void _initDateFilter() {
    filterByDates = new List<DateFilterTemplate>();
// HÔM NAY
    filterByDates.add(
      new DateFilterTemplate(
        name: "Hôm nay ",
        fromDate: new DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 0, 0, 0),
        toDate: new DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 23, 59, 59, 99, 999),
      ),
    );
// HÔM QUA
    toDate = new DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
      59,
      999,
    ).add(Duration(days: -1));

    fromDate = toDate.add(new Duration(days: -1)).add(new Duration(
          milliseconds: 1,
        ));
    filterByDates.add(
      new DateFilterTemplate(
        name: "Hôm qua ",
        toDate: toDate,
        fromDate: fromDate,
      ),
    );
// 7 NGÀY GẦN NHẤT
    toDate = new DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
      59,
      999,
    );

    fromDate =
        toDate.add(new Duration(days: -7)).add(new Duration(milliseconds: 1));
    filterByDates.add(
      new DateFilterTemplate(
        name: "7 ngày gần nhất ",
        toDate: toDate,
        fromDate: fromDate,
      ),
    );

    // 30 NGÀY GẦN NHẤT
    toDate = new DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
      59,
      999,
    );

    fromDate =
        toDate.add(new Duration(days: -30)).add(new Duration(milliseconds: 1));
    filterByDates.add(
      new DateFilterTemplate(
        name: "30 ngày gần nhất ",
        toDate: toDate,
        fromDate: fromDate,
      ),
    );
    // Tất cả
    filterByDates.add(
      new DateFilterTemplate(
        name: "Toàn thời gian",
        toDate: null,
        fromDate: null,
      ),
    );
    selectedFilterByDate = filterByDates.first;
    fromDate = selectedFilterByDate.fromDate;
    toDate = selectedFilterByDate.toDate;
  }

  void selectFilterByDateCommand(DateFilterTemplate date) {
    take = 100;
    skip = 0;
    selectedFilterByDate = date;
    fromDate = date.fromDate;
    toDate = date.toDate;
    notifyListeners();
  }

  Future<void> updateFromDateCommand(DateTime date) async {
    fromDate = date;
    notifyListeners();
  }

  Future<void> updateFromDateTimeCommand(TimeOfDay time) async {
    if (fromDate != null)
      fromDate = new DateTime(
          fromDate.year, fromDate.month, fromDate.day, time.hour, time.minute);
    notifyListeners();
  }

  Future<void> updateToDateCommand(DateTime date) async {
    this.toDate = date;
    notifyListeners();
  }

  Future<void> updateToDateTimeCommand(TimeOfDay time) async {
    if (toDate != null)
      toDate = new DateTime(
          toDate.year, toDate.month, toDate.day, time.hour, time.minute);
    notifyListeners();
  }

  // Chọn loại hóa đơn
  List<Map<String, dynamic>> shipState = [
    {"name": "Tất cả", "value": null},
    {"name": "Đã tiếp nhận", "value": "sent"},
    {"name": "Đã thu tiền", "value": "done"},
    {"name": "Hàng trả về", "value": "refund"},
  ];
  String selectedShipState;

  // get danh sách đối tác giao hàng
  List<DeliveryCarrier> deliveryCarriers = new List<DeliveryCarrier>();
  DeliveryCarrier _selectedDeliveryCarrier;
  DeliveryCarrier get selectedDeliveryCarrier => _selectedDeliveryCarrier;
  set selectedDeliveryCarrier(DeliveryCarrier value) {
    _selectedDeliveryCarrier = value;
  }

  Future<void> getDeliveryCarrier() async {
    deliveryCarriers
        .add(new DeliveryCarrier(name: "Tất cả", deliveryType: null));
    var result = await _tposApi.getDeliveryCarriers();
    deliveryCarriers.addAll(result);
  }

  // Chọn lọc đối tác giao hàng
  void setCommandDeliveryCarrier(DeliveryCarrier value) {
    _selectedDeliveryCarrier = value;
    notifyListeners();
  }

  // Chọn lọc khách hàng
  Partner partner = new Partner();
  void selectPartnerCommand(Partner value) {
    partner?.id = value.id;
    partner?.name = value.name;
    notifyListeners();
  }

  // Đếm lọc
//  int filterCount = 0;
  get filterCount {
    int filterCount = 0;
    if (fromDate != null && toDate != null) {
      filterCount = 1;
    }
    if (selectedShipState != null) {
      filterCount += 1;
    }
    if (selectedDeliveryCarrier != null &&
        selectedDeliveryCarrier != deliveryCarriers.first) {
      filterCount += 1;
    }
    if (partner?.id != null) {
      filterCount += 1;
    }
    return filterCount;
  }

  void removeFilter() {
    selectedFilterByDate = filterByDates.last;
    fromDate = toDate = selectedShipState = null;
    partner = new Partner();
    notifyListeners();
  }

  int sortColumnIndex;
  bool sortAscending = true;
  void sortGeneral<T>(Comparable<T> getField(ReportDeliveryInfo d),
      bool ascending, int columnIndex) {
    reportDelivery.data.sort((ReportDeliveryInfo a, ReportDeliveryInfo b) {
      if (!ascending) {
        final ReportDeliveryInfo c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    sortColumnIndex = columnIndex;
    sortAscending = ascending;
    notifyListeners();
  }
}
