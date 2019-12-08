import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_core/helper/app_filter_helper.dart';
import 'package:tpos_mobile/app_core/template_models/app_filter_date_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/pos_order.dart';
import 'package:tpos_mobile/pos_order/pos_order_state.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/odata_filter.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class PosOrderListViewModel extends ViewModelBase {
  ITposApiService _tposApi;
  DialogService _dialog;

  PosOrderListViewModel(
      {ITposApiService tposApiService, DialogService dialogService}) {
    _tposApi = tposApiService ?? locator<ITposApiService>();
    _dialog = dialogService ?? locator<DialogService>();

    filterToDate = _filterDateRange.toDate;
    filterFromDate = _filterDateRange.fromDate;

    _keywordController
        .debounceTime(Duration(milliseconds: 500))
        .switchMap((keyword) async* {
      yield await loadPosOrders();
    }).listen((posOrders) {
      notifyListeners();
    });
  }

  List<PosOrder> _posOrders;

  List<PosOrder> get posOrders => _posOrders;

  set posOrders(List<PosOrder> value) {
    _posOrders = value;
    notifyListeners();
  }

  String _keyword = "";

  String get keyword => _keyword;
  BehaviorSubject<String> _keywordController = new BehaviorSubject();

  Future<void> setKeyword(String value) async {
    _keyword = value;
    _keywordController.add(value);
  }

  static const int take = 1000;
  int skip = 0;
  int max = 0;
  int _currentPage = 0;

  // XỬ LÝ LỌC

  bool _isFilterByDate = true;
  bool _isFilterByStatus = false;

  bool get isFilterByStatus => _isFilterByStatus;

  set isFilterByStatus(bool value) {
    _isFilterByStatus = value;
    notifyListeners();
  }

  AppFilterDateModel _filterDateRange = getTodayDateFilter();

  AppFilterDateModel get filterDateRange => _filterDateRange;

  set filterDateRange(AppFilterDateModel value) {
    _filterDateRange = value;
    notifyListeners();
  }

  // Lọc theo ngày
  bool get isFilterByDate => _isFilterByDate;

  set isFilterByDate(bool value) {
    _isFilterByDate = value;
    notifyListeners();
  }

  DateTime _filterFromDate;
  DateTime _filterToDate;

  DateTime get filterFromDate => _filterFromDate;

  DateTime get filterToDate => _filterToDate;

  set filterToDate(DateTime value) {
    _filterToDate = value;
    notifyListeners();
  }

  set filterFromDate(DateTime value) {
    _filterFromDate = value;
    notifyListeners();
  }

  List<PosOrderSateOption> _filterStatusList = PosOrderSateOption.options;

  List<PosOrderSateOption> get filterStatusList => _filterStatusList;

  set filterStatusList(List<PosOrderSateOption> value) {
    _filterStatusList = value;
    notifyListeners();
  }

  int get filterCount {
    int value = 0;
    if (_isFilterByDate) value += 1;
    if (_isFilterByStatus) value += 1;
    return value;
  }

  // Reset filter
  void resetFilter() {
    _isFilterByDate = false;
    _isFilterByStatus = false;
    notifyListeners();
  }

  String get filterByStatusString {
    var selectedStatus = _filterStatusList.where((f) => f.isSelected).toList();
    if (selectedStatus != null && selectedStatus.length > 0) {
      if (selectedStatus.length == 1)
        return selectedStatus.first.description;
      else {
        return "${selectedStatus.first.description} + ${selectedStatus.length - 1} khác";
      }
    }
    return null;
  }

  OdataFilter get filter {
    List<FilterBase> filterItems = new List<FilterBase>();

    // Theo trạng thái
    if (_isFilterByStatus) {
      var selectedStatus =
          _filterStatusList?.where((f) => f.isSelected == true)?.toList();
      if (selectedStatus != null && selectedStatus.length > 0) {
        filterItems.add(
          OdataFilter(
            logic: "or",
            filters: selectedStatus
                .map(
                  (f) => OdataFilterItem(
                      operator: "eq", field: "State", value: f.state),
                )
                .toList(),
          ),
        );
      }
    }

    // Theo ngày
    if (_isFilterByDate && _filterFromDate != null && _filterToDate != null) {
      filterItems.add(new OdataFilterItem(
          field: "DateCreated",
          operator: "gte",
          value: filterFromDate.toUtc()));
      filterItems.add(new OdataFilterItem(
          field: "DateCreated", operator: "lte", value: filterToDate.toUtc()));
    }

//    String keywordNoSign = removeVietnameseMark(keyword?.toLowerCase() ?? "");
    if (keyword != null && keyword != "") {
      filterItems.add(OdataFilter(logic: "or", filters: <OdataFilterItem>[
        OdataFilterItem(field: "Name", operator: "contains", value: keyword),
        OdataFilterItem(
            field: "POSReference", operator: "contains", value: keyword),
        OdataFilterItem(
            field: "PartnerName", operator: "contains", value: keyword),
        OdataFilterItem(
            field: "UserName", operator: "contains", value: keyword),
        OdataFilterItem(
            field: "SessionName", operator: "contains", value: keyword),
      ]));
    }

    if (filterItems.length > 0) {
      return new OdataFilter(logic: "and", filters: filterItems);
    } else {
      return null;
    }
  }

//  OdataSortItem sort = new OdataSortItem(field: "Name", dir: "ASC");
  List<OdataSortItem> sorts = new List<OdataSortItem>();
  PosOrderSort posOrderSort = new PosOrderSort(1, "", "desc", "DateOrder");

  void selectSoftCommand(String orderBy) {
    if (posOrderSort.orderBy != orderBy) {
      posOrderSort.orderBy = orderBy;
      posOrderSort.value = "desc";
    } else {
      posOrderSort.value = posOrderSort.value == "desc" ? "asc" : "desc";
    }
    notifyListeners();
    applyFilter();
  }

  Future<List<PosOrder>> loadPosOrders() async {
    sorts = [
      (new OdataSortItem(
          field: "${posOrderSort.orderBy}", dir: "${posOrderSort.value}"))
    ];

    setState(true, message: "Đang tải..");
    // Gọi request
    try {
      var result = await _tposApi.getPosOrders(
          page: take,
          filter: filter,
          sorts: sorts,
          pageSize: take,
          take: take,
          skip: skip);

      if (result != null) {
        posOrders = result.data;
        max = result.total ?? 0;
      }
    } catch (e, s) {
      logger.error("loadPosOrders", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
    return posOrders;
  }

  Future<void> applyFilter() async {
    skip = 0;
    _currentPage = 0;
    posOrders = [];
    loadPosOrders();
  }

  Future handleItemCreated(int index) async {
    var itemPosition = index + 1;
    var requestMoreData = itemPosition % take == 0 && itemPosition != 0;
    var pageToRequest = itemPosition ~/ take;

    if (requestMoreData && pageToRequest > _currentPage) {
      print('handleItemCreated | pageToRequest: $pageToRequest');
      _currentPage = pageToRequest;
      _showLoadingIndicator();
      if (skip + take < max) {
        var newFetchedItems = await loadMorePosOrders();
        posOrders.addAll(newFetchedItems);
      }
      _removeLoadingIndicator();
    }
  }

  void _showLoadingIndicator() {
    posOrders.add(temp);
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    posOrders.remove(temp);
    notifyListeners();
  }

  Future<List<PosOrder>> loadMorePosOrders() async {
    var result;
    skip += take;
    try {
      result = await _tposApi.getPosOrders(
          page: take,
          filter: filter,
          sorts: sorts,
          pageSize: take,
          take: take,
          skip: skip);

      if (result != null) {
        max = result.total ?? 0;
      }
      setState(false);
    } catch (e, s) {
      logger.error("loadMorePosOrders", e, s);
      _dialog.showError(error: e);
    }
    return result.data;
  }

  void removePosOrder(int index) {
    posOrders.removeAt(index);
    notifyListeners();
  }

  Future<bool> deleteInvoice(int id) async {
    try {
      var result = await _tposApi.deletePosOrder(id);
      if (result.result) {
        _dialog.showNotify(message: "Đã xóa đơn hàng Pos", title: "Thông báo");
        return true;
      } else {
        _dialog.showError(
          title: "Lỗi",
          content: "${result.message}",
        );
        return false;
      }
    } catch (e, s) {
      logger.error("deleteInvoice", e, s);
      _dialog.showError(title: "Lỗi", content: "$e");
      return false;
    }
  }
}

var temp = new PosOrder(name: "temp");
