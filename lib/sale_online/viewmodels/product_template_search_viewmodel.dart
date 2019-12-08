/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'dart:async';

import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ProductTemplate.dart';
import 'package:tpos_mobile/src/tpos_apis/models/base_list_order_by_type.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/odata_filter.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class ProductTemplateSearchViewModel extends ViewModel {
  //Permission
  final String permissonInsertName = PERMISSION_CATALOG_PRODUCT_TEMPLATE_INSERT;
  final String permissonUpdateName = PERMISSION_CATALOG_PRODUCT_TEMPLATE_UPDATE;
  final String permissionDeleteName =
      PERMISSION_CATALOG_PRODUCT_TEMPLATE_DELETE;

  ISettingService _settingService;
  ITposApiService _tposApi;
  IAppService _app;
  DialogService _dialog;
  ProductTemplateSearchViewModel(
      {ISettingService settingService,
      ITposApiService tposApi,
      DialogService dialog,
      LogService logService})
      : super(logService: logService) {
    _settingService = settingService ?? locator<ISettingService>();
    _tposApi = tposApi ?? locator<ITposApiService>();
    _app = locator<IAppService>();
    _dialog = dialog ?? locator<DialogService>();

    // Listen keyword changing
    _keywordController
        .debounceTime(new Duration(milliseconds: 500))
        .listen((newKeyword) {
      loadProduct(isBarcode: isBarcode);
    });

    try {
      _selectedOrderBy =
          BaseListOrderBy.values[_settingService.productSearchOrderByIndex];
    } catch (e) {
      _selectedOrderBy = BaseListOrderBy.NAME_ASC;
    }
  }

  bool _isLoaddingMore = false;
  bool get isLoadingMore => _isLoaddingMore;

  bool get canAdd => _app.getWebPermission(permissonInsertName);
  bool get canUpdate => _app.getWebPermission(permissonUpdateName);
  bool get canDelete => _app.getWebPermission(permissionDeleteName);

  /* FILTER */
  ProductPrice _selectedPriceList;
  ProductCategory _selectedProductCategory;
  BaseListOrderBy _selectedOrderBy;
  BaseListOrderBy get selectedOrderBy => _selectedOrderBy;
  ProductPrice get selectedPriceList => _selectedPriceList;
  ProductCategory get selectedProductCategory => _selectedProductCategory;
  Map<BaseListOrderBy, String> _orderByList = {
    BaseListOrderBy.NAME_ASC: "Tên (A-Z)",
    BaseListOrderBy.NAME_DESC: "Tên (Z-A)",
    BaseListOrderBy.PRICE_ASC: "Giá bán tăng dần",
    BaseListOrderBy.PRICE_DESC: "Giá bán giảm dần",
  };

  Map<BaseListOrderBy, String> get orderByList => _orderByList;

  /* FILTER */
  // Keyword controll
  String _keyword = "";
  String get keyword => _keyword;
  set keyword(String value) {
    _keyword = value;
    _keywordController.add(_keyword);
  }

  bool isBarcode = false;
  int _lastSkip = 0;
  int _maxResult = 0;
  List<ProductTemplate> products;

  bool get canLoadMore {
    return (products?.length ?? 0) < (_maxResult ?? 0);
  }

  BehaviorSubject<String> _keywordController = new BehaviorSubject();
  void _onKeywordAdd(String value) {
    _keyword = value;
    if (_keywordController.isClosed == false) {
      _keywordController.add(value);
    }
  }

  set selectedProductCategory(ProductCategory value) {
    _selectedProductCategory = value;
    notifyListeners();
  }

  set selectedPriceList(ProductPrice value) {
    _selectedPriceList = value;
    notifyListeners();
  }

  Future<void> initCommand() async {
    onIsBusyAdd(true);

    onIsBusyAdd(false);
  }

  Future<void> keywordChangedCommand(String keyword) async {
    _onKeywordAdd(keyword);
  }

  List<FilterBase> filterItems = new List<FilterBase>();

  Future loadProduct({bool isBarcode = false, bool isLoadMore = false}) async {
    if (!isLoadMore)
      onIsBusyAdd(true);
    else {
      _isLoaddingMore = true;
      notifyListeners();
    }

    OdataSortItem sort = new OdataSortItem(field: "Name", dir: "ASC");
    if (selectedOrderBy != null) {
      if (_selectedOrderBy == BaseListOrderBy.NAME_ASC) {
        sort.field = "Name";
        sort.dir = "asc";
      } else if (_selectedOrderBy == BaseListOrderBy.NAME_DESC) {
        sort.field = "Name";
        sort.dir = "desc";
      } else if (_selectedOrderBy == BaseListOrderBy.PRICE_ASC) {
        sort.field = "ListPrice";
        sort.dir = "asc";
      } else if (_selectedOrderBy == BaseListOrderBy.PRICE_DESC) {
        sort.field = "ListPrice";
        sort.dir = "desc";
      }
    }
    // Bộ lọc

    String keywordNoSign = removeVietnameseMark(keyword?.toLowerCase() ?? "");
    OdataFilter filter = new OdataFilter(logic: "and", filters: <FilterBase>[
      // Tìm kiếm theo tên, hoặc mã
      if (keywordNoSign != null && keywordNoSign != "")
        OdataFilter(logic: "or", filters: <OdataFilterItem>[
          OdataFilterItem(
              field: "Name", operator: "contains", value: keywordNoSign),
          OdataFilterItem(
              field: "NameNoSign", operator: "contains", value: keywordNoSign),
          OdataFilterItem(
              field: "DefaultCode", operator: "contains", value: keywordNoSign),
        ]),
    ]);

    // Gọi request
    try {
      var result = await _tposApi.getProductTemplate(
          page: 1000,
          filter: filter,
          sorts: [sort],
          pageSize: 1000,
          take: 1000,
          skip: products?.length ?? 0);

      if (result != null) {
        _maxResult = result.total ?? 0;
      }

      if (isLoadMore) {
        products.addAll(result?.data);
        _isLoaddingMore = false;
        notifyListeners();
      } else {
        products = result?.data;
      }
      notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(error: e);
    }
    _isLoaddingMore = false;
    onStateAdd(false);
    notifyListeners();
  }

  Future loadMoreProductCommand() async {
    loadProduct(isBarcode: isBarcode, isLoadMore: true);
  }

  /// selectOrderByCommand
  Future<void> selectOrderByCommand(BaseListOrderBy selectOrderBy) async {
    this._selectedOrderBy = selectOrderBy;
    onPropertyChanged("selectedOrderBy");
    await this.amplyFilterCommand();
  }

  /// Aply Filter COmmand
  /// amplyFilterCommand
  Future<void> amplyFilterCommand() async {
    //save setting
    onIsBusyAdd(true);
    try {
      _settingService.productSearchOrderByIndex = _selectedOrderBy.index;
      await loadProduct(isBarcode: isBarcode);
    } catch (e, s) {
      logger.error("amplyFilterCommand", e, s);
    }
    //await _filter();
    onIsBusyAdd(false);
  }

  bool get isViewAsList {
    return _settingService.isProductSearchViewList;
  }

  Future<void> changeViewTypeCommand(bool isList) async {
    _settingService.isProductSearchViewList = isList;
    onPropertyChanged("");
  }

  Future<void> addNewProductCommand(Product newProduct) async {
    _onKeywordAdd(newProduct.name);
  }

  Future<bool> deleteProductTemplate(int id) async {
    try {
      await _tposApi.deleteProductTemplate(id);
      _dialog.showNotify(message: "Đã xóa sản phẩm");
      return true;
    } catch (e, s) {
      logger.error("deleteProductTemplate fail", e, s);
      _dialog.showError(error: e);
      return false;
    }
  }

  @override
  void dispose() {
    _keywordController.close();
    super.dispose();
  }
}
