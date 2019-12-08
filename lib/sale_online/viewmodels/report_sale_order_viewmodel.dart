import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/company_of_user.dart';
import 'package:tpos_mobile/src/tpos_apis/models/date_filter_template.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/report_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/user_report_staff.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

import '../../app_service_locator.dart';

class ReportSaleOrderViewModel extends ViewModel implements DataTableSource {
  ITposApiService _tposApi;
  Logger _log = new Logger("ReportSaleOrderViewModel");
  ReportSaleOrderViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  // top, skip trang tổng quan, chi tiết
  int topGeneral = 100;
  int skipGeneral = 0;
  int saleOrderGeneralLength = 0;

  int topSaleOrder = 100;
  int skipSaleOrder = 0;
  int saleOrderLength = 0;

  ReportSaleOrderGeneral reportSaleOrderGeneral;
  SumReportSaleGeneral sumReportSaleGeneral;
  SumAmountReportSale sumAmountReportSale;
  ReportSaleOrder reportSaleOrder;

  // init
  Future<void> initCommand() async {
    try {
      _initDateFilter();
      await getCompanyOfUser();
      await getUserReportStaff();
      if (companyOfUsers != null)
        this._selectedCompanyOfUser = companyOfUsers.first;
      if (userReportStaffs != null)
        this._selectedUserReportStaff = userReportStaffs.first;
      await filter();
    } catch (e, s) {
      _log.severe("init", e, s);
    }
  }

  // Lọc
  Future<void> filter() async {
    onStateAdd(true, message: "Đang tải");
    try {
      sumReportSaleGeneral = await _tposApi.getSumReportSaleGeneral(
          fromDate,
          toDate,
          selectedOrderType,
          selectedCompanyOfUser?.value,
          partner?.id,
          selectedUserReportStaff?.value);
      reportSaleOrderGeneral = await _tposApi.getReportSaleOrderGeneral(
          topGeneral,
          skipGeneral,
          fromDate,
          toDate,
          selectedOrderType,
          selectedCompanyOfUser?.value,
          partner?.id,
          selectedUserReportStaff?.value);
      sumAmountReportSale = await _tposApi.getSumAmountReportSale(
          fromDate,
          toDate,
          selectedOrderType,
          selectedCompanyOfUser?.value,
          partner?.id,
          selectedUserReportStaff?.value);
      reportSaleOrder = await _tposApi.getReportSaleOrder(
          topSaleOrder,
          skipSaleOrder,
          fromDate,
          toDate,
          selectedOrderType,
          selectedCompanyOfUser?.value,
          partner?.id,
          selectedUserReportStaff?.value);
      saleOrderGeneralLength = reportSaleOrderGeneral.odataCount;
      saleOrderLength = reportSaleOrder.odataCount;
      amountGeneralCKKM =
          sumReportSaleGeneral.totalCk + sumReportSaleGeneral.totalKM;
    } catch (e, s) {
      _log.severe("filter", e, s);
    }
    notifyListeners();
    onStateAdd(false);
  }

  // Load more tổng quan
  Future<void> loadMoreReportSaleOrderGeneral() async {
    if (saleOrderGeneralLength - (skipGeneral + topGeneral) < 100) {
      topGeneral = saleOrderGeneralLength - (skipGeneral + topGeneral);
      skipGeneral = saleOrderGeneralLength - topGeneral;
    } else {
      skipGeneral += 100;
    }

    onStateAdd(true, message: "Đang tải");
    var result = await _tposApi.getReportSaleOrderGeneral(
        topGeneral,
        skipGeneral,
        fromDate,
        toDate,
        selectedOrderType,
        selectedCompanyOfUser.value,
        partner.id,
        selectedUserReportStaff.value);
    if (result != null) reportSaleOrderGeneral.value.addAll(result.value);
    notifyListeners();
    onStateAdd(false);
  }

  bool get canLoadMore {
    if (skipGeneral + topGeneral == saleOrderGeneralLength) return false;
    return saleOrderGeneralLength > 100 && skipGeneral < saleOrderGeneralLength;
  }

  // Load more chi tiết
  Future<void> loadMoreReportSaleOrder() async {
    if (saleOrderLength - (skipSaleOrder + topSaleOrder) < 100) {
      topSaleOrder = saleOrderLength - (skipSaleOrder + topSaleOrder);
      skipSaleOrder = saleOrderLength - topSaleOrder;
    } else {
      skipSaleOrder += 100;
    }

    onStateAdd(true, message: "Đang tải");
    var result = await _tposApi.getReportSaleOrder(
        topSaleOrder,
        skipSaleOrder,
        fromDate,
        toDate,
        selectedOrderType,
        selectedCompanyOfUser.value,
        partner?.id,
        selectedUserReportStaff.value);
    if (result != null) reportSaleOrder.value.addAll(result.value);
    notifyListeners();
    onStateAdd(false);
  }

  bool get canLoadMoreSaleOrder {
    if (skipSaleOrder + topSaleOrder >= saleOrderLength) return false;
    return saleOrderLength > 100 && skipSaleOrder < saleOrderLength;
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
    topSaleOrder = 100;
    skipSaleOrder = 0;
    topGeneral = 100;
    skipGeneral = 0;
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
  List<Map<String, dynamic>> orderType = [
    {"name": "Tất cả", "value": null},
    {"name": "Điểm bán hàng", "value": "PostOrder"},
    {"name": "Bán hàng", "value": "FastSaleOrder"},
  ];
  String selectedOrderType;

  // get danh sách công ty
  List<CompanyOfUser> companyOfUsers = new List<CompanyOfUser>();
  CompanyOfUser _selectedCompanyOfUser;
  CompanyOfUser get selectedCompanyOfUser => _selectedCompanyOfUser;
  Future<void> getCompanyOfUser() async {
    companyOfUsers.add(new CompanyOfUser(text: "Tất cả", value: ""));
    var result = await _tposApi.getCompanyOfUser();
    companyOfUsers.addAll(result);
  }

  // Chọn lọc công ty
  void setCommandCompanyUser(CompanyOfUser value) {
    _selectedCompanyOfUser = value;
    notifyListeners();
  }

  // Chọn nhân viên bán hàng
  void setCommandUserReportStaff(UserReportStaff value) {
    _selectedUserReportStaff = value;
    notifyListeners();
  }

  // Chọn lọc khách hàng
  Partner partner = new Partner();
  void selectPartnerCommand(Partner value) {
    partner?.id = value.id;
    partner?.name = value.name;
    notifyListeners();
  }

  // Chọn nhân viên bán hàng
  List<UserReportStaff> userReportStaffs = new List<UserReportStaff>();
  UserReportStaff _selectedUserReportStaff;
  UserReportStaff get selectedUserReportStaff => _selectedUserReportStaff;
  Future<void> getUserReportStaff() async {
    userReportStaffs.add(new UserReportStaff(text: "Tất cả", value: ""));
    var result = await _tposApi.getUserReportStaff();
    userReportStaffs.addAll(result);
  }

  // Đếm lọc
//  int filterCount = 0;
  get filterCount {
    int filterCount = 0;
    if (fromDate != null && toDate != null) {
      filterCount = 1;
    }
    if (selectedOrderType != null) {
      filterCount += 1;
    }
    if (selectedUserReportStaff != null &&
        selectedUserReportStaff != userReportStaffs.first) {
      filterCount += 1;
    }
    if (selectedCompanyOfUser != null &&
        selectedCompanyOfUser != companyOfUsers.first) {
      filterCount += 1;
    }
    if (partner?.id != null) {
      filterCount += 1;
    }
    return filterCount;
  }

  void removeFilter() {
    selectedFilterByDate = filterByDates.last;
    fromDate = toDate = selectedOrderType = null;
    _selectedCompanyOfUser = companyOfUsers.first;
    _selectedUserReportStaff = userReportStaffs.first;
    partner = new Partner();
    notifyListeners();
  }

  double amountGeneralCKKM;

  //searchKeyword
/*  String _keyword;
  String get keyword => _keyword;
  BehaviorSubject<String> _keywordController = new BehaviorSubject();
  void onKeywordAdd(String value) {
    _keyword = value;
    if (_keywordController.isClosed == false) {
      _keywordController.add(_keyword);
    }
  }

  Future<void> searchOrderCommand(String keyword) async {
    onKeywordAdd(keyword);
  }*/

  int sortColumnIndex;
  bool sortAscending = true;

  void sortDetail<T>(Comparable<T> getField(ReportSaleOrderInfo d),
      int columnIndex, bool ascending) {
    reportSaleOrder.value.sort((ReportSaleOrderInfo a, ReportSaleOrderInfo b) {
      if (!ascending) {
        final ReportSaleOrderInfo c = a;
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

  void sortGeneral<T>(Comparable<T> getField(ReportSaleOrderGeneralInfo d),
      bool ascending, int columnIndex) {
    reportSaleOrderGeneral.value
        .sort((ReportSaleOrderGeneralInfo a, ReportSaleOrderGeneralInfo b) {
      if (!ascending) {
        final ReportSaleOrderGeneralInfo c = a;
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

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= reportSaleOrder.value.length) return null;
    ReportSaleOrderInfo order = reportSaleOrder.value[index];
    return DataRow.byIndex(
      index: index,
//      selected: order.selected,
//      onSelectChanged: (bool value) {
//        if (order.selected != value) {
//          _selectedCount += value ? 1 : -1;
//          assert(_selectedCount >= 0);
//          order.selected = value;
//          notifyListeners();
//        }
//      },
      cells: <DataCell>[
        DataCell(Text('${order.name ?? ''}')),
        DataCell(Text('${order.partnerDisplayName ?? ''}')),
        DataCell(Text('${order.userName ?? ''}')),
        DataCell(Text('${vietnameseCurrencyFormat(order.amountTotal)}')),
        DataCell(
            Text('${DateFormat("dd/MM/yyyy HH:mm").format(order.dateOrder)}')),
        DataCell(Text('${order.nameTypeOrder ?? ''}')),
        DataCell(Text('${order.showState ?? ''}')),
        DataCell(Text('${order.note ?? ''}')),
      ],
    );
  }

  @override
  int get rowCount => reportSaleOrder.odataCount;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  @override
  // TODO: implement hasListeners
  bool get hasListeners => null;
}
