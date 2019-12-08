import 'dart:async';
import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_core/helper/app_filter_helper.dart';
import 'package:tpos_mobile/app_core/template_models/app_filter_date_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/services/data_services/data_service.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_status_type.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/odata_filter.dart';

import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

import 'dart:io';

class SaleOnlineOrderListViewModel extends ViewModel {
  static const EVENT_GOBACK = "event.goBack";
  ITposApiService _tposApi;
  PrintService _print;
  DialogService _dialog;
  DataService _dataService;
  ISettingService _setting;
  SaleOnlineOrderListFilterViewModel _filterViewModel =
      new SaleOnlineOrderListFilterViewModel();

  StreamSubscription _dataServiceSubscription;
  SaleOnlineOrderListViewModel({
    ISettingService settingService,
    ITposApiService tposApi,
    PrintService print,
    DialogService dialog,
    DataService dataService,
    LogService logService,
    ISettingService setting,
  }) : super(logService: logService) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _print = print ?? locator<PrintService>();
    _dialog = dialog ?? locator<DialogService>();
    _dataService = dataService ?? locator<DataService>();
    _setting = settingService ?? locator<ISettingService>();

    // Load caaus hình thời gian
    _filterDateRange = getFilterDateTemplates().firstWhere(
        (f) => f.name == _setting.saleOnlineOrderListFilterDate,
        orElse: () => getTodayDateFilter());
    _filterFromDate = _filterDateRange.fromDate;
    _filterToDate = _filterDateRange.toDate;

    _keywordController
        .debounceTime(new Duration(milliseconds: 300))
        .listen((key) {
      onSearchingOrderHandled(key);
    });

    // Listen order insert, edit or deleted

    _dataServiceSubscription = _dataService.dataSubject
        .where((f) => f.value is SaleOnlineOrder || f.value is FastSaleOrder)
        .listen((order) {
      if (order.value is SaleOnlineOrder) {
        var updateOrder = order.value as SaleOnlineOrder;
        var existsItem = _orders?.firstWhere((f) => f.id == updateOrder.id,
            orElse: () => null);

        existsItem.telephone = updateOrder.telephone;
        existsItem.address = updateOrder.address;
        existsItem.cityName = updateOrder.cityName;
        existsItem.cityCode = updateOrder.cityCode;
        existsItem.districtName = updateOrder.districtName;
        existsItem.districtCode = updateOrder.districtCode;
        updateOrder.statusText = updateOrder.statusText;
        updateOrder.status = updateOrder.status;
        updateOrder.totalQuantity = updateOrder.totalQuantity;
        updateOrder.totalAmount = updateOrder.totalAmount;
        notifyListeners();
      } else if (order.value is FastSaleOrder) {
        var updateFastSaleOrder = order.value as FastSaleOrder;
        updateFastSaleOrder.saleOnlineIds?.forEach((orderId) {
          var existsItem =
              _orders?.firstWhere((f) => f.id == orderId, orElse: () => null);
          _refreshOrder(existsItem);
        });
      }
    });
  }

  /*BỘ LỌC VÀ ĐIỀU KIỆN LỌC*/
  bool _isFilterByDate = true;
  bool _isFilterByLiveCampaign = false;
  bool _isFilterByCrmTeam = false;
  bool _isFilterByStatus = false;
  bool _isFilterByPartner = false;
  bool _isFilterByPostId = false;

  LiveCampaign _filterLiveCampaign;
  CRMTeam _filterCrmTeam;
  DateTime _filterFromDate;
  DateTime _filterToDate;
  Partner _filterPartner;
  AppFilterDateModel _filterDateRange;
  List<SaleOnlineStatusType> _filterStatusList;
  SaleOnlineStatusType _filterStatus;

  String _postId;

  bool get isFilterByDate => _isFilterByDate;
  bool get isFilterByLiveCampaign => _isFilterByLiveCampaign;
  bool get isFilterByCrmTeam => _isFilterByCrmTeam;
  bool get isFilterByStatus => _isFilterByStatus;
  bool get isFilterByPartner => _isFilterByPartner;
  bool get isFilterByPostId => _isFilterByPostId;

  DateTime get filterFromDate => _filterFromDate;
  DateTime get filterToDate => _filterToDate;
  AppFilterDateModel get filterDateRange => _filterDateRange;
  List<SaleOnlineStatusType> get filterStatusList => _filterStatusList;
  SaleOnlineStatusType get filterStatus => _filterStatus;
  LiveCampaign get filterLiveCampaign => _filterLiveCampaign;
  CRMTeam get filterCrmTeam => _filterCrmTeam;
  Partner get filterPartner => _filterPartner;
  String get postId => _postId;

  int get filterCount {
    int value = 0;
    if (_isFilterByDate) value += 1;
    if (_isFilterByLiveCampaign) value += 1;
    if (_isFilterByCrmTeam) value += 1;
    if (_isFilterByStatus) value += 1;
    if (_isFilterByPartner) value += 1;
    if (_isFilterByPostId) value += 1;
    return value;
  }

  set isFilterByDate(bool value) {
    _isFilterByDate = value;
    notifyListeners();
  }

  set isFilterByStatus(bool value) {
    _isFilterByStatus = value;
    notifyListeners();
  }

  set isFilterByLiveCampaign(bool value) {
    _isFilterByLiveCampaign = value;
    notifyListeners();
  }

  set isFilterByCrmTeam(bool value) {
    _isFilterByCrmTeam = value;
    notifyListeners();
  }

  set isFilterByPartner(bool value) {
    _isFilterByPartner = value;
    notifyListeners();
  }

  set filterCrmTeam(CRMTeam value) {
    _filterCrmTeam = value;
    notifyListeners();
  }

  set filterLiveCampaign(LiveCampaign value) {
    _filterLiveCampaign = value;
    notifyListeners();
  }

  set filterPartner(Partner value) {
    _filterPartner = value;
    notifyListeners();
  }

  set filterDateRange(AppFilterDateModel value) {
    _filterDateRange = value;
    notifyListeners();
  }

  set filterFromDate(DateTime value) {
    _filterFromDate = value;
    notifyListeners();
  }

  set filterToDate(DateTime value) {
    _filterToDate = value;
    notifyListeners();
  }

  set isFilterByPostId(bool value) {
    _isFilterByPostId = value;
    notifyListeners();
  }

  set filterPostId(String value) {
    _postId = value;
  }

  Future<void> loadFilterStatusList() async {
    try {
      _filterStatusList = await _tposApi.getSaleOnlineOrderStatus();
      notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(error: e);
    }
  }

  OdataFilter get filter {
    List<FilterBase> filterItems = new List<FilterBase>();

    // Theo trạng thái
    if (_isFilterByStatus) {
      var selectedStatus =
          _filterStatusList?.where((f) => f.selected == true)?.toList();
      if (selectedStatus != null && selectedStatus.length > 0) {
        filterItems.add(
          OdataFilter(
            logic: "or",
            filters: selectedStatus
                .map(
                  (f) => OdataFilterItem(
                      operator: "eq", field: "StatusText", value: f.text),
                )
                .toList(),
          ),
        );
      }
    }

    // Theo khách hàng
    if (_isFilterByPartner && _filterPartner != null) {
      filterItems.add(
        new OdataFilterItem(
            field: "PartnerId", operator: "eq", value: _filterPartner?.id),
      );
    }

    // Theo ngày
    if (_isFilterByDate && _filterFromDate != null && _filterToDate != null) {
      filterItems.add(new OdataFilterItem(
          field: "DateCreated",
          operator: "ge",
          convertDatetime: _convertDatetimeToString,
          value: filterFromDate.toUtc()));
      filterItems.add(new OdataFilterItem(
          field: "DateCreated",
          operator: "le",
          convertDatetime: _convertDatetimeToString,
          value: filterToDate.toUtc()));
    }

    // Theo bài đăng
    if (_isFilterByPostId && _postId != null) {
      filterItems.add(
        new OdataFilterItem(
            field: "Facebook_PostId", operator: "eq", value: _postId),
      );
    }

    // Theo kênh bán
    if (_isFilterByCrmTeam && _filterCrmTeam != null) {
      filterItems.add(new OdataFilterItem(
          field: "CRMTeamId", operator: "eq", value: _filterCrmTeam.id));
    }

    // Theo chiến dịch
    if (_isFilterByLiveCampaign && _filterLiveCampaign != null) {
      filterItems.add(new OdataFilterItem(
          field: "LiveCampaignId",
          operator: "eq",
          value: _filterLiveCampaign.id,
          dataType: int));
    }

    if (filterItems.length > 0) {
      return new OdataFilter(logic: "and", filters: filterItems);
    } else {
      return null;
    }
  }

  String _convertDatetimeToString(DateTime input) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss'%2B00:00'").format(input);
  }

  void resetFilter() {
    _isFilterByDate = false;
    _isFilterByLiveCampaign = false;
    _isFilterByCrmTeam = false;
    _isFilterByStatus = false;
    _isFilterByPartner = false;
    _isFilterByPostId = false;
    notifyListeners();
  }

  /*// HẾT BỘ LỌC*/

  SaleOnlineOrderListFilterViewModel get filterViewModel => _filterViewModel;

  /* Check all*/

  bool isSelectEnable = false;

  bool get isCheckAll {
    if (_orders != null && _orders.length > 0) {
      return !(_orders.any((f) => f.checked == false));
    } else
      return false;
  }

  int get selectedItemCount {
    return _orders != null ? _orders.where((f) => f.checked).length : 0;
  }

  int get itemCount => _orders?.length ?? 0;

  List<SaleOnlineOrder> get selectedOrders {
    if (_orders == null) return null;
    if (_orders.length == 0) return null;

    return _orders.where((f) => f.checked == true).toList();
  }

// order
  List<SaleOnlineOrder> _orders = new List<SaleOnlineOrder>();
  List<SaleOnlineOrder> get orders => _orders;
  BehaviorSubject<List<SaleOnlineOrder>> _ordersController =
      new BehaviorSubject();
  Observable<List<SaleOnlineOrder>> get ordersObservable => _ordersController;
  void onOrderAdd(List<SaleOnlineOrder> order) {
    _orders = order;
    if (_ordersController.isClosed == false) {
      _ordersController.add(_orders);
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

  List<SaleOnlineOrder> tempOrders = new List<SaleOnlineOrder>();

  Future<void> _filter() async {
    try {
      var result = await _tposApi
          .getSaleOnlineOrdersFilter(
        filter: this.filter,
        sort: this._filterViewModel.sort,
      )
          .catchError((err) {
        throw new Exception(err);
      });
      tempOrders = result;
      amountTotal = 0.0;
      if (tempOrders != null) {
        tempOrders.forEach(
          (f) {
            amountTotal = amountTotal + f.totalAmount;
          },
        );
      }
      onOrderAdd(tempOrders);
      onPropertyChanged("tempOrders");
    } on SocketException catch (e, s) {
      logger.error("", e, s);
      if (_ordersController.isClosed == false) _ordersController.addError(e, s);
    } catch (ex, st) {
      logger.error("", ex, st);
      // onDialogMessageAdd(new DialogMessage.error("Lọc", ex.toString()));
      if (_ordersController.isClosed == false)
        _ordersController.addError(ex, st);
    }
  }

  bool isCancelRequest = false;
  int get currentIndex => tempOrders?.length ?? 0;
  List<SaleOnlineOrder> lastResults;
  bool isFetchingOrder = false;

  Future<void> _filterBegin() async {
    onStateAdd(true);
    isFetchingOrder = true;
    await _filterWithPaging();
    onStateAdd(false);

    while (lastResults != null && lastResults.length > 0) {
      if (isCancelRequest) {
        break;
      }
      await _filterWithPaging();
    }
    isFetchingOrder = false;
    onPropertyChanged("");
  }

  Future<void> _filterWithPaging() async {
    try {
      lastResults = await _tposApi.getSaleOnlineOrdersFilter(
        skip: currentIndex,
        take: 2000,
        filter: this.filter,
        sort: this._filterViewModel.sort,
      );

      tempOrders?.addAll(lastResults);
      amountTotal = 0.0;
      if (tempOrders != null) {
        tempOrders?.forEach((f) {
          amountTotal = amountTotal + (f.totalAmount ?? 0);
        });
      }
      onOrderAdd(tempOrders);
      onPropertyChanged("tempOrders");
    } catch (e, s) {
      logger.error("fukterWithPagingError", e, s);
      _dialog.showError(error: e, isRetry: true).then((result) {
        if (result.type == DialogResultType.RETRY)
          this.initCommand();
        else if (result.type == DialogResultType.GOBACK)
          onEventAdd(EVENT_GOBACK, null);
      });
      lastResults = null;
    }
  }

  Future<void> searchOrderCommand(String keyword) async {
    onKeywordAdd(keyword);
  }

  Future<void> onSearchingOrderHandled(String keyword) async {
    if (keyword == null && keyword == "") {
      onOrderAdd(tempOrders);
      return;
    }
    try {
      String key = (removeVietnameseMark(keyword));
      var orders = tempOrders
          .where((f) => f.name != null
              ? removeVietnameseMark(f.name.toLowerCase())
                      .contains(key.toLowerCase()) ||
                  f.code.toString().toLowerCase().contains(key.toLowerCase()) ||
                  f.telephone
                      .toString()
                      .toLowerCase()
                      .contains(key.toLowerCase())
              : false)
          .toList();

      this.onOrderAdd(orders);
    } catch (e, s) {
      onDialogMessageAdd(new OldDialogMessage.error("", "", error: e));
      logger.error("", e, s);
    }
  }

  ViewSaleOnlineOrder order = new ViewSaleOnlineOrder();

  Product _selectedProduct;
  double amountTotal = 0.0;

  Product get selectedProduct => _selectedProduct;

  set selectedProduct(Product value) {
    _selectedProduct = value;
    notifyListeners();
  }

  Queue<SaleOnlineOrder> _printOrderQuene = new Queue<SaleOnlineOrder>();
  bool _isPrintBusy = false;

  Future<void> printAllSelect() async {
    var select = _orders?.where((f) => f.checked == true)?.toList();
    if (select != null) {
      select.forEach((f) {
        printSaleOnlineTag(f);
      });
    }
  }

  /// In phiếu
  Future<void> printSaleOnlineTag(SaleOnlineOrder order) async {
    _printOrderQuene.addFirst(order);

    if (_isPrintBusy) return;

    onIsBusyAdd(true);

    while (_printOrderQuene.length > 0) {
      _isPrintBusy = true;
      await Future.delayed(Duration(milliseconds: 100));

      try {
        var printOrder = _printOrderQuene.last;
        await _print.printSaleOnlineTag(order: printOrder);
        _printOrderQuene.remove(printOrder);

        printOrder.checked = false;
        onPropertyChanged("");
      } catch (e, s) {
        logger.error("", e, s);
        _dialog.showError(error: e);
        _printOrderQuene.clear();
        break;
      }
    }
    onIsBusyAdd(false);
    _isPrintBusy = false;
  }

  void init({Partner filterPartner, String postId}) {
    if (filterPartner != null) {
      this._filterPartner = filterPartner;
      this._isFilterByPartner = true;
    }

    this._postId = postId;
    this._isFilterByPostId = postId != null;

    if (filterPartner != null || postId != null) {
      this._isFilterByDate = false;
    }
  }

  // initCommand
  Future<void> initCommand() async {
    // Tải trạng thái đơn hàng
    onIsBusyAdd(true);
    await this._filterViewModel.initCommand();

    try {
      await refreshOrdersCommand();
    } catch (e) {
      onDialogMessageAdd(
          new OldDialogMessage.warning("Đã xảy ra lỗi!\n" + e.toString()));
    }

    //Lưu cấu hình lọc
    _setting.saleOnlineOrderListFilterDate = _filterDateRange?.name;
    onIsBusyAdd(false);
  }

  /// amplyFilterCommand
  Future<void> amplyFilterCommand() async {
    //save setting

    onIsBusyAdd(true);
    tempOrders.clear();
    await _filterBegin();
    onIsBusyAdd(false);
  }

  /// RefreshFilterCommand
  Future<void> refreshOrdersCommand() async {
    if (isFetchingOrder) {
      onDialogMessageAdd(OldDialogMessage.flashMessage(
          "Vui lòng đợi cho quá trình lấy dữ liệu chạy xong"));
      return;
    }
    lastResults = null;
    tempOrders?.clear();
    await _filterBegin();
  }

  //
  Future<void> enableSelectedCommand(SaleOnlineOrder selectedOrder) async {
    selectedOrder.checked = true;
    isSelectEnable = true;
    onPropertyChanged("");
  }

  // Chọn/Bỏ chọn item
  Future<void> selectedItemChangedCommand(SaleOnlineOrder selectedOrder) async {
    selectedOrder.checked = !selectedOrder.checked;
    onPropertyChanged("");
  }

  // Lệnh đóng panel lựa chọn
  Future<void> closeSelectPanelCommand() async {
    this.isSelectEnable = false;
    onPropertyChanged("");
  }

  Future unSelectAllCommand() async {
    orders?.forEach((f) {
      f.checked = false;
    });
    _ordersController.add(_orders);
    onPropertyChanged("");
  }

  Future<void> selectAllItemCommand() async {
    if (_orders.any((f) => f.checked == false)) {
      _orders?.forEach((f) {
        f.checked = true;
      });
    } else {
      _orders?.forEach((f) {
        f.checked = false;
      });
    }

    onPropertyChanged("");
  }

  List<String> get selectedIds =>
      _orders?.where((f) => f.checked == true)?.map((ff) => ff.id)?.toList();

  Future<FastSaleOrderAddEditData> prepareFastSaleOrder() async {
    onStateAdd(true, message: "Đang thao tác . Vui lòng chờ");

    var selectedIds =
        _orders.where((f) => f.checked == true).map((ff) => ff.id).toList();
    if (selectedIds == null || selectedIds.length == 0) {
      onDialogMessageAdd(new OldDialogMessage.warning(
          "Vui lòng lựa chọn một hoặc nhiều đơn hàng để tạo hóa đơn",
          title: "Chưa chọn hóa đơn!"));
      onStateAdd(false, message: "");
      return null;
    }

    var firstSelect = selectedOrders.first;
    // khách facebook
    if (selectedOrders
        .any((f) => f.facebookAsuid != firstSelect.facebookAsuid)) {
      onDialogMessageAdd(
          new OldDialogMessage.warning("Các đơn hàng phải cùng facebook"));
      onStateAdd(false, message: "");
      return null;
    }

    try {
      var fastSaleOrder = await _tposApi.prepareFastSaleOrder(selectedIds);
      onStateAdd(false, message: "");
      return fastSaleOrder;
    } catch (e, s) {
      logger.error("prepareFastSaleOrder", e, s);
      onDialogMessageAdd(
          new OldDialogMessage.error("Error", e.toString(), error: e));
    }

    onStateAdd(false, message: "");
    return null;
  }

  Future<void> updateEditOrderCommand(
      SaleOnlineOrder oldOrder, SaleOnlineOrder newOrder) async {
    _updateEditOrder(oldOrder, newOrder);
    if (_ordersController != null) {
      _ordersController.add(_orders);
    }
  }

  Future _refreshOrder(SaleOnlineOrder order) async {
    try {
      var newOrder = await _tposApi.getOrderById(order.id);
      if (newOrder != null) {
        _updateEditOrder(order, newOrder);
      }
      notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
    }
  }

  /// Cập nhật thông tin đơn hàng
  void _updateEditOrder(SaleOnlineOrder oldOrder, SaleOnlineOrder newOrder) {
    assert(newOrder != null);
    oldOrder.address = newOrder.address;
    oldOrder.telephone = newOrder.telephone;
    oldOrder.status = newOrder.status;
    oldOrder.statusText = newOrder.statusText;
    oldOrder.totalQuantity = newOrder.totalQuantity;
    oldOrder.totalAmount = newOrder.totalAmount;
    notifyListeners();
  }

  /// Cập nhật sau khi tạo hóa đơn
  Future<void> updateAfterCreateInvoiceCommand() async {
    if (selectedOrders == null || selectedOrders.length == 0) {
      return;
    }
    try {
      selectedOrders.forEach((oldOrder) async {
        var newOrder = await _tposApi.getOrderById(oldOrder.id);
        if (newOrder != null) {
          _updateEditOrder(oldOrder, newOrder);
        }
      });

      if (_ordersController != null) {
        _ordersController.add(_orders);
      }
      notifyListeners();
    } catch (e, s) {
      logger.error("update after create invoice command", e, s);
    }
  }

  Future<bool> deleteOrder(SaleOnlineOrder order) async {
    try {
      await _tposApi.deleteSaleOnlineOrder(order.id);
      _dialog.showNotify(message: "Đã xóa đơn hàng ${order.code}");
      //remove from list
      _orders.remove(order);
      _ordersController?.add(_orders);
      return true;
    } catch (e, s) {
      logger.error("delete sale online order", e, s);
      onDialogMessageAdd(OldDialogMessage.error("Xóa thất bại", "", error: e));
      return false;
    }
  }

  Future<List<SaleOnlineOrderDetail>> getProductById(
      SaleOnlineOrder order) async {
    var result = await _tposApi.getOrderById(order.id);
    return result?.details;
  }

  void changeCheckItem(SaleOnlineOrder item) {
    item.checked = !item.checked;
    notifyListeners();
  }

  void _saveFilterSetting() {}

  Future changeStatus(SaleOnlineOrder item, String status) async {
    onStateAdd(true);
    try {
      await _tposApi.saveChangeStatus(<String>[item.id], status);
      item.statusText = status;
      notifyListeners();
      _dialog.showNotify(message: "Đã đổi trạng thái đơn hàng");
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(error: e);
    }
    onStateAdd(false);
  }

  @override
  void dispose() {
    _dataServiceSubscription?.cancel();
    _ordersController.close();
    _keywordController.close();
    _filterViewModel.dispose();
    isCancelRequest = true;
    super.dispose();
  }
}

class SaleOnlineOrderListFilterViewModel extends ViewModel {
  ITposApiService _tposApi;
  ISettingService _setting;
  String postId;
  int partnerId;
  SaleOnlineOrderListFilterViewModel(
      {ITposApiService tposApi,
      ISettingService setting,
      String postId,
      int partnerId}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _setting = tposApi ?? locator<ISettingService>();
    this.postId = postId;
    this.partnerId = partnerId;
  }

  OdataSortItem sort;
  List<OdataSortItem> sorts = new List<OdataSortItem>();

  Partner selectedPartner;
  LiveCampaign selectedLiveCampaign;
  String filterLiveVideoId;

  void _initDefaultSort() {
    this.sorts.add(new OdataSortItem(field: "DateCreated", dir: "desc"));
    this.sorts.add(new OdataSortItem(field: "DateCreated", dir: "asc"));
    this.sorts.add(new OdataSortItem(field: "SessionIndex", dir: "desc"));
    this.sorts.add(new OdataSortItem(field: "SessionIndex", dir: "asc"));
    this.sort = this.sorts.first;
  }

  Future<void> initCommand() async {
    _initDefaultSort();

    onPropertyChanged("");
  }

  Future<void> setSortCommand(String value) async {
    sort = sorts.firstWhere((f) => "${f.field}_${f.dir}" == value,
        orElse: () => null);
  }

  Future<void> saveSetting() async {
    try {
//      _setting.saleOnlineOrderListFilterByStatusIndex =
//          filterOrderStatus.indexOf(selectedSaleOnlineStatusType);
//      _setting.saleOnlineOrderListFilterByTimeIndex =
//          filterByDates.indexOf(selectedFilterByDate);
    } catch (e) {}
  }
}
