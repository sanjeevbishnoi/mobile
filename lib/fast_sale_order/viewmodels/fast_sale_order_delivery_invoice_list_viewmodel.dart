/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 8:41 AM
 *
 */

import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_core/template_models/app_filter_date_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/date_filter_template.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_sort.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/fast_sale_order_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

class FastSaleDeliveryInvoiceViewModel extends ViewModel
    implements ViewModelBase {
  //log
  final _log = new Logger("FastSaleDeliveryInvoiceViewModel");
  ITposApiService _tposApi;
  IFastSaleOrderApi _fastSaleOrderApi;
  PrintService _print;
  DialogService _dialog;

  FastSaleDeliveryInvoiceViewModel(
      {ITposApiService tposApi,
      PrintService print,
      DialogService dialog,
      IFastSaleOrderApi fastSaleOrderApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _print = print ?? locator<PrintService>();
    _dialog = dialog ?? locator<DialogService>();
    _fastSaleOrderApi = fastSaleOrderApi ?? locator<IFastSaleOrderApi>();
    // handled search
    _keywordController
        .debounceTime(new Duration(milliseconds: 300))
        .listen((key) {
      onSearchingOrderHandled(key);
    });
  }

  /// Có đang cho phép chọn nhiều hóa đơn hay không
  bool _isSelectEnable = false;
  int _listCount = 0;
  bool _isLoadingMore = false;
  String _lastFilterDescription = "";

  bool get isSelectEnable => _isSelectEnable;
  bool get isSelectAll {
    return !_fastSaleDeliveryInvoices.any((f) => f.isSelected == false);
  }

  bool get isLoadingMore => _isLoadingMore;
  int get listCount => _listCount;
  int get filterCount {
    int count = 0;
    if (_isFilterByDate) count += 1;
    if (_isFilterByStatus) count += 1;
    return count;
  }

  String get dataNotifyString {
    String filterString = "";

    if (filterCount > 0 && orderCount == 0 ||
        (_keyword != null && _keyword != "")) {
      filterString +=
          "\nKhông có kết quả nào phù hợp với điều kiện lọc \n${_lastFilterDescription}";
    }
    return filterString;
  }

  set isSelectEnable(bool value) {
    _isSelectEnable = value;
    notifyListeners();
  }

  set isSelectAll(bool value) {
    if (value) {
      for (var value in _fastSaleDeliveryInvoices) {
        value.isSelected = true;
      }
    } else {
      for (var value in _fastSaleDeliveryInvoices) {
        value.isSelected = false;
      }
    }
    notifyListeners();
  }

  int get selectedCount =>
      _fastSaleDeliveryInvoices?.where((f) => f.isSelected)?.length ?? 0;
  int get orderCount => _fastSaleDeliveryInvoices?.length ?? 0;
  bool get canLoadMore => this.orderCount < _listCount;

  /* FILTER - ĐIỀU KIỆN LỌC */
  bool _isFilterByDate = true;
  bool _isFilterByStatus = false;
  DateTime _filterFromDate;
  DateTime _filterToDate;
  DeliveryStatusReport _filterStatus; // Trạng thái
  AppFilterDateModel _filterDateRange; // Khoảng thời gian

  bool get isFilterByDate => _isFilterByDate;
  bool get isFilterByStatus => _isFilterByStatus;
  DateTime get filterFromDate => _filterFromDate;
  DateTime get filterToDate => _filterToDate;
  DeliveryStatusReport get filterStatus => _filterStatus;
  AppFilterDateModel get filterDateRange => _filterDateRange;

  set isFilterByDate(bool value) {
    _isFilterByDate = value;
    notifyListeners();
  }

  set isFilterByStatus(bool value) {
    _isFilterByStatus = value;
    notifyListeners();
  }

  set fromDate(DateTime value) {
    _filterFromDate = value;
    onPropertyChanged("");
  }

  set toDate(DateTime value) {
    _filterToDate = value;
    onPropertyChanged("");
  }

  set status(DeliveryStatusReport value) {
    _filterStatus = value;
    notifyListeners();
  }

  set filterDateRange(AppFilterDateModel value) {
    if (value != _filterDateRange) {
      _filterDateRange = value;
      _filterFromDate = value.fromDate;
      _filterToDate = value.toDate;
      notifyListeners();
    }
  }

  /// Reset phân trang
  void _resetPaging() {
    _skip = 0;
    _page = 1;
  }

  ///Reset điều kiện lọc
  Future<void> resetFilter() {
    _isFilterByDate = true;
    _isFilterByStatus = false;
    notifyListeners();
  }

  /// Chấp nhận điều kiện lọc
  Future<void> applyFilter() async {
    try {
      onStateAdd(true, message: "Đang tải...");

      _resetPaging();
      await _loadFastSaleOrder();
      notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(error: e);
    }
    onStateAdd(false, message: "Đang tải...");
  }

  Future<void> loadMoreItem() async {
    try {
      this._isLoadingMore = true;
      notifyListeners();
      await _loadFastSaleOrder();
      notifyListeners();
    } catch (e, s) {
      _log.severe("", e, s);
      _dialog.showNotify(
          message: e.toString(),
          showOnTop: true,
          type: DialogType.NOTIFY_ERROR);
    }

    this._isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadAllMoreItem() async {
    while (canLoadMore) {
      await this.loadMoreItem();
    }
  }

  /* END FILTER */

  //FastSaleOrder
  List<FastSaleOrder> _fastSaleDeliveryInvoices;
  List<FastSaleOrder> get fastSaleDeliveryInvoices => _fastSaleDeliveryInvoices;

  List<DeliveryStatusReport> _deliveryStatus;

  List<DeliveryStatusReport> get deliveryStatus => _deliveryStatus;

  Future<void> onSearchingOrderHandled(String keyword) async {
    _keyword = keyword;

    await _loadFastSaleOrder(resetPaging: true);
    notifyListeners();

//    if (keyword == null && keyword == "") {
//      _fastSaleDeliveryInvoices = tempFastSaleDeliveryInvoices;
//      return;
//    }
//    try {
//      String key = (removeVietnameseMark(keyword));
//      var fastSaleDeliveryInvoices = tempFastSaleDeliveryInvoices
//          .where((f) => f.partnerNameNoSign != null
//              ? removeVietnameseMark(f.partnerNameNoSign.toLowerCase())
//                      .contains(key.toLowerCase()) ||
//                  f.number
//                      .toString()
//                      .toLowerCase()
//                      .contains(key.toLowerCase()) ||
//                  f.partnerPhone
//                      .toString()
//                      .toLowerCase()
//                      .contains(key.toLowerCase())
//              : false)
//          .toList();
//
//      this._fastSaleDeliveryInvoices = fastSaleDeliveryInvoices;
//    } catch (ex) {
//      onDialogMessageAdd(new OldDialogMessage.error("", ex.toString()));
//    }
  }

//Load fast sale order
  FastSaleOrderSort fastSaleDeliveryInvoiceSort =
      new FastSaleOrderSort(1, "", "desc", "DateInvoice");

  void selectSoftCommand(String orderBy) {
    if (fastSaleDeliveryInvoiceSort.orderBy != orderBy) {
      fastSaleDeliveryInvoiceSort.orderBy = orderBy;
      fastSaleDeliveryInvoiceSort.value = "desc";
    } else {
      fastSaleDeliveryInvoiceSort.value =
          fastSaleDeliveryInvoiceSort.value == "desc" ? "asc" : "desc";
    }

    initData();
  }

  double totalAmount = 0.0;
  final _take = 100;
  int get take => _take;
  int _skip = 0;
  int _page = 1;
  final _pageSize = 100;
  var _sort = new List<Map>();
  Map _filter;

  /// Lấy danh sách hóa đơn
  Future _loadFastSaleOrder({bool resetPaging = false}) async {
    if (resetPaging) _resetPaging();
    _sort = [
      {
        "field": fastSaleDeliveryInvoiceSort.orderBy,
        "dir": fastSaleDeliveryInvoiceSort.value
      },
    ];

    // Tất cả điều kiện lọc
    var filterList = new List<Map>();
    filterList.add({"field": "Type", "operator": "eq", "value": "invoice"});

    if (_isFilterByDate && filterFromDate != null) {
      filterList.add({
        "field": "DateInvoice",
        "operator": "gte",
        "value": DateFormat("yyyy-MM-ddTHH:mm:ss").format(filterFromDate),
      });
    }

    if (_isFilterByDate && filterToDate != null) {
      filterList.add({
        "field": "DateInvoice",
        "operator": "lte",
        "value": DateFormat("yyyy-MM-ddTHH:mm:ss").format(filterToDate),
      });
    }

    if (_isFilterByStatus && _filterStatus != null) {
      filterList.add({
        "field": "ShipPaymentStatus",
        "operator": "eq",
        "value": _filterStatus.value,
      });
    }

    if (keyword != null && keyword.isNotEmpty) {
      filterList.add(
        {
          "logic": "or",
          "filters": [
            {
              "field": "PartnerDisplayName",
              "operator": "contains",
              "value": "$_keyword"
            },
            {
              "field": "PartnerNameNoSign",
              "operator": "contains",
              "value": "${removeVietnameseMark(_keyword.toLowerCase())}"
            },
            {"field": "Phone", "operator": "contains", "value": "$_keyword"},
            {"field": "Number", "operator": "contains", "value": "$_keyword"}
          ]
        },
      );
    }

    // Điều kiện lọc
    _filter = {
      "logic": "and",
      "filters": filterList,
    };

    _lastFilterDescription = "";
    // build filter note
    if (_keyword != null && _keyword != "") {
      _lastFilterDescription = "- Theo tìm kiếm từ khóa: $_keyword";
    }

    if (_isFilterByDate && _filterFromDate != null && _filterToDate != null) {
      _lastFilterDescription +=
          "\n- Theo thời gian từ ${DateFormat("dd/MM/yyyy  HH:mm").format(_filterFromDate)} tới ${DateFormat("dd/MM/yyyy HH:mm").format(_filterToDate)}";
    }
    if (_isFilterByStatus) {
      _lastFilterDescription += "\n";
      _lastFilterDescription +=
          "- Theo trạng thái đơn hàng: ${_filterStatus?.name}";
    }

    try {
      var result = await _fastSaleOrderApi.getDeliveryInvoices(
        sort: _sort,
        filter: _filter,
        take: _take,
        skip: _skip,
        page: _pageSize,
      );

      if (_skip == 0) {
        _fastSaleDeliveryInvoices = result.data;
      } else {
        _fastSaleDeliveryInvoices.addAll(result.data);
      }
      _listCount = result.count ?? 0;
      _skip = orderCount;

      DateTime statusFromDate = _filterFromDate;
      DateTime statusToDate = _filterToDate;

      if (!_isFilterByDate ||
          _filterFromDate == null && _fastSaleDeliveryInvoices.length > 0) {
        statusFromDate = new DateTime(2017, 1, 1);
      }

      if (!_isFilterByDate ||
          _filterToDate == null && _fastSaleDeliveryInvoices.length > 0) {
        statusToDate = DateTime.now();
      }

      _deliveryStatus = await _tposApi.getFastSaleOrderDeliveryStatusReports(
          startDate: statusFromDate, endDate: statusToDate);

      // Get total amount
      if (_deliveryStatus != null && _deliveryStatus.length > 0) {
        totalAmount =
            (_deliveryStatus.map((f) => f.totalAmount).reduce((a, b) => a + b))
                .toDouble();
      }
    } on SocketException catch (e, s) {
      _log.severe("", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", "Không có kết nối mạng"));
    } catch (e, s) {
      onIsBusyAdd(false);
      _dialog.showError(error: e, isRetry: true).then((result) {
        if (result.type == DialogResultType.RETRY)
          this.initData();
        else if (result.type == DialogResultType.GOBACK)
          onEventAdd("GO_BACK", null);
      });
      _log.severe("", e, s);
    }
  }

  //searchKeyword
  String _keyword;
  String get keyword => _keyword;
  BehaviorSubject<String> _keywordController = new BehaviorSubject();
  void onKeywordAdd(String value) {
    _keyword = value;
    if (_keywordController.isClosed == false) {
      _keywordController.add(_keyword);
    }
  }

  // Search
  Future<void> searchOrderCommand(String keyword) async {
    onKeywordAdd(keyword);
  }

  /// Khởi tạo giá trị và nhận param khi view được tạo
  Future init() {
    filterDateRange = AppFilterDateModel.thisMonth();
  }

  /// Lấy các giá trị và dữ liệu khi view được mở
  Future initData() async {
    _resetPaging();
    onStateAdd(true, message: "Đang tải...");
    await _loadFastSaleOrder();
    onStateAdd(false);
    notifyListeners();
  }

  Future printShipOrderCommand(int orderId, [int carrierId]) async {
    try {
      onStateAdd(true);
      await _print.printFastSaleOrderShip(
        fastSaleOrderId: orderId,
        carrierId: carrierId,
      );
    } catch (e, s) {
      _log.severe("Print ship", e, s);
      onDialogMessageAdd(OldDialogMessage.error(
          "Không in được phiếu ", e.toString(),
          error: e));
    }
    onStateAdd(false);
  }

  Future printInvoiceCommand(int orderId) async {
    try {
      onStateAdd(true, message: "Đang in...");
      await _print.printFastSaleOrderInvoice(
        orderId,
      );
    } catch (e, s) {
      onDialogMessageAdd(OldDialogMessage.error("", e.toString()));
      _log.severe("", e, s);
    }
    onStateAdd(false);
  }

  /// Cập nhật trạng thái giao hàng tất cả hóa đơn
  Future<void> updateDeliveryState() async {
    try {
      onStateAdd(true, message: "Đang cập nhật...");
      await _tposApi.refreshFastSaleOnlineOrderDeliveryState();
    } catch (e, s) {
      _log.severe("", e, s);
      _dialog.showError(error: e);
    }
    onStateAdd(false, message: "Đang cập nhật...");
  }

  /// Hủy bỏ một hoặc nhiều phiếu ship
  Future<void> cancelShips(List<FastSaleOrder> items) async {
    var selectedItem =
        _fastSaleDeliveryInvoices.where((f) => f.isSelected).toList();

    if (selectedItem == null && selectedItem.length == 0) {
      _dialog.showNotify(message: "Vui lòng chọn một hoặc nhiều hóa đơn");
    }

    for (var itm in selectedItem) {
      try {
        onStateAdd(true, message: "Đang hủy ${itm.trackingRef ?? "N/A"}");
        await _tposApi.fastSaleOrderCancelShip(itm.id);
        _loadFastSaleOrder();
      } catch (e, s) {
        _log.severe("Hủy vận đơn", e, s);
        _dialog.showNotify(message: e.toString());
      }
    }

    onStateAdd(false);
    notifyListeners();
  }

  /// Hủy bỏ một hoặc nhiều hóa đơn
  Future<void> canncelInvoices(List<FastSaleOrder> items) async {
    var selectedItem =
        _fastSaleDeliveryInvoices.where((f) => f.isSelected).toList();

    if (selectedItem == null && selectedItem.length == 0) {
      _dialog.showNotify(message: "Vui lòng chọn một hoặc nhiều hóa đơn");
      return;
    }

    try {
      onStateAdd(true, message: "Đang hủy...");
      await _tposApi
          .fastSaleOrderCancelOrder(selectedItem.map((f) => f.id).toList());
      await _loadFastSaleOrder(resetPaging: true);
      _dialog.showNotify(
        message: "Đã hủy hóa đơn",
      );
    } catch (e, s) {
      _log.severe("Hủy vận đơn", e, s);
      _dialog.showNotify(message: e.toString());
    }

    onStateAdd(false);
    notifyListeners();
  }

  /// Hủy bỏ một hoặc nhiều hóa đơn
  Future<void> updateDeliveryInfo(List<FastSaleOrder> items) async {
    onStateAdd(true);
    var selectedItem =
        _fastSaleDeliveryInvoices.where((f) => f.isSelected).toList();

    if (selectedItem == null && selectedItem.length == 0) {
      _dialog.showNotify(message: "Vui lòng chọn một hoặc nhiều hóa đơn");
      return;
    }

    try {
      await _tposApi.refreshFastSaleOrderDeliveryState(
          selectedItem.map((f) => f.id).toList());
      _loadFastSaleOrder();
    } catch (e, s) {
      _log.severe("Hủy vận đơn", e, s);
      _dialog.showNotify(message: e.toString());
    }

    onStateAdd(false);
  }

  Future<void> printOrders() async {
    var selectedItem =
        _fastSaleDeliveryInvoices.where((f) => f.isSelected).toList();

    if (selectedItem == null && selectedItem.length == 0) {
      _dialog.showNotify(message: "Vui lòng chọn một hoặc nhiều hóa đơn");
      return;
    }

    for (var itm in selectedItem) {
      try {
        onStateAdd(true, message: "Đang in ${itm.number ?? "N/A"}");
        await _print.printFastSaleOrderInvoice(itm.id);
        Future.delayed(Duration(seconds: 1));
      } catch (e, s) {
        _log.severe("Hủy vận đơn", e, s);
        _dialog.showNotify(message: e.toString());
      }
    }

    onStateAdd(false);
  }

  Future<void> printShips() async {
    var selectedItem =
        _fastSaleDeliveryInvoices.where((f) => f.isSelected).toList();

    if (selectedItem == null && selectedItem.length == 0) {
      _dialog.showNotify(message: "Vui lòng chọn một hoặc nhiều hóa đơn");
      return;
    }

    for (var itm in selectedItem) {
      try {
        onStateAdd(true, message: "Đang in ${itm.number ?? "N/A"}");
        await _print.printFastSaleOrderShip(fastSaleOrderId: itm.id);
        await Future.delayed(Duration(seconds: 1));
      } catch (e, s) {
        _log.severe("Hủy vận đơn", e, s);
        _dialog.showNotify(message: e.toString());
      }
    }

    onStateAdd(false);
  }

  @override
  void dispose() {
    _keywordController.close();
    super.dispose();
  }
}
