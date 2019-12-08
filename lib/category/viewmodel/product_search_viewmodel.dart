import 'package:rxdart/subjects.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

class ProductSearchViewModel extends ViewModel {
  ISettingService _setting;
  ITposApiService _tposApi;
  DialogService _dialog;

  ProductSearchViewModel(
      {ISettingService settingService,
      ITposApiService tposApiService,
      DialogService dialog,
      LogService log})
      : super(logService: log) {
    _setting = settingService ?? locator<ISettingService>();
    _tposApi = tposApiService ?? locator<ITposApiService>();
    _dialog = dialog ?? locator<DialogService>();

    /// Listen keyword change
    _keywordSubject
        .debounceTime((Duration(milliseconds: 400)))
        .listen((keyword) {
      if (_keyword != keyword) _onSearching(keyword);
    });
  }

  void init({ProductPrice priceList}) {
    _priceList = priceList;
    onStateAdd(false);
  }

  String _keyword;
  List<Product> _products;
  Map<String, dynamic> _inventoryMap;
  Map<String, dynamic> _priceListMap;
  var _keywordSubject = new BehaviorSubject<String>();
  ProductPrice _priceList;
  bool _isListMode = true;

  List<Product> get products => _products;
  int get productCount => (_products?.length ?? 0);
  Sink<String> get keywordSink => _keywordSubject.sink;

  String get keyword => _keyword;
  String get priceListName => _priceList?.name ?? "Giá cố định";
  bool get isListMode => _isListMode;

  set isListMode(bool value) {
    _isListMode = value;
    notifyListeners();
  }

  Future _onSearching(String keyword) async {
    _keyword = keyword;
    onStateAdd(true);
    String keywordNoSign = removeVietnameseMark(keyword ?? "").toLowerCase();
    try {
      var result = await _tposApi.productSearch(keywordNoSign, top: 100);
      _products = result.result;
      // Map to inventory
      _products?.forEach((f) {
        if (_inventoryMap != null) {
          f.inventory = (_inventoryMap[f.id.toString()] != null
              ? _inventoryMap[f.id.toString()]["QtyAvailable"]?.toDouble()
              : 0);
          f.focastInventory = (_inventoryMap[f.id.toString()] != null
              ? _inventoryMap[f.id.toString()]["VirtualAvailable"]?.toDouble()
              : 0);
        }

        if (_priceListMap != null) {
          f.price = _priceListMap["${f.id}_${f.uOMId}"] ?? f.price;
        }
      });
      notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showError(content: e.toString());
    }
    onStateAdd(false);
  }

  void refreshPriceList() async {
    if (_priceList == null) return;
    try {
      _priceListMap = await _tposApi.getPriceListItems(_priceList?.id);
    } catch (e, s) {
      logger.error("refresh pricelist", e, s);
      _dialog.showNotify(message: "Không thể lấy bảng giá");
    }
  }

  Future<void> refreshInventory() async {
    try {
      _inventoryMap = await _tposApi.getProductInventory();
    } catch (e, s) {
      logger.error("refresh inventory", e, s);
      _dialog.showNotify(message: "Không thể lấy thông tin tồn kho");
    }
  }

  Future<void> initData() async {
    await this.refreshPriceList();
    if (_inventoryMap == null) {
      await this.refreshInventory();
    }
  }
}
